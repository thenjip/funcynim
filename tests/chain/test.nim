when isMainModule:
  import pkg/funcynim/[chain]

  import std/[sugar, unittest]



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
            leftHand = first.chain(second.chain(third))
            rightHand = first.chain(second).chain(third)

          check:
            leftHand(input) == rightHand(input)


        doTest((i: int) => i + 1, i => $i, s => s.len(), 0)



  main()
