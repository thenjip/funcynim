import std/[os, strformat, strutils]



type
  ValuedOption* = tuple[name, value: string]



func toLongOption*(name: string): string =
  fmt"--{name}"


func toLongOption*(name, value: string): string =
  fmt"{name.toLongOption()}:{value.quoteShell()}"


func toLongOption*(self: ValuedOption): string =
  self.name.toLongOption(self.value)



func toCmdLine*(parts: seq[string]): string =
  parts.join($' ')
