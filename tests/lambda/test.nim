when isMainModule:
  import pkg/funcynim/[ignore, lambda, run, unit]

  import std/[strutils, sugar, unittest]



  proc main() =
    suite "lambda":
      test [
        """"expr.lambda().run().typeof()" should be the same as""",
        """"expr.typeof()"."""
      ].join($' '):
        template doTest[T](expr: T): Unit -> Unit =
          (
            proc (_: Unit): Unit =
              let p = expr.lambda()

              check:
                p.run().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(new char)]:
          t.run().ignore()



      test [
        """"expr.lambda().run().typeof()" should be the same as""",
        """"expr.typeof()" at compile time."""
      ].join($' '):
        template doTest[T](expr: static[T]): Unit -> Unit =
          (
            proc (_: Unit): Unit =
              const p = expr.lambda()

              check:
                p.run().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(1 + 1)]:
          t.run().ignore()



  main()
