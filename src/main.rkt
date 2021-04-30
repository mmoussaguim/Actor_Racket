#lang racket

(require racket/contract)

(require "actor.rkt")
(require "world.rkt")
(require "display.rkt")
(require "runtime.rkt")

(require  (prefix-in lux: lux)
          (prefix-in raart: raart))

(define world-rows 25)
(define world-cols 60)


(define actor1
  (make-actor 'ally-ship 9 1))

(define actors (list actor1))
(define initial-mail
  (list '()))

(define initial-world
  (world actors))

(define initial-runtime
  (runtime initial-world initial-mail 0))

(define (initial-world-state)
  (game initial-runtime))


;; Starter function
(define (start-application)
  (lux:call-with-chaos
   (raart:make-raart)
   (lambda () (lux:fiat-lux (initial-world-state))))
  (void))

(start-application)
