##[
  This module provides an API to manipulate and combine predicates (procedures
  of type `T -> bool`).

  Since ``1.1.0``.
]##



import
  chain, curry, fold, into, operators, run, unit,

  std/[sugar]



type
  Predicate*[T] = ## Since ``1.1.0``.
    T -> bool



proc test*[T](self: Predicate[T]; value: T): bool =
  ## Since ``1.1.0``.
  self.run(value)



func `not`*[T](self: Predicate[T]): Predicate[T] =
  ## Since ``1.1.0``.
  self.chain(logicNot)



func fold*[A; B](self: Predicate[A]; then, `else`: A -> B): A -> B =
  ## Since ``1.1.0``.
  (value: A) =>
    self
      .test(value)
      .fold((_: Unit) => then.run(value), (_: Unit) => `else`.run(value))



func combine*[T](
  left: Predicate[T];
  right: Predicate[T];
  combiner: (right: bool) -> ((left: bool) -> bool)
): Predicate[T] =
  ##[
    Combines `left` and `right` predicates with the given curried `combiner`.

    Since ``1.1.0``.
  ]##
  (input: T) => left.test(input).into(combiner.with(right.test(input)))


func combine*[T](
  left: Predicate[T];
  right: Predicate[T];
  combiner: (left: bool, right: bool) -> bool
): Predicate[T] =
  ##[
    Combines `left` and `right` predicates with the given `combiner`.

    Since ``1.1.0``.
  ]##
  let curriedCombiner = (right: bool) => ((left: bool) => combiner(left, right))

  left.combine(right, curriedCombiner)



func `and`*[T](left, right: Predicate[T]): Predicate[T] =
  ##[
    Combines `left` and `right` predicates with the short circuiting `and`.

    Since ``1.1.0``.
  ]##
  left.combine(right, logicAnd)


func `or`*[T](left, right: Predicate[T]): Predicate[T] =
  ##[
    Combines `left` and `right` predicates with the short circuiting `or`.

    Since ``1.1.0``.
  ]##
  left.combine(right, logicOr)



func alwaysFalse*[T](_: T): bool =
  ## Since ``1.1.0``.
  false


func alwaysTrue*[T](_: T): bool =
  ## Since ``1.1.0``.
  true
