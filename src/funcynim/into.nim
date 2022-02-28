##[
  Since `0.3.0`.
]##



import std/[sugar]



proc into*[A; B](self: A; f: A -> B): B =
  ## Since `0.3.0`.
  self.f()
