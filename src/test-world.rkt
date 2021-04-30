#lang racket

(require rackunit)
(require rackunit/text-ui)

(require "actor.rkt")
(require "world.rkt")

(define test-actor
  (test-suite
   "Tests file for world.rkt file"
   (test-case
    "Test on function world-send & actors-collision"
    (let* ([actor1 (concrete-actor "A" '(0 . 6) '() 'ally-missile 0)]
           [actor2 (concrete-actor "B" '(0 . 2) '() 'ally-missile 0)]
           [actor3 (concrete-actor "C" '(0 . 3) '() 'ennemy-ship -2)]
           [actor4 (concrete-actor "D" '(0 . 7) '() 'ennemy-ship -2)]
           [actor5 (concrete-actor "E" '(0 . 8) '() 'ennemy-ship -2)]
           [actor6 (concrete-actor "B" '(0 . 1) '() 'ally-ship 20)]           
           [actors1 (list actor1 actor2 actor3 actor4 actor5)]
           [world1 (world actors1)]
           [world2 (world-send world1 '(move 1 0) 'ally-missile)]
           [world3 (world-send world2 '(move 2 2) 'all)]
           [actors2 (actors-collision (car actors1) (cdr actors1) '())]
           [world4 (world (list actor1 actor2 actor3 actor4))]
           [world5 (world-collision world4)])
      (check-true (list-msg? (actor-mailbox actor1)))
      ;;; Test On World-send
      (check-equal? (length (actor-mailbox (car (world-actors world2)))) 1)
      (check-equal? (length (actor-mailbox (caddr (world-actors world2)))) 0)
      (check-equal? (length (actor-mailbox (cadr (world-actors world3)))) 2)
      (check-equal? (length (actor-mailbox (caddr (world-actors world3)))) 1)
      ;;; Test on Actors-collision
      (check-equal? (length actors2 ) 5)
      (check-equal? (length (actor-mailbox (car actors2))) 1)
      (check-equal? (length (actor-mailbox (cadr actors2))) 0)
      (check-equal? (length (actor-mailbox (caddr actors2))) 0)
      (check-equal? (length (actor-mailbox (cadddr actors2))) 1)
      ;;;; Test on World-collision
      (check-equal? (length (world-actors world5)) 4)
      (check-equal? (length (actor-mailbox (car (world-actors world5)))) 1)
      (check-equal? (length (actor-mailbox (cadr (world-actors world5)))) 1)
      (check-equal? (actor-type (caddr (world-actors world5))) 'ennemy-ship)
      (check-equal? (length (actor-mailbox (caddr (world-actors world5)))) 1)
      (check-equal? (length (actor-mailbox (cadddr (world-actors world5)))) 1)
      ))
      
   (test-case
    "Test on function world-update"
    (let* ([actor1 (concrete-actor "A" '(1 . 1) '() 'ally-ship 20)]
           [actor2 (concrete-actor "B" '(3 . 5) '() 'ally-ship 20)]
           [actor3 (concrete-actor "C" '(2 . 2) '() 'ally-missile 0)]
           [world1 (world (list actor1 actor2 actor3))]
           [world2 (world-send world1 '(move 1 2) 'ally-missile)]
           [world3 (world-update world2)]
           [world4 (world-send world3 '(shoot "-") 'ally-ship)]
           [world5 (world-update world4)])
      (check-equal? (actor-location (car (world-actors world3))) '(1 . 1))
      (check-equal? (actor-location (cadr (world-actors world3))) '(3 . 5))
      (check-equal? (actor-location (car (world-actors world5))) '(1 . 1))
      (check-equal? (actor-location (cadr (world-actors world5))) '(1 . 2))
      (check-equal? (actor-location (caddr (world-actors world5))) '(3 . 5))
      (check-equal? (actor-location (cadddr (world-actors world5))) '(3 . 6))))
   ))

(run-tests test-actor)
