#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
factory_home="${FACTORY_HOME:-$HOME/.factory}"
cursor_home="${CURSOR_HOME:-$HOME/.cursor}"
hermes_home="${HERMES_HOME:-$HOME/.hermes}"
augment_home="${AUGMENT_HOME:-$HOME/.augment}"
gemini_home="${GEMINI_HOME:-$HOME/.gemini}"
codeium_home="${CODEIUM_HOME:-$HOME/.codeium}"

project_dir=""
targets=()

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [--target TARGET] [--project DIR]

Targets:
  all-user      Install user/global adapters. This is the default.
  all           Install all user adapters, plus project adapters when --project is set.
  agent-skill   ~/.agents/skills/gloop
  codex         Codex skill and prompt fallback
  claude        Claude Code command and skill
  factory       Factory skill, command, and optional Droid
  antigravity   Antigravity/Gemini skill locations
  cursor        Cursor skill and optional project rule/agent
  hermes        Hermes skill
  augment       Augment/Auggie skill
  gemini        Gemini-style skill compatibility files
  copilot       GitHub Copilot/VS Code project instructions; requires --project
  windsurf      Windsurf/Cascade workflow
  generic       AGENTS.md project adapter; requires --project

Examples:
  scripts/install.sh
  scripts/install.sh --target factory --target cursor
  scripts/install.sh --target all --project /path/to/repo
EOF
}

add_target() {
  local raw="$1"
  local item
  IFS=',' read -ra split_targets <<<"$raw"
  for item in "${split_targets[@]}"; do
    if [ -n "$item" ]; then
      targets+=("$item")
    fi
  done
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      [ "$#" -ge 2 ] || { echo "--target requires a value" >&2; exit 2; }
      add_target "$2"
      shift 2
      ;;
    --project)
      [ "$#" -ge 2 ] || { echo "--project requires a directory" >&2; exit 2; }
      project_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "${#targets[@]}" -eq 0 ]; then
  targets=("all-user")
fi

install_dir() {
  local src="$1"
  local dst="$2"
  rm -rf "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}

install_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp -p "$src" "$dst"
}

install_project_file() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ ! -e "$dst" ] || cmp -s "$src" "$dst"; then
    cp -p "$src" "$dst"
    echo "Installed $dst"
    return
  fi

  local alt="$dst.gloop-new"
  cp -p "$src" "$alt"
  echo "Preserved existing $dst; wrote $alt"
}

install_project_dir() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ ! -e "$dst" ]; then
    cp -R "$src" "$dst"
    echo "Installed $dst"
    return
  fi

  local alt="$dst.gloop-new"
  rm -rf "$alt"
  cp -R "$src" "$alt"
  echo "Preserved existing $dst; wrote $alt"
}

require_project() {
  local target="$1"
  if [ -z "$project_dir" ]; then
    echo "Skipping $target project files; pass --project DIR to install them"
    return 1
  fi
  mkdir -p "$project_dir"
  return 0
}

install_agent_skill() {
  install_dir "$repo_root/adapters/agent-skill/gloop" "$agents_home/skills/gloop"
  chmod +x "$agents_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Agent Skills adapter to $agents_home/skills/gloop"
}

install_codex() {
  install_dir "$repo_root/adapters/codex/skill/gloop" "$agents_home/skills/gloop"
  install_file "$repo_root/adapters/codex/prompts/gloop.md" "$codex_home/prompts/gloop.md"
  chmod +x "$agents_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Codex prompt to $codex_home/prompts/gloop.md"
}

install_claude() {
  install_file "$repo_root/adapters/claude/commands/gloop.md" "$claude_home/commands/gloop.md"
  install_dir "$repo_root/adapters/claude/skills/gloop" "$claude_home/skills/gloop"
  chmod +x "$claude_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Claude adapter to $claude_home"
}

install_factory() {
  install_dir "$repo_root/adapters/factory/skills/gloop" "$factory_home/skills/gloop"
  install_file "$repo_root/adapters/factory/commands/gloop.md" "$factory_home/commands/gloop.md"
  install_file "$repo_root/adapters/factory/droids/gloop-runner.md" "$factory_home/droids/gloop-runner.md"
  chmod +x "$factory_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Factory adapter to $factory_home"
}

