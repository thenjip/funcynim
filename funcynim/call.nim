##[
  Procedures and macros to alias the procedure call operator.

  Useful when calling an anonymous proc.
]##



import std/[macros]



proc call* [T](p: proc (): T {.nimcall.}): T =
  p()


proc call* [T](p: proc (): T {.closure.}): T =
  p()


proc call* (p: proc () {.nimcall.}) =
  p()


proc call* (p: proc () {.closure.}) =
  p()


macro call* (p: proc; arg1: untyped; remaining: varargs[untyped]): untyped =
  result = newCall(p, arg1)

  for arg in remaining:
    result.add(arg)



when isMainModule:
  import operators

  import std/[os, sugar, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"f.call(arg)" should produce "f(arg)".""":
        proc doTest [A; B](f: A -> B; arg: A) =
          let
            actual = f.call(arg)
            expected = f(arg)

          check:
            actual == expected


        doTest((c: char) => c.byte, 'a')
        doTest((s: seq[string]) => s.len(), @["a", "b"])



      test """"f.call(arg1, arg2)" should produce "f(arg1, arg2)".""":
        proc doTest [A; B; C](f: (A, B) -> C; arg1: A; arg2: B) =
          let
            actual = f.call(arg1, arg2)
            expected = f(arg1, arg2)

          check:
            actual == expected


        doTest(plus[int], 1, 2)



      test """"f.call(arg1, arg2, arg3)" should produce "f(arg1, arg2, arg3)".""":
        proc doTest [A; B; C; D](f: (A, B, C) -> D; arg1: A; arg2: B; arg3: C) =
          let
            actual = f.call(arg1, arg2, arg3)
            expected = f(arg1, arg2, arg3)

          check:
            actual == expected


        doTest(
          (b: bool, i: int, c: char) => b.ord() + i - c.ord(),
          false,
          -15,
          '\n'
        )



      test """"call()" should be usable in compile time expressions.""":
        proc doTest () =
          const results =
            (
              call(() => 0),
              call((arg1: (int, int)) => arg1[0], (-1, 5)),
              minus[Natural].call(10, 2),
              call(
                (arg1: string, arg2: int, arg3: tuple[]) => arg1,
                "",
                int.low(),
                ()
              )
            )

          discard results


        doTest()


  main()
