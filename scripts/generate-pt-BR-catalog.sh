#!/usr/bin/env bash
#
# generate-pt-BR-catalog.sh — Brazilian Portuguese CATALOG generator
#
# Usage: scripts/generate-pt-BR-catalog.sh <target_repo_dir>

set -euo pipefail

TARGET="${1:?target repo dir required}"
OUT="$TARGET/CATALOG.md"

dept_name() {
  case "$1" in
    academic)            echo "📖 Acadêmico" ;;
    design)              echo "🎨 Design" ;;
    engineering)         echo "🛠️ Engenharia" ;;
    finance)             echo "🏦 Finanças" ;;
    game-development)    echo "🎮 Game Dev" ;;
    hr)                  echo "👔 Recursos Humanos" ;;
    legal)               echo "⚖️ Jurídico" ;;
    marketing)           echo "📢 Marketing" ;;
    paid-media)          echo "💰 Mídia Paga" ;;
    product)             echo "📦 Produto" ;;
    project-management)  echo "📋 Projetos" ;;
    sales)               echo "💼 Vendas" ;;
    spatial-computing)   echo "🥽 Computação Espacial" ;;
    specialized)         echo "🔬 Especialização" ;;
    supply-chain)        echo "🚚 Cadeia de Suprimentos" ;;
    support)             echo "🤝 Suporte" ;;
    testing)             echo "🧪 Testes" ;;
    *)                   echo "$1" ;;
  esac
}

DEPT_ORDER="academic design engineering finance game-development marketing paid-media product project-management sales spatial-computing specialized support testing"

cat > "$OUT" <<'HEADER_EOF'
# Catálogo de agentes

> Use Ctrl+F / Cmd+F para buscar o nome em português, encontre o caminho do arquivo e diga à sua ferramenta de IA para carregá-lo.
>
> Exemplo: `Use a persona engineering/engineering-software-architect.md para revisar minha arquitetura`

---

HEADER_EOF

extract_name() {
  local f="$1"
  awk 'BEGIN{c=0} /^---$/{c++; if(c>=2)exit; next} c==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); gsub(/["'\''`]/, ""); sub(/[[:space:]]*$/, ""); print; exit}' "$f"
}

for dept in $DEPT_ORDER; do
  if [ ! -d "$TARGET/$dept" ]; then continue; fi
  files=$(find "$TARGET/$dept" -name "*.md" -not -name "README.md" | sort)
  count=$(echo "$files" | grep -c '^.' || true)
  if [ "$count" -eq 0 ]; then continue; fi
  dname=$(dept_name "$dept")
  printf "\n## %s (%d)\n\n| Nome | Caminho do arquivo |\n|------|-------------------|\n" "$dname" "$count" >> "$OUT"
  echo "$files" | while read -r f; do
    [ -z "$f" ] && continue
    name=$(extract_name "$f")
    rel=${f#"$TARGET/"}
    echo "| $name | \`$rel\` |" >> "$OUT"
  done
done

printf "\n---\n\n" >> "$OUT"
TOTAL=$(find "$TARGET" -name "*.md" -not -path "*/.*" -not -name "README.md" -not -name "CATALOG.md" -not -name "CONTRIBUTING.md" -not -name "UPSTREAM.md" -not -name "AGENT-LIST.md" -not -name "LICENSE*" -not -path "*/scripts/*" | wc -l | tr -d ' ')
echo "**Total: $TOTAL agentes** · edição em português brasileiro do [agency-agents](https://github.com/msitarzewski/agency-agents)" >> "$OUT"

echo "[ok] generated $OUT ($(wc -l < "$OUT" | tr -d ' ') lines, $TOTAL agents)"
