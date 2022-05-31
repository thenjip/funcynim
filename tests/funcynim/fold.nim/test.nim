import
  trace,

  pkg/funcynim/[fold, run, unit],

  std/[strutils, sugar, unittest]



proc main() =
  suite "fold":
    test """"true.fold(then, `else`)" should take the "then" path.""":
      proc doTest[T](then, `else`: Unit -> T) =
        let
          actual = true.tracedFold(then, `else`)
          expected = trace(Path.Then, then.run())

        check:
          actual == expected


      doTest((_: Unit) => 0, (_: Unit) => 1)



    test """false.fold(then, `else`)" should take the "else" path.""":
      proc doTest[T](then, `else`: Unit -> T) =
        let
          actual = false.tracedFold(then, `else`)
          expected = trace(Path.Else, `else`.run())

        check:
          actual == expected


      doTest((_: Unit) => 'a', (_: Unit) => 'b')



    test [
      """(Compile time) "true.fold(then, `else`)" should take the "then"""",
      "path."
    ].join($' '):
      when defined(js):
        skip() # https://github.com/nim-lang/Nim/issues/12492
      else:
        proc doTest[T](
          then, `else`: static[
            proc (_: Unit): proc (_: Unit): T {.noSideEffect.}
              {.nimcall, noSideEffect.}
          ]
        ) =
          const
            actual = true.tracedFold(then.run(), `else`.run())
            expected = trace(Path.Then, then.run().run())

          check:
            actual == expected


        doTest(
          (_: Unit) => ((_: Unit) {.closure.} => 0),
          (_: Unit) => ((_: Unit) {.closure.} => 1)
        )
        doTest(
          (_: Unit) => ((_: Unit) {.closure.} => "a"),
          (_: Unit) => ((_: Unit) {.closure.} => "abc")
        )



    test [
      """(Compile time) "false.fold(then, `else`)" should take the "else"""",
      "path."
    ].join($' '):
      when defined(js):
        skip() # https://github.com/nim-lang/Nim/issues/12492
      else:
        proc doTest[T](
          then, `else`: static[
            proc (_: Unit): proc (_: Unit): T {.noSideEffect.}
              {.nimcall, noSideEffect.}
          ]
        ) =
          const
            actual = false.tracedFold(then.run(), `else`.run())
            expected = trace(Path.Else, `else`.run().run())

          check:
            actual == expected


        doTest(
          (_: Unit) => ((_: Unit) {.closure.} => 0),
          (_: Unit) => ((_: Unit) {.closure.} => 1)
        )
        doTest(
          (_: Unit) => ((_: Unit) {.closure.} => "a"),
          (_: Unit) => ((_: Unit) {.closure.} => "abc")
        )



main()
