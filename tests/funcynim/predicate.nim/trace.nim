import
  pkg/funcynim/[chain, curry, predicate],

  std/[sugar]



type
  Path* {.pure.} = enum
    Then
    Else

  Trace*[T] = tuple
    path: Path
    output: T



func trace*[T](path: Path; output: T): Trace[T] {.curry.} =
  (path, output)



proc tracedFold*[A; B](self: Predicate[A]; then,`else`: A -> B): A -> Trace[B] =
  self.fold(then.chain(trace[B](Path.Then)), `else`.chain(trace[B](Path.Else)))
