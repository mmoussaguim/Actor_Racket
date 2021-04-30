#lang scribble/manual

@(define-syntax-rule (sample a . text)
   (codeblock #:context #'a #:keep-lang-line? #f
     "#lang scribble/base" "\n" a . text))

@(define (result . text) (apply nested #:style 'inset text))
@(define sep @hspace[1])
@(define sub*section subsection)


@title{Runtime}


The file @filepath{runtime.rkt} contains the functions that change actors on every tick.

@section[#:tag "runtime-struct"]{Runtime structure}
Here is the structure runtime representing a state of world
          @codeblock|{
            (runtime  world
                      messages
                      tick )
            world : world?
            messages : list-msg?
            tick : integer?
            }|
@section[#:tag "runtime-functions"]{Runtime functions}
A function that return the list of actors in runtime
          @codeblock|{
            (runtime-actors rt) -> list-actor?
            rt : runtime?
          }|

Puts a list of messages in a new structure runtimes
          @codeblock|{
            (runtime-receive rt msgs) -> list-actor?
            rt : runtime?
            msgs : list-msg?
          }|

A fonction that send different messages in runtime-messages to a world of actors
          @codeblock|{
            (runtime-send rt) -> runtime?
            rt : runtime?
          }|

A fonction that update the tick
          @codeblock|{
            (runtime-update rt)-> runtime?
            rt : runtime?
          }|
