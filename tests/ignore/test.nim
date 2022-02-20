when isMainModule:
  import pkg/funcynim/[ignore]

  import std/[unittest]



  proc main() =
    suite "ignore":
      discard



  main()
