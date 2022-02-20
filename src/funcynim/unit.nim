type
  Unit* =
    tuple[]
    ##[
      The `Unit` type from functional programming.

      The type has only a single value.
    ]##



func unit* (): Unit =
  ()


func default* (T: typedesc[Unit]): Unit =
  unit()



func doNothing* [T](_: T): Unit =
  unit()
