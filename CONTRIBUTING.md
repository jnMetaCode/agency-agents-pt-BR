# Guia de contribuição

Obrigado pelo interesse em contribuir! Tradução, correções, novos agentes específicos para o mercado brasileiro — qualquer tipo de contribuição é bem-vinda.

## O que você pode fazer

### 1. Melhorar traduções

Os 184 agentes do upstream [agency-agents](https://github.com/msitarzewski/agency-agents) foram traduzidos em lote com Claude Sonnet. Se encontrar trechos não-fluentes ou que não soam naturais em português brasileiro, envie um PR.

Cuidados na tradução:
- Não traduza literalmente — use português brasileiro natural
- Traduza os comentários dentro dos exemplos de código
- Mantenha o formato do frontmatter (name, description, color, emoji, vibe)
- Termos técnicos consagrados em inglês (TensorFlow, PyTorch, RAG, MLOps, LLM, API, OAuth, REST, etc.) ficam em inglês
- Blocos de código, caminhos de arquivo, URLs, nomes de comandos (cat, ls, grep, git, npm) não mudam

### 2. Criar agentes específicos para o Brasil

Se tem ideias de agentes para plataformas ou cenários brasileiros, envie um PR. Sugestões:

- **Plataformas / Apps**: WhatsApp Business / Cloud API, Instagram BR, TikTok BR, Kwai BR
- **E-commerce**: Mercado Livre seller, Mercado Pago, Magazine Luiza, Amazon BR, Shopee BR
- **Fintech / Pagamentos**: PIX integration, Open Finance Brasil, Pagar.me, Stripe LATAM
- **Delivery / SaaS BR**: iFood seller, Rappi, RD Station, Pipefy
- **Compliance**: LGPD officer, Marco Civil da Internet, BACEN, ANPD
- **Verticais**: K-12 brasileiro (Geekie/Eleva), agronegócio digital, mineração

### 3. Melhorar conteúdo existente

Tradução imprecisa, exemplo de código desatualizado, ou expressão melhor — sinta-se livre para corrigir.

## Formato do arquivo de agente

```markdown
---
name: Nome do agente
description: Uma frase descrevendo o que esse agente faz
color: nome da cor (ou #HEX)
emoji: emoji
vibe: linha curta com o vibe do agente
---

# Nome do agente

Você é o **Nome do agente**, [uma frase de posicionamento].

## Identidade e memória
- **Papel**: papel específico
- **Personalidade**: traços de personalidade
- **Memória**: o que lembra
- **Experiência**: no que é bom

## Missão principal
Responsabilidades específicas e escopo de trabalho

## Regras críticas
Princípios e linhas vermelhas

## Entregáveis técnicos
Exemplos de código, templates, frameworks, etc.

## Fluxo de trabalho
Passos do trabalho

## Estilo de comunicação
Exemplos de fala e tom

## Métricas de sucesso
Critérios quantificáveis
```

## Linhas vermelhas de conteúdo

Os PRs abaixo serão fechados. Confira antes de enviar.

### 1. Sem vinculação a empregador / marca específica

Os agentes são "papéis e metodologias", não identidades de funcionários. O seguinte não é aceito:

```
Você é Engenheiro XX da Empresa XX — grupo líder global em soluções XX...
- Papel: Engenheiro XX, do grupo XX
```

Forma correta (neutra):

```
Você é Engenheiro XX, especialista prático em XX. Em diversos projetos XX você...
- Papel: Engenheiro XX — foco em metodologia e execução em XX
```

**Exceção**: nomes de modelos de equipamentos, softwares ou protocolos consagrados (ex.: "Bullmer S90 PRO", "Adobe Premiere Pro", "PCI DSS") são referência técnica, não brand placement; podem permanecer.

### 2. Sem APIs / plugins de ferramentas específicas no corpo do prompt

O prompt do agente assume execução em qualquer LLM, em qualquer ferramenta. Colocar nomes de API, modos de chamada ou links externos de uma ferramenta específica no corpo do prompt polui usuários em outros contextos e vira espaço de propaganda.

Isto não é aceito:

```
### Integração com ferramenta XX
No ambiente XX Agent, se [xxx-plugin] estiver instalado, use:
- `tool_explore` para buscar...
- `tool_read` para ler...
```

Para divulgar uso da sua ferramenta com esta biblioteca, mantenha um guia em seu próprio repositório.

### 3. Sem "soft marketing" disfarçado de tradução / adição

PR com título "docs: complemento" mas conteúdo é link externo, menção a produto próprio, âncoras de SEO — será tratado pelo conteúdo real, não pelo título.

## Enviar PR

1. Faça fork deste repositório
2. Crie branch: `git checkout -b add-xxx-agent`
3. Escreva o conteúdo e revise o formato localmente
4. Abra o PR explicando brevemente o que foi feito

## Convenções

- Arquivos com quebras LF (não CRLF)
- Um PR faz uma coisa (não misture tradução com adição)
- Commit messages em português ou inglês
