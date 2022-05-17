when isMainModule:
  import
    pkg/funcynim/[variables],

    std/[strutils, unittest]



  proc main() =
    suite "variables":
      test [
        """Reading a "var", then writing the read value should be the same""",
        """as leaving the "var" unmodified."""
      ].join($' '):
        proc doTest[T](value: T) =
          var sut = value

          let
            actual = sut.write(sut.read())
            expected = value

          check:
            actual == expected


        doTest(-5)
        doTest("abc abc")
        doTest(false)



      test [
        """Writing a "var", then reading it should return the written value."""
      ].join($' '):
        proc doTest[T](value: T) =
          var sut {.noInit.}: T

          let
            actual = sut.write(value).read()
            expected = value

          check:
            actual == expected


        doTest(2)
        doTest("abc")
        doTest(("a", '0'))



      test [
        """Writing 2 values successively in a "var" should be the same as""",
        "writing the 2nd value directly."
      ].join($' '):
        proc doTest[T](first, second: T) =
          var
            writtenTwice {.noInit.}: T
            writtenOnce {.noInit.}: T

          require:
            first != second

          let
            actual = writtenTwice.write(first).write(second).read()
            expected = writtenOnce.write(second).read()

          check:
            actual == expected


        doTest(0, int.high())
        doTest("a", "")
        doTest(('a', 8i16), (' ', 4i16))



  main()
