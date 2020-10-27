# Tanks

This is an experiment to test how ECS architecture works in a small but real life scenario.

## Implementation details

Processes:

- Components
- Registers
- Servers
- Cache

System logic:

- Components are registered with their own processes
- Entities are only groups of components, they don't have their own
  processes, but they are registered
- Systems are required to register their component type usage, e.g.
  `[Position, Momentum]`
- Events, Queues and EventProcessors are used to manage when events happen, e.g.
  input system collets input events and processes them at the beginning
  of a tick
- Caches are used to gather state from components and keep them in a
  single process.
