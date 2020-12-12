import std/[sugar]



template lambda* [T](expr: T): auto =
  ##[
    It is the same as ``() => expr``, but the method or classic call syntaxes
    can be used.
  ]##
  () => expr



when isMainModule:
  import call

  import std/[os, strutils, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test [
        """"expr.lambda().call().typeof()" should be the same as""",
        """"expr.typeof()"."""
      ].join($' '):
        template doTest [T](expr: T): proc () =
          (
            proc () =
              let p = expr.lambda()

              check:
                p.call().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(new char)]:
          t.call()



      test [
        """"expr.lambda().call().typeof()" should be the same as""",
        """"expr.typeof()" at compile time."""
      ].join($' '):
        template doTest [T](expr: static[T]): proc () =
          (
            proc () =
              const p = expr.lambda()

              check:
                p.call().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(1 + 1)]:
          t.call()



  main()
