import backend
import ../common/[find]

import pkg/taskutils/[envtypes, optional, parseenv, result]

import std/[strformat, sugar]



type
  EnvVar* {.pure.} = enum
    NimBackend



func envVarNames (): array[EnvVar, string] =
  const names: result.typeof() = ["NIM_BACKEND"]

  names


func name* (self: EnvVar): string =
  envVarNames()[self]



func parseNimBackend* (value: EnvVarValue): ParseEnvResult[Backend] =
  func invalidValue (): ref ParseEnvError =
    EnvVar.NimBackend.name().parseEnvError(&"Invalid value: \"{value}\"")

  Backend
    .findFirst(backend => backend.envVarValue() == value)
    .ifSome(parseEnvSuccess, () => invalidValue.parseEnvFailure(Backend))
