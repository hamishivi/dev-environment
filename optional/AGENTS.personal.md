# Raspberry Pi server

- Codex may proactively use the Raspberry Pi when it materially helps with the user's task, especially for always-on services, scheduled or long-running work, Linux/ARM64 testing, network services, and Hermes Agent administration.
- Connect with `ssh hermes-pi`. The host is `claudeboard.local`, the user is `hamishivi`, and authentication uses the dedicated SSH key configured in `~/.ssh/config`.
- The Pi runs Debian 13 on ARM64 and hosts Hermes Agent under `~/.hermes`.
- Prefer the local Mac for ordinary work that gains nothing from remote execution. Do not move sensitive data to the Pi unless the task requires it, and preserve the same confirmation and safety boundaries that apply to local actions.
- Before relying on the Pi for important work, verify connectivity and available disk space. Keep persistent services managed through systemd where practical.
