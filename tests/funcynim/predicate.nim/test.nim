import
  trace,

  pkg/funcynim/[chain, itself as modItself, partialproc, predicate, run, unit],

  std/[strutils, sugar, unittest]



proc main () =
  suite "funcynim/predicate":
    test """"self.test(value)" should return the expected boolean.""":
      proc doTest[T](self: Predicate[T]; value: T; expected: bool) =
        let actual = self.test(value)

        check:
          actual == expected


      doTest(alwaysFalse[ref Defect], nil, false)
      doTest(alwaysTrue[bool], false, true)
      doTest(partial(?:Natural < 10), 4, true)
      doTest((s: string) => s.len() > 3, "a", false)



    test [
      """"not self" should return a predicate that is the negation of "self"."""
    ].join($' '):
      proc doTest[T](self: Predicate[T]; value: T; expected: bool) =
        let actual = self.`not`().test(value)

        check:
          actual == expected


      doTest(alwaysTrue[int], -854, false)
      doTest(partial(22 in ?:set[uint8]), {0u8, 255u8, 6u8}, true)



    test [
      """"left and right" should return a predicate that combines "left" and""",
      """"right" with a logical "and"."""
    ].join($' '):
      proc doTest[T](left, right: Predicate[T]; value: T; expected: bool) =
        let actual = left.`and`(right).test(value)

        check:
          actual == expected


      doTest(alwaysFalse[char], alwaysTrue, '\r', false)
      doTest(partial(?:int > 0), partial(?_ < 100), 91, true)



    test [
      """"left or right" should return a predicate that combines "left and"""",
      """"right" with a logical "or"."""
    ].join($' '):
      proc doTest[T](left, right: Predicate[T]; value: T; expected: bool) =
        let actual = left.`or`(right).test(value)

        check:
          actual == expected


      doTest(alwaysTrue[Positive], i => i > 8, 1, true)
      doTest(partial(0 in ?:seq[int]), partial(1 in ?_), @[2, 5, 1, 7], true)



    test [
      """"self.fold(then, `else`).run(value)" should take the "then" path""",
      """when "value" verifies "self"."""
    ].join($' '):
      proc doTest[A; B](self: Predicate[A]; then, `else`: A -> B; value: A) =
        let
          actual = self.tracedFold(then, `else`).run(value)
          expected = trace(Path.Then, then.run(value))

        check:
          actual == expected


      doTest(alwaysTrue[Unit], itself[Unit], itself[Unit], unit())
      doTest((i: int16) => i > 500, partial($ ?_), _ => "abc", 542)



    test [
      """"self.fold(then, `else`).run(value)" should take the "else" path""",
      """when "value" does not verify "self"."""
    ].join($' '):
      proc doTest [A; B](self: Predicate[A]; then, `else`: A -> B; value: A) =
        let
          actual = self.tracedFold(then, `else`).run(value)
          expected = trace(Path.Else, `else`.run(value))

        check:
          actual == expected


      doTest(alwaysFalse[int16], partial($ ?_), _ => "abc", 542)
      doTest(isEmptyOrWhitespace, partial(len(?_)), _ => 0, " a ")



main()
