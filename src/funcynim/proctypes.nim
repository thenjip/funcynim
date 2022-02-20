##[
  Utilities to work with procedure types.
]##


import nimnodes

import std/[macros]



macro resultType* (T: typedesc[proc]): typedesc =
  #[
    AST of `T`: typedesc[proc[resultType, arg1Type, ...]]
  ]#
  T.getType().secondChild().secondChild().getTypeInst()


template resultType* (p: proc): typedesc =
  p.typeof().resultType()



macro paramType* (T: typedesc[proc]; position: static Natural): typedesc =
  ##[
    Parameter positions start at 0.
  ]##
  let
    paramPos = 2 + position
    procTypeNode = T.getType().secondChild()

  procTypeNode.expectMinLen(paramPos)

  procTypeNode[paramPos].getTypeInst()


template paramType* (p: proc; position: static Natural): typedesc =
  ##[
    Parameter positions start at 0.
  ]##
  p.typeof().paramType(position)
