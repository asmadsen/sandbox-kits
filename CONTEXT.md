# Sandbox Kits

Reusable, reproducible agent environments for Docker Sandboxes (`sbx`), authored as source so the same environment can be recreated on any machine.

## Language

**Sandbox Kit**:
A versioned artifact that declares an agent environment and the authority it needs: content, network rules, credentials, and launch behavior. Authored as a descriptor plus a Dockerfile recipe, built and run by `sbx`.
_Avoid_: Template, sandbox template, image, compose file

**Sandbox**:
A running, isolated instance created from a Sandbox Kit. It owns its container filesystem, workspace mounts, and published ports, and it persists while it exists.
_Avoid_: Container, VM, instance, environment

**Harness**:
The agent tooling inside a Sandbox: the OpenCode engine plus the OpenChamber interface that drives it. The Harness is the part we are packaging first, deliberately without model or provider configuration.
_Avoid_: Agent (OpenCode is the agent), stack, toolchain

**Workload**:
A Sandbox Kit kind that is the thing that runs. It owns the base image, installed software, entrypoint, and command.
_Avoid_: Base kit, agent kit, root kit

**Mixin**:
A Sandbox Kit kind that overlays content or declarations onto a Workload without defining the process that runs.
_Avoid_: Plugin, extension, layer

**Kit Set**:
A Sandbox Kit kind that composes published Kits into one distributable Kit.
_Avoid_: Bundle, meta kit

**Remote Instance**:
An OpenChamber desktop connection to a Harness running inside a Sandbox, reached over SSH rather than a published port.
_Avoid_: Remote server, remote machine, tunnel
