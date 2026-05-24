#!/usr/bin/env bash
#
# install.sh -- Install agents into local AI tools (Brazilian Portuguese edition)
#
# Reads conversion files from integrations/ and copies to each tool config dir.
# Run scripts/convert.sh first to generate integration files.
#
# Usage:
#   ./scripts/install.sh [--tool <name>] [--no-interactive] [--help]
#
# Supported tools:
#   claude-code  -- Copy to ~/.claude/agents/
#   copilot      -- Copy to ~/.github/agents/
#   antigravity  -- Copy to ~/.gemini/antigravity/skills/
#   gemini-cli   -- Install to ~/.gemini/extensions/agency-agents/
#   opencode     -- Copy to .opencode/agent/(current dir)
#   cursor       -- Copy to .cursor/rules/(current dir)
#   trae         -- Copy to .trae/rules/(current dir)
#   aider        -- Copy CONVENTIONS.md(current dir)
#   windsurf     -- Copy .windsurfrules(current dir)
#   openclaw     -- Copy to ~/.openclaw/agency-agents/
#   qwen         -- Copy SubAgent to .qwen/agents/(project-scope)
#   codex        -- Copy to .codex/agents/(project-scope)
#   deerflow     -- Copy to DeerFlow custom skills dir(Docker project-scope)
#   workbuddy    -- Copy to ~/.workbuddy/skills/(global)
#   hermes       -- Copy to ~/.hermes/skills/(global)
#   kiro         -- Copy to ~/.kiro/agents/(global)
#   qoder        -- Copy to .qoder/agents/(project-scope)
#   all          -- install all detected tools(default)
#
# Hermes-specific options:
#   --category <name>  Install only skills under a category; can be passed multiple times.
#                      Category is the directory name under integrations/hermes/, e.g.:
#                        --category marketing
#                        --category engineering --category design
#                      In Discord mode, Hermes registers each skill as a slash command;
#                      total JSON over 8000 chars is rejected by Discord API (error 50035);
#                      to use in Discord, install in batches by category.

set -euo pipefail

# --- Colors ---
if [[ -t 1 ]]; then
  C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[0;31m'
  C_CYAN=$'\033[0;36m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''; C_DIM=''; C_RESET=''
fi

ok()     { printf "${C_GREEN}[OK]${C_RESET}  %s\n" "$*"; }
warn()   { printf "${C_YELLOW}[!!]${C_RESET}  %s\n" "$*"; }
err()    { printf "${C_RED}[ERR]${C_RESET} %s\n" "$*" >&2; }
header() { printf "\n${C_BOLD}%s${C_RESET}\n" "$*"; }
dim()    { printf "${C_DIM}%s${C_RESET}\n" "$*"; }

# --- Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INTEGRATIONS="$REPO_ROOT/integrations"

ALL_TOOLS=(claude-code copilot antigravity gemini-cli opencode openclaw cursor trae aider windsurf qwen codex deerflow workbuddy hermes kiro qoder)

# --- Usage ---
usage() {
  sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

# --- Pre-check ---
check_integrations() {
  if [[ ! -d "$INTEGRATIONS" ]]; then
    err "integrations/ does not exist. Run ./scripts/convert.sh"
    exit 1
  fi
}

# --- Tool detection ---
detect_claude_code() { [[ -d "${HOME}/.claude" ]]; }
detect_copilot()      { command -v code >/dev/null 2>&1 || [[ -d "${HOME}/.github" ]] || [[ -d "${HOME}/.copilot" ]]; }
detect_antigravity()  { [[ -d "${HOME}/.gemini/antigravity/skills" ]]; }
detect_gemini_cli()   { command -v gemini >/dev/null 2>&1 || [[ -d "${HOME}/.gemini" ]]; }
detect_cursor()       { command -v cursor >/dev/null 2>&1 || [[ -d "${HOME}/.cursor" ]]; }
detect_trae()         { command -v trae >/dev/null 2>&1 || [[ -d "${HOME}/.trae" ]]; }
detect_opencode()     { command -v opencode >/dev/null 2>&1 || [[ -d "${HOME}/.config/opencode" ]]; }
detect_aider()        { command -v aider >/dev/null 2>&1; }
detect_openclaw()     { command -v openclaw >/dev/null 2>&1 || [[ -d "${HOME}/.openclaw" ]]; }
detect_windsurf()     { command -v windsurf >/dev/null 2>&1 || [[ -d "${HOME}/.codeium" ]]; }
detect_qwen()         { command -v qwen >/dev/null 2>&1 || [[ -d "${HOME}/.qwen" ]]; }
detect_codex()        { command -v codex >/dev/null 2>&1 || [[ -d "${HOME}/.codex" ]]; }
detect_deerflow()     { command -v deerflow >/dev/null 2>&1 || [[ -d "${HOME}/.deerflow" ]] || docker ps --format '{{.Names}}' 2>/dev/null | grep -q deerflow; }
detect_workbuddy()    { command -v workbuddy >/dev/null 2>&1 || [[ -d "${HOME}/.workbuddy" ]]; }
detect_hermes()       { command -v hermes >/dev/null 2>&1 || [[ -d "${HOME}/.hermes" ]]; }
detect_kiro()         { command -v kiro >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1 || [[ -d "${HOME}/.kiro" ]]; }
detect_qoder()        { command -v qoder >/dev/null 2>&1 || [[ -d "${HOME}/.qoder" ]]; }

is_detected() {
  case "$1" in
    claude-code) detect_claude_code ;;
    copilot)     detect_copilot     ;;
    antigravity) detect_antigravity ;;
    gemini-cli)  detect_gemini_cli  ;;
    opencode)    detect_opencode    ;;
    openclaw)    detect_openclaw    ;;
    cursor)      detect_cursor      ;;
    trae)        detect_trae        ;;
    aider)       detect_aider       ;;
    windsurf)    detect_windsurf    ;;
    qwen)        detect_qwen        ;;
    codex)       detect_codex       ;;
    deerflow)    detect_deerflow    ;;
    workbuddy)   detect_workbuddy   ;;
    hermes)      detect_hermes      ;;
    kiro)        detect_kiro        ;;
    qoder)       detect_qoder       ;;
    *)           return 1 ;;
  esac
}

