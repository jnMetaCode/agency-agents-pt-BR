# agency-agents Português brasileiro (Equipe de Especialistas em IA)

🌐 **Português (BR)** | [English (upstream)](https://github.com/msitarzewski/agency-agents) | [简体中文](https://github.com/jnMetaCode/agency-agents-zh) | [한국어](https://github.com/jnMetaCode/agency-agents-ko) | [Русский](https://github.com/jnMetaCode/agency-agents-ru) | [Bahasa Indonesia](https://github.com/jnMetaCode/agency-agents-id) | [العربية](https://github.com/jnMetaCode/agency-agents-ar)

> **187 personas de agentes de IA plug-and-play** — cobrindo engenharia, design, marketing, produto, jogos, segurança, finanças e outros 18 departamentos. Não são templates genéricos de prompt: cada agente tem persona própria, fluxo profissional e entregáveis bem definidos. Suporte a Claude Code / Cursor / Copilot e mais 17 ferramentas de IA para programação.

Edição da comunidade brasileira do [agency-agents](https://github.com/msitarzewski/agency-agents). Tradução completa dos 184 agentes upstream. **PRs bem-vindos** para agentes específicos do mercado brasileiro (WhatsApp Business, iFood, Mercado Livre, PIX, LGPD, Nubank-style fintech, etc.).

[![GitHub stars](https://img.shields.io/github/stars/jnMetaCode/agency-agents-pt-BR?style=social)](https://github.com/jnMetaCode/agency-agents-pt-BR)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://makeapullrequest.com)


### 📊 Escala do projeto

| 🤖 Agentes IA | 🌏 Traduções upstream | 🇧🇷 Originais Brasil | 🧠 Ferramentas | 🏢 Departamentos |
|:---:|:---:|:---:|:---:|:---:|
| **187** | **184** | **3** | **17** | **18** |

---

## 🚀 Agency Orchestrator — Coloque a biblioteca de personas para rodar de verdade

> **💡 Uma frase, vários especialistas de IA colaborando automaticamente, resultado completo em minutos.**
>
> A biblioteca de personas fornece os especialistas; o [**Agency Orchestrator**](https://github.com/jnMetaCode/agency-orchestrator) faz eles trabalharem como um time real.

```bash
npm install -g agency-orchestrator
ao compose "Faça uma análise profunda sobre AI Agents" --run
```

```
🎭 Casting automático → Narratologista + Psicólogo + Criador de Conteúdo + Designer Narrativo
📊 Orquestração automática → DAG, detecção de dependências, execução paralela
✅ Entrega automática → resultado completo em minutos
```

| Recurso | Descrição |
|:---|:---|
| 🎯 **Orquestração sem código** | Linguagem natural ou YAML, descreva o que quer numa frase |
| ⚡ **Execução DAG paralela** | Detecta dependências, roda etapas independentes em paralelo, velocidade dobrada |
| 🔄 **Retomada de checkpoint** | Falhou um passo? Roda só ele, não precisa começar do zero |
| 🆓 **6 LLMs gratuitos** | Claude Code / Gemini CLI / Copilot / Codex / OpenClaw / Ollama |
| 💰 **3 integrações via API** | DeepSeek / Claude API / OpenAI |
| 📋 **32 templates prontos** | Dev, marketing, análise de dados, design, operações |

<p align="center">
  <a href="https://github.com/jnMetaCode/agency-orchestrator">
    <strong>⭐ Conheça o Agency Orchestrator — coloque os 187 agentes para colaborar →</strong>
  </a>
</p>

---

## O que é isso?

Uma **biblioteca de personas de IA pronta para uso**. Cada agente tem identidade clara, regras críticas, fluxo de trabalho e entregáveis definidos. Instale na sua ferramenta de IA e ative com linguagem natural.

**Diferença para prompts comuns**: prompts comuns dizem à IA "você é um especialista"; aqui os agentes definem **como o especialista pensa, como trabalha e o que entrega**. Por exemplo, o [Engenheiro de Segurança](engineering/engineering-security-engineer.md) revisa código item por item seguindo OWASP Top 10; o [Desenvolvedor Frontend](engineering/engineering-frontend-developer.md) refatora componentes React conforme ARIA / acessibilidade / orçamento de performance.

---

## Início rápido

### Modo 1: Instalação automática na sua ferramenta de IA

Suporta **17 ferramentas populares de IA para programação**, com um único comando:

```bash
# Detecta automaticamente as ferramentas instaladas e instala em todas
./scripts/install.sh

# Ou especifique a ferramenta
./scripts/install.sh --tool openclaw       # OpenClaw ⭐ recomendado
./scripts/install.sh --tool claude-code    # Claude Code
./scripts/install.sh --tool copilot        # GitHub Copilot
./scripts/install.sh --tool cursor         # Cursor
./scripts/install.sh --tool kiro           # Kiro (Amazon)
./scripts/install.sh --tool trae           # Trae
./scripts/install.sh --tool opencode       # OpenCode
./scripts/install.sh --tool aider          # Aider
./scripts/install.sh --tool windsurf       # Windsurf
./scripts/install.sh --tool antigravity    # Antigravity
./scripts/install.sh --tool gemini-cli     # Gemini CLI
./scripts/install.sh --tool qwen           # Qwen Code
./scripts/install.sh --tool codex          # Codex CLI
./scripts/install.sh --tool deerflow       # DeerFlow 2.0 (ByteDance)
./scripts/install.sh --tool workbuddy      # WorkBuddy (Tencent)
./scripts/install.sh --tool hermes         # Hermes Agent (NousResearch)
./scripts/install.sh --tool qoder          # Qoder
```

> Claude Code e GitHub Copilot funcionam direto; outras ferramentas precisam rodar `./scripts/convert.sh` antes.

### 🔥 OpenClaw — guia rápido

OpenClaw é a integração com mais usuários da comunidade. Cada agente é dividido em três arquivos: `SOUL.md` (identidade/persona) + `AGENTS.md` (capacidades de negócio) + `IDENTITY.md` (resumo). Suporta orquestração multi-agente nativamente.

```bash
./scripts/convert.sh --tool openclaw   # Passo 1: converte para formato SOUL.md
./scripts/install.sh --tool openclaw   # Passo 2: instala em ~/.openclaw/
```

Após instalar, reinicie o gateway OpenClaw para usar.

### Modo 2: Cópia manual

```bash
# Claude Code / GitHub Copilot (basta copiar)
cp -r engineering/*.md ~/.claude/agents/

# Ativando no Claude Code:
# "Ative o modo Desenvolvedor Frontend e me ajude a construir um componente React"
```

### Modo 3: Como referência de prompt

Navegue pelo [CATALOG.md](CATALOG.md) e copie/adapte o que precisar!

---

## Roster de agentes

Catálogo completo dos 187 agentes em **[CATALOG.md](CATALOG.md)**. Resumo por departamento:

| Departamento | Agentes | Papéis típicos |
|--------------|---------|----------------|
| 🛠️ Engenharia | 29 | Frontend, Backend Architect, AI Engineer, DevOps, Security, SRE, Embedded, FPGA |
| 🎨 Design | 8 | UI/UX, Brand Guardian, Image Prompt Engineer, Visual Storyteller |
| 📢 Marketing | 30 | Growth Hacker, Content Creator, SEO, TikTok / Twitter / Instagram / Reddit |
| 💰 Mídia Paga | 7 | Auditoria, Creative Strategist, PPC, Programmatic, Tracking |
| 💼 Vendas | 8 | Account Strategist, Sales Coach, MEDDPICC Deal Strategist, Outbound |
| 🏦 Finanças | 5 | Bookkeeper Controller, FP&A Analyst, Investment Researcher, Fraud Detection |
| 📦 Produto | 5 | Product Manager, Feedback Synthesizer, Trend Researcher, Prioritizer |
| 📋 Projetos | 6 | Studio Producer, Experiment Tracker, Project Shipper |
| 🧪 Testes | 8 | Test Automation, API Tester, Performance Benchmarker, Reality Checker |
| 🤝 Suporte | 6 | Incident Communicator, Customer Insights Extractor |
| 🔬 Especialização | 41 | Blockchain Security Audit, SOC 2 / ISO 27001 / HIPAA Compliance, Legal Document Review, Real Estate, HR Onboarding |
| 🥽 Computação Espacial | 6 | XR User Research, AR/VR Engineer, Haptic Designer |
| 🎮 Game Dev | 20 | Unity Architect, Unreal Architect, Godot, Roblox, Blender, Game Design, Multiplayer |
| 📖 Acadêmico | 5 | Antropólogo, Psicólogo, Historiador, Narratologista, Geógrafo |

---

## 🇧🇷 Agentes específicos para o mercado brasileiro — PRs Welcome

A tradução dos 184 agentes upstream está completa. Contribuições bem-vindas para agentes específicos do Brasil:

- **Plataformas brasileiras**: WhatsApp Business / WhatsApp Cloud API, Instagram BR, TikTok BR, Kwai
- **E-commerce / Marketplaces**: Mercado Livre seller, Mercado Pago, Magazine Luiza, Amazon BR, Shopee BR
- **Fintech / Pagamentos**: PIX integration, Open Finance Brasil, Nubank-style product manager, Pagar.me / Stripe LATAM
- **Delivery / SaaS**: iFood seller, Rappi BR, RD Station marketing, Pipefy automation
- **Compliance**: LGPD officer, Marco Civil da Internet, Banco Central do Brasil regulations, ANPD
- **Verticais**: K-12 brasileiro (Geekie/Eleva), agronegócio digital, mineração e commodities

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes.

---

## Casos de uso

### Cenário 1: MVP para lançamento internacional

**Seu time**:
1. **Desenvolvedor Frontend** — Constrói o app em React
2. **Backend Architect** — Projeta API e banco de dados
3. **Growth Hacker** — Planeja aquisição de usuários
4. **Rapid Prototyper** — Itera rápido
5. **Reality Checker** — Quality gate antes do lançamento

### Cenário 2: Auditoria de segurança + compliance

**Seu time**:
1. **Engenheiro de Segurança** — Revisão de código por OWASP Top 10
2. **Blockchain Security Auditor** (se aplicável) — Análise de vulnerabilidades em smart contracts
3. **Compliance Auditor** — Verificação de SOC 2 / ISO 27001 / HIPAA
4. **Incident Communicator** — Comunica os riscos encontrados para a liderança
5. **Technical Writer** — Documenta o relatório de auditoria

---

## Contribuir

Tradução, melhorias de conteúdo e novos agentes específicos para o Brasil são bem-vindos. Veja [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Projetos irmãos

| Projeto | Posicionamento | Resumo |
|---------|----------------|--------|
| **Este projeto** (agency-agents-pt-BR) | 🎭 Biblioteca de personas em PT-BR | 187 especialistas de IA **prontos para uso**, PRs do mercado brasileiro bem-vindos |
| [agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh) ![](https://img.shields.io/github/stars/jnMetaCode/agency-agents-zh?style=flat&label=⭐) | 🇨🇳 Edição em chinês | 215 agentes (165 traduções + 50 originais do mercado chinês — Xiaohongshu / Douyin / WeChat / Bilibili) |
| [agency-agents-ko](https://github.com/jnMetaCode/agency-agents-ko) | 🇰🇷 Edição em coreano | 187 agentes traduzidos |
| [agency-agents-ru](https://github.com/jnMetaCode/agency-agents-ru) | 🇷🇺 Edição em russo | 187 agentes traduzidos |
| [agency-agents-id](https://github.com/jnMetaCode/agency-agents-id) | 🇮🇩 Edição em indonésio | 187 agentes traduzidos |
| [agency-agents-ar](https://github.com/jnMetaCode/agency-agents-ar) | 🇸🇦 Edição em árabe | 187 agentes traduzidos |
| [agency-agents](https://github.com/msitarzewski/agency-agents) | 🌏 Upstream em inglês | 184 agentes originais — a base deste projeto |
| [agency-orchestrator](https://github.com/jnMetaCode/agency-orchestrator) | 🚀 Motor de orquestração | Uma frase → 187 especialistas colaboram, **resultado em minutos** (9 LLMs / 6 gratuitos) |

---

## Agradecimentos

- Versão original em inglês: [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) (MIT License)
- Obrigado ao autor original [@msitarzewski](https://github.com/msitarzewski) por criar este projeto excelente
- A tradução para português brasileiro foi feita em lote com Claude Sonnet com revisão de amostras representativas. PRs para melhorias de fluência sempre bem-vindos.

---

## Licença

MIT License — uso comercial ou pessoal liberado.

---

<div align="center">

**187 personas de agentes de IA, 17 ferramentas suportadas, prontos para usar**

[⭐ Star neste projeto](https://github.com/jnMetaCode/agency-agents-pt-BR) · [Reportar issue](https://github.com/jnMetaCode/agency-agents-pt-BR/issues) · [Contribuir](https://github.com/jnMetaCode/agency-agents-pt-BR/pulls)

Baseado em [agency-agents](https://github.com/msitarzewski/agency-agents), traduzido e localizado para o Brasil

</div>
