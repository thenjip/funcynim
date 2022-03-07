##[
  The bread and butter of functional programming: function composition.
]##



import into

import std/[sugar]



func chain*[A; B; C](f: A -> B; g: B -> C): A -> C =
  (a: A) => f(a).into(g)


func chain*[A; B](f: () -> A; g: A -> B): () -> B {.
  deprecated: """Since "0.3.0"."""
.} =
  () => f().into(g)



func compose*[A; B; C](self: B -> C; prev: A -> B): A -> C =
  ##[
    Since `0.3.0`.
  ]##
  prev.chain(self)
