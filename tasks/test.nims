import common/"dirs.nims" as taskdirs
import common/["project.nims"]
import test/["env.nims", taskconfig]

import pkg/taskutils/[
  cmdline,
  dirs,
  envtypes,
  filetypes,
  nimcmdline,
  optional,
  parseenv,
  result
]

import std/[os, sequtils, strformat, sugar]



func defaultBackend (): Backend =
  Backend.C


func binGenDirName (): string =
  "bin"



func tryParseEnvConfig (): TaskConfig =
  taskConfig(tryParseNimBackend.failOr(defaultBackend))



func srcGenDir (backend: Backend): AbsoluteDir =
  Task.Test
    .outputDir()
    .map(outputDir => outputDir / backend.envVarValue())
    .map(
      proc (backendDir: auto): auto =
        if backend == Backend.Js:
          backendDir
        else:
          backendDir.crossCompilerCache()
    ).get()


func binGenDir (backend: Backend): AbsoluteDir =
  let srcGenDir = backend.srcGenDir()

  if backend == Backend.Js:
    srcGenDir
  else:
    srcGenDir / binGenDirName()



func jsFlags (backend: Backend): seq[string] =
  if backend == Backend.Js:
    @["-d:nodejs"]
  else:
    @[]



func compileAndRunCmdOptions (
  module: AbsoluteFile;
  config: TaskConfig
): seq[string] =
  let backend = config.backend

  @["run".nimLongOption()]
    .concat(
      backend.jsFlags(),
      {
        "nimcache": backend.srcGenDir(),
        "outdir": backend.binGenDir()
      }.toNimLongOptions()
    )


func compileAndRunCmd (module: AbsoluteFile; config: TaskConfig): string =
  @[config.backend.nimCmdName()]
    .concat(module.compileAndRunCmdOptions(config), @[module.quoteShell()])
    .cmdLine()



when isMainModule:
  proc main () =
    let config = tryParseEnvConfig()

    for module in libNimModules():
      module.compileAndRunCmd(config).selfExec()



  main()
