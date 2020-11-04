import "common.nims"



when isMainModule:
  proc main () =
    nimbleCacheDir().rmDir()



  main()
