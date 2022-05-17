when isMainModule:
  import
    pkg/funcynim/[ignore],

    std/[unittest]



  proc main() =
    suite "ignore":
      test """"self.ignore()" should compile.""":
        proc doTest[T](self: T) =
          self.ignore()


        doTest(114u)
        doTest("abc")
        doTest(-9.2)



  main()
