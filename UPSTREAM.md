# Versão upstream

Registro da versão upstream [agency-agents](https://github.com/msitarzewski/agency-agents) em que este projeto se baseia, para facilitar sincronização de atualizações.

## Baseline atual

- **Repositório upstream**: https://github.com/msitarzewski/agency-agents
- **Commit de referência**: `783f6a7` (2026-04-12)
- **Total de agentes upstream**: 184 (excluindo os 16 documentos de operação em `strategy/`)

## Cobertura de tradução

| Categoria | Total upstream | Traduzidos | Cobertura |
|-----------|---------------:|-----------:|----------:|
| academic | 5 | 5 | 100% |
| design | 8 | 8 | 100% |
| engineering | 29 | 29 | 100% |
| finance | 5 | 5 | 100% |
| game-development | 20 | 20 | 100% |
| marketing | 30 | 30 | 100% |
| paid-media | 7 | 7 | 100% |
| product | 5 | 5 | 100% |
| project-management | 6 | 6 | 100% |
| sales | 8 | 8 | 100% |
| spatial-computing | 6 | 6 | 100% |
| specialized | 41 | 41 | 100% |
| support | 6 | 6 | 100% |
| testing | 8 | 8 | 100% |
| **Total** | **184** | **184** | **100%** |

> `strategy/` contém playbooks / runbooks / templates de colaboração; conteúdo é idêntico ao upstream e não entra na contagem de agentes.

## Método de tradução

Inglês upstream → português brasileiro (tradução em lote via Claude Sonnet). Preserva o tom e estrutura do README original, com expressões naturais para o leitor brasileiro.

- Termos técnicos consagrados em inglês (TensorFlow / PyTorch / RAG / MLOps / LLM / API / OAuth / REST etc.): mantidos em inglês
- Blocos de código, caminhos, URLs, nomes de comandos: inalterados
- Corpo / headings / tabelas / listas: traduzidos para português brasileiro natural
- Frontmatter `name:`, `description:`, `vibe:`: traduzidos; `color:`, `emoji:`: preservados

## Agentes específicos para o Brasil

Além das 184 traduções, **PRs para agentes específicos do Brasil são bem-vindos**. Áreas em aberto:

- Plataformas BR (WhatsApp Business, Instagram BR, TikTok BR, Kwai)
- E-commerce / Marketplaces (Mercado Livre, Magazine Luiza, Amazon BR, Shopee BR)
- Fintech / Pagamentos (PIX, Open Finance, Nubank-style)
- Delivery / SaaS BR (iFood, Rappi, RD Station)
- Compliance (LGPD, Marco Civil, BACEN, ANPD)
- Verticais (K-12 BR, agronegócio, mineração)

Detalhes em [CONTRIBUTING.md](./CONTRIBUTING.md).

## Política de sincronização

- Acompanhar branch `main` do upstream
- Novos agentes upstream serão traduzidos progressivamente
- Mudanças estruturais grandes (renomeação de diretórios, etc.) refletidas em até 1 semana
- Versão do upstream atualizada neste arquivo a cada sincronização
