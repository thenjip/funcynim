##[
  The bread and butter of functional programming: function composition.
]##



import std/[sugar]



func chain* [A; B; C](f: A -> B; g: B -> C): A -> C =
  (a: A) => a.f().g()



func chain* [A; B](f: () -> A; g: A -> B): () -> B =
  () => f().g()
