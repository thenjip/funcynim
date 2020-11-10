import common/["dirs.nims", "project.nims"]

import pkg/taskutils/[optional]



when isMainModule:
  proc main () =
    Task.Test.outputDir().get().rmDir()



  main()
