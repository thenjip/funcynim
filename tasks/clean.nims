import common/["dirs.nims"]



when isMainModule:
  proc main () =
    nimbleCacheDir().rmDir()



  main()
