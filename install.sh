#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_URL="${DEV_SETUP_REPOSITORY:-https://github.com/intosoft-tm/dev-setup.git}"
TEMP_DIR=""
cleanup() { [[ -z "$TEMP_DIR" || ! -d "$TEMP_DIR" ]] || rm -rf -- "$TEMP_DIR"; }
trap cleanup EXIT INT TERM

if [[ ! -d "$ROOT_DIR/scripts" ]]; then
    TEMP_DIR="$(mktemp -d)"
    command -v git >/dev/null 2>&1 || { printf 'git is required to download the repository.\n' >&2; exit 1; }
    printf 'Downloading Ubuntu Developer Setup...\n'
    git clone --depth 1 --quiet "$REPOSITORY_URL" "$TEMP_DIR/dev-setup" || { printf 'Unable to download %s\n' "$REPOSITORY_URL" >&2; exit 1; }
    ROOT_DIR="$TEMP_DIR/dev-setup"
fi

usage() { cat <<'EOF'
Ubuntu Developer Setup

Usage: ./install.sh [--recommended|--custom|--full|--help]

Without an option, opens the interactive installer. Recommended is a curated
developer baseline; Custom selects supported components; Full installs all
safe, supported components. Security-sensitive and destructive scripts remain
manual-only.
EOF
}

COMPONENTS=(
    'zsh|Shell|ZSH|scripts/shell/zsh.sh'
    'zsh_plugins|Shell|ZSH plugins|scripts/shell/zsh_plugins.sh'
    'fzf|CLI tools|fzf|scripts/tools/fzf.sh'
    'fzf_tab|Shell|fzf-tab|scripts/shell/fzf_tab.sh'
    'zsh_defer|Shell|zsh-defer|scripts/shell/zsh_defer.sh'
    'eza|CLI tools|eza|scripts/tools/eza.sh'
    'fd|CLI tools|fd|scripts/tools/fd.sh'
    'ripgrep|CLI tools|ripgrep|scripts/tools/ripgrep.sh'
    'yazi|CLI tools|yazi|scripts/shell/yazi.sh'
    'zoxide|CLI tools|zoxide|scripts/tools/zoxide.sh'
    'chezmoi|Development|Chezmoi|scripts/dev/chezmoi.sh'
    'oh_my_posh|Shell|oh-my-posh|scripts/shell/oh_my_posh.sh'
    'oh_my_tmux|Shell|oh-my-tmux|scripts/shell/oh_my_tmux.sh'
    'podman|Development|Podman|scripts/dev/podman.sh'
    'podman_docker|Development|Docker compatibility|scripts/dev/podman_as_docker.sh'
    'sdkman|Development|SDKMAN|scripts/dev/sdkman.sh'
    'ansible|Development|Ansible|scripts/dev/ansible.sh'
    'ssh_agent|System|SSH agent setup|scripts/system/ssh_agent.sh'
    'ssh_windows|WSL|Copy SSH keys from Windows|scripts/system/ssh_from_windows.sh'
)
component_field() { local id="$1" field="$2" entry cid category name script; for entry in "${COMPONENTS[@]}"; do IFS='|' read -r cid category name script <<< "$entry"; [[ "$cid" == "$id" ]] || continue; case "$field" in category) printf '%s' "$category";; name) printf '%s' "$name";; script) printf '%s' "$script";; esac; return; done; }
component_ids() { local entry; for entry in "${COMPONENTS[@]}"; do printf '%s\n' "${entry%%|*}"; done; }
dependencies() { case "$1" in zsh_plugins|fzf_tab|zsh_defer|oh_my_posh|oh_my_tmux) printf 'zsh\n';; podman_docker) printf 'podman\n';; esac; }
SELECTED=(); INSTALLED=(); FAILED=(); SKIPPED=()
contains() { local x; for x in "${SELECTED[@]}"; do [[ "$x" == "$1" ]] && return 0; done; return 1; }
recommended() { SELECTED=(zsh zsh_plugins eza fzf fzf_tab fd yazi ripgrep zoxide zsh_defer oh_my_posh oh_my_tmux); }
full() { mapfile -t SELECTED < <(component_ids); }
is_wsl() { [[ -n "${WSL_INTEROP:-}${WSL_DISTRO_NAME:-}" || -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; }
add_dependencies() { local id dep; for id in "${SELECTED[@]}"; do while IFS= read -r dep; do contains "$dep" || SELECTED=("$dep" "${SELECTED[@]}"); done < <(dependencies "$id"); done; }
header() { printf '\n\033[1m🛠️  Ubuntu Developer Setup\033[0m\n\033[2mBuild your environment. Your way.\033[0m\n\n'; }

main_menu() {
    header
    printf '  1  ⭐ Recommended\n  2  🛠 Custom\n  3  🔎 Explore components\n\n  Choose an option [1-3]: '
    local choice; IFS= read -r choice
    case "$choice" in
        1) recommended;; 2) custom || return 1;; 3) printf '\nSupported components:\n'; local entry id category name script; for entry in "${COMPONENTS[@]}"; do IFS='|' read -r id category name script <<< "$entry"; printf '  • %-24s [%s] %s\n' "$name" "$category" "$id"; done; printf '\nPress Enter to continue. '; IFS= read -r; main_menu;; *) return 1;;
    esac
}

