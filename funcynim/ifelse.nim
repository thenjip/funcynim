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
  import chain

  import std/[os, unittest]



  type
    Path {.pure.} = enum
      Then
      Else

    IfElseOutput [T] = tuple
      takenPath: Path
      output: T



  func ifElseOutput [T](takenPath: Path; output: T): IfElseOutput[T] =
    (takenPath, output)


  func takePath [T](choice: bool; then, `else`: () -> T): IfElseOutput[T] =
    choice.ifElse(
      then.chain((value: T) => ifElseOutput(Path.Then, value)),
      `else`.chain((value: T) => ifElseOutput(Path.Else, value))
    )



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"condition.ifElse(then, else)" should take the "then" path when "condition" is "true".""":
        proc doTest [T](then, `else`: () -> T) =
          let
            actual = true.takePath(then, `else`)
            expected = ifElseOutput(Path.Then, then())

          check:
            actual == expected


        doTest(() => 0, () => 0)
        doTest(() => "a", () => "abc")



      test """"condition.ifElse(then, else)" should take the "else" path when "condition" is "false".""":
        proc doTest [T](then, `else`: () -> T) =
          let
            actual = false.takePath(then, `else`)
            expected = ifElseOutput(Path.Else, `else`())

          check:
            actual == expected


        doTest(() => 0, () => 0)
        doTest(() => "a", () => "abc")



      test """"ifElse()" should be usable in compile time expressions.""":
        proc doTest () =
          const someVal = true.ifElse(() => 1, () => 0)

          discard someVal


        doTest()



  main()
