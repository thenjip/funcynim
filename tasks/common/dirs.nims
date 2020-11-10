import "project.nims"

import pkg/taskutils/[dirs, filetypes, optional]

import std/[os, sugar]



func nimbleCacheDir* (): AbsoluteDir =
  getCurrentDir() / nimbleCache()



type
  OutputDirBuilder = proc (): Optional[AbsoluteDir] {.nimcall, noSideEffect.}



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
