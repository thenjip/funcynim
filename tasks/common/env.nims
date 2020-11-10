import pkg/taskutils/[envtypes, optional, parseenv, result]

import std/[sugar]



func findInEnv* (name: EnvVarName): Optional[EnvVarValue] =
  name.findValue(existsEnv, key => key.getEnv())


proc tryParseEnv* [T](
  name: EnvVarName;
  parse: EnvVarValue -> ParseEnvResult[T]
): Optional[ParseEnvResult[T]] =
  name.tryParse(findInEnv, parse)



proc failOr* [T](
  tryParse: () -> Optional[ParseEnvResult[T]];
  default: () -> T
): T {.raises: [Exception, ParseEnvError].} =
  tryParse().map(unboxSuccessOrRaise).getOr(default)
