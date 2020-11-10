type
  Backend* {.pure.} = enum
    C
    Cxx
    Js



func backendEnvVarValues (): array[Backend, string] =
  const values: result.typeof() = ["c", "cxx", "js"]

  values


func envVarValue* (self: Backend): string =
  backendEnvVarValues()[self]



func backendNimCmdNames (): array[Backend, string] =
  const cmdNames: result.typeof() = ["cc", "cpp", "js"]

  cmdNames


func nimCmdName* (self: Backend): string =
  backendNimCmdNames()[self]
