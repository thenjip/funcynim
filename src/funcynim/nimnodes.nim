##[
  Utilities for ``system.NimNode``.

  They may be handy when writing macros.
]##



import std/[macros]



type
  NimNodeIndex* = int



func low*(self: NimNode): NimNodeIndex =
  0


func high*(self: NimNode): NimNodeIndex =
  ## Returns ``-1`` if `self` has no children.
  self.len().pred()


func firstChild*(self: NimNode): NimNode =
  self[self.low()]


func secondChild*(self: NimNode): NimNode =
  self[self.low().succ()]
