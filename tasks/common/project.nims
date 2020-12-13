import "../../funcynim.nimble"

import pkg/taskutils/[fileiters, filetypes]

import std/[os]



export funcynim



func nimblePackageName* (): string =
  "funcynim"



func nim* (f: FilePath): FilePath =
  f.addFileExt(nimExt())



func srcDir* (): AbsoluteDir =
  ##[
    Returns the path to the `src` directory relative to the project root
    directory.
  ]##
  srcDirName()



iterator libNimModules* (): AbsoluteFile =
  ##[
    Yields paths to the library modules relative to the project root directory.

    Assumes the current working directory is the project root directory.
  ]##
  yield srcDirName() / nimblePackageName().nim()

  for module in srcDirName().`/`(nimblePackageName()).absoluteNimModulesRec():
    yield module
