func srcDirName* (): string =
  "src"



version = "0.2.1"
author = "thenjip"
description = "Utility library to ease functional programming in Nim."
license = "MIT"

srcDir = srcDirName()

requires "nim >= 1.4.0"
requires "https://github.com/thenjip/taskutils >= 0.2.1"



import std/[macros, os, sequtils, strformat, strutils, sugar]



func taskScriptsDirName (): string =
  "tasks"


func nims (file: string): string =
  file.addFileExt("nims")



# Task API

type
  Task* {.pure.} = enum
    Test
    Docs
    CleanTest
    CleanDocs
    Clean



func taskNames (): array[Task, string] =
  const names = [
    "test",
    "docs",
    "clean_test",
    "clean_docs",
    "clean"
  ]

  names


func name* (self: Task): string =
  taskNames()[self]


func identifier* (self: Task): NimNode =
  self.name().ident()



func testTaskDescription (): string =
  let backendChoice = ["c", "cxx", "js"].join($'|')

  [
    "Build the tests and run them.",
    "The backend can be specified with the environment variable",
    fmt""""NIM_BACKEND=({backendChoice})"."""
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


func description* (self: Task): string =
  taskDescriptions()[self]



# Tasks

macro define (self: static Task; body: Task -> void): untyped =
  let
    selfIdent = self.identifier()
    selfLit = self.newLit()

  quote do:
    task `selfIdent`, `selfLit`.description():
      `body`(`selfLit`)


proc execTaskScript (self: Task) =
  taskScriptsDirName().`/`(self.name().nims()).selfExec()


macro defineTasks (): untyped =
  toSeq(Task.items())
    .map(
      proc (task: auto): auto =
        let
          taskLiteral = task.newLit()

        quote do:
          `taskLiteral`.define(execTaskScript)
    ).newStmtList()



defineTasks()
