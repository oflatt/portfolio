#lang racket
(require html-writing html-parsing)

(define test-text "sdf asdf asdf asdf asdf d sf wee rqw erqw er qwer qwer qwe rrq wer 
qwer qwer qwer qwe rq weer qwweer qwe rqw er qwerr qwer qw qwr qw qw rqw erqw erq wer")

(define inlinetext2 "width:47.5%;display:inline-block")
(define margin-format "")
(define post-style "text-indent:2px;width:95%;overflow:auto;text-align:justify")
(define button-style "width:25%;display:inline-block;margin-left:4.16666%;border-radius:20px;margin-right:4.16666%;outline:none;border:none")
(define download-button-style (string-append button-style ";height:60px;width:270px;font-size:15px;background-color:#DBC222"))

(define (short-name title)
  (let ([l (string-split title)])
           (if (= (length l) 1)
               (first l)
               (string-append (first l) " " (second l)))))

;; all strings, title, language, year, github link, description, path to picture
(define
  (build-post title language year github description pic (windows-download "none") (mac-download "none") (html-video "none"))
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
          [(equal? windows-download "http://bearlydancing.com")
           (list
            `(div
              (@ (style ,(string-append "text-align:center;" inlinetext2))
                        (target "_blank"))
              (button
               (@ (style ,download-button-style)
                  (onmouseenter "buttonhover(this)")
                  (onmouseleave "buttonoff(this)")
                  (onclick ,(string-append "window.location.href='" windows-download "'")))
               "bearly dancing website")))]
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
       (h1 (@ (style ,(string-append "width:8%;font-size:10px;color:rgb(100,100,100);display:inline-block;position:fixed;top:0px;right:0;cursor:default;visibility:hidden"))
              (onmouseenter "texthover(this)")
              (onmouseout "textoff(this)")
              (onclick "scrollToPos(this)")
              (class "navtext"))
           ,(short-name title))
       (div
        (@ (style ,(string-append margin-format "margin-bottom:10px;padding-bottom:10px;background-color:#B4E4E7;margin-left:2%;margin-right:0;display:inline-block"))
           (class "post"))
        (center (div (@ (style "text-align:left;color:black;width:95%;padding-top:5px;"))
                     (h2 (@ (style "margin-bottom:0px;font-size:22px")) ,title))

                (div
                 (@ (style "color:#5A5A5A;width:95%"))
                 (div (@ (style "float:left"))
                      (h3 (@ (style ,text-margins)) ,year))
                 (div (@ (style "float:right"))
                      (h3 (@ (style ,text-margins)) ,language-text)))
                
                ,(if
                  (equal? github "")
                  `(div (@ (style ,(string-append post-style ";" text-margins)))
                        "")
                  `(div (@ (style ,(string-append post-style ";" text-margins)))
                        "Source: "
                        (a (@ (href ,github) (style "margin-top:0px") (target "_blank")) ,github)))

                ;; insert the picture
                (div (@ (style "margin-bottom:10px;padding-top:10px"))
                     ,(if
                       (equal? html-video "none")
                       (if (equal? windows-download "predetermined.html")
                           "" ;; TODO- add picture for predetermined
                           "")
                       `(div (@ (class "mediaiframe"))
                             ,(html->xexp html-video)))
                     
                     ,(if (or (equal? pic "") (equal? pic "none"))
                          ""
                          `(img (@ (class "media")
                                   (src ,(string-append "https://github.com/oflatt/portfolio-gifs/raw/master/" pic))))))

                ;; put in the abstract and/or description
                (div (@ (style ,(string-append post-style ";" text-margins ";line-height:20px")))
                     ,abstract-text)
                (div (@ (style ,(string-append post-style ";line-height:20px")))
                     ,description)

                ;; put in the buttons
                ,@download-buttons

                (dev (@ (style "color:#B4E4E7"))
                     "_"))))
     file-port)
    (close-output-port file-port)
    (short-name title)))


(define (page-button page-name current-page)
  (define link
    (if (equal? page-name "papers")
        "index.html"
        (string-append page-name ".html")))
  (define special-button-style
    (if (equal? page-name current-page)
        (string-append button-style ";background-color:#DBC222")
        (string-append button-style ";background-color:#6CC97F")))
  `(button (@ (style ,(string-append special-button-style ";text-align:center"))
              (onclick ,(string-append "window.location.href='" link "'"))
              (onmouseenter "buttonhover(this)")
              (onmouseleave "buttonoff(this)"))
        (h2 (@ (style "font-weight:normal")) ,page-name)))

(define (menu current-page)
  `(div
    (@ (style ,(string-append margin-format ";margin-bottom:20px;text-align:center")))
    ,(page-button "papers" current-page)
    ,(page-button "projects" current-page)
    ,(page-button "experiences" current-page)))


(define (page filenamelist name [extra-head-html (list)])
  (define filenamestring
    (substring
     (foldl (lambda (s result)
              (string-append result "," s))
            ""
            filenamelist)
     1))
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
           (link (@ (rel "stylesheet") (type "text/css") (href "poststyle.css")))
           
          (title "Oliver Flatt"))
          (body
           (@ (style "background-color:rgb(245,245,245)"))
           (center
           (div
            (@ (style "margin:auto 0"))
          ;;  (img (@ (style "float:left;max-width:12%;height:auto;padding-left:280px;margin-right:-400px")
          ;;          (src "https://github.com/oflatt/portfolio-gifs/raw/master/plobdark.png")))
            (div
             (h1 (@ (style "padding-bottom:0px;margin-top:0px;padding-top:10px;font-weight:normal;"))
                 "Oliver Flatt")
             (h2 (@ (style "font-weight:normal;font-size:large")) "The future of art is the dynamic, interactive medium."))))
           
           ,(menu name)
           ;;now put in the div that will hold all the posts
           ;; the container holds a list of the file names for the posts
           (div
            (@ (class "container") (data-postlist ,filenamestring)))
           (div (@ (style "width:100%"))
                (center (p "email me: oflatt@gmail.com"))))
           ;; load more navtext
           (h1 (@ (style ,(string-append "width:8%;font-size:10px;color:rgb(100,100,100);position:fixed;bottom:20px;right:0;cursor:default;visibility:hidden"))
                  (onmouseenter "texthover(this)")
                  (onmouseout "textoff(this)")
                  (onclick "loadnew()")
                  (id "load more"))
               "Load More"))))

(define index-file-port (open-output-file "../docs/index.html" #:exists 'replace))

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
  (list
    (build-post "How Implementations of the Persistent Data Type HAMT with Varying Node Sizes Compare
in Performance When Implemented in Python"
                 "" "2017" "hamt python.pdf" hamt-abstract "")
    (build-post "Mathematically Generating Sound Waves for Music" "" "2016"
                 "generating-sound.pdf" sound-abstract ""))
  "papers")
 index-file-port)

(close-output-port index-file-port)

(define space-orbs-description
  "An online multiplayer first person shooter that is unique because the perspective of the player is not relative
to any one axis. Rotation of the player's perspective is based only on the current orientation of the player so
that it is more like space. Currently there is no dedicated server, so to play you must run one yourself.")

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

(define projects-file-port (open-output-file "../docs/projects.html" #:exists 'replace))

(write-html
 (page
  (list
    (build-post "Bearly Dancing" "Python, with the library Pygame" "2016-present"
                 "https://github.com/oflatt/bearlydancing" bearly-dancing-description "" "http://bearlydancing.com" "none"
                 "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/g6SlOlGsGdE?rel=0&autoplay=1&mute=1&amp&loop=1&controls=0&playlist=g6SlOlGsGdE;showinfo=0&amp' frameborder='0' allowfullscreen></iframe></div>")
    (build-post "Gravigon" "Javascript, HTML" "2018"
                 "https://github.com/oflatt/portfolio/tree/master/gravigon" "Play with gravity and visualize floating point error with newton's method." "gravigon.gif" "gravigon.html" "none") ;; TODO add gravigon page link
    (build-post "Chinese Remainder Algorithm Visualized" "Java" "2018"
                 "https://github.com/oflatt/chinese-remainder-algorithm-visualized" "A visualization and lecture on Chinese Remainder Theorem using an example problem."
                 "" "none" "none"
                 "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe width='950' height='540'  src='https://www.youtube.com/embed/s0hg4ONFP6I?rel=0&amp;showinfo=0&amp' frameborder='0' allowfullscreen></iframe></div>")
    (build-post "Predetermined- Randomly Generated Art" "Processing.js" "2017"
                 "https://github.com/oflatt/predetermined"
                 "An art work that explores using hitboxes to determine the movemet of a turtle. Converted to javascript using Processing.js."
                 "none" "predetermined.html")
    (build-post "This Website" "TypeScript, HTML (Racket html-writing), CSS" "2017-present"
                 "https://github.com/oflatt/portfolio" "A portfolio of my work in Computer Science. It was written
in Racket and generates the html by passing an s-expression to the html-writing library. It passes W3C CSS
validation."
                 "thiswebsitegrey.png")
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
  `(script (@ (src "processing.js"))))
 projects-file-port)

(close-output-port projects-file-port)

(define great-camps-description
  "I volunteered to help teach at the at the University of Utah GREAT summer camps for two years in a row.
The first summer I taught middle schoolers taking that processing camp for six weeks, and took the Arduino camp
myself. The second summer I taught in the Python game development camp for three weeks. The animation above is of
one of the student’s finished space invaders game in the camp.")

(define racket-explanation
  "Many of my projects are in Racket, a powerful functional programming language. Because of my interest in Racket
and programming in general, I attend RacketCon events. I have also been to two
Strange Loop conferences.")

(define sonic-pi-explanation
  "I had the opportunity to participate in a unique live coding camp for a week held in Cambridge, England.
I learned the basics of programming in Sonic Pi to make music, and enjoyed experimenting with randomness.
This helped inspire me to work on randomly generated music for Bearly Dancing.")

(define experiences-file-port (open-output-file "../docs/experiences.html" #:exists 'replace))
(write-html
 (page
  (list
    (build-post "GREAT Camp Volunteer Work" "Python" "2016-2017"
                 "https://www.cs.utah.edu/~dejohnso/GREAT" great-camps-description
                 "space-invaders-demo.gif")
    (build-post "RacketCon" "Racket" "2015-present, annually"
                 "https://racket-lang.org" racket-explanation "racket.jpg")
    (build-post "Sonic Pi Live Coding Camp" "Sonic Pi" "2015"
                "http://sonic-pi.net/" sonic-pi-explanation "" "none" "none"
                "<div margin-top='0px' margin-bottom='0px' padding-top='10px'> <iframe src='https://www.youtube.com/embed/RH-80LOBvLE?rel=0&autoplay=1&loop=1&mute=1&amp;showinfo=0&amp' frameborder='0' allowfullscreen></iframe></div>"))
    "experiences")
 experiences-file-port)

(close-output-port experiences-file-port)

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

(close-output-port tessa-file-port)
 
