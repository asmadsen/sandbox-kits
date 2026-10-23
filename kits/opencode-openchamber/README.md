# OpenCode + OpenChamber

A Docker Sandboxes workload that runs [OpenCode](https://opencode.ai) under the
[OpenChamber](https://openchamber.dev) server. The server listens on
`127.0.0.1:3000`; you use it from the OpenChamber desktop app as an **external
Remote Instance** over SSH. Nothing is published to the host.

## Requirements

- Docker Sandboxes (`sbx`) with a local sandbox runtime
- `sbx login`
- One-time SSH setup on the host: `sbx setup ssh` (writes an include into
  `~/.ssh/config`, so `ssh <sandbox-name>.sbx` works with no keys)
- The OpenChamber desktop app for the UI

## Run

The kit does not need to be published. Register it once in your
[`~/.sbxenv.yaml`](https://docs.docker.com/ai/sandboxes/configuration/environment-files/#set-user-defaults)
user defaults, pointing at the absolute path of this directory:

```yaml
schemaVersion: "1"
agent: opencode-openchamber
workspace: ${{ env.projectDir }}
kits:
  - source: /absolute/path/to/sandbox-kits/kits/opencode-openchamber
```

Then start from any project without naming the kit:

```console
$ cd ~/src/my-project
$ sbx env run --name my-project
```

`sbx env` is experimental. It mounts the current directory as the workspace,
creates the sandbox on first use, and re-attaches by name afterwards.

> `sbx env run <path>` reads `<path>` as an environment file, or as a directory
> containing `sbxenv.yaml` — it is **not** a workspace argument, and passing it
> skips `~/.sbxenv.yaml`. To mount a project with the user defaults, `cd` into
> the project first and run `sbx env run` with no path.

Without the user defaults file, pass the kit path explicitly:

```console
$ sbx run --name my-project /absolute/path/to/sandbox-kits/kits/opencode-openchamber ~/src/my-project
```

The first run builds the kit (Node 24, OpenCode, OpenChamber), then starts the
server and stays attached to its logs. The server starts with the agent
session, so use this attached form at least once; the sandbox then keeps
running after you disconnect because the kit requests `long-running@1`.
If you omit `--name`, `sbx env` generates one as
`<agent>-<project-directory-name>`; find it with `sbx ls`.

## Connect the desktop app

1. Open **Settings → Remote Instances** and add an instance.
2. SSH command: `ssh my-project.sbx`
3. Mode: **external** (the kit already runs OpenChamber)
4. If it asks for the OpenChamber port, use `3000`.
5. Connect.

OpenChamber forwards the remote port over its own SSH connection, so no host
port is published and no UI password is set.

### Browser fallback

If the desktop connection misbehaves, forward the loopback port yourself:

```console
$ ssh -N -L 3000:127.0.0.1:3000 my-project.sbx
$ open http://localhost:3000
```

This is a troubleshooting path, not the normal workflow.

## Operate

```console
$ ssh my-project.sbx -- openchamber status
$ ssh my-project.sbx -- openchamber logs
$ ssh my-project.sbx -- opencode --version
$ sbx ls
$ sbx stop my-project
$ sbx env run --name my-project        # restart and re-attach
$ sbx env rm --name my-project         # delete the sandbox and its state
```

Everything inside the sandbox — OpenCode auth and sessions, OpenChamber
settings, installed packages — survives `sbx stop` and restarts. Removing the
sandbox deletes it.

## Versions

`nodeVersion`, `opencodeVersion`, and `openchamberVersion` are kit arguments.
Change the defaults in `opencode-openchamber.yaml` (or pass `--kit-arg` when
creating a sandbox), then create a **new** sandbox: existing sandboxes do not
pick up image changes.

OpenCode's self-updater is disabled (`OPENCODE_DISABLE_AUTOUPDATE=1`); upgrades
happen by editing and rebuilding the kit.

## Network

Runtime egress is limited to what the harness itself needs: `opencode.ai` and
its subdomains, the npm registry, and GitHub hosts used for language-server
downloads. Model provider endpoints are **not** allowed yet — that is a
separate change.

If something is blocked, inspect and widen:

```console
$ sbx policy log
```

## Security notes

- The server is bound to loopback inside the sandbox and is never published.
- There is no UI password. Anything that can run inside the sandbox can reach
  the port, and the desktop app authenticates to the sandbox over SSH.
- Do not add `--publish` for port 3000 without also setting
  `OPENCHAMBER_UI_PASSWORD`.