tool_label() {
  case "$1" in
    claude-code) printf "%-14s  %s" "Claude Code"  "(~/.claude/agents)"     ;;
    copilot)     printf "%-14s  %s" "Copilot"      "(~/.github + ~/.copilot)" ;;
    antigravity) printf "%-14s  %s" "Antigravity"  "(~/.gemini/antigravity)" ;;
    gemini-cli)  printf "%-14s  %s" "Gemini CLI"   "(gemini extension)"          ;;
    opencode)    printf "%-14s  %s" "OpenCode"     "(opencode.ai)"          ;;
    openclaw)    printf "%-14s  %s" "OpenClaw"     "(~/.openclaw)"          ;;
    cursor)      printf "%-14s  %s" "Cursor"       "(.cursor/rules)"        ;;
    trae)        printf "%-14s  %s" "Trae"         "(.trae/rules)"          ;;
    aider)       printf "%-14s  %s" "Aider"        "(CONVENTIONS.md)"       ;;
    windsurf)    printf "%-14s  %s" "Windsurf"     "(.windsurfrules)"       ;;
    qwen)        printf "%-14s  %s" "Qwen Code"    "(~/.qwen/agents)"       ;;
    codex)       printf "%-14s  %s" "Codex CLI"    "(.codex/agents)"        ;;
    deerflow)    printf "%-14s  %s" "DeerFlow"     "(skills/custom)"        ;;
    workbuddy)   printf "%-14s  %s" "WorkBuddy"    "(~/.workbuddy/skills)"  ;;
    hermes)      printf "%-14s  %s" "Hermes Agent" "(~/.hermes/skills)"     ;;
    kiro)        printf "%-14s  %s" "Kiro"         "(~/.kiro/agents)"       ;;
    qoder)       printf "%-14s  %s" "Qoder"        "(.qoder/agents)"        ;;
  esac
}

# --- Installer ---

