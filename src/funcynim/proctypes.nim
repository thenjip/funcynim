##[
  Utilities to work with procedure types.
]##


import nimnodes

import std/[macros]



macro resultType* (T: typedesc[proc]): typedesc =
  T.getType().secondChild().secondChild().getTypeInst()


template resultType* (p: proc): typedesc =
  p.typeof().resultType()



macro paramType* (T: typedesc[proc]; position: static Natural): typedesc =
  ##[
    Parameter positions start at 0.
  ]##
  let
    procTypeNode = T.getType().secondChild()

  procTypeNode.expectMinLen(2 + position)

  T.getType().secondChild()[2 + position].getTypeInst()


template paramType* (p: proc; position: static Natural): typedesc =
  ##[
    Parameter positions start at 0.
  ]##
  p.typeof().paramType(position)



when isMainModule:
  import call, operators

  import std/[os, sugar, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"T.resultType()" should return the return type of the given procedure type.""":
        template doTest (T: typedesc[proc]; expected: typedesc): proc () =
          (
            proc () =
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
          t.call()



      test """"T.paramType(position)" should return the type of the parameter of the given procedure type at position "position".""":
        template doTest (
          T: typedesc[proc];
          position: static Natural;
          expected: typedesc
        ): proc () =
          (
            proc () =
              check:
                T.paramType(position).`is`(expected)
          )


        for t in [
          doTest(next[Natural].typeof(), 0, Natural),
          doTest(divFloat[cfloat].typeof(), 1, cfloat),
          doTest((int, char, bool) -> (char, int), 1, char)
        ]:
          t.call()



  main()
