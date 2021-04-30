#lang racket

(require "actor.rkt")
(require "world.rkt")

(define scribblings '(("runtime.scrbl" (multi-page))))

;;STRUCTURE RUNTIME
;; structure runtime representing a state of world 
(struct runtime (world messages tick))

;;FUNCTIONS
;;Function that return the list of actors in runtime
(define (runtime-actors rt)
  (world-actors (runtime-world rt)))

;; Function that add  actors (list) in the runtime-world
(define (runtime-add-actor rt actor)
  (runtime (world-add-actor (runtime-world rt) actor) (runtime-messages rt) (runtime-tick rt)))

;; return health of the ally-ship

(define (ally-health rt)
  (ally-health-world (runtime-world rt)))

;; Put a list of messages in a new structure runtimes  runtime * list-msgs -> runtime 
(define (runtime-receive rt msgs)
  (cond
  [(or (= (length (runtime-messages rt)) 0) (and (= (length (runtime-messages rt)) 1) (null? (car (runtime-messages rt))))) 
  (runtime (runtime-world rt) msgs (runtime-tick rt))]
  [else (runtime (runtime-world rt) (append (runtime-messages rt) msgs) (runtime-tick rt))]
))

;; fonction that send the different messages in runtime-messages to a specific Actors from the world  runtime -> runtime
(define (runtime-send rt)
    (cond
    [(or (null? (runtime-world rt)) (null? (runtime-messages rt))) 
      (runtime (runtime-world rt) (runtime-messages rt) (runtime-tick rt))]
    [else (runtime-send
           (runtime (world-send (runtime-world rt)
                                (car (car (runtime-messages rt)))
                                (cadar (runtime-messages rt)))
                    (cdr (runtime-messages rt))
                    (runtime-tick rt)))
      ]))

;; fonction that update the tick   runtime -> runtime
(define (runtime-update rt)
    (runtime (world-update (runtime-world rt)) (runtime-messages rt) (add1 (runtime-tick rt))))

;; Functions and structures provided by this file

(provide (struct-out runtime)
         (contract-out
          [runtime-actors (-> runtime? list-actor?)]
          [runtime-receive (-> runtime? list? runtime?)]
          [runtime-add-actor (-> runtime? list-actor? runtime?)]
          [ally-health (-> runtime? real?)]
          [runtime-send (-> runtime? runtime?)]
          [runtime-update (-> runtime? runtime?)]))