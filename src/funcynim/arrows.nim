import unit

import std/[sugar]



export `->`, `=>`



template `->`*(_: Unit; R: typedesc): typedesc[proc] =
  Unit -> R



template `=>`*[R](u: Unit; body: R): proc =
  (_: Unit) => body