install_claude_code() {
  local dest="${HOME}/.claude/agents"
  local count=0
  mkdir -p "$dest"
  local dir f first_line
  for dir in academic design engineering finance game-development hr legal marketing paid-media sales product \
              project-management supply-chain testing support spatial-computing specialized; do
    [[ -d "$REPO_ROOT/$dir" ]] || continue
    while IFS= read -r -d '' f; do
      first_line="$(head -1 "$f")"
      [[ "$first_line" == "---" ]] || continue
      cp "$f" "$dest/"
      (( count++ )) || true
    done < <(find "$REPO_ROOT/$dir" -name "*.md" -type f -print0)
  done
  ok "Claude Code: $count agents -> $dest"
}

install_copilot() {
  local dest1="${HOME}/.github/agents"
  local dest2="${HOME}/.copilot/agents"
  local count=0
  mkdir -p "$dest1" "$dest2"
  local dir f first_line
  for dir in academic design engineering finance game-development hr legal marketing paid-media sales product \
              project-management supply-chain testing support spatial-computing specialized; do
    [[ -d "$REPO_ROOT/$dir" ]] || continue
    while IFS= read -r -d '' f; do
      first_line="$(head -1 "$f")"
      [[ "$first_line" == "---" ]] || continue
      cp "$f" "$dest1/"
      cp "$f" "$dest2/"
      (( count++ )) || true
    done < <(find "$REPO_ROOT/$dir" -name "*.md" -type f -print0)
  done
  ok "Copilot: $count agents -> $dest1 + $dest2"
}

install_antigravity() {
  local src="$INTEGRATIONS/antigravity"
  local dest="${HOME}/.gemini/antigravity/skills"
  local count=0
  [[ -d "$src" ]] || { err "integrations/antigravity does not exist. Run convert.sh"; return 1; }
  mkdir -p "$dest"
  local d
  while IFS= read -r -d '' d; do
    local name; name="$(basename "$d")"
    mkdir -p "$dest/$name"
    cp "$d/SKILL.md" "$dest/$name/SKILL.md"
    (( count++ )) || true
  done < <(find "$src" -mindepth 1 -maxdepth 1 -type d -print0)
  ok "Antigravity: $count skills -> $dest"
}

install_gemini_cli() {
  local src="$INTEGRATIONS/gemini-cli"
  local dest="${HOME}/.gemini/extensions/agency-agents"
  local count=0
  [[ -d "$src" ]] || { err "integrations/gemini-cli does not exist. Run convert.sh --tool gemini-cli"; return 1; }
  [[ -f "$src/gemini-extension.json" ]] || { err "gemini-extension.json missing. Run convert.sh --tool gemini-cli"; return 1; }
  [[ -d "$src/skills" ]] || { err "skills/ dirmissing. Run convert.sh --tool gemini-cli"; return 1; }
  mkdir -p "$dest/skills"
  cp "$src/gemini-extension.json" "$dest/gemini-extension.json"
  local d
  while IFS= read -r -d '' d; do
    local name; name="$(basename "$d")"
    mkdir -p "$dest/skills/$name"
    cp "$d/SKILL.md" "$dest/skills/$name/SKILL.md"
    (( count++ )) || true
  done < <(find "$src/skills" -mindepth 1 -maxdepth 1 -type d -print0)
  ok "Gemini CLI: $count skills -> $dest"
}

install_opencode() {
  local src="$INTEGRATIONS/opencode/agents"
  local dest="${PWD}/.opencode/agents"
  local count=0
  [[ -d "$src" ]] || { err "integrations/opencode does not exist. Run convert.sh"; return 1; }
  mkdir -p "$dest"
  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"; (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)
  ok "OpenCode: $count agents -> $dest"
  warn "OpenCode: project-scopeinstall. Run from project root."
}

