##[
  Utilities for ``system.NimNode``.

  They may be handy when writing macros.
]##



import std/[macros]



type
  NimNodeIndex* = int



func low* (self: NimNode): NimNodeIndex =
  0


func high* (self: NimNode): NimNodeIndex =
  ## Returns ``-1`` if `self` has no children.
  self.len().pred()


func firstChild* (self: NimNode): NimNode =
  self[self.low()]


func secondChild* (self: NimNode): NimNode =
  self[self.low().succ()]



when isMainModule:
  import std/[os, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"self.high()" should return -1 when "self.len() == 0".""":
        proc doTest () =
          const
            actual = newEmptyNode().high()
            expected = -1

          check:
            actual == expected


        doTest()



  main()
