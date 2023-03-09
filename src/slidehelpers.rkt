#lang racket

(require pict pict/color)

(provide (all-defined-out))
(define BORDERWIDTH 3)

(define (superimpose pictb picta x y)
  (lt-superimpose
    (vl-append (blank 0 (if (< y 0) (- y) 0))
      (ht-append (blank (if (< x 0) (- x) 0) 0) picta))
    (vl-append (blank 0 (if (> y 0) y 0))
      (ht-append (blank (if (> x 0) x 0) 0) pictb))))

(define (autoarrow node1 node2 contents #:alpha [alpha 1] #:arrow-size [arrow-size 25] #:style [style #f] #:line-width [line-width (* 2 BORDERWIDTH)] #:finder1 [finder1 #f] #:finder2 [finder2 #f] #:start-angle [start-angle #f] #:end-angle [end-angle #f] #:label [label (blank)] #:x-adjust-label [x-adjust-label 0] #:y-adjust-label [y-adjust-label -10] #:color [color #f])
  (define-values (a b) (lt-find contents node1))
  (define-values (c d) (lt-find contents node2))
  (match-define (list afind1 afind2)
    (cond
      [(> c (+ a (pict-width node1))) ;; right
       (list rc-find lc-find)]
      [(< (+ c (pict-width node2)) a) ;; left
       (list lc-find rc-find)]
      [(and (> d (+ b (pict-height node1)))) ;; underneath
       (list cb-find ct-find)]
      [(and (< (+ d (pict-height node2)) b)) ;; above
       (list ct-find cb-find)]
      [else
       (list lc-find rc-find)])) ;; default left I guess
  (define find1 (if finder1 finder1 afind1))
  (define find2 (if finder2 finder2 afind2))
  
  (pin-arrow-line arrow-size contents
   node1 find1
   node2 find2
   #:alpha alpha
   #:style style
   #:start-pull 0.075
   #:end-pull 0.075
   #:line-width line-width
   #:start-angle start-angle
   #:end-angle end-angle
   #:label label
   #:x-adjust-label x-adjust-label
   #:y-adjust-label y-adjust-label
   #:color color
   ))

