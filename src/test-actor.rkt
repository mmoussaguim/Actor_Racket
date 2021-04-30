#lang racket

(require rackunit)
(require rackunit/text-ui)

(require "actor.rkt")

(define test-actor
  (test-suite
   "Tests file for actor.rkt"
   (test-case
    "Test on function actor-location"
    (let* ([actor1 (concrete-actor "A" '(0 . 0) '() 'ally-ship 20)]
           [actor2 (concrete-actor "B" '(3 . 5) '() 'ally-ship 20)]
           [actor3 (concrete-actor "C" '(1 . 2) '((move 1 0) (move 1 1)) 'ally-ship 20)])      
      (check-equal? (actor-location actor1) '(0 . 0))
      (check-equal? (actor-location actor2) '(3 . 5))
      (check-equal? (actor-location actor3) '(1 . 2))))
   
   (test-case
    "Test on function actor-send"
    (let* ([actor1 (concrete-actor "A" '(0 . 0) '() 'ally-ship 20)]
           [actor2 (concrete-actor "B" '(1 . 2) '((move 1 0) (move 1 1)) 'ally-ship 20)]
           [actor3 (actor-send actor1 '(move 1 0))]
           [actor4 (actor-send actor1 '(move 1 0))]
           [actor5 (actor-send actor2 '(move 0 1))])
      (check-equal? (length (actor-mailbox actor1)) 0)
      (check-equal? (length (actor-mailbox actor2)) 2)
      (check-equal? (length (actor-mailbox actor3)) 1)
      (check-equal? (length (actor-mailbox actor4)) 1)
      (check-equal? (length (actor-mailbox actor5)) 3)
      (check-equal? (caddr (actor-mailbox actor5)) '(move 0 1))))
   
   (test-case
    "Test on function actor-update"
    (let* ([actor1 (concrete-actor "A" '(0 . 0) '() 'ally-ship 20)]
           [actor2 (concrete-actor "B" '(1 . 2) '((move 1 0) (move 1 1)) 'ally-ship 20)]
           [actor3 (concrete-actor "C" '(1 . 3) '((collide)) 'ally-ship 20)]
           [actor4 (actor-send actor1 '(move 1 0))]
           [actor5 (car (actor-update actor4))]
           [actor6 (car (actor-update (actor-send actor2 '(move 0 1))))]
           [actor7 (car (actor-update (actor-send actor1 '(shoot "-"))))]
           [actor8 (cadr (actor-update (actor-send actor1 '(shoot "-"))))])
      (check-equal? (actor-location actor1) '(0 . 0))
      (check-equal? (actor-location actor2) '(1 . 2))
      (check-equal? (actor-location actor4) '(0 . 0))
      (check-equal? (actor-location actor5) '(1 . 0))
      (check-equal? (actor-location actor6) '(3 . 4))
      (check-equal? (actor-location actor7) '(0 . 0))
      (check-equal? (concrete-actor-name actor8) "-")
      (check-equal? (actor-location actor8) '(0 . 1))
      (check-pred null? (actor-update actor3))))))
   

(run-tests test-actor)
