import std/[sugar]



template lambda* [T](expr: T): auto =
  ##[
    It is the same as ``() => expr``, but the method or classic call syntaxes
    can be used.
  ]##
  () => expr
