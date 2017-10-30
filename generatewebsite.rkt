#lang racket
(require html-writing html-parsing)

(define test-text "sdf asdf asdf asdf asdf d sf wee rqw erqw er qwer qwer qwe rrq wer 
qwer qwer qwer qwe rq weer qwweer qwe rqw er qwerr qwer qw qwr qw qw rqw erqw erq wer")

(define inlinetext2 "width:47.5%;display:inline-block")
(define margin-format "margin:0 auto;width:950px")
(define post-style "text-indent:2em;width:95%;overflow:auto;text-align:justify")
(define download-button-style "height:60px;width:270px;font-size:15;background-color:#FDFF5C")

;; all strings, title, language, year, github link, description, path to picture
(define
  (build-post title language year github description pic (windows-download "none") (mac-download "none") (html-video "none"))
  (define windows-list
    (if (equal? windows-download "none")
        (list)
        (list
         `(div
           (@ (style ,(string-append "text-align:center;" inlinetext2)))
           (button
            (@ (style ,download-button-style)
               (onclick ,(string-append "window.location.href='" windows-download "'")))
           "Download for Windows")))))
  (define mac-list
    (if (equal? mac-download "none")
        (list)
        (list
         `(div
           (@ (style ,(string-append "text-align:center;" inlinetext2)))
           (button
            (@ (style ,download-button-style)
               (onclick ,(string-append "window.location.href='" windows-download "'")))
            "Download for Mac")))))
  (define abstract-text
    (if (equal? pic "")
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
  `(div
    (@ (style ,(string-append margin-format ";margin-bottom:10px;background-color:#B4E4E7")))
    (center (div (@ (style "text-align:left;color:black;width:95%;padding-top:5px;"))
                 (h2 (@ (style "margin-bottom:0px;font-size:22")) ,title))

            (div
             (@ (style "color:#5A5A5A;width:95%;"))
             (div (@ (style "float:left"))
                  (h3 (@ (style ,text-margins)) ,year))
             (div (@ (style "float:right"))
                  (h3 (@ (style ,text-margins)) ,language-text)))
            
            ,(if
              (equal? github "")
              ""
              `(div (@ (style ,(string-append post-style ";" text-margins)))
                 "Source: "
                 (a (@ (href ,github) (style "margin-top:0px") (target "_blank")) ,github)))

            ,(if
              (equal? html-video "none")
              ""
              (html->xexp html-video))
            
            ,(if (equal? pic "")
                 ""
                 `(img (@ (style "margin-bottom:10px;padding-top:10px")
                          (src ,(string-append "https://github.com/oflatt/portfolio-gifs/raw/master/" pic)))))
            ,@download-buttons
            
            (div (@ (style ,(string-append post-style ";" text-margins ";line-height:20px")))
                 ,abstract-text)
            (div (@ (style ,(string-append post-style ";line-height:20px")))
                 ,description)
            (dev (@ (style "color:#B4E4E7"))
                 "_"))))

(define button-style "width:33.33334%;display:inline-block;text-decoration:underline;background-color:#6CC97F")

(define (page-button page-name current-page)
  (define link
    (if (equal? page-name "papers")
        "index.html"
        (string-append page-name ".html")))
  (define button-style
    (if (equal? page-name current-page)
        ";font-size:34;color:black;font-weight:normal"
        ";color:blue;font-weight:normal"))
  `(h2 (@ (onclick ,(string-append "window.location.href='" link "'")))
       (a (@ (style ,button-style) (href ,link)) ,page-name)))

(define (menu current-page)
  `(div
    (@ (style ,(string-append margin-format ";margin-bottom:20px;text-align:center")))
    (div (@ (style ,(string-append button-style ";text-align:center")))
         ,(page-button "papers" current-page))
    (dif (@ (style ,(string-append button-style ";text-align:center")))
         ,(page-button "projects" current-page))
    (dif (@ (style ,(string-append button-style ";text-align:center")))
         ,(page-button "experiences" current-page))))

(define (page body name)
  `((html (head
           ,(html->xexp "<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-108872403-1'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-108872403-1');
</script>")
          (title "Oliver Flatt"))
         (body (center
                (h1 (@ (style "margin-bottom:0px;margin-top:20px;font-weight:normal")) "Oliver Flatt")
                (h2 (@ (style "margin-top:10px;font-weight:normal")) "portfolio"))

               ,(menu name)
               ,body
               ,(menu name))
         (footer
          (center (p "email me: oflatt@gmail.com"))))))

(define index-file-port (open-output-file "index.html" #:exists 'replace))

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

(write-html
 (page
  `(div
    ,(build-post "How Implementations of the Persistent Data Type HAMT with Varying Node Sizes Compare
in Performance When Implemented in Python"
                 "" "2017" "hamt python.pdf" hamt-abstract "")
    ,(build-post "Mathematically Generating Sound Waves for Music" "" "2016"
                 "generating-sound.pdf" sound-abstract ""))
  "papers")
 index-file-port)

(close-output-port index-file-port)

(define space-orbs-description
  "An online multiplayer first person shooter that is unique because the perspective of the player is not relative
to any one axis. Rotation of the player's perspective is based only on the current orientation of the player so
that it is more like space. Currently there is no dedicated server, so to play you must run one yourself.")

(define bearly-dancing-description
  "This is my largest and most ambitious project. Bearly Dancing is a cross between a rhythm game and a role
playing game. It features randomly generated art and a comical storyline.
Gameplay is unique because player actually creates the music when they press keys, and they try to follow
a randomly generated beatmap. The random music generator is a research project in itself, employing rules of
composition in a procedurally-generated fashion. Bearly Dancing is currently in development. I am working towards
publishing it to Steam, although it will not happen within a single year. Pixel art that is not randomly
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

(define projects-file-port (open-output-file "projects.html" #:exists 'replace))
(write-html
 (page
  `(div
    ,(build-post "Bearly Dancing" "Python, with the library Pygame" "2016-present"
                 "https://github.com/oflatt/bearlydancing" bearly-dancing-description "bearly-dancing-demo.gif")
    ,(build-post "Curve Stitching Animation" "Racket" "2017"
                 "https://github.com/oflatt/curve-stitching" curve-stitching-description "circle-curve-stitch.gif")
    ,(build-post "Space Orbs" "Racket" "2015"
                 "https://github.com/oflatt/space-orbs" space-orbs-description ""
                 "https://github.com/oflatt/files-for-download/raw/master/space-orbs-client.zip"
                 "https://github.com/oflatt/files-for-download/raw/master/space-orbs-client.dmg"
                 "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/mP8ud9Yztz8?rel=0&autoplay=1&amp;controls=0&amp;showinfo=0&amp;start=43' frameborder='0' allowfullscreen></iframe></div>")
    ,(build-post "Devine Idle" "Racket" "2014"
                 "https://github.com/oflatt/devine-idle" devine-idle-description "devine-idle-demo.gif"
                 "http://www.cs.utah.edu/~mflatt/oflatt/Devine-Idle-Windows.zip"
                 "http://www.cs.utah.edu/~mflatt/oflatt/Devine-Idle-Mac.dmg")
    ,(build-post "Sickle Cell Anemia Population Simulator" "Racket" "2014"
                 "https://github.com/oflatt/sickle-cell-population-simulator" sickle-cell-description
                 "sickle-cell-anemia-demo.gif"
                 "https://drive.google.com/uc?export=download&id=0B6SmFaR0J_BpWU9TQzA4SmJ0cHM")
    ,(build-post "This Website" "Racket with html-writing library" "2017"
                 "https://github.com/oflatt/portfolio" "A portfolio of my work in Computer Science."
                 "thiswebsitegrey.png")
    ,(build-post "Bubble Field" "Clickteam Fusion" "2014"
                 "" "A local multiplayer game with a surprisingly high skill cap. Trap your opponent so that they
cannot move."
                 "bubble-field-demo.gif"
                 "https://github.com/oflatt/files-for-download/raw/master/bubble_field.exe")
    ,(build-post "Screensaver- Randomly Generated Dragon Curve and Other Animations" "Processing" "2016"
                 "" "A screensaver full of different kinds of randomly generated animations. The dragon curves
are generated using an implementation of the L-system in processing (java wraparound)."
                 "screensaver-demo.gif"
                 "https://github.com/oflatt/files-for-download/raw/master/screensaver_variety.zip"))
  "projects")
 projects-file-port)

(close-output-port projects-file-port)

(define great-camps-description
  "I volunteered to help teach at the at the University of Utah GREAT summer camps for two years in a row.
The first summer I taught middle schoolers taking that processing camp for six weeks, and took the Arduino camp
myself. The second summer I taught in the Python game development camp for three weeks. The animation above is of
one of the student’s finished space invaders game in the camp.")

(define racket-explanation
  "Many of my projects are in Racket, a powerful functional programming language. Because of my interest in Racket
and programming in general, I attended the past three RacketCon events. I listened to many interesting talks,
most of them going right over my head. I'm not afraid of trying to learn new and difficult concepts.")

(define experiences-file-port (open-output-file "experiences.html" #:exists 'replace))
(write-html
 (page
  `(div
    ,(build-post "GREAT Camp Volunteer Work" "Python" "2016-2017"
                 "https://www.cs.utah.edu/~dejohnso/GREAT" great-camps-description
                 "space-invaders-demo.gif")
    ,(build-post "RacketCon" "Racket" "2015, 2016, and 2017"
                "https://racket-lang.org" racket-explanation "racket.jpg"))
    "experiences")
 experiences-file-port)

(close-output-port experiences-file-port)

(define embed-video-html
  "<iframe width='950' height='950' src='https://www.youtube.com/embed/ZswrScw3eLA?rel=0&autoplay=1&rel=0&rel=0&amp;controls=0&amp;showinfo=0' frameborder='0' allowfullscreen></iframe>")


(define tessa-file-port (open-output-file "tessa.html" #:exists 'replace))

(write-html
 `((html
    (head (title "Tessa's page"))
    (body
     (center
      ,(html->xexp embed-video-html)))))
 tessa-file-port)

(close-output-port tessa-file-port)
 