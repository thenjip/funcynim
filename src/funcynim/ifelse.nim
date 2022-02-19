##[
  A module to lift the "if/else" expression as a procedure.
]##



import std/[sugar]



proc ifElse* [T](condition: bool; then, `else`: () -> T): T =
  if condition:
    then()
  else:
    `else`()
