#lang racket
(require html-writing html-parsing)

(define test-text "sdf asdf asdf asdf asdf d sf wee rqw erqw er qwer qwer qwe rrq wer 
qwer qwer qwer qwe rq weer qwweer qwe rqw er qwerr qwer qw qwr qw qw rqw erqw erq wer")

(define inlinetext2 "width:47.5%;display:inline-block")
(define margin-format "")
(define section-title-size "32px")

(define post-style "text-indent:2px;width:95%;text-align:justify")
(define post-spacing "30")
(define post-title-size "24px")

(define button-style "width:25%;display:inline-block;margin-left:4.16666%;border-radius:20px;margin-right:4.16666%;outline:none;border:none")
(define download-button-style (string-append button-style ";height:60px;width:270px;font-size:15px;background-color:#DBC222"))

(define (write-html-to html file-name)
  (define file-port (open-output-file (string-append "../docs/" file-name) #:exists 'replace))
  (write-html html file-port))

(define (tag-name title-normal)
  (define short (short-name title-normal))
  (string-replace short " " "_"))

(define (short-name title-normal)
  (define title (string-replace title-normal ":" ""))
  (let ([l (string-split title)])
           (if (= (length l) 1)
               (first l)
               (string-append (first l) " " (second l)))))

(define (make-link link inner #:style [style ""])
  `(a (@ (href ,link) (style ,(string-append "text-decoration:none;" style)))
      ,inner))


;; all strings, title, language, year, github link, description, path to picture
(define
  (build-post title language year github description pic (windows-download "none") (mac-download "none") (html-video "none") #:authors [authors ""] #:website-text [website-text ""] #:video [video #f])
  (define windows-list
    (cond [(equal? windows-download "none")
           (list)]
          [(equal? (substring windows-download (- (string-length windows-download) 4)) "html")
           (list
            `(div
              (@ (style ,(string-append "text-align:center;" inlinetext2)))
              (button
               (@ (style ,download-button-style)
                  (onmouseenter "buttonhover(this)")
                  (onmouseleave "buttonoff(this)")
                  (onclick ,(string-append "window.location.href='" windows-download "'")))
               "Go To Site")))]
          [(not (equal? website-text ""))
           (list
            `(div
              (@ (style ,(string-append "text-align:center;" inlinetext2))
                        (target "_blank"))
              (button
               (@ (style ,download-button-style)
                  (onmouseenter "buttonhover(this)")
                  (onmouseleave "buttonoff(this)")
                  (onclick ,(string-append "window.location.href='" windows-download "'")))
               ,website-text)))]
          [else
           (list
            `(div
              (@ (style ,(string-append "text-align:center;" inlinetext2)))
              (button
               (@ (style ,download-button-style)
                  (onmouseenter "buttonhover(this)")
                  (onmouseleave "buttonoff(this)")
                  (onclick ,(string-append "window.location.href='" windows-download "'")))
               "Download for Windows")))]))
  (define mac-list
    (if (equal? mac-download "none")
        (list)
        (list
         `(div
           (@ (style ,(string-append "text-align:center;" inlinetext2)))
           (button
            (@ (style ,download-button-style)
               (onmouseenter "buttonhover(this)")
               (onmouseleave "buttonoff(this)")
               (onclick ,(string-append "window.location.href='" mac-download "'")))
            "Download for Mac")))))
  
  (define abstract-text
    (if (and (equal? pic "") (equal? html-video "none"))
        "Abstract:"
        ""))
  (define language-text
    (if (equal? language "")
        ""
        (string-append "Language: " language)))
  
  (define download-buttons
    (append windows-list mac-list))
  
  (define text-margins
    "margin-top: 0px;margin-bottom:0px;padding-top:10px")

  (define file-port (open-output-file (string-append "../docs/posts/" (short-name title) ".html") #:exists 'replace))
  
  (begin
    (write-html
     `(div
       (a (@ (style ,(string-append "width:8%;font-size:10px;color:rgb(100,100,100);display:inline-block;position:fixed;top:0px;right:0;cursor:default;visibility:hidden"))
              (onmouseenter "texthover(this)")
              (onmouseout "textoff(this)")
              (href ,(string-append "#" (tag-name title)))
              (class "navtext"))
           ,(short-name title))
       (div
        (@ (style ,(string-append margin-format "margin-bottom:" post-spacing "px;padding-bottom:10px;background-color:rgb(232, 245, 247);margin-left:2%;margin-right:0;display:inline-block"))
           (class "post"))
        (center (div (@ (style "text-align:left;color:black;width:95%;padding-top:5px;")
                        (id ,(tag-name title)))
                     (h2 (@ (style ,(string-append "margin-bottom:0px;font-size:" post-title-size))) ,title))

                ,(if (not (equal? authors ""))
                     `(div
                      (@ (style "width:95%"))
                      (div (@ (style "text-align:left"))
                      (h3 (@ (style ,text-margins)) ,authors)))
                     "")
         
                (div
                 (@ (style "color:#5A5A5A;width:95%"))
                 (div (@ (style "float:left"))
                      (h3 (@ (style ,text-margins)) ,year))
                 (div (@ (style "float:right"))
                      (h3 (@ (style ,text-margins)) ,language-text)))
                
                ,(if
                  (equal? github "")
                  `(div (@ (style ,(string-append post-style ";" text-margins "; overflow:auto")))
                        "")
                  `(div (@ (style ,(string-append post-style ";" text-margins "; overflow: auto")))
                        "Source: "
                        (a (@ (href ,github) (style "margin-top:0px") (target "_blank")) ,github)))

                ,(if video
                     `(div (@ (style ,(string-append post-style ";" text-margins "; overflow: auto")))
                           "Video: "
                           (a (@ (href ,video) (style "margin-top:0px") (target "_blank")) ,video))
                     "")

                ;; insert the picture
                (div (@ (style "margin-bottom:10px;padding-top:10px"))
                     ,(if
                       (equal? html-video "none")
                       (if (equal? windows-download "predetermined.html")
                           ""
                           "")
                       `(div (@ (class "mediaiframe"))
                             ,(html->xexp html-video)))
                     
                     ,(if (or (equal? pic "") (equal? pic "none"))
                          ""
                          `(img (@ (class "media")
                                   (src ,(string-append "https://github.com/oflatt/portfolio-gifs/raw/master/" pic))))))

                ;; put in the abstract and/or description
                ,@(if (or (equal? abstract-text "")
                          (equal? description ""))
                      `()
                      `((div (@ (style ,(string-append post-style ";" text-margins ";line-height:20px")))
                     ,abstract-text)))
                ,@(if (equal? description "")
                      `()
                      `((div (@ (style ,(string-append post-style ";line-height:20px")))
                     ,description)))

                ;; put in the buttons
                ,@download-buttons

                (dev (@ (style "color:#B4E4E7"))
                     "_"))))
     file-port)
    (close-output-port file-port)
    (short-name title)))


(define (page-button page-name current-page link)
  (define special-button-style
    (string-append "line-height: 0px; text-align: center; font-size:" post-title-size ";" button-style
                   (if (equal? page-name current-page)
                       ";background-color:#DBC222"
                       ";background-color:#6CC97F")))
  `(button (@ (style ,special-button-style)
              (onclick ,(string-append "window.location.href='" link "'"))
              (onmouseenter "buttonhover(this)")
              (onmouseleave "buttonoff(this)"))
        (h2 (@ (style "font-weight:normal")) ,page-name)))

(define (menu current-page)
  `(div
    (@ (style ,(string-append margin-format ";margin-bottom:20px;text-align:center")))))


(define (section-title name)
  `(center
    (div
     (@ (style
         ,(string-append "margin-top: " post-spacing "px; margin-bottom: 0px; margin-left: auto; margin-right: auto; color: rgb(0, 0, 50)")))
     (div
      (h1 (@ (style ,(string-append "padding-bottom:0px;margin-top:0px;font-weight:normal;font-size:" section-title-size)))
          ,name)))))

(define (about-post page-name)
  `(div
    (@ (style ,(string-append margin-format "margin-bottom:" post-spacing "px;padding-bottom:10px;background-color:rgb(232, 245, 247);margin-left:2%;margin-right:8%")))
    (div (@ (style ,(string-append post-style 
                                   ";margin: 0 auto; padding-top: 20px; padding-bottom: 20px; font-size:"
                                   post-title-size)))
         "I'm interested in programming languages, especially verification and formal methods. Currently, I'm a graduate student at the University of Washington. I work on the "
         ,(make-link "http://herbie.uwplse.org/" "Herbie")
         " tool, which reduces floating-point error in programs. I also work on the e-graph library "
         ,(make-link "https://egraphs-good.github.io/" "Egg")
         ". Are you recruiting for research internships? Check out my "
         (a (@ (href "https://docs.google.com/document/d/1EfzL7y3L3tN5qd-v90aa0eHmJcoRtcb_IK7R6YAyLvk/edit?usp=sharing") (style "text-decoration:none"))
                   "resume")
         "."
         (br)
        )))
    
    

(define (page filenamelist name projects-title body-html [extra-head-html (list)])
  (define filenamestring
    (if (empty? filenamelist) ""
        (substring
          (foldl (lambda (s result)
                   (string-append result "," s))
                 ""
                 filenamelist)
          1)))
  `((html (head
           ,(html->xexp "<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-108872403-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-108872403-1');
</script>")
           ,extra-head-html
           (script (@ (src "mainscript.js")))
           (link (@ (href "https://fonts.googleapis.com/css?family=Nunito+Sans")
                    (rel "stylesheet")))
           (link (@ (rel "stylesheet") (type "text/css") (href "poststyle.css")))
           (link (@ (rel "stylesheet") (type "text/css") (href "docstyle.css")))
           
          (title "Oliver Flatt"))
          (body
           (@ (style "background-color:rgb(245,245,245)"))
           (div
            (@ (style "text-align: center; margin-top: 10px"))
            
            (img (@ (style "max-width:15%;height:auto;padding-right:30px;display: inline-block;")
                    (src "./careerolivercropped.jpg")))
            (div (@ (style "padding-bottom:0px;margin:auto 0px;font-weight:normal;font-size:64px;display: inline-block; vertical-align: top;"))
                 "Oliver Flatt"
                 (h2 (@ (style "font-weight:normal;font-size:18px"))
                     (a (@ (href "https://docs.google.com/document/d/1EfzL7y3L3tN5qd-v90aa0eHmJcoRtcb_IK7R6YAyLvk/edit?usp=sharing") (style "text-decoration:none"))
                        "resume")
                     " | "
                     (a (@ (href "mailto:oflatt@cs.washington.edu") (style "text-decoration:none"))
                        "oflatt@cs.washington.edu")
                     " | "
                     (a (@ (href "https://twitter.com/oflatt") (target "_blank") (style "text-decoration:none"))
                        "twitter")
                     " | "
                     (a (@ (href "https://www.youtube.com/channel/UCcmOhnWCA1ACNsPKWcOum0w") (target "_blank") (style "text-decoration:none"))
                        "youtube")
                      
                      )))
           
           ,(menu name)

           (div (@ (style "width:95%"))
                ,(page-button "publications" name "index.html")
                ,(page-button "projects" name "projects.html")
                ,(page-button "blog" name "blog.html"))
           
           (div (@ (style "display:block; margin-top: 10px"))
                ,(about-post name))
           ,(section-title projects-title)
           
           ;;now put in the div that will hold all the posts
           ;; the container holds a list of the file names for the posts
           ,(if (empty? filenamelist)
                empty
                `(div
                      (@ (class "container") (data-postlist ,filenamestring))))

           ;; body html
           ,body-html

           ;; load more navtext
           (h1 (@ (style ,(string-append "width:8%;font-size:10px;color:rgb(100,100,100);position:fixed;bottom:20px;right:0;cursor:default;visibility:hidden"))
                  (onmouseenter "texthover(this)")
                  (onmouseout "textoff(this)")
                  (onclick "loadnew()")
                  (id "load more"))
               "Load More")))))

