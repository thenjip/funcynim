import
  pkg/funcynim/[nimnodes],

  std/[macros, unittest]



proc main() =
  suite "nimnodes":
    test """"self.high()" should return -1 when "self.len() == 0".""":
      proc doTest() =
        const
          actual = newEmptyNode().high()
          expected = -1

        check:
          actual == expected


      doTest()



main()
