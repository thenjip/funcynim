import std/[sugar]



proc into*[A; B](self: A; f: A -> B): B =
  self.f()
