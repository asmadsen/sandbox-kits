# Access OpenChamber over SSH, not a published port

The kit runs a web UI (OpenChamber) but publishes no port and sets no UI
password. Access is the OpenChamber desktop app's Remote Instance feature,
which connects to `ssh <sandbox>.sbx` and forwards the server's loopback port
over that SSH connection. We chose this over publishing a container port
because `sbx` already provides authenticated SSH into a sandbox (daemon socket
plus Docker login, no keys) while a published port would be reachable from the
host and would require a UI password to be generated, stored, and surfaced.

Consequences: the kit is desktop-first and requires `sbx setup ssh` once per
host; the server must stay on `127.0.0.1`; any browser fallback needs an
explicit `ssh -L`; and the sandbox declares `long-running@1` so the server
outlives terminal sessions. Reversing this means adding `port@1`, a password
path, and a different access story, so it is recorded here rather than left
implicit.
