# Migration decisions

## Preserved

- Zinit + Powerlevel10k with the actual `.p10k.zsh`, asynchronous shell plugins and Git shortcuts.
- Lazy pyenv, NVM and optional Conda setup; fzf bindings; `ls=lsd`, `slep` and cluster aliases.
- Klone and Tillicum endpoint, user, multiplexing and keepalive settings.
- Visual iTerm2 profiles, with Dracula recorded as the original default.
- Codex model/style/appearance/queue preferences, public documentation MCP, custom hatch-pet skill and three finished custom pets.

## Adapted

- Absolute username paths became `$HOME` paths, and Homebrew is detected for Apple Silicon or Intel.
- Packages/plugins must be freshly installed; missing optional tools do not prevent shell startup.
- No compiler SDK flags are set globally: Xcode and each project should select their current SDK.
- NVM loading no longer recurses indefinitely if NVM is missing. Node LTS is a starting point, not a claimed copy of the source version.
- iTerm2 profile exports are allowlisted visual fields; discontinued Powerline font names are replaced where needed.
- Existing Codex configuration is preserved for a receiving agent to merge. Approval settings and project trust records are not migrated.

## Optional or excluded

- The source shell starts `pokemon -d` in the background. It is omitted because the executable/assets were not packaged.
- Old Ruby/chruby, Racket, Miniforge, Rust, Google Cloud, Nebius and LM Studio paths are omitted from startup. Add needed tools through current approved installers, then put guarded initialization in `~/.config/hamish-dev/local.zsh`.
- Historical Homebrew packages and virtual environments are not automatically installed. The included Brewfile covers this terminal workflow, not all research projects ever used on the source Mac.
- Bash setup is not migrated because the active environment is zsh. No shell history, active terminal sessions or iTerm2 AI configuration is copied.
- Legacy institution/cloud SSH hosts beyond the two requested clusters are omitted. The personal Pi is a separate opt-in example.
- No Codex task data, memories, prompts/drafts, automations, permissions, command-approval rules, auth, project lists, browser state, bundled runtimes or plugin caches. Old rules contained historical command approvals and do not belong on a fresh work machine.
- Personal global AGENTS instructions are optional because they authorize a personal Pi integration. Do not apply them automatically to corporate tasks.
- Git personal identity, signing key and credential storage settings require destination-specific choices.

## What was tested before upload

See `VALIDATION.md`. Actual app appearance, remote authentication and company policy compliance must be verified on the destination; this bundle has not configured that laptop remotely.
