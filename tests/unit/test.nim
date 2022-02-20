when isMainModule:
  import pkg/funcynim/[unit]

  import std/[unittest]



  proc main() =
    suite "unit":
      test """"Unit.default()" should be equal to "unit()".""":
        proc doTest() =
          let
            actual = Unit.default()
            expected = unit()

          check:
            actual == expected


        doTest()



  main()
