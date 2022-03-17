when isMainModule:
  import pkg/funcynim/[itself, run]

  import std/[sugar, unittest]



  proc main() =
    suite "itself":
      test "The identity function should be idempotent.":
        proc repeat[T](self: T -> T; n: Positive): T -> T =
          (proc (input: T): T =
            result = input

            for _ in 0 ..< n:
              result = self(result)
          )


        proc doTest[T](input: T; n: Positive) =
          let
            actual = itself.itself[T].repeat(n).run(input)
            expected = input.itself()

          check:
            actual == expected


        doTest("a", 1)
        doTest('a', 5)
        doTest(-1, 15)
        doTest(FloatingPointDefect.newException(""), 3)



  main()
