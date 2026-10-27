#lang scribble/manual
@require[scribble-math/dollar]
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

@title[#:style  title-style]{ Vibe Coding Animated Slides with Rhombus Pict }

I recently gave two talks using the Rhombus pict library to create
  high-quality animated slides.
The @link["https://www.youtube.com/watch?v=TyJv8ewUVvM"]{first talk} was about pict itself, and the
  second was about my @link["https://www.youtube.com/watch?v=nYucEGRk4Kk"]{latest research on e-graphs}.

This is meant as a short guide on how to create animated slides
  using Rhombus pict with AI.

@section{ Initial Prompt }

You'll want to point your AI to the Rhombus documentation, the pict documentation, the pict paper, my example talks, and finally some tips on how to validate the slides are good.

Here's an example prompt I used to get started:

@nested[#:style 'inset]{
I'm writing an animated slide deck for a conference talk in Rhombus, using the
pict and slideshow libraries.
Before writing any slides, gather context from the following:

@itemlist[
 @item{The Rhombus language documentation: @url{https://docs.racket-lang.org/rhombus/}}
 @item{The pict documentation: @url{https://docs.racket-lang.org/rhombus-pict/},
       especially the sections on animated picts, findable identity, and rebuilds.
       Also the slideshow documentation: @url{https://docs.racket-lang.org/rhombus-slideshow/}}
 @item{The pict paper, @italic{Animated Pictures for Slide Presentations} (ICFP 2026):
       @url{https://doi.org/10.1145/3828692}.
       It explains how animations are built out of epochs, and how picts keep an
       identity across transformations so that they can be found and replaced later.}
 @item{Example talks in @url{https://github.com/oflatt/talks}, in the
       @tt{2026-icfp-pict/talk} and @tt{2026-eggcc} folders.
       Read @tt{talk.rhm} and @tt{slidehelpers.rhm} in each to learn the style of
       the slides and the helpers.}
]

Then write the slides as a Rhombus program in @tt{talk.rhm}, with reusable helpers
(titles, speech bubbles, arrows, outlines, transitions) in a separate @tt{slidehelpers.rhm}.
Each slide is a pict whose epochs are the clicks.
Run the deck and render frames of each slide to check your work visually before reporting back.

@bold{Validating that the slides are good}: ensure that everything is on screen,
so the screen doesn't shift around even during animations.
Ensure that the resulting slides have the correct number of epochs, and that there
are no "dead epochs" where the user has to press input and nothing happens.
Ensure that animations are clean and that slide transitions are smooth.
Also ensure that all fonts used are included with the source code.
}

@section{ Iteration and Slide Helpers }

When iterating on slides, I found it helpful to keep a few things in mind.
First, give detailed instructions on layout, look of things, how animations should look,
  and which things should get their own animations.
My usual workflow is to describe the slide I want in detail, wait quite a while
  for the first draft of the slide, then use a pretty tight loop of looking at the slides and giving feedback.


Another thing I found helpful is to explicitly create a library of
  reusable slide helpers, which I lightly review / keep an eye on myself.
I put these in @link["https://github.com/oflatt/talks/blob/main/2026-eggcc/slidehelpers.rhm"]{slidehelpers.rhm} so far,
  and it may be worth turning
  them into a small library at some point.
Creating your own personal style and bank of useful combinators
  consolidated in a small library helps a lot.
