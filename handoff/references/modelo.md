# Esqueleto do handoff

Copie para `docs/<TEMA>_HANDOFF.md` e preencha. Seção marcada *(opcional)* sai
inteira quando não se aplica — não deixe título vazio. Prosa curta, frases
inteiras, pt-BR; nada de segredo (cite variáveis de ambiente).

```markdown
# <Título da frente> — handoff

<Um parágrafo: o que o Daniel pediu, quando (AAAA-MM-DD), para quem é o valor e
de onde veio o pedido (cliente, conversa, incidente).>

Prompt para continuar em outra conversa:

> Continue o `docs/<TEMA>_HANDOFF.md`

**Próxima fatia: <ID>.** Protocolo: skill `handoff`
(`~/.codex/skills/handoff/SKILL.md`). <Se houver: "Frente N do roteador
`UX_MELHORIAS.md` §9.">

**Referência visual:** `docs/mockups/<arquivo>.html` *(opcional — só frente com tela nova)*

## Decisões

### Fechadas (Daniel, AAAA-MM-DD)

- <decisão> — <o porquê, se ele disse>.

### Padrões do planejamento

São escolhas técnicas desta proposta, não decisões do Daniel. Valem até ele
dizer outra coisa.

- <padrão>.

### Abertas

<"Nenhuma." ou, por item:>
- **<pergunta>** — impacto: <o que muda>; trava: <fatias>.

## Estado conferido no código *(opcional)*

<O que já existe e o que falta, com caminho. Conferido em AAAA-MM-DD — a
próxima conversa confere de novo antes de mexer.>

| Parte | Já existe | Falta |
|---|---|---|

## Fatias

Ordem de execução = ordem da tabela. Dependência é pré-requisito, não
trabalho simultâneo.

| Fatia | Escopo | Depende de | Estado |
|---|---|---|---|
| X1 | <uma linha> | — | pendente |
| X2 | <uma linha> | X1 | pendente |

### X1 — <título>

- <escopo: o que muda, regra de negócio, caso de borda>.
- **Entradas:** <arquivos/pacotes onde começa>.
- **Contrato/API:** <operação nova e escopo de API key, ou por que não entra
  em automações>.
- **Migration:** <o que muda no banco e o backfill — não reserve número, ele
  sai na hora de implementar> *(se houver)*.
- **Aceite/testes:** <o que prova que está pronto; specs novos precisam estar na configuração de testes>.

## Onde mexe

- `internal/<pacote>/` — <papel>.
- `web/src/<caminho>` — <papel>.

## Testes da frente

<Só o que é específico desta frente (specs, filtro `-run`, dado de cliente para
ensaio). O comum está em `~/.codex/skills/handoff/references/validacao.md`.>

## Entregas

<Uma seção por fatia comitada, a mais recente por último.>

### X1 — comitada (`<hash>`, AAAA-MM-DD)

<Escopo final e o que difere do plano.>

- Arquivos compartilhados: <lista>.
- Contrato/API: <…>.
- Validação (índice em worktree limpo): <comandos e resultado>.
- Já falhava no HEAD `<hash>`: <testes>, não vem desta fatia.
- Limites reais: <o que só navegador/aparelho/cliente confere>.

## Pendências

- <o que fica para depois da frente: conferir no navegador, deploy, cliente,
  ideia fora do escopo>.
```

## Variações por tipo

- **Investigação:** "Estado conferido" vira **Evidências** (consultas, logs,
  hashes, o que foi descartado). Fatias são hipóteses; entrega documental é
  `sem código`.
- **Migração de cliente:** acrescente **Origem medida** (contagens reais e a
  data da medição) e **Corte** (janela, backup, rollback, quem avisa o cliente).
- **Frente com roteador próprio** (muitas fatias, ordem que muda): a tabela
  "Fatias" já é o roteador; não crie outro arquivo.
