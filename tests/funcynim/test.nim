when isMainModule:
  import
    pkg/[funcynim],

    std/[unittest]



  proc main() =
    suite "funcynim":
      test "The module should compile.":
        discard



  main()
