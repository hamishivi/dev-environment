# Hamish's macOS development environment

Portable setup captured 2026-09-29 for a new corporate Mac using iTerm2 and Codex. Start here if you are the Codex instance doing the migration. This is a curated setup, not a backup of the old Mac.

## Instructions for the receiving Codex instance

1. Read this file, `MIGRATION.md`, and `install.py`. Inspect the destination's existing shell and Codex configuration and corporate managed settings before changing anything. Follow applicable company policy; preserve existing managed configuration.
2. Use the user's local home directory. Never recreate `/Users/hamishivison` or reuse this computer's app/runtime paths. Identify Apple Silicon versus Intel and the available Homebrew prefix.
3. Install dependencies below, then run `python3 install.py` for a dry run. On a fresh setup, run `python3 install.py --apply`. The installer backs up changed files and is repeatable. It only changes local files: no package installs, authentication or connections.
4. Resolve any `MERGE MANUALLY` messages. Existing `~/.codex/config.toml`, skills and pets are deliberately preserved. Merge only the supplied preferences into the existing TOML without overwriting managed settings, credentials, MCP runtime entries or unrelated configuration. Quit/restart the app around config changes when needed to avoid it overwriting them.
5. Complete iTerm2, Codex and authentication steps below. Report exactly what was installed, any unavailable settings/plugins, and anything waiting for login or corporate approval.

## Packages and shell

