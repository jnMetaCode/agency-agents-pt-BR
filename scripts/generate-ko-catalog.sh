#!/usr/bin/env bash
#
# generate-ko-catalog.sh — 扫描 ko repo 的 agent 文件，从 frontmatter 抽 name，生成 CATALOG.md
#
# Usage: scripts/generate-ko-catalog.sh <target_repo_dir>

set -euo pipefail

TARGET="${1:?target repo dir required}"
OUT="$TARGET/CATALOG.md"

if [ ! -d "$TARGET" ]; then
  echo "[ERR] $TARGET does not exist"
  exit 1
fi

dept_name() {
  case "$1" in
    academic)            echo "📖 학술" ;;
    design)              echo "🎨 디자인" ;;
    engineering)         echo "🛠️ 엔지니어링" ;;
    finance)             echo "🏦 금융" ;;
    game-development)    echo "🎮 게임 개발" ;;
    hr)                  echo "👔 인사" ;;
    legal)               echo "⚖️ 법무" ;;
    marketing)           echo "📢 마케팅" ;;
    paid-media)          echo "💰 페이드 미디어" ;;
    product)             echo "📦 제품" ;;
    project-management)  echo "📋 프로젝트 관리" ;;
    sales)               echo "💼 세일즈" ;;
    spatial-computing)   echo "🥽 공간 컴퓨팅" ;;
    specialized)         echo "🔬 스페셜티" ;;
    supply-chain)        echo "🚚 공급망" ;;
    support)             echo "🤝 고객 지원" ;;
    testing)             echo "🧪 테스팅" ;;
    *)                   echo "$1" ;;
  esac
}

DEPT_ORDER="academic design engineering finance game-development marketing paid-media product project-management sales spatial-computing specialized support testing"

cat > "$OUT" <<'HEADER_EOF'
# 에이전트 카탈로그

> Ctrl+F / Cmd+F 로 한국어명을 검색하여 해당 파일 경로를 찾고, AI 도구에 로드하라고 알려주세요.
>
> 사용 예: `engineering/engineering-software-architect.md 역할로 내 아키텍처를 리뷰해 줘`

---

HEADER_EOF

extract_name() {
  local f="$1"
  awk 'BEGIN{c=0} /^---$/{c++; if(c>=2)exit; next} c==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/["'\''`]/, ""); sub(/[[:space:]]*$/, ""); print; exit}' "$f"
}

for dept in $DEPT_ORDER; do
  if [ ! -d "$TARGET/$dept" ]; then
    continue
  fi
  files=$(find "$TARGET/$dept" -name "*.md" -not -name "README.md" | sort)
  count=$(echo "$files" | grep -c '^.' || true)
  if [ "$count" -eq 0 ]; then
    continue
  fi
  dname=$(dept_name "$dept")
  printf "\n## %s (%d)\n\n| 한국어명 | 파일 경로 |\n|---------|-----------|\n" "$dname" "$count" >> "$OUT"
  echo "$files" | while read -r f; do
    [ -z "$f" ] && continue
    name=$(extract_name "$f")
    rel=${f#"$TARGET/"}
    echo "| $name | \`$rel\` |" >> "$OUT"
  done
done

printf "\n---\n\n" >> "$OUT"
TOTAL=$(find "$TARGET" -name "*.md" -not -path "*/.*" -not -name "README.md" -not -name "CATALOG.md" -not -name "CONTRIBUTING.md" -not -name "UPSTREAM.md" -not -name "AGENT-LIST.md" -not -name "LICENSE*" -not -path "*/scripts/*" | wc -l | tr -d ' ')
echo "**총 $TOTAL 개의 에이전트** · 상위 [agency-agents](https://github.com/msitarzewski/agency-agents) 의 한국어판" >> "$OUT"

echo "[ok] generated $OUT ($(wc -l < "$OUT" | tr -d ' ') lines, $TOTAL agents)"
