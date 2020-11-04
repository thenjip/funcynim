##[
  An implementation of partial function application for Nim.

  It is inspired by the way Scala does it (with underscores as arguments), but
  it takes into account Nim's current limitations on type inference.
]##



import ifelse, nimnodes

import std/[macros, sequtils, strformat, strutils, sugar, tables]



type
  LambdaParam = tuple
    name: string
    argType: NimNode

  CallExpr = tuple
    callee: NimNode
    args: seq[NimNode]

  SplitArgPair = tuple
    partialParams: OrderedTable[Natural, LambdaParam]
    callArgs: seq[NimNode]



func lambdaParam (name: string; `type`: NimNode): LambdaParam =
  (name, `type`)


func callExpr (callee: NimNode; args: seq[NimNode]): CallExpr =
  (callee, args)



func partialParamPrefix* (): string =
  $'?'


func partialTypedParamPrefix* (): string =
  partialParamPrefix() & ':'



func newLambda* (
  params: seq[NimNode];
  body: NimNode;
  returnType: NimNode
): NimNode =
  newProc(newEmptyNode(), returnType & params, body, nnkLambda, newEmptyNode())



func isUnderscore* (n: NimNode): bool =
  n.kind() == nnkIdent and n.strVal() == $'_'



func collectArgs (call: NimNode): seq[NimNode] =
  call[call.low().succ() .. call.high()]



func toCallExpr (call: NimNode): CallExpr =
  callExpr(call.firstChild(), call.collectArgs())


func toCommandCallExpr (call: NimNode): CallExpr =
  call.toCallExpr()


func toPrefixCallExpr (call: NimNode): CallExpr =
  callExpr(nnkAccQuoted.newTree(call.firstChild()), @[call.secondChild()])


func toStrLitCallExpr (call: NimNode): CallExpr =
  call.toPrefixCallExpr()


func toInfixCallExpr (call: NimNode): CallExpr =
  callExpr(nnkAccQuoted.newTree(call.firstChild()), call.collectArgs())



func callExprBuilder (kind: NimNodeKind): toCallExpr.typeof() =
  case kind:
    of nnkCall:
      toCallExpr
    of nnkCommand:
      toCommandCallExpr
    of nnkPrefix:
      toPrefixCallExpr
    of nnkCallStrLit:
      toStrLitCallExpr
    of nnkInfix:
      toInfixCallExpr
    else:
      raise newException(ValueError, fmt"Expected a call AST, but got: {kind}")


func astToCallExpr (call: NimNode): CallExpr =
  call.kind().callExprBuilder()(call)



func isValidPrefix (prefix: NimNode): bool =
  prefix.kind() == nnkIdent and prefix.strVal().startsWith(partialParamPrefix())


func isPartialParamPrefixed (arg: NimNode): bool =
  arg.kind() == nnkPrefix and arg.firstChild().isValidPrefix()


func splitArgs (callExpr: CallExpr): SplitArgPair =
  for pos, arg in callExpr.args:
    if arg.isPartialParamPrefixed():
      let paramName = nskParam.genSym(fmt"a{pos}")

      result.partialParams[pos] =
        paramName.strVal().lambdaParam(
          arg.firstChild().strVal().`==`(partialParamPrefix()).ifElse(
            () => ident"auto",
            () => arg.secondChild()
          )
        )
      result.callArgs.add(paramName.strVal().ident())
    else:
      result.callArgs.add(arg)



macro partial* (call: untyped{call}): untyped =
  ##[
    Transforms a call expression of any kind into a lambda expression.

    The macro understands 2 types of placeholders:
      - The identifier placeholder (examples: ``?_``, ``?a``).

        Its type will be inferred by the compiler. The macro does not make use
        of the identifier after the ``?``.
      - The typed placeholder (examples: ``?:string``, ``?:ref Exception``).

        The type of the parameter of the generated lambda expression at that
        position will be the one passed after the ``?:``.

    **Examples:**
      .. code-block:: nim

        import std/[sugar]

        proc plus [T](a, b: T): T =
          a + b

        proc chain [A; B; C](f: A -> B; g: B -> C): A -> C =
          (a: A) => a.f().g()

        proc `not` [T](predicate: T -> bool): T -> bool =
          predicate.chain(partial(not ?_))

        let
          f1 = partial(0 + ?:int)
          f2 = partial(5.plus(?:int))
          f3 = partial(plus(?:uint, 6))
          f4 = partial(?:string & ?:char)
          f5 = not partial(?:int < 0)

        doAssert(f1(1) == 1)
        doAssert(f2(10) == 15)
        doAssert(f3(154u) == 160u)
        doAssert(f4("abc", 'd') == "abcd")
        doAssert(f5(1))
  ]##
  let
    callExpr = call.astToCallExpr()
    splitArgs = callExpr.splitArgs()

  newLambda(
    toSeq(splitArgs.partialParams.values())
      .mapIt(newIdentDefs(it.name.ident(), it.argType))
    ,
    newStmtList(callExpr.callee.newCall(splitArgs.callArgs)),
    ident"auto"
  )



when isMainModule:
  import chain

  import std/[os, unittest]



  func plus [A: SomeNumber; B: SomeNumber; R: SomeNumber](a: A; b: B): R =
    a + b


  func ternaryProc (a: char; b: int; c: string): bool =
    true


  func sum [N: SomeNumber](a, b, c: N): N =
    a + b + c



  proc main () =
    suite currentSourcePath().splitFile().name:
      test """"partial(a + ?:N)" should return a lambda expression equivalent to "(b: N) => a + b".""":
        proc doTest [N: SomeNumber](a, b: N) =
          let
            actual = partial(a + ?:N)(b)
            expected = a + b

          check:
            actual == expected


        doTest(1, 9)
        doTest(11563.7, -5.568)



      test """"partial($ ?:T)" should return a lambda expression equivalent to "(a: T) => $a".""":
        proc doTest [T](a: T) =
          let
            actual = partial($ ?:T)(a)
            expected = $a

          check:
            actual == expected


        doTest('a')
        doTest("a")
        doTest(-8)
        doTest(Nan)
        doTest({0: @[0, 1, 2]})



      test """"partial(f(a, ?:B))" should return a lambda expression equivalent to "(b: B) => f(a, b)".""":
        proc doTest [A; B; R](f: (A, B) -> R; a: A; b: B) =
          let
            actual = partial(f(a, ?:B))(b)
            expected = f(a, b)

          check:
            actual == expected


        doTest(plus[int, int, int], 0, 1)
        doTest(plus[uint32, uint32, uint32], 5646532, 11)
        doTest((a: string, b: string) => a & b, "a", "b")



      test """"partial(f(?:A, b, ?:C))" should return a lambda expression equivalent to "(a: A, c: C) => f(a, b, c)".""":
        proc doTest [A; B; C; R](f: (A, B, C) -> R; a: A; b: B; c: C) =
          let
            actual = partial(f(?:A, b, ?:C))(a, c)
            expected = f(a, b, c)

          check:
            actual == expected


        doTest(sum[uint16], 3, 5, 7)
        doTest(ternaryProc, 'a', 1, "")



      test """"f.chain(partial(g(?b, c)))" should be equivalent to "f.chain(b => b.g(c))(a)".""":
        proc doTest [A; B; C; D](f: A -> B; g: (B, C) -> D; a: A; c: C) =
          let
            actual = f.chain(partial(g(?b, c)))(a)
            expected = f.chain(b => b.g(c))(a)

          check:
            actual == expected


        doTest((a: int) => $a, (b: string, c: Positive) => b & $c, 1, 1)



  main()
