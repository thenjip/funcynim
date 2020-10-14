type
  Unit* =
    tuple[]
    ##[
      The `Unit` type from functional programming.

      The type has only a single value.
    ]##



func unit* (): Unit =
  ()


func default* (T: typedesc[Unit]): Unit =
  unit()



func doNothing* [T](_: T): Unit =
  unit()



when isMainModule:
  import std/[os, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"Unit.default()" should be equal to "unit()".""":
        proc doTest () =
          let
            actual = Unit.default()
            expected = unit()

          check:
            actual == expected


        doTest()



  main()
