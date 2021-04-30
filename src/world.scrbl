#lang scribble/manual

@(define-syntax-rule (sample a . text)
   (codeblock #:context #'a #:keep-lang-line? #f
     "#lang scribble/base" "\n" a . text))

@(define (result . text) (apply nested #:style 'inset text))
@(define sep @hspace[1])
@(define sub*section subsection)


@title{World}


The file @filepath{world.rkt} contains the functions that help manipulate the type world.

@section[#:tag "world-struct"]{World structure}
The structure world contains a list of actors. It is defined as follows:
          @codeblock|{
            (world  actors)

            actors : list-actor?
            }|

@section[#:tag "world-predicates"]{Predicates}

@codeblock|{
 (list-actor? l) -> boolean
 l: any/c}|

Predicate to check if @italic{l} is a list of actors or not.


@section[#:tag "world-functions"]{Wolrd functions}
A function to send a message to a specific actors from the world.
if the type = all the message will be sent to all actors in the world
          @codeblock|{
            (world-send wld msg type) -> world?
            wld: world?
            mgs : msg?
            type: symbol?
          }|

A function to add an actor into a world structure
          @codeblock|{
            (world-add-actor wld l) -> world?
            wld: world?
            l : concrete-actor?
          }|

A function that verifies the collisions and sending the message Collide
          @codeblock|{
            (world-collision wld)-> world?
            wld : world?
          }|
          
A function to update the actors in a world structure
          @codeblock|{
            (world-update wld) -> world?
            wld: world?
          }|
