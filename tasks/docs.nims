import common/[filetypes, nimcmdline, "project.nims"]

import std/[options, os, sequtils, strutils, sugar]



const BuildDir = Task.Docs.buildDir().get()



func html(f: FilePath): FilePath =
  f.addFileExt("html")



func docCmdOptions(): seq[string] =
  const
    repoUrl = "https://github.com/thenjip/funcynim"
    mainGitBranch = "main"

  let valuedOptions =
    {
      "outdir": BuildDir,
      "index": "on",
      "git.url": repoUrl,
      "git.devel": mainGitBranch,
      "git.commit": mainGitBranch
    }.map(toLongOption)

  "project".toLongOption() & valuedOptions


func docCmd(): string =
  const mainModule = srcDir() / packageName().nim()

  @["doc"].concat(docCmdOptions(), @[mainModule.quoteShell()]).toCmdLine()



when isMainModule:
  proc main() =
    docCmd().selfExec()

    withDir BuildDir:
      "theindex".html().cpFile("index".html())



  main()
