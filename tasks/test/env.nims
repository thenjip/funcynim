import backend, envvar
import ../common/["env.nims"]

import pkg/taskutils/[optional, parseenv]



export backend, env, envvar



func tryParseNimBackend* (): Optional[ParseEnvResult[Backend]] =
  EnvVar.NimBackend.name().tryParseEnv(parseNimBackend)
