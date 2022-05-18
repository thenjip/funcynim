##[
  This module provides sugar for writing `Unit -> T` procedures.

  Since ``1.1.0``.
]##

#[
  TODO: Add support for pragmas.
]#



import unit

import std/[sugar]



export `->`, `=>`



template `->`*(_: Unit; R: typedesc): typedesc[proc] =
  ##[
    Allows to write `() -> T` instead of `Unit -> T`.

    Pragmas are not supported.

    Since ``1.1.0``.
  ]##
  Unit -> R



template `=>`*[R](u: Unit; body: R): proc =
  ##[
    Allows to write `() => body` instead of `(_: Unit) => body`.

    Pragmas are not supported.

    Since ``1.1.0``.
  ]##
  (_: Unit) => body
