import funcynim/[chain, ifelse]

import std/[sugar]



type
  Path* {.pure.} = enum
    Then
    Else

  Trace*[T] = tuple
    path: Path
    output: T



func trace*[T](path: Path; output: T): Trace[T] =
  (path, output)



func trace [T](self: Path; f: () -> T): () -> Trace[T] =
  f.chain((output: T) => trace(self, output))


proc tracedIfElse*[T](condition: bool; then, `else`: () -> T): Trace[T] =
  condition.ifElse(Path.Then.trace(then), Path.Else.trace(`else`))
