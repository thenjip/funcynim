##[
  The bread and butter of functional programming: function composition.
]##



import
  into,

  std/[sugar]



func chain*[A; B; C](self: A -> B; next: B -> C): A -> C =
  (a: A) => self(a).into(next)



func compose*[A; B; C](self: B -> C; prev: A -> B): A -> C =
  ##[
    Since `0.3.0`.
  ]##
  prev.chain(self)
