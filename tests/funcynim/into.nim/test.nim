import
  pkg/funcynim/[into],

  std/[sugar, unittest]



proc main() =
  suite "into":
    test """"self.into(f)" should compile.""":
      proc doTest[A; B](self: A; f: A -> B) =
        discard self.into(f)


      doTest(5, i => $i)
      doTest("abc", s => s)



main()