install_openclaw() {
  local src="$INTEGRATIONS/openclaw"
  local dest="${HOME}/.openclaw/agency-agents"
  local count=0
  [[ -d "$src" ]] || { err "integrations/openclaw does not exist. Run convert.sh"; return 1; }
  mkdir -p "$dest"
  local d
  while IFS= read -r -d '' d; do
    local name; name="$(basename "$d")"
    mkdir -p "$dest/$name"
    cp "$d/SOUL.md" "$dest/$name/SOUL.md"
    cp "$d/AGENTS.md" "$dest/$name/AGENTS.md"
    cp "$d/IDENTITY.md" "$dest/$name/IDENTITY.md"
    if command -v openclaw >/dev/null 2>&1; then
      # skip already-registered agents to avoid blocking on duplicate add(#34)
      if openclaw agents list 2>/dev/null | grep -q "$name"; then
        dim "  skip already-registered: $name"
      else
        # 30s timeout to prevent hang(macOS-compatible form)
        if command -v timeout >/dev/null 2>&1; then
          timeout 30 openclaw agents add "$name" --workspace "$dest/$name" --non-interactive 2>/dev/null || true
        else
          openclaw agents add "$name" --workspace "$dest/$name" --non-interactive 2>/dev/null &
          local pid=$!
          ( sleep 30 && kill "$pid" 2>/dev/null ) &
          wait "$pid" 2>/dev/null || true
        fi
      fi
    fi
    (( count++ )) || true
  done < <(find "$src" -mindepth 1 -maxdepth 1 -type d -print0)
  ok "OpenClaw: $count workspaces -> $dest"
  if command -v openclaw >/dev/null 2>&1; then
    warn "OpenClaw: run "openclaw gateway restart" to activate new agents"
  fi
}

install_cursor() {
  local src="$INTEGRATIONS/cursor/rules"
  local dest="${PWD}/.cursor/rules"
  local count=0
  [[ -d "$src" ]] || { err "integrations/cursor does not exist. Run convert.sh"; return 1; }
  mkdir -p "$dest"
  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"; (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.mdc" -print0)
  ok "Cursor: $count rules -> $dest"
  warn "Cursor: project-scopeinstall. Run from project root."
}

install_trae() {
  local src="$INTEGRATIONS/trae/rules"
  local dest="${PWD}/.trae/rules"
  local count=0
  [[ -d "$src" ]] || { err "integrations/trae does not exist. Run convert.sh --tool trae"; return 1; }
  mkdir -p "$dest"
  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"; (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)
  ok "Trae: $count rules -> $dest"
  warn "Trae: project-scopeinstall. Run from project root."
}

install_aider() {
  local src="$INTEGRATIONS/aider/CONVENTIONS.md"
  local dest="${PWD}/CONVENTIONS.md"
  [[ -f "$src" ]] || { err "integrations/aider/CONVENTIONS.md does not exist. Run convert.sh"; return 1; }
  if [[ -f "$dest" ]]; then
    warn "Aider: CONVENTIONS.md already exists ($dest)，delete and retry。"
    return 0
  fi
  cp "$src" "$dest"
  ok "Aider: installed -> $dest"
  warn "Aider: project-scopeinstall. Run from project root."
}

install_windsurf() {
  local src="$INTEGRATIONS/windsurf/.windsurfrules"
  local dest="${PWD}/.windsurfrules"
  [[ -f "$src" ]] || { err "integrations/windsurf/.windsurfrules does not exist. Run convert.sh"; return 1; }
  if [[ -f "$dest" ]]; then
    warn "Windsurf: .windsurfrules already exists ($dest)，delete and retry。"
    return 0
  fi
  cp "$src" "$dest"
  ok "Windsurf: installed -> $dest"
  warn "Windsurf: project-scopeinstall. Run from project root."
}

install_qwen() {
  local src="$INTEGRATIONS/qwen/agents"
  local dest="${PWD}/.qwen/agents"
  local count=0

  [[ -d "$src" ]] || { err "integrations/qwen does not exist. Run convert.sh"; return 1; }

  mkdir -p "$dest"

  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"
    (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)

  ok "Qwen Code: $count agents -> $dest"
  warn "Qwen Code: project-scopeinstall. Run from project root."
  warn "Tip: Run in Qwen Code '/agents manage' to refresh, or restart session"
}

