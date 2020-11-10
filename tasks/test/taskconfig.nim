import backend



type
  TaskConfig* = tuple
    backend: Backend



func taskConfig* (backend: Backend): TaskConfig =
  (backend, )
