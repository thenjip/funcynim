import
  pkg/funcynim/[chain, partialproc],

  std/[strutils, sugar, unittest]



func plus[A: SomeNumber; B: SomeNumber; R: SomeNumber](a: A; b: B): R =
  a + b


func ternaryProc(a: char; b: int; c: string): bool =
  true


func sum[N: SomeNumber](a, b, c: N): N =
  a + b + c



proc main() =
  suite "funcynim/partialproc":
    #[
      `should be equivalent to` means `should return an expression that is
      effectively the same as`.
    ]#
    test """"partial(a + ?:N)" should be equivalent to "(b: N) => a + b".""":
      proc doTest[N: SomeNumber](a, b: N) =
        let
          actual = partial(a + ?:N)(b)
          expected = a + b

        check:
          actual == expected


      doTest(1, 9)
      doTest(11563.7, -5.568)



    test """"partial($ ?:T)" should be equivalent to "(a: T) => $a".""":
      proc doTest[T](a: T) =
        let
          actual = partial($ ?:T)(a)
          expected = $a

        check:
          actual == expected


      doTest('a')
      doTest("a")
      doTest(-8)
      doTest(Nan)
      doTest({0: @[0, 1, 2]})



    test [
      """"partial(f(a, ?:B))" should be equivalent to "(b: B) => f(a, b)"."""
    ].join($' '):
      proc doTest[A; B; R](f:(A, B) -> R; a: A; b: B) =
        let
          actual = partial(f(a, ?:B))(b)
          expected = f(a, b)

        check:
          actual == expected


      doTest(plus[int, int, int], 0, 1)
      doTest(plus[uint32, uint32, uint32], 5646532, 11)
      doTest((a: string, b: string) => a & b, "a", "b")



    test [
      """"partial(f(?:A, b, ?:C))" should be equivalent to""",
      """"(a: A, c: C) => f(a, b, c)"."""
    ].join($' '):
      proc doTest[A; B; C; R](f:(A, B, C) -> R; a: A; b: B; c: C) =
        let
          actual = partial(f(?:A, b, ?:C))(a, c)
          expected = f(a, b, c)

        check:
          actual == expected


      doTest(sum[uint16], 3, 5, 7)
      doTest(ternaryProc, 'a', 1, "")



    test [
      """"f.chain(partial(g(?b, c)))" should be equivalent to""",
      """"f.chain(b => b.g(c))(a)"."""
    ].join($' '):
      proc doTest[A; B; C; D](f: A -> B; g:(B, C) -> D; a: A; c: C) =
        let
          actual = f.chain(partial(g(?b, c)))(a)
          expected = f.chain(b => b.g(c))(a)

        check:
          actual == expected


      doTest((a: int) => $a, (b: string, c: Positive) => b & $c, 1, 1)



    test [
      """(Compile time) "partial(a + ?:N)" should be equivalent to""",
      """"(b: N) => a + b"."""
    ].join($' '):
      proc doTest[N: SomeNumber](a, b: static N) =
        const
          actual = partial(a + ?:N)(b)
          expected = a + b

        check:
          actual == expected


      doTest(1, 9)
      doTest(11563.7, -5.568)



    test [
      """(Compile time) "partial($ ?:T)" should be equivalent to""",
      """"(a: T) => $a"."""
    ].join($' '):
      proc doTest[T](a: static[T]) =
        const
          actual = partial($ ?:T)(a)
          expected = $a

        check:
          actual == expected


      doTest('a')
      doTest("a")
      doTest(-8)
      doTest(Nan)
      doTest({0: @[0, 1, 2]})



    test [
      """(Compile time) "partial(f(a, ?:B))" should be equivalent to""",
      """"(b: B) => f(a, b)"."""
    ].join($' '):
      proc doTest[A; B; R](
        f: static proc (a: A; b: B): R {.nimcall.};
        a: static A;
        b: static B
      ) =
        const
          actual = partial(f(a, ?:B))(b)
          expected = f(a, b)

        check:
          actual == expected


      doTest(plus[int, int, int], 0, 1)
      doTest(plus[uint32, uint32, uint32], 5646532, 11)
      doTest((a: string, b: string) => a & b, "a", "b")



    test [
      """(Compile time) "partial(f(?:A, b, ?:C))" should be equivalent to""",
      """"(a: A, c: C) => f(a, b, c)"."""
    ].join($' '):
      proc doTest[A; B; C; R](
        f: static proc (a: A; b: B; c: C): R {.nimcall.};
        a: static A;
        b: static B;
        c: static C
      ) =
        const
          actual = partial(f(?:A, b, ?:C))(a, c)
          expected = f(a, b, c)

        check:
          actual == expected


      doTest(sum[uint16], 3, 5, 7)
      doTest(ternaryProc, 'a', 1, "")



    test [
      """(Compile time) "f.chain(partial(g(?b, c)))" should be equivalent to""",
      """"f.chain(b => b.g(c))(a)"."""
    ].join($' '):
      when defined(js):
        skip() # https://github.com/nim-lang/Nim/issues/12492
      else:
        proc doTest[A; B; C; D](
          f: static proc (a: A): B {.nimcall.};
          g: static proc (b: B; c: C): D {.nimcall.};
          a: static A;
          c: static C
        ) =
          const
            actual = f.chain(partial(g(?b, c)))(a)
            expected = f.chain(b => b.g(c))(a)

          check:
            actual == expected


        doTest((a: int) => $a, (b: string, c: Positive) => b & $c, 1, 1)



main()
