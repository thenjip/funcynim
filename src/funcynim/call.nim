##[
  Procedures and macros to alias the procedure call operator.

  Useful when calling an anonymous proc.
]##



import std/[macros]



proc call*[T](p: proc(): T {.nimcall.}): T =
  p()


proc call*[T](p: proc(): T {.closure.}): T =
  p()


proc call*(p: proc() {.nimcall.}) =
  p()


proc call*(p: proc() {.closure.}) =
  p()


macro call*(p: proc; arg1: typed; remaining: varargs[typed]): untyped =
  result = p.newCall(arg1)

  for arg in remaining:
    result.add(arg)
