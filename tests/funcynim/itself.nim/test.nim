import
  pkg/funcynim/[itself, run],

  std/[sugar, unittest]



proc repeat[T](self: T -> T; n: Positive): T -> T =
  (proc (input: T): T =
    result = input

    for _ in 0 ..< n:
      result = self(result)
  )



proc main() =
  suite "itself":
    test "The identity function should be idempotent.":
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



    test "(Compile time) The identity function should be idempotent.":
      when defined(js):
        skip() # https://github.com/nim-lang/Nim/issues/12492
      else:
        proc doTest[T](input: static[T]; n: static Positive) =
          const
            actual = itself.itself[T].repeat(n).run(input)
            expected = input.itself()

          check:
            actual == expected


        doTest("a", 1)
        doTest('a', 3)
        doTest(-1, 11)



main()
