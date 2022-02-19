when isMainModule:
  import common/["project.nims"]
  import test_common/["cmd.nims"]



  proc main() =
    Task.TestC.compileRunAllTests()



  main()
