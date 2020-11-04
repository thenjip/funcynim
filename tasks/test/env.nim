type
  EnvVar* {.pure.} = enum
    NimBackend



func envVarNames (): array[EnvVar, string] =
  const names: result.typeof() = ["NIM_BACKEND"]

  names


func name* (self: EnvVar): string =
  envVarNames()[self]
