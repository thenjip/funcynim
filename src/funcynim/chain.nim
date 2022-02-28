##[
  The bread and butter of functional programming: function composition.
]##



import std/[sugar]



func chain*[A; B; C](
  first: proc (_: A): B {.nimcall.};
  second: proc (_: B): C {.nimcall.}
): proc (_: A): C {.nimcall.} =
  ## Since `0.3.0`.
  (a: A) {.nimcall.} => a.first().second()


func chain*[A; B](
  first: proc (): A {.nimcall.};
  second: proc (_: A): B {.nimcall.}
): proc (): B {.nimcall.} =
  ## Since `0.3.0`.
  () {.nimcall.} => first().second()



func chain*[A; B; C](f: A -> B; g: B -> C): A -> C =
  (a: A) => a.f().g()


func chain*[A; B](f: () -> A; g: A -> B): () -> B =
  () => f().g()
