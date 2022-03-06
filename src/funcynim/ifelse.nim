##[
  A module to lift the "if/else" expression as a procedure.
]##



{.deprecated: """Since "0.3.0". Use the "fold" module instead.""".}



import std/[sugar]



proc ifElse*[T](condition: bool; then, `else`: () -> T): T =
  if condition:
    then()
  else:
    `else`()
