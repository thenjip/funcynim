# funcynim

[![Build Status](https://github.com/thenjip/funcynim/workflows/Tests/badge.svg?branch=main)](https://github.com/thenjip/funcynim/actions?query=workflow%3A"Tests"+branch%3A"main")
[![Licence](https://img.shields.io/github/license/thenjip/funcynim.svg)](https://raw.githubusercontent.com/thenjip/funcynim/main/LICENSE)

Utility library to ease functional programming in Nim.

This project focuses on maximum backend compatibility, that is:

- C
- C++
- Objective-C
- JavaScript
- NimScript (not tested yet)
- Compile time expressions in all the backends above

## Installation

```sh
nimble install 'https://github.com/thenjip/funcynim'
```

## Dependencies

- [`nim`](https://nim-lang.org/) >= `1.6.0`
- [`nim_curry`](https://nimble.directory/pkg/nimcurry) >= `0.1.0`

## Documentation

- [API](https://thenjip.github.io/funcynim)

## Overview

### The Unit type

#### Adapting a procedure returning `void`

```Nim
import pkg/funcynim/[unit]


proc println*(s: string): Unit =
  echo(s)
  #[
    No need for explicit return.
    Since "Unit" is a single valued type, default initialization has already
    initialized "result" to the only valid value.
  ]#
```

### Procedure composition

```Nim
func pow2[N: SomeNumber](n: N): N =
  n * n

proc debugPrintlnAndReturn[T](x: T): T =
  debugEcho(x)
  x

when isMainModule:
  import pkg/funcynim/[chain]
  import std/[sugar]

  const
    input = 4.Natural
    got = pow2[input.typeof()].chain(debugPrintlnAndReturn)(input)

  doAssert(got == input * input)
```

### Procedure aliases for operators

#### `discard` operator

```Nim
import pkg/funcynim/[ignore]
import std/[sequtils]

discard
  "abc"
    .`&`('\n')
    .filterIt(it == 'b')
"abc"
  .`&`('\n')
  .filterIt(it == 'b')
  .ignore()
```

#### `if ...: else: ...` expression as a `proc`

```Nim
import pkg/funcynim/[fold, into, unit]
import std/[os, sugar]

paramCount()
  .`==`(0)
  .fold((_: Unit) => "no args", (_: Unit) => "got args")
  .into(s => echo(s))
```

#### Common math operators

```Nim
import pkg/funcynim/[operators]

doAssert(5.plus(5).divInt(5) == 2)
doAssert(not true.logicOr(false).logicNot())
```

### Currying

Thanks to [nim_curry](https://nimble.directory/pkg/nimcurry).

```Nim
import pkg/funcynim/[curry, ignore, run, unit]
import std/[terminal]

proc writeLn(f: File; styles: set[Style]; self: string): Unit {.curry.} =
  f.styledWriteLine(styles, self)

writeLn(stdout)
  .with({styleUnderscore})
  .run("abc")
  .ignore()
```

### Partial application

Not to be confused with [currying](https://en.wikipedia.org/wiki/Currying#Contrast_with_partial_function_application).

```Nim
import pkg/funcynim/[chain, operators, partialproc]

let f =
  partial(1 + ?:int) # (i: int) => 1 + i
  .chain(partial(1.mult(?_))) # (_: auto) => 1.mult(_)

doAssert(f(10) == 11)
```

### And more

See [documentation](#documentation).