custom() {
    local i key cursor=0
    while :; do
        clear 2>/dev/null || true; header
        for i in "${!COMPONENTS[@]}"; do
            IFS='|' read -r id category name script <<< "${COMPONENTS[$i]}"
            if contains "$id"; then printf '  %s \033[32m◉\033[0m %-24s [%s]\n' "$([[ $i == $cursor ]] && echo '>' || echo ' ')" "$name" "$category"; else printf '  %s ◯ %-24s [%s]\n' "$([[ $i == $cursor ]] && echo '>' || echo ' ')" "$name" "$category"; fi
        done
        printf '\n  ↑↓ Navigate   Space Select   Enter Continue   Q Cancel\n'
        IFS= read -r -s -n 1 key || return 1
        case "$key" in
            $' ') IFS='|' read -r id _ _ _ <<< "${COMPONENTS[$cursor]}"; contains "$id" && SELECTED=("${SELECTED[@]/$id/}") || SELECTED+=("$id");;
            $'\n'|$'\r') return 0;; [qQ]) return 1;;
            $'\033') IFS= read -r -s -n 2 key; [[ "$key" == '[A' ]] && ((cursor=(cursor+${#COMPONENTS[@]}-1)%${#COMPONENTS[@]})); [[ "$key" == '[B' ]] && ((cursor=(cursor+1)%${#COMPONENTS[@]}));;
        esac
    done
}

run_selected() {
    local id script
    add_dependencies
    for id in "${SELECTED[@]}"; do
        [[ -z "$id" ]] && continue
        script="$(component_field "$id" script)"
        if [[ "$id" == ssh_windows ]] && ! is_wsl; then SKIPPED+=("$id"); continue; fi
        if (cd "$ROOT_DIR" && bash "$ROOT_DIR/$script"); then INSTALLED+=("$id"); else FAILED+=("$id"); fi
    done
}

case "${1:-}" in
    --help|-h) usage; exit 0;; --recommended) recommended;; --full) full;; --custom) custom || exit 0;; "") main_menu || exit 0;; *) usage >&2; exit 2;;
esac
header; printf 'Installing your environment...\n'; run_selected
printf '\nInstallation complete.\n  Installed: %s\n  Skipped: %s\n  Failed: %s\n' "${#INSTALLED[@]}" "${#SKIPPED[@]}" "${#FAILED[@]}"
if ((${#FAILED[@]})); then printf 'Failed components: %s\n' "${FAILED[*]}"; exit 1; fi