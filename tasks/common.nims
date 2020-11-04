import "../funcynim.nimble"

import pkg/taskutils/[dirs, envtypes, fileiters, filetypes, optional, parseenv]

import std/[os, sugar]



export funcynim



type
  OutputDirBuilder = proc (): Optional[AbsoluteDir] {.nimcall, noSideEffect.}



func nimbleProjectName* (): string =
  "funcynim"



func nimbleCacheDir* (): AbsoluteDir =
  getCurrentDir() / nimbleCache()



func noOutputDir (): Option[AbsoluteDir] =
  AbsoluteDir.none()


func outputInCache (self: Task): AbsoluteDir =
  self.name().outputIn(nimbleCacheDir())


func taskOutputDirBuilders (): array[Task, OutputDirBuilder] =
  const builders: result.typeof() =
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


func outputDir* (self: Task): Option[AbsoluteDir] =
  self.outputDirBuilder()()



proc findInEnv* (name: EnvVarName): Optional[EnvVarValue] =
  name.findValue(existsEnv, (name) => name.getEnv())



iterator libNimModules* (): AbsoluteFile =
  yield srcDirName() / nimbleProjectName().addFileExt(nimExt())

  for module in absoluteNimModules(srcDirName() / nimbleProjectName()):
    yield module
