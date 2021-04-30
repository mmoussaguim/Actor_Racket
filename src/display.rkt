#lang racket
(require racket/contract)
(require "actor.rkt")
(require "world.rkt")
(require "runtime.rkt")

(require 2htdp/universe)

(require
          (prefix-in ct: charterm)
          (prefix-in lux: lux)
          (prefix-in raart: raart))

(require racket/cmdline)

(define fps (make-parameter "3.0"))
(command-line #:program "compiler"
              #:once-each

              [("-f" "--FPS") value "" (fps value)])
(define b (exact->inexact (string->number (fps))))

(define rows 60)
(define cols 80)
(define world-rows 25)
(define world-cols 60)
(define title " ACTING SHOOTING STAR ")


(struct game (run)
        #:methods lux:gen:word
        [(define (word-fps w)      ;; FPS desired rate
           b)
         (define (word-label s ft) ;; Window label of the application
           "Acting Shooting Star")
         (define (word-event w e)  ;; Event Handler
           (match-define (game run) w)
           (match e
             ["<left>"  (game (runtime-receive run (list (list '(move 0 -1) 'ally-ship))))]
             ["<right>" (game (runtime-receive run (list (list '(move 0 1) 'ally-ship))))]
             ["<up>"    (game (runtime-receive run (list (list '(move -1 0) 'ally-ship))))]
             ["<down>"  (game (runtime-receive run (list (list '(move 1 0) 'ally-ship))))]
             [" "       (game (runtime-receive run (list (list (list 'shoot (raart:text "-")) 'ally-ship))))]
             ["q" #f]
             [_    w];; Otherwise do nothing
         ))
         (define (word-output w)      ;; What to display for the application
           (match-define (game run) w)

           (raart:crop 0 cols 0 rows
                 (raart:vappend
                  #:halign 'center
                  (raart:text (~a "Hello! Enjoy it!"))
                  (raart:text (~a "Press the arrow keys on the keyboard to move your player and Press q to quit."))
                  (raart:happend (raart:fg 'brgreen (raart:text "* ")) (raart:text (~a "Gives you +3 in Health  "))
                  (raart:fg 'yellow (raart:text "# ")) (raart:text (~a "Gives you -5 in Health    "))
                  (raart:fg 'blue (raart:text "< ")) (raart:text (~a "Gives you -5 in Health")))
                  (raart:matte 60 3 (raart:frame (raart:fg 'red (raart:text (~a title )))))
                  (raart:frame (for/fold ([c (raart:blank  world-cols world-rows)])
                                         ([actor (in-list (runtime-actors run))])
                                 (raart:crop 0 world-cols 0 world-rows
                                             (raart:place-at c
                                                             (car (actor-location actor))
                                                             (cdr (actor-location actor))
                                                             (concrete-actor-name actor)))))
                 (raart:happend (raart:text (~a "Health: " (ally-health run) " Score: " (runtime-tick run))))

                 )))

          (define (word-return w) ;; What to return if the game is over
            (match-define (game run) w)
            (raart:fg 'red (raart:text "GAME OVER"))
            (raart:text (~a "You got a score = " (runtime-tick run))))

         (define (word-tick w)        ;; Update function after one tick of time
           (match-define (game run) w)
           (define m-a-m (list '(move 0 2) 'ally-missile))
           (define m-e-m (list '(move 0 -1) 'ennemy-missile))
           (define m-e-s (list '(move 0 -1) 'ennemy-ship))
           (define m-b (list '(move 0 -1) 'bonus))
           (define m-o (list '(move 0 -1) 'obstacle))
           (define messages (list m-a-m m-e-s m-b m-o))
           (define run1 (runtime-receive run messages))
           (define run2 (runtime-send run1))
           (define run3 (runtime-update run2))
           (game (runtime-add-actor run3 (generate-actor (runtime-tick run3)))))


         ])

(provide (struct-out game))
