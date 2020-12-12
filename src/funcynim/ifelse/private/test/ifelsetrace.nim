import ../../../chain, ../../../ifelse

import std/[sugar]



type
  Path* {.pure.} = enum
    Then
    Else

  IfElseTrace* [T] = tuple
    path: Path
    output: T



func ifElseTrace* [T](path: Path; output: T): IfElseTrace[T] =
  (path, output)



func trace [T](self: Path; f: () -> T): () -> IfElseTrace[T] =
  f.chain((output: T) => ifElseTrace(self, output))


proc tracedIfElse* [T](condition: bool; then, `else`: () -> T): IfElseTrace[T] =
  condition.ifElse(Path.Then.trace(then), Path.Else.trace(`else`))
