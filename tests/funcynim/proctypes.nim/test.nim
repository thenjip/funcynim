import
  pkg/funcynim/[ignore, operators, proctypes, run, unit],

  std/[strutils, sugar, unittest]



proc main() =
  suite "proctypes":
    test [
      """"T.resultType()" should return the return type of the given""",
      "procedure type."
    ].join($' '):
      template doTest(T: typedesc[proc]; expected: typedesc): Unit -> Unit =
        (
          proc (_: Unit): Unit =
            check:
              T.resultType().`is`(expected)
        )


      type
        SomeProc = ref NilAccessDefect -> seq[char]
        SomeGenericProc [T; R] = T -> R


      for t in [
        doTest(proc (), void),
        doTest(
          proc (a: string): Natural {.cdecl.},
          range[Natural.low() .. Natural.high()]
        ),
        doTest((int, () -> tuple[]) -> pointer, pointer),
        doTest(SomeProc, seq[char]),
        doTest(
          SomeGenericProc[float, ref FloatingPointDefect],
          ref FloatingPointDefect
        ),
        doTest(() -> var int, var int)
      ]:
        t.run().ignore()



    test [
      """"T.paramType(position)" should return the type of the parameter of""",
      """the given procedure type at position "position"."""
    ].join($' '):
      template doTest(
        T: typedesc[proc];
        position: static Natural;
        expected: typedesc
      ): Unit -> Unit =
        (
          proc (_: Unit): Unit =
            check:
              T.paramType(position).`is`(expected)
        )


      for t in [
        doTest(next[Natural].typeof(), 0, Natural),
        doTest(divFloat[cfloat].typeof(), 1, cfloat),
        doTest((int, char, bool) -> (char, int), 1, char)
      ]:
        t.run().ignore()



main()
