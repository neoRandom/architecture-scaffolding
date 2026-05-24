# Architecture Scaffolding

Tool to scaffold projects using hexagonal (or similar) architecture, made in Godot.

Support planned for: Go, Python.

---

input:
- use cases
- models
- services
- driver adapters
- driven adapters
> (how the dev imagine the code will look like; only elements, not relations)

parsing:
- 2D view of input

then input:
- connections/relations
- interfaces (arguments, methods)
- model contents
- DTOs

final output:
- create architecture.md
- create files
- write boilerplate code
- generate mermaid
