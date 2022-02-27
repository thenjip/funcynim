when isMainModule:
  import trace

  import pkg/funcynim/[call, chain]

  import std/[strutils, sugar, unittest]



  proc main() =
    suite "ifelse":
      test [
        """"condition.ifElse(then, else)" should take the "then" path when""",
        """"condition" is "true".""""
      ].join($' '):
        proc doTest[T](then, `else`: () -> T) =
          let
            actual = true.tracedIfElse(then, `else`)
            expected = trace(Path.Then, then())

          check:
            actual == expected


        doTest(() => 0, () => 0)
        doTest(() => "a", () => "abc")



      test [
        """"condition.ifElse(then, else)" should take the "else" path when""",
        """"condition" is "false"."""
      ].join($' '):
        proc doTest[T](then, `else`: () -> T) =
          let
            actual = false.tracedIfElse(then, `else`)
            expected = trace(Path.Else, `else`())

          check:
            actual == expected


        doTest(() => 0, () => 0)
        doTest(() => "a", () => "abc")



      test [
        """"condition.ifElse(then, else)" should take the "then" path when""",
        """"condition" is "true" at compile time.""""
      ].join($' '):
        when defined(js):
          skip() # https://github.com/nim-lang/Nim/issues/12492
        else:
          proc doTest[T](
            then, `else`: static[
              proc (): proc(): T {.noSideEffect.} {.nimcall, noSideEffect.}
            ]
          ) =
            const
              actual = true.tracedIfElse(then(), `else`())
              expected = trace(Path.Then, then().call())

            check:
              actual == expected


          doTest(
            proc (): auto =() {.closure.} => 0,
            proc (): auto =() {.closure.} => 0
          )
          doTest(
            proc (): auto =() {.closure.} => "a",
            proc (): auto =() {.closure.} => "abc"
          )



      test [
        """"condition.ifElse(then, else)" should take the "else" path when""",
        """"condition" is "false" at compile time."""
      ].join($' '):
        when defined(js):
          skip() # https://github.com/nim-lang/Nim/issues/12492
        else:
          proc doTest[T](
            then, `else`: static[
              proc (): proc(): T {.noSideEffect.} {.nimcall, noSideEffect.}
            ]
          ) =
            const
              actual = false.tracedIfElse(then(), `else`())
              expected = trace(Path.Else, `else`().call())

            check:
              actual == expected


          doTest(
            proc (): auto =() {.closure.} => 0,
            proc (): auto =() {.closure.} => 0
          )
          doTest(
            proc (): auto =() {.closure.} => "a",
            proc (): auto =() {.closure.} => "abc"
          )



  main()
