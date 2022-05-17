##[
  Since `0.3.0`.
]##



import
  run, unit,

  std/[sugar]



proc fold*[T](self: bool; then, `else`: Unit -> T): T =
  ##[
    The `if else` expression reified as a `proc`.

    Since `0.3.0`.
  ]##
  let path = if self: then else: `else`

  path.run()
