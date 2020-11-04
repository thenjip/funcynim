import "common.nims"

import pkg/taskutils/[cmdline, fileiters, nimcmdline, optional]

import std/[os, sequtils]



func genDocCmdOptions (): seq[string] =
  const
    repoUrl = "https://github.com/thenjip/funcynim"
    mainGitBranch = "main"

  concat(
    @["project".nimLongOption()],
    {
      "outdir": Task.Docs.outputDir().get(),
      "git.url": repoUrl,
      "git.devel": mainGitBranch,
      "git.commit": mainGitBranch
    }.toNimLongOptions()
  )


func genDocCmd (): string =
  const mainModule = srcDirName() / nimbleProjectName().addFileExt(nimExt())

  @["doc"]
    .concat(
      genDocCmdOptions(),
      @["project".nimLongOption()],
      @[mainModule.quoteShell()]
    ).cmdLine()



when isMainModule:
  proc main () =
    genDocCmd().selfExec()

    withDir Task.Docs.outputDir().get():
      "theindex".addFileExt("html").cpFile("index".addFileExt("html"))



  main()
