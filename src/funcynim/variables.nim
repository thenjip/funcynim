##[
  Utilities to manipulate variables.

  Useful when composing procedures that use variables with others that do not.
]##



import ignore, unit

import std/[sugar]



func read* [T](self: var T): T =
  self


proc write* [T](self: var T; value: T): var T =
  self = value

  self


proc modify* [T](self: var T; f: T -> T): var T =
  self.write(self.read().f())


proc modify* [T](self: var T; f: var T -> Unit): var T =
  f(self).ignore()

  self
