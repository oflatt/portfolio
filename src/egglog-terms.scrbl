#lang scribble/manual
@require[scribble-math/dollar]

@(require "slidehelpers.rkt")
@(require (except-in pict table))
@(require scribble/core
          scribble/html-properties
          racket/runtime-path
          (only-in xml cdata))

@(define head-google (head-extra (cdata #f #f "<link rel=\"stylesheet\"
          href=\"https://fonts.googleapis.com/css?family=Nunito+Sa
          ns\">")))

@(define-runtime-path css-path "documents/docstyle.css")
@(define css-object (css-addition css-path))

@(define html5-style (with-html5 manual-doc-style))
@(define title-style
   (struct-copy style html5-style
                [properties (append (style-properties html5-style) (list css-object head-google))]))

@title[#:style  title-style]{ Implementing egglog: Encoding Equality Saturation in Datalog+2extensions }

@section{ What is egglog? }

@link["https://arxiv.org/abs/2304.04332"]{egglog} is a new language we've
been working on that combines datalog and equality saturation.
If you would like to read about what datalog is, check out @link["https://github.com/remysucre/blog/blob/main/posts/datalog-resources.md"]{Remy's guide}.
If you are interested in using egglog, check out my tutorial on egglog @link["https://www.youtube.com/watch?v=N2RDQGRBrSY"]{here}.


In the original paper, we showed how we could extend datalog with several features
and use it to implement equality saturation / egraphs.
However, it is actually possible to implement it efficiently using a more standard
variant of datalog.
In this post, I'll describe what that variant is and how we can desugar
and instrument egglog code to use it as the core backend of egglog.
I've implemented this post as @link["https://github.com/egraphs-good/egglog/pull/158"]{this PR}.



@section{ Datalog+2extensions }

I'm not sure if there's a standard name for the variant
of datalog described in this section.
I'm also not a datalog expert, but I'll try to describe
the variant we need for egglog.
Starting with standard datalog, we need to add two extensions:
existential variables and subsumption.


@subsection{ Existential Variables / Fresh Names }


We need @bold{existential variables} in the head of rules.
This allows us to create new terms based on existing terms in the database.
For example, suppose we have a datalog table @${Add(x, y, z)} where @${x}
and @${y} are numbers and @${z} is a unique name for the sum of @${x} and @${y}.

Then we could have the following datalog rule, which I'll write using pseudo-egglog syntax:
@codeblock|{
(rule
   ((Add x y z))
   ((exists fresh)
    (Add y x fresh)))
}|

Datalog rules are usually written right to left: the matcher ("body") of the rule
on the right and actions ("head") on the left.
In egglog we write it left to right instead:
the matcher comes first and the actions are next.

This rule states that if we have an addition between two numbers @${x}
and @${y} in the database, we can make some new addition with
a fresh name @${\mathit{fresh}} between @${y} and @${x}.
However, it doesn't say that they are equal- we will get to that later in this
blog post.
Also, in practice, the @code{exists} call is aware if we already have
a unique name for the term we are creating, and will return that instead.

@link["https://dl.acm.org/doi/pdf/10.1145/1514894.1514897"]{Here} is a paper that 
describes this variant of datalog and others.

@subsection{ Subsumption }

For efficiency, it's also going to be important to have some sort
of subsumption or aggregation.
In other words, a way to view some data in the database as no longer important
and so does not yield new rule matches.
For example, perhaps we are keeping track of a lower bound
for a particular variable in the database.
If we find two lower bounds for the same variable, we know that
the higher (tighter) bound is always better:

@codeblock|{
(rule
   ((LowerBound x y)
    (LowerBound x z)
    (< y z))
   ((MarkSubsumed (LowerBound x y))))
}|

This rule says that, for a variable @${x} with two lower bounds @${y} and @${z},
if @${y} is less than @${z}, then we can mark the smaller lower bound of @${x} as subsumed.

There are multiple ways to do this, but usually you'll want to prove or assume
that your subsumption rules form a lattice.
In normal datalog + subsumption this allows you to prove that, regardless
of the execution order of the datalog program, it always terminates
are reaches the same fixed point (this is the approach
@link["https://flix.dev/"]{Flix} takes for example).
Otherwise, running the rules in different orders can yield different results.
In egglog, we don't enforce this property,
so users should ensure their 
subsumption rules form a lattice.
We have also already given up on termination with our existential extension
from the last section.


@section{ Desugaring egglog }

This section will walk through how we desugar an egglog program
into the datalog+2extensions variant described in the last section.
Here's a simple egglog program that we'll use as an example:

@codeblock|{
(datatype Math
   (Add Math Math)
   (Mul Math Math)
   (Var String)
   (Num i64))

(let expr (Add (Var "x") (Var "x")))

(rule
   ((= lhs (Add ?x ?x)))
   ((union lhs (Mul (Num 2) ?x))))

(run 1)

(check (= expr (Mul (Num 2) (Var "x"))))
}|

This egglog program inserts the term @${(Add (Var "x") (Var "x"))}
into the database.
It declares a rule that matches @${x+x} makes it equal
to @${2x}.
The ability to call @bold{union}, declaring that two things are considered
equal, is the difference between egglog and datalog.
In order to desugar egglog, we will need to deal with the implicit global 
equality relation between terms in the database.
We'll also need to instrument all of the rules so that they match
modulo this equality relation: this is called @bold{e-matching}
and @link["https://arxiv.org/abs/2108.02290"]{this paper} describes how it boils down to database queries.

The first step in desugaring egglog code is to converting
the datatypes above into tables.
It defines one table per datatype variant.
For example, Add variant becomes a table with three columns:
two Math identifiers for the inputs and one Math identifier for the output.
The table encodes `Math` terms, with a unique output identifier per term
in the database.


@subsection{ Encoding the Union-Find }

Every e-graph representation uses a @link["https://en.wikipedia.org/wiki/Disjoint-set_data_structure"]{union-find} data structure to represent
what things are in the same equivalence class.
Each term in the e-graph has a unique id. Finding the leader of a term
in the union-find data structure allows you to find the representative
term of the equivalence class.
To encode equality saturation in datalog, we will literally represent
this data structure as a table, doing path compression 
and unioning two terms using rules.

First, we define a "Leader" table, which stores the union-find:
@codeblock|{
(relation (Leader Math Math))
}|

Next, we need a rule to do path compression.
Our encoding is going to require that it only takes one lookup
in the table to find the leader of a term.
This is less efficient than doing path compression when we do the lookup,
but it makes the encoding simpler.

@codeblock|{
(ruleset union-find)
(rule ((Leader a b)
       (Leader b c))
      ((Leader a c))
      :ruleset union-find)
}|

This rule says that if @${b} is the leader of @${a} and @${c} is the leader of @${b}, then @${c} is the leader of @${a}.
We add the rule to a ruleset "union-find", and we need to make
sure to run it to saturation before other rules.

But wait, this rule is going to cause an inefficient encoding
because we left the old rows in the leader table un-touched.
What we really want to do is mark these old rows as subsumed.

Here's the improved rule:
@codeblock|{
(ruleset union-find)
(rule ((Leader a b)
       (Leader b c)
       ;; need to ensure that these are distinct rows
       (!= a b) 
       (!= b c))
      ((Leader a c)
       (MarkSubsumed (Leader a b)))
      :ruleset union-find)
}|


@subsection{Encoding the Union Operation}

Now, egglog programs are also going to need to be able to
union two terms together.
But how are they going to do this?
In traditional implementations, the union operation in the union-find
data structure looks up two leaders and makes one point to the other.
For consistency, we choose the smaller of the two leaders to be the new leader.
This has the nice effect of always choosing the older terms as representatives.
Here's how commutativity of addition is encoded in egglog:

@codeblock|{
(rule ((Add x y add-id)
       (Leader add-id add-leader))
      ((exists rhs-fresh)
       (Add y x rhs-fresh)
       (Leader (min add-leader rhs-fresh)
               (max add-leader rhs-fresh))))
}|


However this doesn't actually work yet for a subtle reason.
All of the rules in egglog are run at the same time,
so the term add-id might be unioned with two different
terms in the same step.
That means that add-leader might have two different leaders!

To fix this problem, we have a rule that fixes up
the parent relation, which we also add to the union-find ruleset:

@codeblock|{
(rule
   ;; a has leaders b and c
   ((Leader a b)
    (Leader a c)
    (!= b c))
   ((MarkSubsumed (Leader a (min b c)))
    (Leader (max b c) (min b c)))
   :ruleset union-find)
}|

The rule subsumes the smaller of the two leaders,
and then unions the two leaders together.
The rule will fire recursively in conjunction with the
path compression rule to resolve all unions that have happened.

Also, now that we have the parent table, we need to make sure
to initialize the leader of anything we add to the database.
So our initial term:
@codeblock|{
(let expr (Add (Var "x") (Var "x")))
}|
becomes:
@codeblock|{
(exists varx)
(Var "x" varx)
(Leader varx varx)
(exists expr)
(Add varx varx expr)
(Leader expr expr)
}|

@subsection{ Encoding E-Matching }

Now that we have a union-find, we are finally ready to
encode e-matching.
Recall our motivating example rule:
@codeblock|{
(rule
   ((= lhs (Add ?x ?x)))
   ((union lhs (Mul (Num 2) ?x))))
}|

The rule desugars due to the encoding to tables to:
@codeblock|{
(rule
   ((Add ?x ?x lhs-id))
   ((exists num-2)
    (Num 2 num-2)
    (exists rhs-id)
    (Mul num-2 ?x rhs-id)
    (union lhs-id rhs-id)))
}|

This rule has an equality constraint due to
the variable appearing twice, and can be written as:
@codeblock|{
(rule
   ((Add ?x1 ?x2 lhs-id)
    (= ?x1 ?x2))
   ((exists num-2)
    (Num 2 num-2)
    (exists rhs-id)
    (Mul num-2 ?x1 rhs-id)
    (union lhs-id rhs-id)))
}|

After desugaring all of our equality constraints this way,
encoding e-matching is simple.
All we need to do is to compare leaders instead of the terms themselves.
This is why it was important to do path compression before running
these rules.
Here's the encoded rule:
@codeblock|{
(rule
   ((Add ?x1 ?x2 lhs-id)
    (Leader ?x1 ?x1-leader)
    (Leader ?x2 ?x2-leader)
    (= ?x1-leader ?x2-leader))
   ((exists num-2)
    (Num 2 num-2)
    (exists rhs-id)
    (Mul num-2 ?x1-leader rhs-id)
    (union lhs-id rhs-id)))
}|

Now, lets also desugar the actions of the rule,
initializing the leader table and converting the union as above:
@codeblock|{
(rule
   ((Add ?x1 ?x2 lhs-id)
    (Leader ?x1 ?x1-leader)
    (Leader ?x2 ?x2-leader)
    (= ?x1-leader ?x2-leader))
   ((exists num-2)
    (Num 2 num-2)
    (Leader num-2 num-2)
    (exists rhs-id)
    (Mul num-2 ?x1-leader rhs-id)
    (Leader (max lhs-id rhs-id)
            (min lhs-id rhs-id))))
}|

Phew, that was a lot of desugaring!
But now we have a datalog+2extensions program, which makes
the backend of egglog much simpler.
However, we are not done yet.
This query can be made faster by taking advantage
of another property taken from the e-graph literature:
congruence closure.



@subsection{ Congruence Closure }

Congruence closure is the following property:
if @${a} and @${b} are equal, and @${f} is a function,
then @${f(a)} and @${f(b)} are also equal.
Naturally, for multiple arguments, the arguments need to be pairwise equal
between the two functions.
E-graphs usually maintain this property, which is quite nice, and they do
it with a fancy algorithm.

Luckily, we can implement congruence closure in our
datalog+2extensions efficiently with just one rule per table.
For example, here is the congruence rule for the @code{Add} table:

@codeblock|{
(rule
   ((Add a b id)
    (Leader a a-leader)
    (Leader b b-leader))
   ((exists fresh)
    (Add a-leader b-leader fresh)
    (Leader (max id fresh)
            (min id fresh))))
}|

The rule simply makes a new term, updating the
children to the newest representatives.
It also unions this new term with the old one.
Running this rule until fixpoint maintains congruence closure,
since all of the terms in the database will canonicalize to one form.


@subsection{ Faster Queries Leveraging Congruence Closure }


Now that every term (or e-node as egraph people call them)
in the database has a canonical form, we can leverage this to write
more efficient queries.
This is because it suffices to only match on canonical terms, ignoring
the old ones.

For example, here is our encoded query from the last section:
@codeblock|{
(rule
   ((Add ?x1 ?x2 lhs-id)
    (Leader ?x1 ?x1-leader)
    (Leader ?x2 ?x2-leader)
    (= ?x1-leader ?x2-leader))
   ...)
}|

We can instead only match on a canonical term,
constraining @code{?x1} and @code{?x2} to be representatives:
@codeblock|{
(rule
   ((Add ?x1 ?x2 lhs-id)
    (Leader ?x1 ?x1)
    (Leader ?x2 ?x2)
    (= ?x1 ?x2))
    ...)
}|


It might also occur to the reader that the query has gotten much more complicated,
and that is true.
We are working on a more efficient query compiler, which can take advantage
of the functional dependency between the term and the leader
and run this efficiently.


Damn if you got this far you might want another example of
a rule encoding.
Here's an egglog rule for associativity of addition:
@codeblock|{
(rule
   ((= lhs (Add ?x1 (Add ?x2 ?x3))))
   ((= rhs (Add (Add ?x1 ?x2) ?x3))   
    (union lhs rhs)))
}|

First, encoding terms as tables and adding equality constraints explicitly:
@codeblock|{
(rule
   ((Add ?x2 ?x3 inner-id)
    (Add ?x1 child-id lhs-id)
    ;; equality 
    (= inner-id child-id))
   ((exists new-inner)
    (Add ?x1 ?x2 new-inner)

    (exists rhs-id)
    (Add new-inner ?x3 rhs-id)
    (union lhs-id rhs-id)))
}|

Encoding union and e-matching using the Leader table:
@codeblock|{
(rule
   ((Add ?x2 ?x3 inner-id)
    (Add ?x1 child-id lhs-id)
    (Leader inner-id inner-leader)
    (Leader child-id child-leader)
    (= child-leader inner-leader))
   ((exists new-inner)
    (Add ?x1 ?x2 new-inner)
    ;; initialize the leader of new-inner
    (Leader new-inner new-inner)

    (exists rhs-id)
    (Add new-inner ?x3 rhs-id)
    (Leader (max lhs-id rhs-id)
            (min lhs-id rhs-id))))
}|

Finally, the optimization to only match on canonical terms:
@codeblock|{
(rule
   ((Add ?x2 ?x3 inner-id)
    (Add ?x1 child-id lhs-id)
    (Leader ?x2 ?x2)
    (Leader ?x3 ?x3)
    (Leader ?x1 ?x1)
    (Leader child-id child-id)
    (Leader inner-id inner-leader)
    (= child-id inner-leader))
   ((exists new-inner)
    (Add ?x1 ?x2 new-inner)
    ;; initialize the leader of new-inner
    (Leader new-inner new-inner)

    (exists rhs-id)
    (Add new-inner ?x3 rhs-id)
    (Leader (max lhs-id rhs-id)
            (min lhs-id rhs-id))))
}|

And we are all done!
Questions? Join the @link["https://egraphs.zulipchat.com/"]{egglog zulip}.