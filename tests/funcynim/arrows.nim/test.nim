import
  pkg/funcynim/[arrows, unit],

  std/[unittest]



proc main() =
  suite "arrows":
    test """"() -> T" should be "Unit -> T".""":
      proc doTest(T: typedesc) =
        proc checkType(Expected: typedesc[Unit -> T]) =
          discard

        checkType(() -> T)


      doTest(int)
      doTest(int -> char)
      doTest(ptr byte)



    test """"() => T.default()" should be of type "Unit -> T".""":
      proc doTest(T: typedesc) =
        let actual = () => T.default()

        proc checkType(Expected: typedesc[Unit -> T]) =
          discard

        checkType(actual.typeof())


      doTest(int)
      doTest(int -> char)
      doTest(ptr byte)



main()
