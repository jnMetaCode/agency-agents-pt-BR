#!/usr/bin/env bash
#
# translate-to-lang.sh — 用 Claude CLI 把上游 agency-agents 批量翻译到目标语言
#
# Usage:
#   scripts/translate-to-lang.sh <lang_code> <lang_native_name> <target_dir>
#
# Example:
#   scripts/translate-to-lang.sh ko "한국어 (Korean)" /Users/yx/work/wenzhang/agency-agents-ko
#   scripts/translate-to-lang.sh pt-BR "Português brasileiro" /Users/yx/work/wenzhang/agency-agents-pt-BR
#
# Env:
#   PARALLEL=N    并发数（默认 5）
#   FORCE=1       覆盖已存在的目标文件
#   ONLY=path     只翻译单个文件（路径相对仓库根）
#   MODEL=sonnet  模型别名
#   COMMIT=sha    上游 commit（默认 783f6a7）

set -euo pipefail

# ─── worker 模式 ─────────────────────────────────────────────────────────
# 当被 xargs 调用时执行单个文件翻译
if [ "${1:-}" = "--worker" ]; then
  shift
  PATH_REL="$1"
  TARGET_DIR="$2"
  LANG_NATIVE="$3"
  MODEL="$4"
  COMMIT="$5"
  FORCE="$6"
  LOG_DIR="$7"

  OUT="$TARGET_DIR/$PATH_REL"
  LOG="$LOG_DIR/$(echo "$PATH_REL" | tr '/' '_').log"

  if [ "$FORCE" != "1" ] && [ -f "$OUT" ] && [ -s "$OUT" ]; then
    echo "[skip] $PATH_REL"
    exit 0
  fi

  mkdir -p "$(dirname "$OUT")"

  SRC=$(curl -sfL "https://raw.githubusercontent.com/msitarzewski/agency-agents/${COMMIT}/${PATH_REL}") || {
    echo "[ERR ] fetch failed: $PATH_REL"
    exit 1
  }
  if [ -z "$SRC" ]; then
    echo "[ERR ] empty source: $PATH_REL"
    exit 1
  fi

  PROMPT_FILE=$(mktemp -t translate-XXXXXX.txt)
  trap 'rm -f "$PROMPT_FILE"' EXIT

  cat > "$PROMPT_FILE" <<PROMPT_EOF
Translate the following AI agent definition markdown file from English to ${LANG_NATIVE}.

RULES:
1. Preserve frontmatter (between --- delimiters) structure exactly. Translate the values of \`name:\`, \`description:\`, and \`vibe:\` into ${LANG_NATIVE}. Keep \`color:\` and \`emoji:\` values as-is.
2. Translate all body text (headings, paragraphs, bullets, table cells) into natural, native-speaker ${LANG_NATIVE} suitable for senior software professionals. Avoid literal/word-for-word translation. Use professional technical-writing register.
3. KEEP unchanged: code blocks (triple-backtick blocks), inline code (single-backtick), file paths, URLs, command names (cat, ls, grep, git, npm, docker, etc.), and well-known English technical terms (TensorFlow, PyTorch, RAG, MLOps, LLM, API, OAuth, SOC 2, OWASP, REST, GraphQL, Kubernetes, Docker, CI/CD, etc.).
4. KEEP all markdown structure: heading levels (# ## ###), emoji prefixes (🧠 🎯 🚨 etc.), table syntax (|---|---|), bold/italic markers, link syntax [text](url), list markers (- 1.).
5. For the agent's self-address (e.g. "You are an X"), use the natural ${LANG_NATIVE} idiom for AI/agent system prompts.
6. Do not add explanations, prefaces ("Here is the translation"), or notes. Output ONLY the translated markdown.
7. Do not wrap output in a code fence. Start directly with the frontmatter \`---\`.

SOURCE FILE (${PATH_REL}):
---BEGIN SOURCE---
${SRC}
---END SOURCE---
PROMPT_EOF

  if claude -p --no-session-persistence --model "$MODEL" --output-format text "$(cat "$PROMPT_FILE")" > "$OUT" 2> "$LOG"; then
    LINES=$(wc -l < "$OUT" | tr -d ' ')
    echo "[ok  ] $PATH_REL ($LINES lines)"
  else
    echo "[ERR ] translate failed: $PATH_REL (see $LOG)"
    rm -f "$OUT"
    exit 1
  fi
  exit 0
fi

# ─── 主模式 ──────────────────────────────────────────────────────────────
LANG_CODE="${1:?lang code required (e.g. ko)}"
LANG_NATIVE="${2:?lang native name required (e.g. \"한국어 (Korean)\")}"
TARGET_DIR="${3:?target dir required}"

PARALLEL="${PARALLEL:-5}"
FORCE="${FORCE:-0}"
ONLY="${ONLY:-}"
MODEL="${MODEL:-sonnet}"
COMMIT="${COMMIT:-783f6a7}"

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
UPSTREAM_FILES="/tmp/upstream-agents-${COMMIT}.txt"
LOG_DIR="/tmp/translate-${LANG_CODE}"
mkdir -p "$LOG_DIR" "$TARGET_DIR"

# 拉上游 agent 列表（缓存）
if [ ! -f "$UPSTREAM_FILES" ]; then
  echo "[fetch] upstream file list @ $COMMIT"
  gh api "repos/msitarzewski/agency-agents/git/trees/${COMMIT}?recursive=true" \
    --jq '.tree[] | select(.path | endswith(".md")) | .path' \
    | grep -Ev '^(\.github/|CONTRIBUTING|README|SECURITY|LICENSE|CATALOG|AGENT-LIST|UPSTREAM|ROADMAP|docs/|strategy/|skills/|examples/|integrations/|workflows/|scripts/)' \
    > "$UPSTREAM_FILES"
fi

TOTAL=$(wc -l < "$UPSTREAM_FILES" | tr -d ' ')
echo "[info] $TOTAL upstream agent files → $TARGET_DIR (lang=$LANG_NATIVE, model=$MODEL, parallel=$PARALLEL)"

if [ -n "$ONLY" ]; then
  echo "[only] $ONLY"
  bash "$SCRIPT_PATH" --worker "$ONLY" "$TARGET_DIR" "$LANG_NATIVE" "$MODEL" "$COMMIT" "$FORCE" "$LOG_DIR"
else
  cat "$UPSTREAM_FILES" \
    | xargs -n 1 -P "$PARALLEL" -I {} bash "$SCRIPT_PATH" --worker {} "$TARGET_DIR" "$LANG_NATIVE" "$MODEL" "$COMMIT" "$FORCE" "$LOG_DIR"
fi

DONE=$(find "$TARGET_DIR" -name "*.md" -not -path "*/.*" | wc -l | tr -d ' ')
echo ""
echo "[done] $DONE / $TOTAL files translated to $TARGET_DIR"
