func srcDirName*(): string =
  "src"



version = "0.3.0"
author = "thenjip"
description = "Utility library to ease functional programming in Nim."
license = "MIT"

srcDir = srcDirName()

requires "nim >= 1.6.0", "nim_curry >= 0.1.0"



import std/[macros, os, sequtils, strformat, strutils]



func taskBuildDirName*(): string =
  "nimble-build"


func taskScriptDirName(): string =
  "tasks"



type
  Task* {.pure.} = enum
    TestC
    TestCxx
    TestObjc
    TestJs
    Docs
    Clean

  TestTask* = Task.TestC .. Task.TestJs



func backendName*(self: TestTask): string =
  const names: array[TestTask, string] = [
    "C",
    "C++",
    "Objective-C",
    "JavaScript"
  ]

  names[self]


func nimCmdName*(self: TestTask): string =
  const names: array[TestTask, string] = ["cc", "cpp", "objc", "js"]

  names[self]



func name*(self: Task): string =
  const names: array[Task, string] = [
    "test-c",
    "test-cxx",
    "test-objc",
    "test-js",
    "docs",
    "clean"
  ]

  names[self]


func scriptName*(self: Task): string =
  self.name().replace('-', '_')


func identifier(self: Task): NimNode =
  self.name().ident()



func description*(self: Task): string =
  func description(self: TestTask): string =
    fmt"Build the tests using the {self.backendName()} backend and run them."

  const descriptions: array[Task, string] = [
    Task.TestC.TestTask.description(),
    Task.TestCxx.TestTask.description(),
    Task.TestObjc.TestTask.description(),
    Task.TestJs.TestTask.description(),
    "Build the API doc.",
    fmt"""Remove "{taskBuildDirName()}" directory."""
  ]

  descriptions[self]



# Tasks

proc execScript(self: Task) =
  func nims(file: string): string =
    file.addFileExt("nims")

  let script = taskScriptDirName().`/`(self.scriptName().nims())

  fmt"e {script.quoteShell()}".selfExec()


macro define(self: static Task): untyped =
  let
    identifier = self.identifier()
    literal = self.newLit()

  quote do:
    task `identifier`, `literal`.description():
      `literal`.execScript()


macro defineTasks(): untyped =
  toSeq(Task.items())
    .map(newLit)
    .map(
      proc (literal: auto): auto =
        quote do:
          `literal`.define()
    ).newStmtList()



defineTasks()
