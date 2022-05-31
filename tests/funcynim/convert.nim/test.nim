import
  pkg/funcynim/[convert],

  std/[unittest]



proc main() =
  suite "funcynim/convert":
    test """"self.to(B)" should compile.""":
      proc doTest[A](self: A; B: typedesc) =
        discard self.to(B)


      doTest(0, float)
      doTest('a', byte)
      doTest(ValueError.newException(""), ref Exception)



main()
