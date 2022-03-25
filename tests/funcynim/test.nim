when isMainModule:
  import pkg/[funcynim]

  import std/[unittest]



  proc main() =
    suite "funcynim":
      test "The module should compile.":
        discard



  main()