install_codex() {
  local src="$INTEGRATIONS/codex/agents"
  local dest="${PWD}/.codex/agents"
  local count=0

  [[ -d "$src" ]] || { err "integrations/codex does not exist. Run convert.sh --tool codex"; return 1; }

  mkdir -p "$dest"

  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"
    (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.toml" -print0)

  ok "Codex CLI: $count agents -> $dest"
  warn "Codex CLI: project-scopeinstall. Run from project root."
}

install_deerflow() {
  local src="$INTEGRATIONS/deerflow"
  local dest="${DEERFLOW_SKILLS_DIR:-./skills/custom}"
  local count=0

  [[ -d "$src" ]] || { err "integrations/deerflow does not exist. Run convert.sh --tool deerflow"; return 1; }

  mkdir -p "$dest"

  local d
  while IFS= read -r -d '' d; do
    local name; name="$(basename "$d")"
    [[ -f "$d/SKILL.md" ]] || continue
    mkdir -p "$dest/$name"
    cp "$d/SKILL.md" "$dest/$name/SKILL.md"
    (( count++ )) || true
  done < <(find "$src" -mindepth 1 -maxdepth 1 -type d -print0)

  ok "DeerFlow: $count skills -> $dest"
  warn "DeerFlow: installs to ./skills/custom/。Set DEERFLOW_SKILLS_DIR to customize path。"
}

install_workbuddy() {
  local src="$INTEGRATIONS/workbuddy"
  local dest="${HOME}/.workbuddy/skills"
  local count=0

  [[ -d "$src" ]] || { err "integrations/workbuddy does not exist. Run convert.sh --tool workbuddy"; return 1; }

  mkdir -p "$dest"

  local d
  while IFS= read -r -d '' d; do
    local name; name="$(basename "$d")"
    [[ -f "$d/SKILL.md" ]] || continue
    mkdir -p "$dest/$name"
    cp "$d/SKILL.md" "$dest/$name/SKILL.md"
    (( count++ )) || true
  done < <(find "$src" -mindepth 1 -maxdepth 1 -type d -print0)

  ok "WorkBuddy: $count skills -> $dest"
}

install_hermes() {
  local src="$INTEGRATIONS/hermes"
  local dest="${HOME}/.hermes/skills"
  local count=0

  [[ -d "$src" ]] || { err "integrations/hermes does not exist. Run convert.sh --tool hermes"; return 1; }

  # If --category，install only matched categories；otherwise install all
  local filter_note=""
  if [[ ${#HERMES_CATEGORIES[@]} -gt 0 ]]; then
    local c
    for c in "${HERMES_CATEGORIES[@]}"; do
      [[ -d "$src/$c" ]] || { err "hermes categorydoes not exist: ${c}(optional: $(ls "$src" | tr '\n' ' '))"; return 1; }
    done
    filter_note=" [category: ${HERMES_CATEGORIES[*]}]"
  fi

  mkdir -p "$dest"

  # Hermes preserves two-level dir structure：category/skill-name/SKILL.md
  local catdir
  while IFS= read -r -d '' catdir; do
    local catname; catname="$(basename "$catdir")"
    if [[ ${#HERMES_CATEGORIES[@]} -gt 0 ]]; then
      local matched=false c
      for c in "${HERMES_CATEGORIES[@]}"; do [[ "$c" == "$catname" ]] && matched=true && break; done
      $matched || continue
    fi
    local skilldir
    while IFS= read -r -d '' skilldir; do
      local skillname; skillname="$(basename "$skilldir")"
      [[ -f "$skilldir/SKILL.md" ]] || continue
      mkdir -p "$dest/$catname/$skillname"
      cp "$skilldir/SKILL.md" "$dest/$catname/$skillname/SKILL.md"
      (( count++ )) || true
    done < <(find "$catdir" -mindepth 1 -maxdepth 1 -type d -print0)
  done < <(find "$src" -mindepth 1 -maxdepth 1 -type d -print0)

  ok "Hermes Agent: $count skills -> $dest$filter_note"
  if [[ ${#HERMES_CATEGORIES[@]} -eq 0 && $count -gt 80 ]]; then
    warn "Hermes Discord mode caps total slash commands at 8000 chars(error 50035)。"
    warn "To use in Discord, prefer --category <name> to install in batches by category。"
  fi
}

install_kiro() {
  local src="$INTEGRATIONS/kiro"
  local dest="${HOME}/.kiro/agents"
  local count=0

  [[ -d "$src" ]] || { err "integrations/kiro does not exist. Run convert.sh --tool kiro"; return 1; }

  mkdir -p "$dest/prompts"

  # Copy JSON config file
  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"
    (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.json" -print0)

  # Copy prompt file
  if [[ -d "$src/prompts" ]]; then
    while IFS= read -r -d '' f; do
      cp "$f" "$dest/prompts/"
    done < <(find "$src/prompts" -maxdepth 1 -name "*.md" -print0)
  fi

  ok "Kiro: $count agents -> $dest"
  warn "Tip: Use in Kiro '/agent swap' to switch agents"
}

install_qoder() {
  local src="$INTEGRATIONS/qoder/agents"
  local dest="${PWD}/.qoder/agents"
  local count=0

  [[ -d "$src" ]] || { err "integrations/qoder does not exist. Run convert.sh --tool qoder"; return 1; }

  mkdir -p "$dest"

  local f
  while IFS= read -r -d '' f; do
    cp "$f" "$dest/"
    (( count++ )) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)

  ok "Qoder: $count agents -> $dest"
  warn "Qoder: project-scopeinstall. Run from project root."
}

install_tool() {
  case "$1" in
    claude-code) install_claude_code ;;
    copilot)     install_copilot     ;;
    antigravity) install_antigravity ;;
    gemini-cli)  install_gemini_cli  ;;
    opencode)    install_opencode    ;;
    openclaw)    install_openclaw    ;;
    cursor)      install_cursor      ;;
    trae)        install_trae        ;;
    aider)       install_aider       ;;
    windsurf)    install_windsurf    ;;
    qwen)        install_qwen        ;;
    codex)       install_codex       ;;
    deerflow)    install_deerflow    ;;
    workbuddy)   install_workbuddy   ;;
    hermes)      install_hermes      ;;
    kiro)        install_kiro        ;;
    qoder)       install_qoder       ;;
  esac
}

