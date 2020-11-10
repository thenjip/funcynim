import "../../funcynim.nimble"

import pkg/taskutils/[fileiters, filetypes]

import std/[os]



export funcynim



func nimblePackageName* (): string =
  "funcynim"



func nim* (f: FilePath): FilePath =
  f.addFileExt(nimExt())



iterator libNimModules* (): AbsoluteFile =
  yield srcDirName() / nimblePackageName().nim()

  for module in srcDirName().`/`(nimblePackageName()).absoluteNimModules():
    yield module
