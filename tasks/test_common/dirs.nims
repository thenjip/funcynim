import ../common/[filetypes, "project.nims"]

import std/[options, os]



func srcGenDir*(self: TestTask): RelativeDir =
  ##[
    Returns the path to the cache directory for the generated source files.

    The path is relative to the project root directory.
  ]##
  self.buildDir().get() / "nimcache"


func binGenDir*(self: TestTask; module: RelativeFile): RelativeDir =
  ##[
    Returns the path to the directory for the generated executable from
    `module`.

    `module` path is assumed to be relative to the project source directory.

    The path is relative to the project root directory.
  ]##
  self.buildDir().get() / "bin" / module
