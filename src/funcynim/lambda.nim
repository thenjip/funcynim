import std/[sugar]



template lambda* [T](expr: T): proc =
  ##[
    It is the same as ``() => expr``, but the method or classic call syntaxes
    can be used.
  ]##
  () => expr



when isMainModule:
  import call

  import std/[os, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"expr.lambda().call().typeof()" should be "expr.typeof()".""":
        template doTest [T](expr: T): proc () =
          (
            proc () =
              check:
                expr.lambda().call().typeof().`is`(T)
          )


        for t in [doTest(1), doTest("abc"), doTest(new char)]:
          t.call()



  main()
