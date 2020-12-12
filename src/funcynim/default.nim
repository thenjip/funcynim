proc default* [T](): T =
  T.default()



when isMainModule:
  import std/[os, unittest]



  proc main () =
    suite currentSourcePath().splitFile().name:
      discard



  main()
