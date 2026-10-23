# Sandbox Kits

Reusable agent environments for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
(`sbx`), authored as v3 Kit source. Each kit lives in its own directory under
[`kits/`](./kits/) and is built and run by `sbx` from that directory.

## Kits

| Kit | What it is |
|---|---|
| [`opencode-openchamber`](./kits/opencode-openchamber/) | OpenCode + OpenChamber server, used from the OpenChamber desktop app over SSH |

## Run a kit

Register the kit once in `~/.sbxenv.yaml` so you never pass its path:

```yaml
schemaVersion: "1"
agent: opencode-openchamber
workspace: ${{ env.projectDir }}
kits:
  - source: /absolute/path/to/sandbox-kits/kits/opencode-openchamber
```

```console
$ cd ~/src/my-project
$ sbx env run --name my-project
```

`sbx env` is experimental but is the supported way to reuse a local kit
without publishing it. It mounts the current directory and creates or
re-attaches the sandbox. Passing the kit directory to `sbx run` still works.

If you'd rather keep standard `sbx run` semantics and take a project path
argument, use the wrapper:

```console
$ ./bin/sbx-oc --name my-project ~/src/my-project
```

It injects the kit path and forwards everything else to `sbx run`. Symlink it
onto your `PATH` if you want `sbx-oc` from anywhere.

`sbx` builds the kit on first use and on source changes, then launches its
entrypoint. See each kit's README for its own requirements and workflow.

## Authoring conventions

- One directory per kit, named after the kit.
- Descriptor and Dockerfile share the stem: `<kit-name>.yaml` + `<kit-name>.dockerfile`.
- Versions that can move are kit arguments (`args` with `buildArg`), never
  floating `latest` references inside the Dockerfile.
- Authority is declared, not assumed: network rules, credentials, ports, and
  lifetime go in `capabilities`.
- Kits do not publish ports unless the kit's README explains why.
- `CONTEXT.md` holds the vocabulary; `docs/adr/` holds decisions worth
  remembering.

## Validate

```console
$ ./scripts/validate.sh
```

Runs `sbx kit validate` against every kit directory. The first run creates the
shared `sbx-kit-builder` sandbox and compiles the kits, so it needs `sandboxd`
and an `sbx login` session.
