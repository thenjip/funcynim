when isMainModule:
  import pkg/funcynim/[lambda, run]

  import std/[strutils, unittest]



  proc main() =
    suite "lambda":
      test [
        """"expr.lambda().run().typeof()" should be the same as""",
        """"expr.typeof()"."""
      ].join($' '):
        template doTest[T](expr: T): proc () =
          (
            proc () =
              let p = expr.lambda()

              check:
                p.run().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(new char)]:
          t.run()



      test [
        """"expr.lambda().run().typeof()" should be the same as""",
        """"expr.typeof()" at compile time."""
      ].join($' '):
        template doTest[T](expr: static[T]): proc () =
          (
            proc () =
              const p = expr.lambda()

              check:
                p.run().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(1 + 1)]:
          t.run()



  main()
