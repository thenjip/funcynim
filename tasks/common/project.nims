import filetypes

import "funcynim.nimble"

import std/[options, os, strutils]



export funcynim except srcDirName, taskBuildDirName, taskScriptDirName



func packageName*(): string =
  "funcynim"



func nimExt(): string =
  "nim"


func nim*(f: FilePath): FilePath =
  f.addFileExt(nimExt())



func srcDir*(): RelativeDir =
  ##[
    Returns the path to the `src` directory relative to the project root
    directory.
  ]##
  srcDirName()


func testDir*(): RelativeDir =
  "tests"


func baseBuildDir*(): RelativeDir =
  ##[
    Returns the path to the parent build directory for all tasks relative to the
    project root directory.
  ]##
  taskBuildDirName()


func buildDir*(self: Task): Option[RelativeDir] =
  ##[
    Returns the path to the task build directory relative to the project root
    directory, if `self` can generate files.

    Otherwise, return an empty `Option`.
  ]##
  const nonGenerativeTasks = {Task.Clean}

  if self in nonGenerativeTasks:
    RelativeDir.none()
  else:
    baseBuildDir().`/`(self.name()).some()



iterator filesRec*(dir: DirPath; ext: string; relative: bool): FilePath =
  ##[
    Recursively looks for the files in the directory `dir` with the extension
    `ext`.

    If `relative = true`, the yielded paths will be relative to `dir`.
    Otherwise, the yielded paths are `dir / yielded`.

    Complete absolute paths can be obtained by passing `getCurrentDir() / dir`
    as the first parameter.

    `ext` should not include the separator.

    Symlinks are not followed.
  ]##
  for file in dir.walkDirRec(relative = relative):
    if file.endsWith(ExtSep & ext):
      yield file


iterator relativeFilesRec*(dir: DirPath; ext: string): RelativeFile =
  ##[
    Recursively looks for the files in the directory `dir` with the extension
    `ext`.

    The yielded paths are relative to `dir`.

    `ext` should not include the separator.

    Symlinks are not followed.
  ]##
  for file in dir.filesRec(ext, relative = true):
    yield file


iterator relativeNimModulesRec*(dir: DirPath): RelativeFile =
  ##[
    Recursively looks for the Nim modules in the directory `dir`.

    The yielded paths are relative to `dir`.

    Symlinks are not followed.
  ]##
  for file in dir.relativeFilesRec(nimExt()):
    yield file


iterator tests*(): RelativeFile =
  ##[
    Yields the tests relative to the project root directory.

    Assumes the current working directory is the project root directory.
  ]##
  for module in testDir().relativeNimModulesRec():
    if module.splitFile().name == "test":
      yield testDir() / module