(define sound-abstract
  "The aim of this paper is to demonstrate how to use mathematical models to generate sound waves using computers,
and how to manipulate these models for desired effects. The application of this paper is a low-level control over
the generation of sound for use in computer generated music. The method of investigation is to research and
implement various models of waves, as well as derive new waveforms and tools to manipulate them. These will be
implemented in the programming language Python, using a library called pygame for playing audio, and the library
numpy for representing the audio in a buffer. A basic evaluation of the success of the implementation is whether
the correct pitch is produced and sustained. Beyond that, it can only be judged subjectively, based on what
varieties are produced that sound good.")

(define hamt-abstract
  "Researchers recently implemented the HAMT (Hash Array Mapped Trie) in many programming languages and
optimized it for performance and memory efficiency, replacing traditional hash tables in many cases. The HAMT has
many possible implementation differences that can have significant effects on its performance, such as separation
of data types, bitmap compression, and node size. The purpose of this investigation is to explore how the size of
the nodes in the data structure Hash Array Mapped Trie affect the performance of the search and insert functions on
it. To investigate this, I implemented the HAMT data structure in Python and tested it for insert and search times
with varying node sizes using the PyPy Python interpreter.  I initially hypothesize that as node size increases,
speeds for both insert and search increase, but that the greater node size increases memory overhead, making the
middle node size the most effective. My test results refute both of these claims. HAMT implementations in Python
with a node size of 32 perform best on insert and search tests and memory use decreases as node size increases.
I conclude that HAMT implementations that have bitmap compression with a node size of 32 are optimal when written
in Python.")

(define space-orbs-description
  "An online multiplayer first person shooter that is unique because the perspective of the player is not relative
to any one axis. Rotation of the player's perspective is based only on the current orientation of the player so
that it is more like space. Currently there is no dedicated server, so to play you must run one yourself.")

(define sonic-onion-description
  "Sonic Onion is a reactive, visual language for composing music. Chain together blocks and create functions that generate the song in real time.")

(define bearly-dancing-description
  "Bearly Dancing is a cross between a rhythm game and a role
playing game. It features randomly generated art and a comical storyline.
Unlike many rhythm games, player actually creates the music when they press keys. The random music generator employs rules of
composition in a procedurally-generated fashion. Bearly Dancing is currently in development. I am working towards
publishing it to Steam, but for now, play the demo of the game at bearlydancing.com. Pixel art that is not randomly
generated by Sophie Flatt.")

(define curve-stitching-description
  "An animation based upon any mathematical equation that stitches the curve using its tangent lines. It then draws
the entire stitched curve each frame, offsetting the position of the points relative to time. Finally, using points
on the tangent lines, it draws connecting lines for an added effect. It is fun to watch because of its seeming
complexity arising from simple mathematics.")

(define devine-idle-description
  "A fun little idle game that grows a plant. Watch it grow large randomly or direct its growth.")

(define sickle-cell-description
  "A simulator that shows how the recessive sickle cell anemia gene gets passed down through generations.")

(define great-camps-description
  "I taught middle and high school kids programming in the
University of Utah GREAT camps for three years. The animation above is of one of the student’s finished space invaders
game in the camp. It was a fun and challenging summer job.")


;; autoplay link https://www.youtube.com/embed/g6SlOlGsGdE?rel=0&autoplay=1&mute=1&amp&loop=1&controls=0&playlist=g6SlOlGsGdE;showinfo=0&amp

(define (mk-youtube link)
  (format "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='560' height='315'  src='~a' frameborder='0' allowfullscreen></iframe></div>" link))

(write-html-to
 (page
  (list
   (build-post "Bearly Dancing" "Python, with the library Pygame" "2016-present"
               "https://github.com/oflatt/bearlydancing" bearly-dancing-description "" "http://bearlydancing.com" "none"
               "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/g6SlOlGsGdE' frameborder='0' allowfullscreen></iframe></div>" #:website-text "Bearly Dancing Website")
   (build-post "Sonic Onion" "Elm" "2020-present"
               "https://github.com/oflatt/soniconion" sonic-onion-description "soniconion.png" "https://soniconion.net" #:website-text "Sonic Onion Website")
   (build-post "I have 196 hands" "Python (MoviePy)" "2022"
               "https://www.youtube.com/watch?v=xgyq1l_NNuA"
               "Running conway's game of life on my hands."
               "" "none" "none"
               (mk-youtube "https://www.youtube.com/embed/xgyq1l_NNuA"))
   (build-post "Esonify" "elisp" "2019"
               "https://github.com/oflatt/esonify"
               "An emacs package that sonifies your code. Skilled users will begin to be able to recognize some code based solely upon the music it generates. Hear sine waves at different frequencies for lowercase letters, square waves for upper case letters, and triangle waves for keybindings."
               "" "none" "none"
               (mk-youtube "https://www.youtube.com/embed/fwBh6FKxzcQ"))
   (build-post "GREAT Camps" "Python, Processing" "2016-2018"
               "https://www.cs.utah.edu/~dejohnso/GREAT" great-camps-description
               "space-invaders-demo.gif")
   (build-post "Gravigon" "Javascript, HTML" "2018"
               "https://github.com/oflatt/portfolio/tree/master/gravigon" "Play with gravity and visualize floating point error with newton's method." "gravigon.gif" "gravigon.html" "none")
   (build-post "Chinese Remainder Algorithm Visualized" "Java" "2018"
               "https://github.com/oflatt/chinese-remainder-algorithm-visualized" "A visualization and lecture on Chinese Remainder Theorem using an example problem."
               "" "none" "none"
               "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/s0hg4ONFP6I?rel=0&amp;showinfo=0&amp' frameborder='0' allowfullscreen></iframe></div>")
   (build-post "Predetermined- Randomly Generated Art" "Processing.js" "2017"
               "https://github.com/oflatt/predetermined"
               "An art work that explores using hitboxes to determine the movement of a trailing particle. Converted to javascript using Processing.js."
               "leafspredetermined.gif" "predetermined.html")
   (build-post "Curve Stitching Animation" "Racket" "2017"
               "https://github.com/oflatt/curve-stitching" curve-stitching-description "circle-curve-stitch.gif")
   (build-post "Space Orbs" "Racket" "2015"
               "https://github.com/oflatt/space-orbs" space-orbs-description ""
               "https://github.com/oflatt/files-for-download/raw/master/space-orbs-client.zip"
               "https://github.com/oflatt/files-for-download/raw/master/space-orbs-client.dmg"
               "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/mP8ud9Yztz8?rel=0&autoplay=1&mute=1&amp;controls=0&amp;showinfo=0&amp;start=43' frameborder='0' allowfullscreen></iframe></div>")
   (build-post "Devine Idle" "Racket" "2014"
               "https://github.com/oflatt/devine-idle" devine-idle-description "devine-idle-demo.gif"
               "http://www.cs.utah.edu/~mflatt/oflatt/Devine-Idle-Windows.zip"
               "http://www.cs.utah.edu/~mflatt/oflatt/Devine-Idle-Mac.dmg")
   (build-post "Sickle Cell Anemia Population Simulator" "Racket" "2014"
               "https://github.com/oflatt/sickle-cell-population-simulator" sickle-cell-description
               "sickle-cell-anemia-demo.gif"
               "https://drive.google.com/uc?export=download&id=0B6SmFaR0J_BpWU9TQzA4SmJ0cHM")
   (build-post "Bubble Field" "Clickteam Fusion" "2014"
               "" "A local multiplayer game inspired by snake. Trap your opponent so that they cannot move. Use resources tactically."
               "bubble-field-demo.gif"
               "https://github.com/oflatt/files-for-download/raw/master/bubble_field.exe")
   (build-post "Screensaver- Randomly Generated Dragon Curve and Other Animations" "Processing" "2016"
               "" "A screensaver full of different kinds of randomly generated animations. The dragon curves
are generated using an implementation of the L-system in processing (java wraparound)."
               "screensaver-demo.gif"
               "https://github.com/oflatt/files-for-download/raw/master/screensaver_variety.zip"
               "https://github.com/oflatt/files-for-download/raw/master/screensaver_variety_mac.zip"))
  "projects"
  "Projects"
  empty)
 "projects.html")

(define egg-abstract "An e-graph efficiently represents a congruence relation over many expressions. Although they were originally developed in the late 1970s for use in automated theorem provers, a more recent technique known as equality saturation repurposes e-graphs to implement state-of-the-art, rewrite-driven compiler optimizations and program synthesizers. However, e-graphs remain unspecialized for this newer use case. Equality saturation workloads exhibit distinct characteristics and often require ad-hoc e-graph extensions to incorporate transformations beyond purely syntactic rewrites.
This work contributes two techniques that make e-graphs fast and extensible, specializing them to equality saturation. A new amortized invariant restoration technique called rebuilding takes advantage of equality saturation's distinct workload, providing asymptotic speedups over current techniques in practice. A general mechanism called e-class analyses integrates domain-specific analyses into the e-graph, reducing the need for ad hoc manipulation.
We implemented these techniques in a new open-source library called egg. Our case studies on three previously published applications of equality saturation highlight how egg's performance and flexibility enable state-of-the-art results across diverse domains.")
(define pherbie-abstract "Precision tuning and rewriting can improve both
the accuracy and speed of floating point expressions, yet these
techniques are typically applied separately. This paper explores
how finer-grained interleaving of precision tuning and rewriting
can help automatically generate a richer set of Pareto-optimal
accuracy versus speed trade-offs.
We introduce Pherbie (Pareto Herbie), a tool providing both
precision tuning and rewriting, and evaluate interleaving these
two strategies at different granularities. Our results demonstrate
that finer-grained interleavings improve both the Pareto curve
of candidate implementations and overall optimization time. On
a popular set of tests from the FPBench suite, Pherbie finds
both implementations that are significantly more accurate for
a given cost and significantly faster for a given accuracy bound
compared to baselines using precision tuning and rewriting alone
or in sequence.")

(define small-proofs-abstract
  "Satisfiability Modulo Theory (SMT) solvers and equality saturation engines must generate proof certificates from e-graph-based congruence closure procedures to enable verification and conflict clause generation. Smaller proof certificates speed up these activities. Though the problem of generating proofs of minimal size is known to be NP-complete, existing proof minimization algorithms for congruence closure generate unnecessarily large proofs and introduce asymptotic overhead over the core congruence closure procedure. In this paper, we introduce an O(n^5) time algorithm which generates optimal proofs under a new relaxed \"proof tree size\" metric that directly bounds proof size. We then relax this approach further to a practical O(n \\log(n)) greedy algorithm which generates small proofs with no asymptotic overhead. We implemented our techniques in the egg equality saturation toolkit, yielding the first certifying equality saturation engine. We show that our greedy approach in egg quickly generates substantially smaller proofs than the state-of-the-art Z3 SMT solver on a corpus of 3760 benchmarks.")

(write-html-to
 (page (list
        (build-post "Better Together: Unifying Datalog and Equality Saturation" "" "PLDI 2023"
                    "https://arxiv.org/abs/2304.04332"
                    "" ""
                    #:authors "Yihong Zhang, Yisu Remy Wang, Oliver Flatt, David Cao, Philip Zucker, Eli Rosenthal, Zachary Tatlock, Max Willsey"
        )
        (build-post "Small Proofs from Congruence Closure" "" "FMCAD 2022"
                    "https://arxiv.org/abs/2209.03398" "" ""
                    #:authors "Oliver Flatt, Samuel Coward, Max Willsey, Zachary Tatlock, and Pavel Panchekha"
                    #:video "https://www.youtube.com/watch?v=_KnAHFdqWT0")
        (build-post "Combining Precision Tuning and Rewriting for Faster, More Accurate Programs" "" "ARITH 2021"
               "http://arith2021.arithsymposium.org/session/session1video.html" "" ""
               #:authors "Brett Saiki, Oliver Flatt, Zachary Tatlock, Pavel Panchekha and Chandrakana Nandi")
        (build-post "egg: Fast and extensible equality saturation" "" "POPL 2021 Distinguished Paper"
               "https://dl.acm.org/doi/10.1145/3434304" "" ""
               #:authors "Max Willsey, Chandrakana Nandi, Yisu Remy Wang, Oliver Flatt, Zachary Tatlock, and Pavel Panchekha"))
       "publications"
       "Publications"
       empty)
 "index.html")



(define (make-blog)
  (define blog-posts
    `(("Minimizing Sets of Rewrite Rules: Sound and Unsound Approaches"
       "magic-terms.html" 3 8 2023)
      ("Limitations of E-Graph Intersection" "egraph-union-intersect.html" 8 5 2022)
    ))
  
  `(div (@ (style ,(string-append margin-format "margin-bottom:" post-spacing "px;padding-bottom:10px;background-color:rgb(232, 245, 247);margin-left:2%;margin-right:0;")))
        ,@(for/list ([post blog-posts])
                    `(div (@ (style ,(string-append "padding-top: 10px; margin-bottom:0px; display:flex")))
                          ,(make-link (second post)
                                     `(h2 (@ (style ,(string-append "font-size:" post-title-size)))
                                          ,(first post))
                                     #:style "margin-right:auto; padding-left:10px")
                          (h2
                           (@ (style ,(string-append "padding-right: 10px; font-size:" post-title-size)))
                           ,(format "~a/~a/~a" (third post) (fourth post) (fifth post)))))))

(write-html-to
 (page empty "blog" "Blog"
       (make-blog))
 "blog.html")


(define embed-video-html
  "<iframe width='950' height='950' src='https://www.youtube.com/embed/ZswrScw3eLA?rel=0&autoplay=1&mute=1&rel=0&rel=0&amp;controls=0&amp;showinfo=0' frameborder='0' allowfullscreen></iframe>")


(define tessa-file-port (open-output-file "../docs/tessa.html" #:exists 'replace))

(write-html
 `((html
    (head (title "Tessa's page"))
    (body
     (center
      ,(html->xexp embed-video-html)))))
 tessa-file-port)


 