install_antigravity() {
  install_dir "$repo_root/adapters/antigravity/skills/gloop" "$gemini_home/config/skills/gloop"
  install_dir "$repo_root/adapters/antigravity/skills/gloop" "$gemini_home/antigravity-cli/skills/gloop"
  echo "Installed Antigravity skill adapters to $gemini_home"
  if require_project antigravity; then
    install_project_dir "$repo_root/adapters/antigravity/skills/gloop" "$project_dir/.agents/skills/gloop"
    install_project_file "$repo_root/adapters/antigravity/workflows/gloop.md" "$project_dir/.agents/workflows/gloop.md"
  fi
}

install_cursor() {
  install_dir "$repo_root/adapters/cursor/skills/gloop" "$cursor_home/skills/gloop"
  install_file "$repo_root/adapters/cursor/agents/gloop-verifier.md" "$cursor_home/agents/gloop-verifier.md"
  chmod +x "$cursor_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Cursor user adapter to $cursor_home"
  if require_project cursor; then
    install_project_dir "$repo_root/adapters/cursor/skills/gloop" "$project_dir/.cursor/skills/gloop"
    install_project_file "$repo_root/adapters/cursor/rules/gloop.mdc" "$project_dir/.cursor/rules/gloop.mdc"
    install_project_file "$repo_root/adapters/cursor/agents/gloop-verifier.md" "$project_dir/.cursor/agents/gloop-verifier.md"
  fi
}

install_hermes() {
  install_dir "$repo_root/adapters/hermes/skills/gloop" "$hermes_home/skills/gloop"
  chmod +x "$hermes_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Hermes adapter to $hermes_home/skills/gloop"
}

install_augment() {
  install_dir "$repo_root/adapters/augment/skills/gloop" "$augment_home/skills/gloop"
  chmod +x "$augment_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Augment adapter to $augment_home/skills/gloop"
}

install_gemini() {
  install_dir "$repo_root/adapters/gemini/skills/gloop" "$gemini_home/skills/gloop"
  chmod +x "$gemini_home/skills/gloop/scripts/gloop-codex-exec.sh"
  echo "Installed Gemini compatibility adapter to $gemini_home"
}

install_copilot() {
  if require_project copilot; then
    install_project_file "$repo_root/adapters/copilot/copilot-instructions.md" "$project_dir/.github/copilot-instructions.md"
    install_project_file "$repo_root/adapters/copilot/instructions/gloop.instructions.md" "$project_dir/.github/instructions/gloop.instructions.md"
  fi
}

install_windsurf() {
  install_file "$repo_root/adapters/windsurf/workflows/gloop.md" "$codeium_home/windsurf/global_workflows/gloop.md"
  echo "Installed Windsurf global workflow to $codeium_home/windsurf/global_workflows/gloop.md"
  if require_project windsurf; then
    install_project_file "$repo_root/adapters/windsurf/workflows/gloop.md" "$project_dir/.windsurf/workflows/gloop.md"
  fi
}

install_generic() {
  if require_project generic; then
    install_project_file "$repo_root/adapters/generic/AGENTS.md" "$project_dir/AGENTS.md"
  fi
}

expanded_targets=()
for target in "${targets[@]}"; do
  case "$target" in
    all-user)
      expanded_targets+=(agent-skill codex claude factory antigravity cursor hermes augment gemini windsurf)
      ;;
    all)
      expanded_targets+=(agent-skill codex claude factory antigravity cursor hermes augment gemini copilot windsurf generic)
      ;;
    agent-skill|codex|claude|factory|antigravity|cursor|hermes|augment|gemini|copilot|windsurf|generic)
      expanded_targets+=("$target")
      ;;
    *)
      echo "Unknown target: $target" >&2
      usage >&2
      exit 2
      ;;
  esac
done

seen=" "
for target in "${expanded_targets[@]}"; do
  case "$seen" in
    *" $target "*) continue ;;
  esac
  seen="$seen$target "
  case "$target" in
    agent-skill) install_agent_skill ;;
    codex) install_codex ;;
    claude) install_claude ;;
    factory) install_factory ;;
    antigravity) install_antigravity ;;
    cursor) install_cursor ;;
    hermes) install_hermes ;;
    augment) install_augment ;;
    gemini) install_gemini ;;
    copilot) install_copilot ;;
    windsurf) install_windsurf ;;
    generic) install_generic ;;
  esac
done

echo "Gloop install complete."
