type
  Backend* {.pure.} = enum
    C
    Cxx
    Js



func nimBackendEnvVarValues (): array[Backend, string] =
  const values: result.typeof() = ["c", "cxx", "js"]

  values


func envVarValue* (self: Backend): string =
  nimBackendEnvVarValues()[self]



func nimBackendNimCmdNames (): array[Backend, string] =
  const cmdNames: result.typeof() = ["cc", "cpp", "js"]

  cmdNames


func nimCmdName* (self: Backend): string =
  nimBackendNimCmdNames()[self]
