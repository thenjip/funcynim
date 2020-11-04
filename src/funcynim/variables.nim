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



when isMainModule:
  import std/[os, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """Reading a "var" after it being written should return the written value.""":
        proc doTest [T](value: T) =
          var sut {.noInit.}: T

          let
            actual = sut.write(value).read()
            expected = value

          check:
            actual == expected


        doTest(2)
        doTest("abc")
        doTest(("a", '0'))



  main()
