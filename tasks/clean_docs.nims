import common/["dirs.nims", "project.nims"]

import pkg/taskutils/[optional]



when isMainModule:
  proc main () =
    Task.Docs.outputDir().get().rmDir()



  main()