Use the corporate software catalog for Homebrew, developer tools, iTerm2 and Codex where applicable. If Homebrew is not installed, use the [official Homebrew installer](https://brew.sh/) after reviewing it. Xcode Command Line Tools may be needed (`xcode-select --install`).

From this repository, with Homebrew available:

```sh
brew bundle --file Brewfile
mkdir -p "$HOME/.local/share/zinit" "$HOME/.nvm"
# Only clone if this directory does not already exist.
git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.local/share/zinit/zinit.git"
python3 install.py
python3 install.py --apply
```

Zinit fetches Powerlevel10k, fast-syntax-highlighting, zsh-autosuggestions, zsh-completions, and the Oh My Zsh Git plugin on first interactive launch. Open a fresh iTerm2 window. If the new Mac already has a prompt/plugin manager, merge its `.zshrc` first to avoid loading two prompt managers. The installer appends one source line and does not remove existing shell setup.

Run `nvm install --lts` once if Node is required; no old runtime version was pinned. Pyenv and uv are available, but Python environments are project-specific and need recreating from project manifests. Miniforge, Ruby/chruby, Rust, cloud CLIs and specialized scientific packages are optional; see `MIGRATION.md`.

Local additions belong in `~/.config/hamish-dev/local.zsh`. Keep secrets out of this repository. The old exported API credential is intentionally absent.

## iTerm2

Four profiles are installed as `~/Library/Application Support/iTerm2/DynamicProfiles/hamish-dev.json`: **Hamish — Dracula**, Afterglow, Homebrew, and Solarized Dark. Choose **Hamish — Dracula** and make it the default in Settings → Profiles. Dracula was the default on the source Mac. Font: Roboto Mono 12; non-ASCII glyphs: Hack Nerd Font 12. Check the installed font names in iTerm2 if it falls back to Monaco.

The Homebrew/Solarized profiles use Hack Nerd Font instead of obsolete Powerline font names. Color values, spacing, opacity and relevant visual preferences came from the original profiles. Commands, host bindings, triggers, AI settings, logging, session contents and app-wide preferences were not exported. Profile GUIDs are new to avoid collisions. Changes to dynamic profiles should be made in their JSON file. [iTerm2 dynamic profile documentation](https://iterm2.com/documentation-dynamic-profiles.html).

## SSH: Klone and Tillicum

`klone`, `tillicum`, `klone-check`, and `klone-close` shell aliases are included. Hostnames are `klone.hyak.uw.edu` and `tillicum.hyak.uw.edu`, both using UW username `hamishiv`. SSH connection sharing persists for 8 hours, with 60-second keepalives and compression, matching the original configuration.

The installer prepends an SSH `Include` for these two hosts. Review any existing definitions because the included values take precedence. No private/public keys, host keys, known_hosts or live sockets were copied. Use institution-approved authentication and enroll a new machine key if required. Do not disable host-key checking; verify a new fingerprint through an appropriate trusted channel. VPN/MFA may require user interaction.

Offline validation:

```sh
ssh -G klone
ssh -G tillicum
zsh -n "$HOME/.config/hamish-dev/shell/dev.zsh"
```

Then authenticate interactively with `ssh klone` and `ssh tillicum`; `klone-check` works after establishing a shared connection. Do not consider access tested merely because `ssh -G` succeeds.

## Codex

Install the desktop app through your company's catalog or the current official OpenAI distribution, then sign in afresh. The local CLI Homebrew cask `codex` is distinct from the desktop app; install it separately only if wanted.

Included preferences: model `gpt-6-astra`, reasoning `medium`, personality `pragmatic`, service tier `default`; Notion light and Dracula dark themes; queue follow-ups; detailed steps/commands; selected custom pet Mika. These are a source-machine snapshot. Check availability in the destination's current app/account; omit unsupported model/UI settings instead of forcing them.

`payload/codex/config.toml` contains these allowlisted preferences and the public OpenAI Developer Docs MCP URL. The app's generated browser/computer-use runtime configuration must regenerate on the new Mac. User-level configuration lives in `~/.codex/config.toml`; organizational constraints can override local defaults. [Official configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).

The custom **hatch-pet** skill and the **Hamish**, **Mika**, and **Tinnie** pet manifests/spritesheets are included. Built-in/system skills and plugin caches must come from a fresh installation. See `inventory/codex-plugins.json` for enabled plugins in the source config; available plugins in the running session also included Notion, Sites and Work Pets, whose account-provided availability may differ. Reinstall/reconnect desired plugins through the app, using current marketplace entries. Do not recreate stale internal marketplace/cache paths. Messages and personal service integrations are optional on a work machine.

Add **klone** and **tillicum** as remote SSH connections in the new app once terminal authentication works. Saved projects and remote UI state are not copied. The global `AGENTS.md` on the source only contained personal Raspberry Pi instructions; it is preserved in `optional/AGENTS.personal.md`, along with a matching SSH stanza. Only enable that personal integration if desired and permitted; provision a fresh SSH key first. It is not enabled by the installer.

## Git, authentication and rollback

The installer includes pull-merge behavior and Git LFS filters. Choose the corporate Git author name/email and the organization's credential helper/signing method on the new machine. Personal email, old GPG signing key, `credential.helper=store`, and SourceTree paths were deliberately not applied. Existing corporate Git identity and signing settings remain intact. Ignore-file snapshots in `inventory/` are references to merge if useful.

Sign in to Codex and GitHub on the new Mac (e.g. `gh auth login` where permitted). Cloud CLIs, SSH/MFA, GPG signing and connector OAuth must be set up afresh. Never copy `auth.json`, keychains, `.git-credentials`, shell history, Codex sessions, databases or a complete `~/.codex` directory.

Changed files are backed up under `~/.local/state/hamish-dev/backups/<timestamp>/` with a `changes.json` manifest. To roll back, close affected apps, restore files marked `previously_existed`, and remove only newly created files listed in that run's manifest. Package installation and first-run Zinit downloads are separate and are not covered by those backups.

## Verification on the destination

- Open a new iTerm2 window: correct theme, glyphs, prompt, autosuggestions and history arrow search; no startup errors.
- `type klone tillicum klone-check klone-close`; verify SSH effective hostname/user and test real login.
- `git --version`, `git lfs version`, `gh --version`, `uv --version`; verify corporate Git identity/signing separately.
- `nvm --version`, then `node --version` after installing Node; test project Python environments after recreating them.
- Restart Codex, confirm model/theme/pet, custom skill discovery, desired plugins and remote connections.
