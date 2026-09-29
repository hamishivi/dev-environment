# Validation before upload

Validated on the source Mac on 2026-09-29:

- Every packaged TOML and JSON file parsed successfully; shell files passed `zsh -n`.
- Installer dry run made no filesystem changes in an empty temporary home.
- Fresh install produced the expected Codex preference file.
- Existing corporate-style shell/Git settings and existing Codex config were preserved; Codex merge was reported explicitly.
- Installer generated timestamped backup/change records. Repeating it made no further file changes.
- `ssh -G` confirmed both Hyak hostnames, `hamishiv`, and 28,800-second connection persistence without network access.
- Interactive zsh startup in an isolated temporary home returned no startup errors and exposed both SSH aliases. This test did not download Zinit/plugins.
- Text files were scanned for common private-key/token patterns and hardcoded source home paths. Literal credential exports detected in the source shell file were checked for absence throughout the payload. No matches remained. This is a targeted scan, not a guarantee against every possible secret format.

Not tested here: corporate laptop software installation, rendering in its iTerm2,
first-run plugin downloads, its Codex version/account capabilities, actual cluster
authentication, company VPN/MFA, or corporate configuration policy.

`SHA256SUMS` covers all delivered files except itself. Verify after download with
`shasum -a 256 -c SHA256SUMS` from the repository directory.
