##[
  Procedures to alias common math and logical operators.

  They may be handy to avoid quoted calls in multiline statements or to pass an
  operator as a procedure in a call.
]##



proc plus* [T](x, y: T): T =
  x + y


proc plus1* [T](x: T): T =
  x.plus(1.T)


proc minus* [T](x, y: T): T =
  x - y


proc mult* [T](x, y: T): T =
  x * y


func divInt* [T: SomeInteger](x, y: T): T =
  x div y


func divFloat* [T: SomeFloat](x, y: T): T =
  x / y


func modulo* [T: SomeInteger](x, y: T): T =
  x mod y



func next* [T: Ordinal](x: T): T =
  x.succ(1)


func prev* [T: Ordinal](x: T): T =
  x.pred(1)



proc less* [T](x, y: T): bool =
  x < y


proc lessOrEq* [T](x, y: T): bool =
  x <= y


proc equal* [T](x, y: T): bool =
  x == y


proc greaterOrEq* [T](x, y: T): bool =
  x >= y


proc greater* [T](x, y: T): bool =
  x > y



func logicNot* (x: bool): bool =
  not x


func logicAnd* (x, y: bool): bool =
  x and y


func logicOr* (x, y: bool): bool =
  x or y
