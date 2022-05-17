when isMainModule:
  import
    pkg/funcynim/[run],

    std/[sugar, unittest]



  proc main() =
    suite "run":
      test """"self.run(input)" should compile.""":
        proc doTest[A; B](self: A -> B; input: A) =
          discard self.run(input)


        doTest((_: tuple[]) => "a", ())
        doTest((s: seq[int]) => s.len(), @[0, 2, 3])
        doTest((_: float -> int) => (), _ => -1)



  main()
