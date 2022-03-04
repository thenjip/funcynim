##[
  Since `0.3.0`.
]##



import unit

import std/[sugar]



proc run*[A; B](self: A -> B; arg: A): B =
  ##[
    Since `0.3.0`.
  ]##
  self(arg)


proc run*[T](self: Unit -> T): T =
  ##[
    Since `0.3.0`.
  ]##
  self.run(unit())


proc run*[T](self: () -> T): T =
  ##[
    Since `0.3.0`.
  ]##
  self()
