#lang scribble/manual

@title{Actor}

This page shows how actors are implemented and the functions that modify them.

@section{Structure}

@racketblock[
 (concrete-actor name
                 location
                 mailbox
                 type
                 health)
 name: raart?
 location: pair?
 mailbox: list-msg?
 type: symbol?
 health: integer?
]

Creates a @italic{concrete-actor}.

The @italic{name} argument is the raart shown by the buffer.

The @italic{location} argument is a pair indicating the location of the actor.

The @italic{mailbox} argument is a list of messages that are sent to the actor in order to change its state.

The @italic{type} argument is a symbol indicating the type of the actor in order to ease manipulating the actors and know what message send.
 There are four type of actors :

    @itemlist[@item{ally ship,}
          @item{ally missile,}
          @item{ennemy ship,}
          @item{ennemy missile.}
          @item{obstacle,}
          @item{bonus.}]

The @italic{health} argument is a number that represents the remaining points before death.

@section{Predicates}

@racketblock[
 (msg? msg) -> boolean
 msg: any/c]

Predicate saying if @italic{msg} is a message or not.

@racketblock[
 (list-msg? l) -> boolean
 l: any/c]

Predicate to tell if @italic{l} is a list of messages or not.

@racketblock[
 (list-actor? l) -> boolean
 l: any/c]

Predicate to check if @italic{l} is a list of actors.

@racketblock[
 (actor-type? actor
              type) ->boolean
 actor: concrete-actor?
 type: symbol?]

Predicate saying if the type of the @italic{actor} and @italic{type} are the same.

@section{functions}

This part presents many functions that deal with actors.

@subsection{Functions to ease access to the structure fields}

@racketblock[
 (actor-mailbox actor) -> list-msg?
 actor: concrete-actor?]

A function to return the mailbox of @italic{actor}.

@racketblock[
 (actor-location actor) -> pair?
 actor: concrete-actor?]

A function that returns the location of @italic{actor}.

@racketblock[
 (actor-type actor) -> symbol?
 actor: concrete-actor?]

A function that returns the type of @italic{actor}.

@racketblock[
 (actor-health actor) -> integer?
 actor: concrete-actor?]

A function to return the health field of @italic{actor}.

@subsection{Functions that modify actors}

@racketblock[
 (actor-send actor
             message) -> concrete-actor?
 actor: concrete-actor?
 message: msg?]

A function that sends a message to an actor.

The @italic{actor} parameter indicate the actor recepient.

The @italic{message} is the message sent.

@racketblock[
 (actor-update actor) -> list-actor?
 actor: concrete-actor?]

A function to empty the mailbox and update the actor consequently and return a list of actors containing the one update and the ones that might
have been created during the update.

The @italic{actor} parameter indicates the actor updated.

@racketblock[
 (make-actor type r c) -> concrete-actor?
 type : symbol?
 r : integer?
 c : integer?]

A function that creates an actor of type @italic{type} at row @italic{r} and column @italic{c}
