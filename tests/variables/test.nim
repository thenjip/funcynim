when isMainModule:
  import pkg/funcynim/[variables]

  import std/[strutils, unittest]



  proc main() =
    suite "variables":
      test [
        """Reading a "var" after it being written should return the written""",
        "value."
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



  main()
