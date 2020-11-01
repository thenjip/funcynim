func srcDirName (): string =
  "src"



version = "0.1.0"
author = "thenjip"
description = "Utility library to ease functional programming in Nim."
license = "MIT"

srcDir = srcDirName()

requires "nim >= 1.4.0"
requires "https://github.com/thenjip/taskutils >= 0.1.0"



import pkg/taskutils/[
  cmdline,
  dirs,
  envtypes,
  fileiters,
  filetypes,
  nimcmdline,
  optional,
  parseenv,
  result,
  unit
]

import std/[macros, os, sequtils, strformat, strutils, sugar]



# Utils

func findFirst [I, T](a: array[I, T]; predicate: T -> bool): Optional[I] =
  result = I.none()

  for i, item in a:
    if item.predicate():
      return i.some()



func nimbleProjectName (): string =
  "funcynim"


func binOutDirName (): string =
  "bin"


func nimbleCacheDir (): AbsoluteDir =
  getCurrentDir() / nimbleCache()



proc tryRmDir (dir: AbsoluteDir) =
  if system.existsDir(dir):
    dir.rmDir()


proc findEnvValue (name: EnvVarName): Optional[EnvVarValue] =
  name.findValue(existsEnv, (name) => name.getEnv())



iterator libNimModules (): AbsoluteFile =
  yield srcDirName() / nimbleProjectName().addFileExt(nimExt())

  for module in absoluteNimModules(srcDirName() / nimbleProjectName()):
    yield module



# Environment variables

type
  EnvVar {.pure.} = enum
    NimBackend

  Backend {.pure.} = enum
    C,
    Cxx,
    Js



func envVarNames (): array[EnvVar, string] =
  const names = ["NIM_BACKEND"]

  names


func name (self: EnvVar): string =
  envVarNames()[self]



func nimBackendEnvVarValues (): array[Backend, string] =
  const values = ["c", "cxx", "js"]

  values


func envVarValue (self: Backend): string =
  nimBackendEnvVarValues()[self]



func nimBackendNimCmdNames (): array[Backend, string] =
  const cmdNames = ["cc", "cpp", "js"]

  cmdNames


func nimCmdName (self: Backend): string =
  nimBackendNimCmdNames()[self]



proc parseNimBackend (envValue: string): ParseEnvResult[Backend] =
  func invalidValue (): ref ParseEnvError =
    EnvVar.NimBackend.name().parseEnvError(fmt"Invalid backend: {envValue}")

  nimBackendEnvVarValues()
    .findFirst(val => val == envValue)
    .ifSome(parseEnvSuccess, () => invalidValue.parseEnvFailure(Backend))


proc tryParseNimBackend (): Optional[ParseEnvResult[Backend]] =
  EnvVar
    .NimBackend
    .name()
    .tryParse(findEnvValue, parseNimBackend)



# Task API

type
  Task {.pure.} = enum
    Test
    Docs
    CleanTest
    CleanDocs
    Clean

  OutputDirBuilder = proc (): Optional[AbsoluteDir] {.nimcall, noSideEffect.}



func taskNames (): array[Task, string] =
  const names = [
    "test",
    "docs",
    "clean_test",
    "clean_docs",
    "clean"
  ]

  names


func name (self: Task): string =
  taskNames()[self]


func identifier (self: Task): NimNode =
  self.name().ident()



func testTaskDescription (): string =
  func backendChoice (): string =
    nimBackendEnvVarValues().join($'|')

  [
    "Build the tests and run them.",
    "The backend can be specified with the environment variable",
    fmt""""{EnvVar.NimBackend.name()}=({backendChoice()})"."""
  ].join($' ')


func cleanOtherTaskDescription (cleaned: Task): string =
  fmt"""Remove the build directory of the "{cleaned.name()}" task."""


func taskDescriptions (): array[Task, string] =
  const descriptions =
    [
      testTaskDescription(),
      "Build the API doc.",
      Task.Test.cleanOtherTaskDescription(),
      Task.Docs.cleanOtherTaskDescription(),
      "Remove all the build directories."
    ]

  descriptions


func description (self: Task): string =
  taskDescriptions()[self]



func noOutputDir (): Option[AbsoluteDir] =
  AbsoluteDir.none()


func outputInCache (self: Task): AbsoluteDir =
  self.name().outputDir(nimbleCacheDir())


func taskOutputDirBuilders (): array[Task, OutputDirBuilder] =
  const builders =
    [
      () => Task.Test.outputInCache().some(),
      () => Task.Docs.outputInCache().some(),
      noOutputDir,
      noOutputDir,
      noOutputDir
    ]

  builders


func outputDirBuilder (self: Task): OutputDirBuilder =
  taskOutputDirBuilders()[self]


func outputDir (self: Task): Option[AbsoluteDir] =
  self.outputDirBuilder()()



# Nimble tasks.

macro define (self: static Task; body: proc (self: Task)): untyped =
  let
    selfIdent = self.identifier()
    selfLit = self.newLit()
    taskBody = body.newCall(selfLit)

  quote do:
    task `selfIdent`, `selfLit`.description():
      `taskBody`


macro run (self: static Task) =
  fmt"{self.identifier()}Task".newCall()



Task.Test.define(
  proc (task: Task) =
    func defaultBackend (): Backend =
      Backend.C

    func srcGenDir (backend: Backend): AbsoluteDir =
      task
        .outputDir()
        .map(outputDir => outputDir / backend.envVarValue())
        .map(
          proc (backendDir: auto): auto =
            if backend == Backend.Js:
              backendDir
            else:
              backendDir.compilerCache()
        ).get()

    func jsFlags (backend: Backend): seq[string] =
      if backend == Backend.Js:
        @["-d:nodejs"]
      else:
        @[]

    func buildCompileCmd (module: AbsoluteFile; backend: Backend): string =
      let
        srcGenDir = backend.srcGenDir()
        binOutDir = srcGenDir / binOutDirName()
        jsFlags = backend.jsFlags()
        outDirOptions =
          {"nimcache": srcGenDir, "outdir": binOutDir}.toNimLongOptions()

      @[backend.nimCmdName(), "run".longOption()]
        .concat(jsFlags, outDirOptions, @[module.quoteShell()])
        .cmdLine()

    tryParseNimBackend()
      .getOr(() => defaultBackend().parseEnvSuccess())
      .ifSuccess(
        proc (backend: Backend): Unit =
          for module in libNimModules():
            module.buildCompileCmd(backend).selfExec()
        ,
        proc (fail: auto): Unit =
          raise fail()
      ).ignore()
)


Task.Docs.define(
  proc (task: Task) =
    func genDocCmd (): string =
      const
        mainGitBranch = "main"
        mainModule = srcDirName() / nimbleProjectName().addFileExt(nimExt())

      let
        longOptions =
          {
            "outdir": Task.Docs.outputDir().get(),
            "git.url": "https://github.com/thenjip/funcynim",
            "git.devel": mainGitBranch,
            "git.commit": mainGitBranch
          }.toNimLongOptions()

      @["doc"]
        .concat(longOptions & "project".longOption(), @[mainModule.quoteShell()])
        .cmdLine()

    genDocCmd().selfExec()
    withDir task.outputDir().get():
      "theindex".addFileExt("html").cpFile("index".addFileExt("html"))
)


Task.CleanTest.define(
  proc (_: Task) =
    Task.Test.outputDir().get().tryRmDir()
)


Task.CleanDocs.define(
  proc (_: Task) =
    Task.Docs.outputDir().get().tryRmDir()
)


Task.Clean.define(
  proc (_: Task) =
    Task.CleanTest.run()
    Task.CleanDocs.run()
)
