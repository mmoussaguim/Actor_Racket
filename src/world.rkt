#lang racket

(require racket/contract)

(require "actor.rkt")

(define world-rows 25)
(define world-cols 60)

;;; PREDICATES
;; Predicate returning true if l is a list of concrete-actor

(define (list-actor? l)
  (if (null? l)
      #t
      (and (concrete-actor? (car l)) (list-actor? (cdr l)))))

;;; Functions

;;Function that verify if there is a collision between actor1 and actor1


(define (will-collide? actor1 actor2)
  (cond

    ;; Return 1 if the collision happens between a ennemy and a ally-missile
  [(and (is-ennemy? actor2) (is-ally-miss? actor1) 
  (< (abs (- (cdr (actor-location actor2)) (cdr (actor-location actor1)))) 2) 
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 1]
  [(and (is-ennemy? actor1) (is-ally-miss? actor2) 
  (< (abs (- (cdr (actor-location actor1)) (cdr (actor-location actor2)))) 2)
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 1]

   ;;Return 2 if the collision happens between a ennemy and ally-ship 
  [(and (is-ennemy? actor2) (is-ally-ship? actor1) 
  (< (abs (- (cdr (actor-location actor2)) (cdr (actor-location actor1)))) 2) 
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 2]
  [(and (is-ennemy? actor1) (is-ally-ship? actor2) 
  (< (abs (- (cdr (actor-location actor1)) (cdr (actor-location actor2)))) 2)
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 2]

   ;;Return 3 if the collision happens between a ally-ship and a obstacle
  [(and (is-obstacle? actor2) (is-ally-ship? actor1) 
  (< (abs (- (cdr (actor-location actor2)) (cdr (actor-location actor1)))) 2) 
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 3]
  [(and (is-obstacle? actor1) (is-ally-ship? actor2) 
  (< (abs (- (cdr (actor-location actor1)) (cdr (actor-location actor2)))) 2)
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 3]

   ;; Return 4 if the collision happens between a bonus and a ally-ship
  [(and (is-bonus? actor2) (is-ally-ship? actor1) 
  (< (abs (- (cdr (actor-location actor2)) (cdr (actor-location actor1)))) 2) 
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 4]
  [(and (is-bonus? actor1) (is-ally-ship? actor2) 
  (< (abs (- (cdr (actor-location actor1)) (cdr (actor-location actor2)))) 2)
  (= (car (actor-location actor2)) (car (actor-location actor1)))) 4]

   ;; Else return 0
  [else 0]))


;;Function that verify if act will collide with another in the list actors
;;then send a message 'Collide-*** to the both actors

(define (actors-collision act actors l)
  (if (null? actors) (append (list act) l)
      (let ([q (will-collide? act (car actors))])
        (cond
          [(= q 1) (append (list (actor-send act '(collide)))
                           l (list (actor-send (car actors) '(collide))) (cdr actors))]
          
          [(= q 2) (append (list (actor-send act '(collide-ennemy)))
                           l (list (actor-send (car actors) '(collide-ennemy))) (cdr actors))]
          
          [(= q 3) (append (list (actor-send act '(collide-obstacle)))
                           l (list (actor-send (car actors) '(collide-obstacle))) (cdr actors))]
          
          [(= q 4) (append (list (actor-send act '(collide-bonus)))
                           l (list (actor-send (car actors) '(collide-bonus))) (cdr actors))]
          
          [else (actors-collision act (cdr actors) (append l (list (car actors))))]
      ))))

;; This function eliminates the actors who leave the framework
(define (destroy-actor l)
  (cond
    [(null? l) '()]
    [(and (zero? (cdr (actor-location (car l))))
          (or (symbol=? (actor-type (car l)) 'ennemy-ship)
              (symbol=? (actor-type (car l)) 'bonus)
              (symbol=? (actor-type (car l)) 'obstacle)))
     (destroy-actor (cdr l))]
    [(and (or (= (car (actor-location (car l))) 0)
              (= (car (actor-location (car l))) 18)  ;; 18 = world-rows - 7
              (= (cdr (actor-location (car l)))  0))
           (symbol=? (actor-type (car l)) 'ally-ship))
      (destroy-actor (cdr l))]
    [else     (cons (car l) (destroy-actor (cdr l)))]))

;;STRUCTURE
;; structure world representing actors
(struct world (actors))


;;;FUNCTIONS

;; Function that return health of ally-ship 

(define (ally-health-world wld)
  (letrec ([aux (lambda (l)
                  (if (null? l) '()
                      (if (is-ally-ship? (car l))
                          (actor-health (car l))
                          (aux (cdr l)))))])
    (aux (world-actors wld))))
                    

;;This function add actors l in the world wld

(define (world-add-actor wld l)
  (world (foldl cons l (world-actors wld))))

;; Verify the collisions and sending msg Collide-***

(define (world-collision wld)
  (letrec ([aux (lambda (l)
                  (cond
                  [(< (length l) 2) l]
                  [(let([res (actors-collision (car l) (cdr l) '())]) 
                  (cons (car res) (aux (cdr res))))]
                  ))])
    (world (aux (world-actors wld)))))

;; Send a message to a specific actors from the world - (world*msg*type) -> world
;; if the type = all the message will be sent to all actors in the world
(define (world-send wld msg type)
  (letrec ([aux (lambda (l msg type)
                  (cond
                  [(or (null? l) (null? msg)) l]
                  [(symbol=? type 'all) (cons (actor-send (car l) msg) (aux (cdr l) msg type))]
                  [(actor-type=? (car l) type) (cons (actor-send (car l) msg) (aux (cdr l) msg type))]
                  [else (cons (car l) (aux (cdr l) msg type))]
                  ))])
    (world (aux (world-actors wld) msg type))))



;; Updates the actors in the world - world -> world
(define (world-update wld)
  (letrec ([aux (lambda (l)
                  (if (null? l)
                      '()
                      (append (actor-update (car l))
                            (aux (cdr l)))))])
    (world-collision (world (aux (destroy-actor (world-actors wld)))))))


(provide (struct-out world)
         (contract-out
          [world-send (-> world? msg? symbol? world?)]
          [world-add-actor (-> world? list-actor? world?)]
          [ally-health-world (-> world? real?)]
          [actors-collision (-> concrete-actor? list-actor? list? list-actor?)]
          [world-collision (-> world? world?)]
          [world-update (-> world? world?)]))