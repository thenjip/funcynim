import
  pkg/funcynim/[chain],

  std/[sugar, unittest]



proc main() =
  suite "chain":
    test "Chaining procs should be associative.":
      proc doTest[A; B; C; D](
        first: A -> B;
        second: B -> C;
        third: C -> D;
        input: A
      ) =
        let
          leftHand = first.chain(second.chain(third))(input)
          rightHand = first.chain(second).chain(third)(input)

        check:
          leftHand == rightHand


      doTest((i: int) => i + 1, i => $i, s => s.len(), 0)



    test "(Compile time) Chaining procs should be associative.":
      when defined(js):
        skip() # https://github.com/nim-lang/Nim/issues/12492
      else:
        proc doTest[A; B; C; D](
          first: static[proc (_: A): B {.nimcall, noSideEffect.}];
          second: static[proc (_: B): C {.nimcall, noSideEffect.}];
          third: static[proc (_: C): D {.nimcall, noSideEffect.}];
          input: static A
        ) =
          const
            leftHand = first.chain(second.chain(third))(input)
            rightHand = first.chain(second).chain(third)(input)

          check:
            leftHand == rightHand


        doTest((i: int) => i + 1, (i: int) => $i, (s: string) => s.len(), 0)



main()
