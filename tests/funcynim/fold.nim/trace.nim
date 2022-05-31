import
  pkg/funcynim/[chain, fold, unit],

  std/[sugar]



type
  Path* {.pure.} = enum
    Then
    Else

  Trace*[T] = tuple
    path: Path
    output: T



func trace*[T](path: Path; output: T): Trace[T] =
  (path, output)



func addTrace[T](self: Unit -> T; path: Path): Unit -> Trace[T] =
  self.chain((output: T) => trace(path, output))


proc tracedFold*[T](self: bool; then, `else`: Unit -> T): Trace[T] =
  self.fold(then.addTrace(Path.Then), `else`.addTrace(Path.Else))
