##[
  This module adds support for currying to Nim.

  Currying a `proc` with N parameters transforms it into one that:
    - takes 1 parameter.
    - returns another `proc` that takes 1 parameter.
    - and so on for each remaining parameter.

  Since `0.3.0`.
]##



import pkg/[nim_curry]

import std/[sugar]



template curry*(self: untyped{nkProcDef | nkFuncDef}) =
  ##[
    Transforms a `proc` or `func` definition into a curried one.

    Only procedures having 2 or more parameters are affected.

    **Example:**
      .. code-block:: nim

        import pkg/funcynim/[curry]

        proc `+`[T](item: T; self: seq[T]): seq[T] {.curry.} =
          self & item

        let addB = + "b"

        assert(@["a"].addB() == @["a", "b"])

    Since `0.3.0`.
  ]##
  nim_curry.curry(self)


template curry*(self: untyped{nkLambda}): untyped =
  ##[
    Transforms an anonymous `proc` into a curried one.

    Only procedures having 2 or more parameters are affected.

    `auto` return type is currently not supported.

    **Example:**
      .. code-block:: nim

        import pkg/funcynim/[curry]

        let
          f =
            proc (item: string; s: seq[string]): seq[string] {.curry.} =
              s & item
          addB = f("b")

        assert(@["a"].addB() == @["a", "b"])

    Since `0.3.0`.
  ]##
  nim_curry.curry(self)



func with*[A; B; C](curried: A -> (B -> C); arg: A): B -> C =
  ##[
    Gives an argument to a curried `proc`.

    This gives the choice of writing `f(a)(b)...` or `f.with(a).with(b)...`.

    Since `0.3.0`.
  ]##
  curried(arg)
