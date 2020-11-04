import "common.nims"
import test/[env, nimbackend]

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



func findFirst [T](self: openArray[T]; predicate: T -> bool): Optional[T] =
  result = T.none()

  for item in self:
    if item.predicate():
      return item.some()



proc parseNimBackend (value: EnvVarValue): ParseEnvResult[Backend] =
  func invalidValue (): ref ParseEnvError =
    EnvVar.NimBackend.name().parseEnvError(fmt"Invalid backend: {value}")

  toSeq(Backend.items())
    .map(backend => (backend: backend, envVarValue: backend.envVarValue()))
    .findFirst(pair => pair.envVarValue == value)
    .map(pair => pair.backend)
    .ifSome(parseEnvSuccess, () => invalidValue.parseEnvFailure(Backend))


proc tryParseNimBackend (): Optional[ParseEnvResult[Backend]] =
  EnvVar
    .NimBackend
    .name()
    .tryParse(findInEnv, parseNimBackend)



func defaultBackend (): Backend =
  Backend.C


func binOutDirName (): string =
  "bin"


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


func jsFlags (backend: Backend): seq[string] =
  if backend == Backend.Js:
    @["-d:nodejs"]
  else:
    @[]


func compileAndRunCmd (module: AbsoluteFile; backend: Backend): string =
  let
    srcGenDir = backend.srcGenDir()
    binOutDir = srcGenDir / binOutDirName()
    jsFlags = backend.jsFlags()
    outDirOptions =
      {"nimcache": srcGenDir, "outdir": binOutDir}.toNimLongOptions()

  @[backend.nimCmdName(), "run".nimLongOption()]
    .concat(jsFlags, outDirOptions, @[module.quoteShell()])
    .cmdLine()



when isMainModule:
  proc main () =
    let backend =
      tryParseNimBackend()
        .getOr(() => defaultBackend().parseEnvSuccess())
        .unboxSuccessOrRaise()

    for module in libNimModules():
      module.compileAndRunCmd(backend).selfExec()



  main()
