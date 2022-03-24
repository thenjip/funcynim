##[
  Functions to alias the explicit conversion operator.
]##



proc convert*[A](a: A; B: typedesc): B =
  a.B


proc convert*[A; B](a: A): B =
  a.convert(B)



proc to*[A](a: A; B: typedesc): B =
  a.convert(B)


proc to*[A; B](a: A): B =
  a.convert(B)
