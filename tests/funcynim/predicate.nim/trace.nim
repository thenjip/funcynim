import
  pkg/funcynim/[chain, predicate],

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



func addTrace[A; B](self: A -> B; path: Path): A -> Trace[B] =
  self.chain((output: B) => trace(path, output))


proc tracedFold*[A; B](self: Predicate[A]; then,`else`: A -> B): A -> Trace[B] =
  self.fold(then.addTrace(Path.Then), `else`.addTrace(Path.Else))