# --- Entry ---
main() {
  local tool="all"
  HERMES_CATEGORIES=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tool)            tool="${2:?'--tool requires a value'}"; shift 2 ;;
      --category)        HERMES_CATEGORIES+=("${2:?'--category requires a value'}"); shift 2 ;;
      --no-interactive)  shift ;;
      --help|-h)         usage ;;
      *)                 err "Unknown option: $1"; usage ;;
    esac
  done

  if [[ ${#HERMES_CATEGORIES[@]} -gt 0 && "$tool" != "hermes" ]]; then
    warn "--category only applies to --tool hermes; ignored."
    HERMES_CATEGORIES=()
  fi

  check_integrations

  if [[ "$tool" != "all" ]]; then
    local valid=false t
    for t in "${ALL_TOOLS[@]}"; do [[ "$t" == "$tool" ]] && valid=true && break; done
    if ! $valid; then
      err "Unknown tool '$tool'。optional: ${ALL_TOOLS[*]}"
      exit 1
    fi
  fi

  SELECTED_TOOLS=()

  if [[ "$tool" != "all" ]]; then
    SELECTED_TOOLS=("$tool")
  else
    header "AI Agent Team -- scanning installed tools..."
    printf "\n"
    local t
    for t in "${ALL_TOOLS[@]}"; do
      if is_detected "$t" 2>/dev/null; then
        SELECTED_TOOLS+=("$t")
        printf "  ${C_GREEN}[*]${C_RESET}  %s  ${C_DIM}detected${C_RESET}\n" "$(tool_label "$t")"
      else
        printf "  ${C_DIM}[ ]  %s  not found${C_RESET}\n" "$(tool_label "$t")"
      fi
    done
  fi

  if [[ ${#SELECTED_TOOLS[@]} -eq 0 ]]; then
    warn "No tool selected and none detected。"
    printf "\n"
    dim "  Tip: Use --tool <name> to force-install a specific tool。"
    dim "  optional: ${ALL_TOOLS[*]}"
    exit 0
  fi

  printf "\n"
  header "AI Agent Team -- installing agents"
  printf "  Repo:     %s\n" "$REPO_ROOT"
  printf "  Install to:   %s\n" "${SELECTED_TOOLS[*]}"
  printf "\n"

  local installed=0 t
  for t in "${SELECTED_TOOLS[@]}"; do
    install_tool "$t"
    (( installed++ )) || true
  done

  printf "\n"
  ok "done! installed $installed tools。"
  printf "\n"
  dim "  Run ./scripts/convert.sh to regenerate integration files。"
  printf "\n"
}

main "$@"
