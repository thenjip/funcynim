import
  pkg/funcynim/[curry],

  std/[sugar, unittest]



proc plus(first: int16, second: int32): int64 {.curry.} =
  first.int64 + second.int64


func inter[T: Ordinal](self, other: set[T]): set[T] {.curry.} =
  self * other



proc main() =
  suite "curry":
    test "A curried binary proc definition should have the type A -> (B -> C).":
      proc doTest[A; B; C](_: A -> (B -> C)) =
        discard


      doTest(plus)



    test "A curried binary func definition should have the type A -> (B -> C).":
      proc doTest[A; B; C](f: proc (_: A): B -> C {.noSideEffect.}) =
        discard


      doTest(inter[char])



    test(
      "A curried binary lambda expression should have the type A -> (B -> C)."
    ):
      proc doTest() =
        let f = proc (a, b: int): char {.curry.} = '\0'

        check:
          f(0)(0).typeof() is char


      doTest()



main()
