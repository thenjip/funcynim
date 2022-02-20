import common/["project.nims"]



when isMainModule:
  proc main () =
    baseBuildDir().rmDir()



  main()
