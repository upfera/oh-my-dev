# Ubuntu Developer Setup

A modular developer environment bootstrapper for Ubuntu, with tools and integrations for a productive development workflow.
It is for developers who want a useful baseline without handing control to a large installer framework.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/upfera/oh-my-dev/main/install.sh | bash
```

The bootstrap downloads a temporary checkout, runs the single public entry point, and removes the checkout afterward. From a clone:

```bash
./install.sh
./install.sh --recommended
./install.sh --custom
./install.sh --full
./install.sh --help
```

`Recommended` is a curated, relatively fast baseline. `Custom` exposes supported optional components. `Full` installs all supported normal developer components, but never silently runs security-sensitive or destructive utilities.

## Profiles and components

The recommended profile includes ZSH, its plugins and shell helpers, plus `eza`, `fzf`, `fd`, `yazi`, `ripgrep`, and `zoxide`. Components selected through Custom or Full are run in dependency order; for example, ZSH plugins automatically include ZSH.

Supported components are listed in `install.sh` and grouped by Shell, CLI tools, Development, System, and WSL. Explore the interactive menu for the current descriptions. Lower-level scripts such as `scripts/dev/ansible_config.sh`, `scripts/wsl/bind_dir_from_wsl.sh`, and Bitwarden helpers remain available for inspection and deliberate manual use; they are not silently promoted into the installer menu.

WSL-only SSH integration is skipped on ordinary Ubuntu. Disk-image and bind-mount helpers are manual because they change mounts or create storage; inspect their scripts before use.

## Safety and repeatability

Scripts may install APT packages, configure user services, and add managed shell configuration. Existing configuration is preserved where practical, repositories are reused, and managed lines are not appended repeatedly. There is no destructive uninstall command.

The installer does not perform a full system upgrade. A component failure does not prevent independent components from running; the final Installed/Skipped/Failed summary is clear and the process exits non-zero when failures occur.

Review scripts before running components that use `sudo`, access SSH material, configure containers, or change system settings. The project does not claim that every lower-level manual script is idempotent.

## Requirements

- Ubuntu 20.04+ or Ubuntu on WSL2
- Bash, Git, network access, and `sudo`

The installer itself does not require Python, Node, ZSH, or an external TUI dependency. Missing bootstrap prerequisites produce an actionable error rather than being installed blindly.

## Individual scripts and development

The implementation remains ordinary Bash under `scripts/core`, `scripts/shell`, `scripts/tools`, `scripts/dev`, `scripts/system`, and `scripts/wsl`; dot files are under `dot_files`. Run an individual script from any working directory with `bash /path/to/dev-setup/scripts/tools/fzf.sh`, after reviewing what it changes. The installer is orchestration only; scripts contain the implementation.

To inspect or extend the setup, start with `install.sh`, then add a small registry entry only for a supported, safe-to-select component. Keep sensitive or highly contextual utilities manual-only and document their risks.