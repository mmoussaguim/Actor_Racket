#lang racket

(require racket/contract)
(require (prefix-in raart: raart))
(define scribblings '(("actor.scrbl" (multi-page))))

;;WORLD DIMENSIONS
(define world-rows 25)
(define world-cols 60)

;;; STRUCTURE CONCRETE-ACTOR
;; Structure representing actors

(struct concrete-actor (name location mailbox type health))


;;; PREDICATES
;; Predicate returning true if msg is a message
(define (msg? msg)
  (and (list? msg) (not (null? msg)) (symbol? (car msg))))

;; Predicate defining list of msg
(define (list-msg? l)
  (if (null? l)
      #t
      (and (msg? (car l)) (list-msg? (cdr l)))))

;; Predicate defining list of actor
(define (list-actor? l)
  (if (null? l)
      #t
      (and (concrete-actor? (car l)) (list-actor? (cdr l)))))

;; Predicate saying if the first msg       - actor * symbol -> bool
;; of the mailbox is the one in parameter
(define (current-msg=? actor msg)
  (symbol=? (caar (actor-mailbox actor)) msg))

;; Predicate saying if the type is the     - actor * symbol -> bool
;; the same given in parameters
(define (actor-type=? actor type)
  (symbol=? (concrete-actor-type actor) type))


;; Predicate saying if actor is a ennemy     - actor -> bool
(define (is-ennemy? actor)
  (or (symbol=? (actor-type actor) 'ennemy-ship) (symbol=? (actor-type actor) 'ennemy-missile)))


;; Predicate saying if actor is a ally-ship     - actor -> bool
(define (is-ally-ship? actor)
  (actor-type=? actor 'ally-ship))

;; Predicate saying if actor is a ally-missile    - actor -> bool
(define (is-ally-miss? actor)
  (actor-type=? actor 'ally-missile))

;; Predicate saying if actor is a obstacle    - actor -> bool
(define (is-obstacle? actor)
  (actor-type=? actor 'obstacle))

;; Predicate saying if actor is a bonus     - actor -> bool
(define (is-bonus? actor)
  (actor-type=? actor 'bonus))

;;;FUNCTIONS

;;Returns the actor name
(define actor-name concrete-actor-name)

;; Returns the actor location              - actor -> location
(define actor-location concrete-actor-location)

;; Returns the actor mailbox               - actor -> list of msg
(define actor-mailbox concrete-actor-mailbox)

;; Return the actor type                   - actor -> symbol
(define actor-type concrete-actor-type)

;; Return the actor health
(define actor-health concrete-actor-health)

;;Function creating an actor with location (r . c)
(define (make-actor type r c)
  (cond
    [(symbol=? type 'ally-ship) (concrete-actor (raart:fg 'red (raart:text ">>")) (list* r c) '() type 20)]
    [(symbol=? type 'ennemy-ship) (concrete-actor (raart:fg 'blue (raart:text "<")) (list* r c) '() type -2)]
    [(symbol=? type 'obstacle) (concrete-actor (raart:fg 'yellow (raart:text "#")) (list* r c) '() type -5)]
    [(symbol=? type 'bonus) (concrete-actor (raart:fg 'brgreen (raart:text "*")) (list* r c) '() type 3)]))

;;Function that generate actor on a given tick

(define (generate-actor tick)
(cond
  [(equal? (modulo tick 6) 0)
    (list (make-actor 'obstacle (random 2 4) world-cols)
          (make-actor 'obstacle (+ 12 (random 1 4)) world-cols)
          (make-actor 'obstacle 1 world-cols)
          (make-actor 'obstacle 17 world-cols)
          (make-actor 'bonus (random 5 12) world-cols))]
  [(equal? (modulo tick 2) 0)
   (list (make-actor 'obstacle 1 world-cols)
         (make-actor 'obstacle 17 world-cols)
         (make-actor 'ennemy-ship (random 5 12) world-cols))]
  [else '()]))



;;; FUNCTIONS

;;;Send
;; Send a message to an actor              - (actor*msg) -> actor
;; and returns an actor with a new message
(define (actor-send actor message)
  (concrete-actor (concrete-actor-name actor)
                  (actor-location actor)
                  (append (actor-mailbox actor) (list message))
                  (actor-type actor)
                  (actor-health actor)))


;;; Move
;; Return a pair which is the sum          - pair * list -> pair
;; of a pair and a list of two elements
(define (sum-pair-list p l)
  (cons (+ (car p) (car l)) (+ (cdr p) (cadr l))))

;; Return an actor which is the actor      - actor * pair -> actor
;; taken in parameters moved by the movement mvnt
(define (actor-move actor mvnt)
  (concrete-actor (concrete-actor-name actor)
                  (sum-pair-list (actor-location actor) mvnt)
                  (cdr (actor-mailbox actor))
                  (actor-type actor)
                  (actor-health actor)))


;;; Shoot
;; Return a list of two actor               -actor -> list of actor
;; one is the same taken in parameter and the second one
;; is an actor of type missile
(define (actor-shoot actor)
  (cond
    [(actor-type=? actor 'ally-ship) (list (concrete-actor (concrete-actor-name actor)
                                                           (actor-location actor)
                                                           (cdr (actor-mailbox actor))
                                                           (actor-type actor)
                                                           (actor-health actor))
                                           (concrete-actor (cadar (actor-mailbox actor))
                                                           (sum-pair-list (actor-location actor) '(0 1))
                                                           '()
                                                           'ally-missile
                                                           0))]
    [(actor-type=? actor 'ennemy-ship) (list (concrete-actor (concrete-actor-name actor)
                                                           (actor-location actor)
                                                           (cdr (actor-mailbox actor))
                                                           (actor-type actor)
                                                           (actor-health actor))
                                           (concrete-actor (cadar (actor-mailbox actor))
                                                           (sum-pair-list (actor-location actor) '(0 -1))
                                                           '()
                                                           'ennemy-missile
                                                           -2))]
    [else (list actor)]))


;;; Collide
;; Return a list of actor than             - actor -> list of actor
;; can be empty
(define (actor-collide actor)
  '())

(define (actor-collide-ennemy actor)
  (if (is-ennemy? actor) '()
      (list (concrete-actor
       (actor-name actor)
       (actor-location actor)
       (cdr (actor-mailbox actor))
       (actor-type actor)
       (- (actor-health actor) 2)))))

(define (actor-collide-obstacle actor)
  (if (is-obstacle? actor) '()
      (list (concrete-actor
       (actor-name actor)
       (actor-location actor)
       (cdr (actor-mailbox actor))
       (actor-type actor)
       (- (actor-health actor) 5)))))

(define (actor-collide-bonus actor)
  (if (is-bonus? actor) '()
      (list (concrete-actor
       (actor-name actor)
       (actor-location actor)
       (cdr (actor-mailbox actor))
       (actor-type actor)
       (+ (actor-health actor) 3)))))
;;; Update
;; Handles the actor list of messages      - actor -> list of actor
;; and returns a new updated list of actor
;; with an empty mailbox
(define (actor-update actor)
  (cond
    [(null? (actor-mailbox actor)) (list actor)]
    [(current-msg=? actor 'move) (actor-update (actor-move actor (cdar (actor-mailbox actor))))]
    [(current-msg=? actor 'collide) (actor-collide actor)]
    [(current-msg=? actor 'collide-ennemy) (actor-collide-ennemy actor)]
    [(current-msg=? actor 'collide-obstacle) (actor-collide-obstacle actor)]
    [(current-msg=? actor 'collide-bonus) (actor-collide-bonus actor)]
    [(current-msg=? actor 'shoot) (let ([l (actor-shoot actor)])
                                    (append (actor-update (car l)) (cdr l)))]))


;; Functions and structures provide by this file
(provide (struct-out concrete-actor)
         (contract-out
          [msg? (-> any/c boolean?)]
          [list-msg? (-> any/c boolean?)]
          [list-actor? (-> any/c boolean?)]
          [actor-mailbox (-> concrete-actor? list-msg?)]
          [actor-location (-> concrete-actor? pair?)]
          [make-actor (-> symbol? integer? integer? concrete-actor?)]
          [generate-actor (-> integer? list-actor?)]
          [actor-type (-> concrete-actor? symbol?)]
          [actor-health (-> concrete-actor? real?)]
          [actor-type=? (-> concrete-actor? symbol? boolean?)]
          [is-ennemy? (-> concrete-actor? boolean?)]
          [is-ally-miss? (-> concrete-actor? boolean?)]
          [is-ally-ship? (-> concrete-actor? boolean?)]
          [is-obstacle? (-> concrete-actor? boolean?)]
          [is-bonus? (-> concrete-actor? boolean?)]
          [actor-send (-> concrete-actor? msg? concrete-actor?)]
          [actor-update (-> concrete-actor? list-actor?)]))
