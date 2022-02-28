when isMainModule:
  import pkg/funcynim/[chain]

  import std/[sugar, unittest]



  proc main() =
    suite "chain":
      test "Chaining nimcall procs together should give a nimcall proc.":
        proc doTest[A; B; C](
          first: proc (_: A): B {.nimcall.};
          second: proc (_: B): C {.nimcall.}
        ) =
          template actual(): typedesc[proc] =
            first.chain(second).typeof()

          template expected(): typedesc[proc (_: A): C {.nimcall.}] =
            typeof(proc (_: A): C {.nimcall.})

          check:
            actual() is expected()

        doTest((s: string) => s, s => s.len())




  main()
