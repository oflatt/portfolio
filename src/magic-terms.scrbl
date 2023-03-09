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

@title[#:style title-style]{ Minimizing Sets of Rewrite Rules: Sound and Unsound Approaches }

@section{ Rewrite Rules }

Many applications make use of @bold{rewrite rules}: 
directed equalities over terms that can include forall-quantified variables.
For example, a compiler might make use of this rule to
optimize your code:
@${r_1: \forall x, x*0 \rightarrow 0}.

Combining rewrite rules can be a powerful way to 
simplify or optimize terms.
Here's a rule for commutativity of addition: @${r_2: \forall x y, x*y \rightarrow y*x}.
If we use it in sequence with the rule above, we can now
prove that @${0*x =_{r_2} x*0 =_{r_1} 0}.

Rewrite rules are typically applied in a bottom-up way.
We can represent a @italic{state} as a set of grounded terms and equalities between them.
For example, our initial state might be @${\{x*0\}},
our initial program we want to optimize.
We can then apply @${r_1} to this state, and get a new state, @${\{x*0, 0, x*0 = 0\}}.
The bottom-up evaluation also means that rewrite rules must be directed.
For example, it's impossible to apply @${r_1} in the reverse
direction, because the left-hand side of the rule contains @${x}, a variable not bound on the right-hand side.


@;{
For the rest of this post, we will also assume that
we are using the rewrite rules in the presence of @italic{congruence}.
For the one-argument case, congruence is the property that @${\forall f x y, x = y \rightarrow f(x) = f(y)}.
Similarly, in the multi-argument case, all the children of a function must be equal for the function to be equal.
}


@section{ Reducing Sets of Rewrite Rules }


@link["https://github.com/uwplse/ruler"]{Ruler} is a tool that automatically synthesizes a set of rewrite rules for a particular domain.
The first thing it does is enumerate generate thousands or hundreds of thousands of rewrite rules, all of them valid for you domain.
However, many of these rules are redundant- you can get the same effect using other rules.
So it has to reduce this giant set of rewrite rules into somthing small and usable in other applications.


We would then know that the smaller subset of rules @${subsumes} the original set.
Let's define this idea more formally.
I'll write @${R} for a set of rewrite rules, and @${R_n(S)} for applying @${R} to a state @${S} @italic{n} times.
Now, a ruleset @${R'} subsumes another ruleset @${R} if,
for any grounded equality we can prove with @${R},
we can prove the same equality using @${R'}.
More formally,

@centered{@${\forall S, \forall n, (t = u) \in @${R_n(S)} \implies}}
@centered{@${\exists m, (t = u) \in R'_m(S)}}

where @${S} is an initial state and @${(t = u)} is some grounded equality that we can prove with @${R}.


So how are we going to reduce our set of rewrite rules?
@${R'} is a subset of @${R}, so we can try removing one rule @${r \in R} at a time from @${R}.
Now, @${R'} subsumes @${R} if it can subsume the single rule @${r}.
For some intuition why, consider that any equality
is derived from some sequence of rewrite rule applications
starting from some initial term.
Now, if @${R'} subsumes @${r}, it means that under any situation it can do "the same thing" as @${r}.
So if at any point the derivation of an equality uses @${r}, we can replace it with some use of rules in @${R'}.


Now the problem becomes proving that @${R'} subsumes @${r}.
The cool trick that we will use is to actually insert the left-hand side of @${r} into a database, and then apply @${R'} to it to try and derive @${r}.
But @${r} has forall-quantified variables in it, so first we
@italic{skolemize} it, turning it into a ground term on variables.
For example, if we have a rule @${r: \forall x, x*0 \rightarrow 0}, we skolemize the left-hand side, turning it into @${v*0}, for some fresh name @${v}.
Now, for the initial database @${S = \{v*0\}}, if for some @${n} we have that @${(v*0 = 0) \in R'_n(S)},
then we know that @${R'} subsumes @${r}.
Intuitively, this is because we didn't know anything about
the skolemized variable @${v}, so if we found that we can derive the right side of @${r} from the left side,
then for any @${v} we will be able to do the same thing.


@section{ Ruler's Unsound Algorithm }

We saw in the last section that we can reduce a set of rewrite rules soundly by trying to remove each of the rules one by one.
However, this is a very expensive process.
Remember, Ruler generates hundreds of thousands of valid rewrite rules.
For each of these rules, we need to run a full bottom-up procedure that tries to derive the right side of the rule.
Even though it's easily parallelizable, it's still too expensive in many cases.

Ruler has a much faster, but unsound way to reduce a set of rewrite rules.
Instead of starting with just one skolemized rewrite rule, it starts with a large set of them all at once.
They also share common skolemized variables, getting a bunch of sharing.
They then run a small set of (heuristically) selected rewrite rules, finding which rewrites can be derived.
This is much faster because many rewrite rules can be derived at once, and there is a lot of sharing of state during the evaluation process.

To see why this is unsound, consider the following example.
Suppose we have the following rewrite rules:
@centered{@${r_1: \forall x, x*0 \rightarrow 0}}
@centered{@${r_3: \forall x, x*1 \rightarrow 1*x}}
@centered{@${r_4: \forall x, (x*1)*0 \rightarrow x}}
@centered{@${r_5: \forall x, x*1 \rightarrow x*0}}

Now, let's try to derive @${r_4} and @${r_5} using @${r_1} and @${r_3}.
First, we skolemize @${r_4} and @${r_5}, getting @${(v*1)*0} and @${v*1}.
Now, we apply our rules on the initial state @${S = \{(v*1)*0\}}.
And it turns out, we can derive both @${r_4} and @${r_5}!

Here's a derivation of @${r_4}:
@centered{@${(v*1)*0 \rightarrow_{r_1} (v*1) \rightarrow_{r_3} v \rightarrow_{r_4} v}}

And here's a derivation of @${r_5}:
@centered{@${ v*1 \leftarrow_{r_1} (v*1)*0 \rightarrow_{r_3} v*0 }}

But wait a second... is @${r_5} really derivable from @${r_1} and @${r_3}?
Actually, no. If you start with @${v*1}, there's no way to introduce a @${0} to get @${v*0}.
The reason the unsound algorithm above was able to derive it was that there was what I call a @italic{magic term} in the initial state.
Namely, @${(v*1)*0} was in the initial state because
we were trying to derive another rule at the same time.
The existence of that term allowed us to derive @${r_5}.
(If you know a better name for magic terms, terms that are used in a derivation that need to be introduced out of thin air, please let me know!)



It turns out that Ruler's @${enumeration} of rewrite rules, which tries to shrink the space of possible rules by using the existing ones, is also unsound in a similar way.


@section{ A Faster Sound Algorithm }

Are we doomed to picking single rules from @${R} and attempting to derive them?
It seems like the trick that Ruler plays in batching many 
queries together won't work.
However, we might be able to do something similar, but soundly.

Suppose we are trying to derive a batch of rules @${D}, whose left and right-hand sides skolemize to terms @${t_1, t_2, ....}.
Construct a graph that has a node for each term @${t_i}, and initially contains no edges.
We'll start out with a graph like this one:


@(define (var str) (superimpose (text str null 30)
  (blank 40 40)
  5 5
))
@(define t1 (var "t1"))
@(define t2 (var "t2"))
@(define t3 (var "t3"))
@(define t4 (var "t4"))
@(define gap 100)
@(define empty-graph
  (vc-append gap
    (ht-append gap t1 t2)
    (ht-append gap t3 t4)))

@empty-graph


Now, for each rule @${r \in D}, try to derive it the slow and sound way.
For each of the rewrite rules we are able to derive, add an edge from the left-hand side to the right-hand side.
For example, we may end up with something like this:



@(define three-arrows
  (autoarrow t1 t2
    (autoarrow t2 t3
      (autoarrow t3 t4 
      (autoarrow t4 t1 empty-graph)))))

@three-arrows


Now, we automatically know that our ruleset also derives a rule whose left side is @${t_1} and right-hand side is @${t_3}.
This is because we derive @${t_1 \rightarrow t_2} and @${t_2 \rightarrow t_3}, and so by transitivity we know that we derive @${t_1 \rightarrow t_3}.

In fact, we know that any rule whose left hand side and right hand side are within a @link["https://en.wikipedia.org/wiki/Strongly_connected_component"]{strongly connected component} in the graph is already derived.
This is a less strong inference than ruler makes in its unsound algorithm, but it can still reduce a quadratic number of checks to linear in some cases.

