##[
  A module to lift the "if/else" expression as a procedure.
]##



import std/[sugar]



proc ifElse* [T](condition: bool; then, `else`: () -> T): T =
  if condition:
    then()
  else:
    `else`()



when isMainModule:
  import call, chain
  import ifelse/private/test/[ifelsetrace]

  import std/[os, strutils, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test [
        """"condition.ifElse(then, else)" should take the "then" path when""",
        """"condition" is "true".""""
      ].join($' '):
        proc doTest [T](then, `else`: () -> T) =
          let
            actual = true.tracedIfElse(then, `else`)
            expected = ifElseTrace(Path.Then, then())

          check:
            actual == expected


        doTest(() => 0, () => 0)
        doTest(() => "a", () => "abc")



      test [
        """"condition.ifElse(then, else)" should take the "else" path when""",
        """"condition" is "false"."""
      ].join($' '):
        proc doTest [T](then, `else`: () -> T) =
          let
            actual = false.tracedIfElse(then, `else`)
            expected = ifElseTrace(Path.Else, `else`())

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
          proc doTest [T](
            then, `else`: static[
              proc (): proc (): T {.noSideEffect.} {.nimcall, noSideEffect.}
            ]
          ) =
            const
              actual = true.tracedIfElse(then(), `else`())
              expected = ifElseTrace(Path.Then, then().call())

            check:
              actual == expected


          doTest(
            proc (): auto = () {.closure.} => 0,
            proc (): auto = () {.closure.} => 0
          )
          doTest(
            proc (): auto = () {.closure.} => "a",
            proc (): auto = () {.closure.} => "abc"
          )



      test [
        """"condition.ifElse(then, else)" should take the "else" path when""",
        """"condition" is "false" at compile time."""
      ].join($' '):
        when defined(js):
          skip() # https://github.com/nim-lang/Nim/issues/12492
        else:
          proc doTest [T](
            then, `else`: static[
              proc (): proc (): T {.noSideEffect.} {.nimcall, noSideEffect.}
            ]
          ) =
            const
              actual = false.tracedIfElse(then(), `else`())
              expected = ifElseTrace(Path.Else, `else`().call())

            check:
              actual == expected


          doTest(
            proc (): auto = () {.closure.} => 0,
            proc (): auto = () {.closure.} => 0
          )
          doTest(
            proc (): auto = () {.closure.} => "a",
            proc (): auto = () {.closure.} => "abc"
          )



  main()
