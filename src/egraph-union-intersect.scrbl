#lang scribble/manual
@require[scribble-math/dollar]
@(require scribble/core
          scribble/html-properties
          (only-in xml cdata))

@(define head-google (head-extra (cdata #f #f "<link rel=\"stylesheet\"
          href=\"https://fonts.googleapis.com/css?family=Nunito+Sa
          ns\">")))


@title[#:style (style #f (list head-google))]{ EGraph Union, Intersection, and Difference }

@section{ EGraphs }

E-Graphs are a data structure for representing a equalities between terms
efficiently. This post assumes you know what an egraph is, @link["https://www.philipzucker.com/egraph-1/"]{here's a great post about them}.

@section{ EGraphs and Proofs }

E-Graph implementations (including egg) typically provide a way to generate
a proof certificate for why two terms are equal.
Example: why is @${a + b} equal to @${b + a}?
Example answer: we had a rule about commutativity of addition that says @${x + y = y + x} and we used it to infer the specific terms @${a + b} and @${b + a} are equal.
You can think of this proof certificate as a set of equalities @${E = \{ T_1 = T_2, T_3 = T_4, ... \}}
where each @${T} is a term.

Another nice property is that the egraph computes the congruence closure over the terms.
A congruence closure procedure goes from a set of terms @${E} to an egraph.
If you insert a set of equalities @${E} into the egraph, then it will say two terms @${T_i} and @${T_j} are equal iff there is a valid proof between them (potentially using congruence).
We can also go the other way: given an egraph, we can extract back out the set of
equalities that generate the egraph.
There are multiple choices for this set of equalities, but the simplest choice is simply
the terms that were inserted into the egraph either directly or by axiom instantiations.


@section{ EGraph Union }

Let's write the union of two egraph @${E_1 \cup E_2 = E_3}.
Intuitively, @${E_3} should represent terms that are equal in either @${E_1} or @${E_2}.
More formally, let's write @${=_{E}} for equality in an egraph @${E} (after inserting the terms and maintaining congruence closure).
We want that, for any two terms @${T_1} and @${T_2}, @${T_1 =_{E_3} T2} iff @${T1 =_{E1} T2} or @${T1 =_{E2} T2}.


Egraph union is super easy- for every equality @${T_i = T_j} 