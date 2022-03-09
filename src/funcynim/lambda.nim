import std/[sugar]



{.deprecated: """Since "0.3.0".""".}



template lambda*[T](expr: T): auto =
  ##[
    It is the same as ``() => expr``, but the method or classic call syntaxes
    can be used.
  ]##
  () => expr
