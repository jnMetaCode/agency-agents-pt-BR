#!/usr/bin/env bash
#
# lint-agents.sh — 验证智能体 Markdown 文件
#   1. YAML frontmatter 必须包含 name, description, color, emoji (ERROR)
#   2. 推荐章节仅做警告 (WARN)
#   3. 文件必须有实质内容
#
# Usage: ./scripts/lint-agents.sh [file ...]
#   If no files given, scans all agent directories.

set -euo pipefail

# 与 scripts/convert.sh 中的 AGENT_DIRS 保持同步
AGENT_DIRS=(
  academic
  design
  engineering
  finance
  game-development
  hr
  legal
  marketing
  paid-media
  product
  project-management
  sales
  spatial-computing
  specialized
  strategy
  supply-chain
  support
  testing
)

REQUIRED_FRONTMATTER=("name" "description" "color" "emoji")
# 中英文任一即可——本仓库以中文为主，英文版用于上游同步
RECOMMENDED_SECTION_PATTERNS=(
  "身份|记忆|Identity"
  "核心使命|Core Mission"
  "关键规则|Critical Rules"
)

errors=0
warnings=0

classify_header_target() {
  local header_lower="$1"

  # 中文版支持中英文章节标题
  if [[ "$header_lower" =~ 身份 ]] ||
     [[ "$header_lower" =~ identity ]] ||
     [[ "$header_lower" =~ learning.*memory ]] ||
     [[ "$header_lower" =~ 记忆 ]] ||
     [[ "$header_lower" =~ communication ]] ||
     [[ "$header_lower" =~ 沟通 ]] ||
     [[ "$header_lower" =~ critical.rule ]] ||
     [[ "$header_lower" =~ 关键规则 ]] ||
     [[ "$header_lower" =~ rules.you.must.follow ]] ||
     [[ "$header_lower" =~ 核心使命 ]] ||
     [[ "$header_lower" =~ core.mission ]]; then
    printf 'soul'
  else
    printf 'agents'
  fi
}

lint_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "ERROR $file: 文件不存在"
    errors=$((errors + 1))
    return
  fi

  # 1. 检查 frontmatter 分隔符
  local first_line
  first_line=$(head -1 "$file")
  if [[ "$first_line" != "---" ]]; then
    echo "ERROR $file: 缺少 frontmatter 开头的 ---"
    errors=$((errors + 1))
    return
  fi

  # 提取 frontmatter（在两个 --- 之间）
  local frontmatter
  frontmatter=$(awk 'NR==1{next} /^---$/{exit} {print}' "$file")

  if [[ -z "$frontmatter" ]]; then
    echo "ERROR $file: frontmatter 为空或格式错误"
    errors=$((errors + 1))
    return
  fi

  # 2. 检查必须的 frontmatter 字段
  for field in "${REQUIRED_FRONTMATTER[@]}"; do
    if ! echo "$frontmatter" | grep -qE "^${field}:"; then
      echo "ERROR $file: 缺少 frontmatter 字段 '${field}'"
      errors=$((errors + 1))
    fi
  done

  # 3. 检查推荐章节（仅警告）
  local body
  body=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$file")

  for pattern in "${RECOMMENDED_SECTION_PATTERNS[@]}"; do
    if ! echo "$body" | grep -qiE "$pattern"; then
      echo "WARN  $file: 缺少推荐章节 (匹配: ${pattern})"
      warnings=$((warnings + 1))
    fi
  done

  # 4. 检查文件有实质内容（awk 处理 macOS/BSD wc 前导空格）
  local word_count
  word_count=$(echo "$body" | wc -w | awk '{print $1}')
  if [[ "${word_count:-0}" -lt 50 ]]; then
    echo "WARN  $file: 正文内容过短（< 50 词）"
    warnings=$((warnings + 1))
  fi

  # 5. 检查章节标题分类
  local soul_headers=0
  local agents_headers=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]] ]]; then
      local header_lower
      header_lower=$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')
      local target
      target=$(classify_header_target "$header_lower")
      if [[ "$target" == "soul" ]]; then
        soul_headers=$((soul_headers + 1))
      else
        agents_headers=$((agents_headers + 1))
      fi
    fi
  done <<< "$body"

  if [[ $soul_headers -eq 0 ]]; then
    echo "WARN  $file: 没有映射到 SOUL.md 的章节标题"
    warnings=$((warnings + 1))
  fi

  if [[ $agents_headers -eq 0 ]]; then
    echo "WARN  $file: 没有映射到 AGENTS.md 的章节标题"
    warnings=$((warnings + 1))
  fi
}

# 非角色文件（排除 lint 检查）
EXCLUDE_FILES=(
  strategy/QUICKSTART.md
  strategy/EXECUTIVE-BRIEF.md
  strategy/nexus-strategy.md
)

# 收集需要检查的文件
files=()
if [[ $# -gt 0 ]]; then
  files=("$@")
else
  for dir in "${AGENT_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      # 只扫描一级目录下的 .md 文件，跳过子目录（如 strategy/playbooks/）
      while IFS= read -r f; do
        files+=("$f")
      done < <(find "$dir" -maxdepth 1 -name "*.md" -type f | sort)
    fi
  done
  # 排除非角色文件
  for i in "${!files[@]}"; do
    for exc in "${EXCLUDE_FILES[@]}"; do
      if [[ "${files[$i]}" == "$exc" ]]; then
        unset 'files[i]'
        break
      fi
    done
  done
  # 重建索引
  files=("${files[@]}")
fi

if [[ ${#files[@]} -eq 0 ]]; then
  echo "未找到智能体文件。"
  exit 1
fi

echo "正在检查 ${#files[@]} 个智能体文件..."
echo ""

for file in "${files[@]}"; do
  lint_file "$file"
done

echo ""
echo "结果: ${errors} 个错误, ${warnings} 个警告, 共 ${#files[@]} 个文件。"

if [[ $errors -gt 0 ]]; then
  echo "❌ 未通过：合并前请修复以上错误。"
  exit 1
else
  echo "✅ 通过"
  exit 0
fi
