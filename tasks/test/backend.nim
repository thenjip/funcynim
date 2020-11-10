type
  Backend* {.pure.} = enum
    C
    Cxx
    Objc
    Js



func backendEnvVarValues (): array[Backend, string] =
  const values: result.typeof() = ["c", "cxx", "objc", "js"]

  values


func envVarValue* (self: Backend): string =
  backendEnvVarValues()[self]



func backendNimCmdNames (): array[Backend, string] =
  const cmdNames: result.typeof() = ["cc", "cpp", "objc", "js"]

  cmdNames


func nimCmdName* (self: Backend): string =
  backendNimCmdNames()[self]
