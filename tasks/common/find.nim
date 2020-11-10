import pkg/taskutils/[optional]

import std/[sugar]



func findFirst* (O: typedesc[Ordinal]; predicate: O -> bool): Optional[O] =
  result = O.none()

  for item in O:
    if item.predicate():
      return item.some()


func findFirstIndex* [I; T](
  self: array[I, T];
  predicate: T -> bool
): Optional[I] =
  I.findFirst(i => self[i].predicate())
