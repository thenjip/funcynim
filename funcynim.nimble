version = "0.1.0"
author = "thenjip"
description = "Utility library to ease functional programming in Nim."
license = "MIT"

requires "nim >= 1.2.0"



import std/[macros, options, os, sequtils, strformat, strutils, sugar]



# Utils

func findFirst [I, T](a: array[I, T]; predicate: T -> bool): Option[I] =
  result = I.none()

  for i, item in a:
    if item.predicate():
      return i.some()



func stripTrailing (input: string; chars: set[char]): string =
  result = input

  result.removeSuffix(chars)


func stripTrailing (input: string; c: char): string =
  input.stripTrailing({c})



func joinWithSpace (a: openArray[string]): string =
  a.join($' ')



# Paths

type
  AbsoluteDir = string
  AbsoluteFile = string

  RelativeDir = string
  RelativeFile = string



func nimbleProjectName (): string =
  projectName().stripTrailing(Digits).stripTrailing('_')


func nimcacheDirName (): string =
  ".nimcache"


func binOutDirName (): string =
  "bin"



func nimcacheDir (): AbsoluteDir =
  projectDir() / nimcacheDirName()



proc tryRmDir (dir: AbsoluteDir) =
  if system.existsDir(dir):
    dir.rmDir()



iterator files (dir: AbsoluteDir; ext: string; relative: bool): RelativeFile =
  for file in dir.walkDirRec(relative = relative):
    if file.endsWith(fmt"{ExtSep}{ext}"):
      yield file


iterator nimModules (dir: AbsoluteDir): RelativeFile =
  for file in dir.files("nim", true):
    yield file


iterator libNimModules (): RelativeFile =
  yield fmt"{nimbleProjectName()}{ExtSep}nim"

  for module in nimModules(projectDir() / nimbleProjectName()):
    yield nimbleProjectName() / module



# Nim command line

func toNimLongOption (name, value: string): string =
  fmt"--{name}:{value.quoteShell()}"



func toNimLongOptions (
  pairs: openArray[tuple[name, value: string]]
): seq[string] =
  pairs.map(pair => pair.name.toNimLongOption(pair.value))



# Environment variables

type
  EnvVar {.pure.} = enum
    NimBackend

  Backend {.pure.} = enum
    C,
    Cxx,
    Js

  InvalidEnvVarValueError = object of CatchableError



func shellNames (): array[EnvVar, string] =
  const names = ["NIM_BACKEND"]

  names


func shellName (self: EnvVar): string =
  shellNames()[self]



func nimBackendShellValues (): array[Backend, string] =
  const shellValues = ["c", "cxx", "js"]

  shellValues


func shellValue (self: Backend): string =
  nimBackendShellValues()[self]



func nimBackendNimCmdNames (): array[Backend, string] =
  const cmdNames = ["cc", "cpp", "js"]

  cmdNames


func nimCmdName (self: Backend): string =
  nimBackendNimCmdNames()[self]



func newInvalidEnvVarValueError (
  name: string;
  value: string
): ref InvalidEnvVarValueError =
  InvalidEnvVarValueError.newException(&"{name}=\"{value}\"")


func newInvalidEnvVarValueError (
  self: EnvVar;
  value: string
): ref InvalidEnvVarValueError =
  newInvalidEnvVarValueError(self.shellName(), value)



proc getEnvOrEmpty (key: string): string =
  key.getEnv()


proc tryReadEnv (key: string): Option[string] =
  key.some().filter(existsEnv).map(getEnvOrEmpty)


proc tryReadEnv [T](self: EnvVar; parseValue: string -> T): Option[T] =
  self
    .shellName()
    .tryReadEnv()
    .map(parseValue)


proc readNimBackendFromEnv (): Option[Backend] =
  const envVar = EnvVar.NimBackend

  func parseBackendOrError (envValue: string): Backend =
    let found =
      nimBackendShellValues().findFirst(expected => envValue == expected)

    if found.isSome():
      found.get()
    else:
      raise newInvalidEnvVarValueError(envVar, envValue)

  envVar.tryReadEnv(parseBackendOrError)



# Task API

type
  Task {.pure.} = enum
    Test
    Docs
    CleanTest
    CleanDocs
    Clean

  OutputDirBuilder = proc (): Option[AbsoluteDir] {.nimcall, noSideEffect.}



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
    nimBackendShellValues().join($'|')

  [
    "Build the tests and run them.",
    "The backend can be specified with the environment variable",
    fmt""""{EnvVar.NimBackend.shellName()}=({backendChoice()})"."""
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



func baseOutputDir (self: Task): AbsoluteDir =
  nimCacheDir() / self.name()



func noOutputDir (): Option[AbsoluteDir] =
  AbsoluteDir.none()


func taskOutputDirBuilders (): array[Task, OutputDirBuilder] =
  const builders =
    [
      () => Task.Test.baseOutputDir().some(),
      () => Task.Docs.baseOutputDir().some(),
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

macro define (self: static Task; body: untyped): untyped =
  let
    selfIdent = self.identifier()
    selfLit = self.newLit()

  quote do:
    task `selfIdent`, `selfLit`.description():
      `body`


macro run (self: static Task) =
  fmt"{self.identifier()}Task".newCall()



define Task.Test:
  func defaultBackend (): Backend =
    Backend.C


  func buildSrcGenDir (module: RelativeFile; backend: Backend): AbsoluteDir =
    Task.Test.outputDir().get() / backend.shellValue() / module


  func handleJsFlags (backend: Backend): seq[string] =
    if backend == Backend.Js:
      @["-d:nodejs"]
    else:
      @[]


  func buildCompileCmd (module: RelativeFile; backend: Backend): string =
    let
      srcGenDir = module.buildSrcGenDir(backend)
      binOutDir = srcGenDir / binOutDirName()

      jsFlags = backend.handleJsFlags()
      outDirOptions =
        [("nimcache", srcGenDir), ("outdir", binOutDir)].toNimLongOptions()

    @[backend.nimCmdName(), "-r"]
      .concat(jsFlags, outDirOptions, @[module.quoteShell()])
      .join($' ')


  let backend = readNimBackendFromEnv().get(defaultBackend())

  for module in libNimModules():
    module.buildCompileCmd(backend).selfExec()



define Task.Docs:
  func buildCompileCmd (module: RelativeFile): string =
    const
      repoUrl = "https://github.com/thenjip/funcynim"
      mainGitBranch = "main"

    let longOptions =
      [
        ("index", "on"),
        ("docRoot", projectDir()),
        ("outdir", Task.Docs.outputDir().get()),
        ("git.url", repoUrl),
        ("git.devel", mainGitBranch),
        ("git.commit", mainGitBranch)
      ].toNimLongOptions()

    @["doc"]
      .concat(longOptions & "--project", @[module.quoteShell()])
      .join($' ')


  ($CurDir / fmt"{nimbleProjectName()}{ExtSep}nim").buildCompileCmd().selfExec()

  withDir Task.Docs.outputDir().get():
    const cmd = [
      "buildIndex",
      "out".toNimLongOption(fmt"index{ExtSep}html".quoteShell()),
      CurDir.`$`().quoteShell()
    ]

    cmd.join($' ').selfExec()



define Task.CleanTest:
  Task.Test.outputDir().get().tryRmDir()



define Task.CleanDocs:
  Task.Docs.outputDir().get().tryRmDir()



define Task.Clean:
  Task.CleanTest.run()
  Task.CleanDocs.run()
