when isMainModule:
  import pkg/funcynim/[call, operators]

  import std/[strutils, sugar, unittest]



  proc main() =
    suite "call":
      test """"f.call(arg)" should produce "f(arg)".""":
        proc doTest[A; B](f: A -> B; arg: A) =
          let
            actual = f.call(arg)
            expected = f(arg)

          check:
            actual == expected


        doTest((c: char) => c.byte, 'a')
        doTest((s: seq[string]) => s.len(), @["a", "b"])



      test """"f.call(arg1, arg2)" should produce "f(arg1, arg2)".""":
        proc doTest[A; B; C](f:(A, B) -> C; arg1: A; arg2: B) =
          let
            actual = f.call(arg1, arg2)
            expected = f(arg1, arg2)

          check:
            actual == expected


        doTest(plus[int], 1, 2)



      test [
        """"f.call(arg1, arg2, arg3)" should produce "f(arg1, arg2, arg3)"."""
      ].join($' '):
        proc doTest[A; B; C; D](f:(A, B, C) -> D; arg1: A; arg2: B; arg3: C) =
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



      test [
        """"f.call(arg)" should produce "f(arg)" in compile time expressions."""
      ].join($' '):
        proc doTest[A; R](
          f: static proc (a: A): R {.nimcall, noSideEffect.};
          arg: static A
        ) =
          const
            actual = f.call(arg)
            expected = f(arg)

          check:
            actual == expected


        doTest((s: string) => s.len(), "abc")



      test [
        """"f.call(arg1, arg2)" should produce "f(arg1, arg2)" in compile""",
        "time expressions."
      ].join($' '):
        proc doTest[A; B; C](
          f: static proc (a: A; b: B): C {.nimcall, noSideEffect.};
          arg1: static A;
          arg2: static B
        ) =
          const
            actual = f.call(arg1, arg2)
            expected = f(arg1, arg2)

          check:
            actual == expected


        doTest(plus[int], 1, 2)



      test [
        """"f.call(arg1, arg2, arg3)" should produce "f(arg1, arg2, arg3)"""",
        "in compile time expresions."
      ].join($' '):
        proc doTest[A; B; C; D](
          f: static proc (a: A; b: B; c: C): D {.nimcall, noSideEffect.};
          arg1: static A;
          arg2: static B;
          arg3: static C
        ) =
          const
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



  main()
