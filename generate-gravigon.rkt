#lang racket
(require html-writing html-parsing)

(define index-file-port (open-output-file "gravigon.html" #:exists 'replace))

(write-html
 `((html
    (head
     (title "gravigon")
     (script (@ (src "gravigon/mainscript.js")))
     (script (@ (src "gravigon/menu.js")))
     (script (@ (src "gravigon/polygonhandler.js")))
     (link (@ (rel "stylesheet")
              (type "text/css")
              (href "gravigon/style.css"))))
    (body
     (@
      (style "padding:0;margin:0")
      (onkeydown "onKey(event)")
      (onload "onLoad()"))
     (div
      (@ (id "myNav")
         (class "overlay"))
      (a
       (@ (href "javascript:void(0)")
          (class "closebtn")
          (onclick "closeNav()"))
       "\u00D7")
      (div
       (@
        (class "overlay-content")
        (id "overlay-content"))))
     (canvas
      (@ (id "background")
         (color "black")
         (style "position:absolute; padding:0;margin:0;top:0;left:0;z-index:0")
         (width "100%")
         (height "100%")))
     (canvas
      (@ (id "foreground")
         (oncontextmenu "return false;")
         (style "position:absolute; padding:0;margin:0;top:0;left:0;z-index:1")
         (width "100%")
         (height "100%")
         (onmousemove "onMouseMove(event)")
         (onresize "resizeBackground()")
         (onmousedown "onMouseDown(event)")
         (onmouseup "onMouseUp(event)")))
     (span
      (@ (style "position:absolute; left:1%; top:0.5%; font-size:30px;color:rgb(150,150,150);cursor:pointer;z-index:2")
         (onclick "openNav()"))
      "\u2630")
     (div
      (@ (style "position:absolute;z-index:4")
         (id "equation div"))
      (span
       (@ (style "margin-left:50%;color:white;transform:translate(-50%,0%)"))
       "equation hereasdfasdfasdf")))))
 index-file-port)

(close-output-port index-file-port)
