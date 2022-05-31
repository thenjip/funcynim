import
  pkg/funcynim/[unit],

  std/[unittest]



proc main() =
  suite "unit":
    test """"Unit.default()" should be equal to "unit()".""":
      proc doTest() =
        let
          actual = Unit.default()
          expected = unit()

        check:
          actual == expected


      doTest()



    test """"self.doNothing()" should compile.""":
      proc doTest[T](self: T) =
        discard self.doNothing()


      doTest(1687)
      doTest(6.3)
      doTest("abc ")
      doTest(unit())
      doTest((-7, 1.2))



main()
