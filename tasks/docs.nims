import common/["dirs.nims", "project.nims"]

import pkg/taskutils/[cmdline, fileiters, filetypes, nimcmdline, optional]

import std/[os, sequtils]



func html (f: FilePath): FilePath =
  f.addFileExt("html")



func genDocCmdOptions (): seq[string] =
  const
    repoUrl = "https://github.com/thenjip/funcynim"
    mainGitBranch = "main"

  @["project".nimLongOption()]
    .concat(
      {
        "outdir": Task.Docs.outputDir().get(),
        "git.url": repoUrl,
        "git.devel": mainGitBranch,
        "git.commit": mainGitBranch
      }.toNimLongOptions()
    )


func genDocCmd (): string =
  const mainModule = srcDirName() / nimblePackageName().nim()

  @["doc"].concat(genDocCmdOptions(), @[mainModule.quoteShell()]).cmdLine()



when isMainModule:
  proc main () =
    genDocCmd().selfExec()

    withDir Task.Docs.outputDir().get():
      "theindex".html().cpFile("index".html())



  main()
