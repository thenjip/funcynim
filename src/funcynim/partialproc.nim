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
