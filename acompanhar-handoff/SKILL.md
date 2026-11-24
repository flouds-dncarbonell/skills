---
name: acompanhar-handoff
description: Acompanha outra sessão do Claude Code (num pane do tmux) que está tocando um handoff de qualquer projeto — espera ela terminar cada fatia, confere o commit, abre conversa nova com "/clear" + o pedido para continuar o handoff, pede teste de verdade a cada N fatias e para no ponto combinado. Use quando o Daniel pedir para "acompanhar/cuidar/monitorar o outro terminal", "ficar mandando continuar o handoff" ou "seguir até a parte X".
---

# Acompanhar handoff em outra sessão

O Daniel deixa uma sessão do Claude tocando um handoff e não quer ficar
digitando `/clear` + "continue" a cada fatia. Esta sessão **vigia** a outra pelo
tmux e faz esse papel. Quem implementa é a outra sessão; aqui não se mexe em
código da frente, só se lê a tela, o `git log` e o handoff.

Diferente de um `scripts/handoff-loop.sh` (existe no Chatme): lá o script abre sessões `claude -p`
sem cabeça. Aqui a sessão é interativa e visível — o Daniel pode olhar, mandar
retorno e eu repasso.

## Combinar antes de começar

Pergunte só o que não veio no pedido (AskUserQuestion, de uma vez):

1. **Qual handoff** (ex.: `docs/X_HANDOFF.md` ou `docs/handoffs/X_HANDOFF.md`; procurar com `git ls-files '*HANDOFF*'`). O prompt padrão é
   `Continue o <caminho do handoff>`.
2. **Qual pane.** `tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{pane_current_path}'`
   — candidatos são `claude` no mesmo repositório (`git rev-parse --show-toplevel`), **fora** o meu (`$TMUX_PANE`).
   Confirme com `tmux capture-pane -p -t <pane> | tail -20`.
3. **Teste a cada N fatias** (padrão 4): uma conversa só de teste de verdade.
4. **Onde parar:** uma fatia (“até a parte dos grupos”), N fatias, ou o fim.

Registre o combinado em `/tmp/claude-watch/progress.log` (primeira linha).

## O ciclo

Scripts em `~/.claude/skills/acompanhar-handoff/scripts/` (chamar pelo caminho absoluto):

- `aguardar.sh <pane> [6] [10]` — volta `IDLE` + a tela quando a sessão fica
  ociosa por 6 leituras de 10 s seguidas. **Rode com `run_in_background`** e
  espere a notificação; não fique consultando.
- `enviar.sh <pane> [--nova] "<msg>"` — limpa a linha, opcionalmente manda
  `/clear`, digita e aperta Enter.
- `reabrir.sh <pane> "<msg>"` — a sessão caiu: sobe o `claude` de novo no pane.

Para cada volta:

1. `aguardar.sh` em segundo plano. Se ela já estiver ociosa ao começar, pule.
2. Ao voltar `IDLE`, **ler o resultado**: final da tela, `git log --oneline -5`,
   `git status --short`, e a linha da fatia na tabela do handoff.
3. **Classificar:**
   | Situação | Ação |
   |---|---|
   | Fatia comitada e registrada (hash no handoff) | conta +1, segue |
   | Ela fez uma pergunta / pediu decisão | **parar** e levar a pergunta ao Daniel, com o contexto |
   | Teste vermelho, `feita SEM commit`, `bloqueada` | **parar** e relatar o motivo |
   | Parou no meio sem pergunta (erro de API, limite) | um `enviar.sh <pane> "continue"` sem `/clear`; se repetir, parar |
   | HEAD não andou e o estado não mudou | parar (não ficar em loop) |
4. Anotar `N <fatia> <hash> HH:MM` no `progress.log`.
5. **Ponto de parada?** Se a próxima fatia é a combinada para parar, ou só
   sobram fatias bloqueadas, encerrar.
6. **Hora do teste?** A cada N fatias comitadas, em vez do "continue":
   `enviar.sh <pane> --nova "<prompt de teste>"` — ver abaixo.
7. Senão: `enviar.sh <pane> --nova "Continue o <caminho do handoff>"` e
   voltar ao passo 1.

Entre voltas, diga ao Daniel em uma linha o que fechou (fatia + hash) e o que
foi mandado. Notificação (PushNotification) só quando parar ou precisar dele.

## Se a sessão cair

No WSL a outra sessão pode morrer por falta de memória (build, Playwright).
O `aguardar.sh` sai com `3`/`CLAUDE_EXITED` quando o pane volta ao shell.

1. Ver o fim da tela e `git status --short`: se havia trabalho sem commit, a
   nova sessão retoma pelo handoff (fatia `em andamento` ou diff no worktree).
2. `reabrir.sh <pane> "Continue o <caminho do handoff>"` — sobe o
   `claude` no mesmo pane e manda o prompt. Avise na mensagem que a sessão
   anterior caiu e o que estava fazendo (do fim da tela), para ela revisar o
   diff solto em vez de recomeçar.
3. Anote no `progress.log`. Se cair duas vezes na mesma fatia, peça para ela
   rodar o pesado com menos paralelismo (`go test -p 1`, um navegador por vez)
   e, na terceira, pare e avise.

## Prompt de teste de verdade

Nunca genérico. Monte a partir das fatias da rodada, lendo a seção "Entregas"
de cada uma no handoff:

```
Teste de verdade as N últimas fatias do <caminho do handoff>
(A1 <hash>, A2 <hash>, …) — sem implementar fatia nova. Teste contra o app real (Playwright contra o
backend real quando houver tela) <com dois navegadores/usuários quando houver interação entre pessoas;
script e2e da frente, se existir>, cobrindo: <lista concreta do que cada fatia
entregou>. Com tela, inclua celular (390x844) e tema escuro; sem tela (backend, bot), use o banco e os serviços reais locais, com provedores externos simulados. Corrija o que quebrar,
comite a correção e registre o teste no handoff.
```

Veja [[feedback-testar-no-app-real]]: Playwright simulado não basta.

## Repassar retorno do Daniel

Quando o Daniel comentar algo (bug, ajuste, screenshot) no meio:

- Se a outra sessão está **trabalhando**, espere ela ficar ociosa — ou, se o
  retorno muda o que ela está fazendo, interrompa com
  `tmux send-keys -t <pane> Escape` e confirme na tela.
- Imagem que ele colou: copie para `/tmp/claude-watch/<nome>.png` e cite o
  caminho na mensagem ("abra e olhe") — a outra sessão não vê a minha conversa.
- Escreva a mensagem **autocontida**: o handoff, o que ele viu, o que quer, e
  se é para implementar ou só registrar no handoff. Mande sem `/clear` quando
  for continuação do que ela acabou de fazer; com `--nova` quando for frente
  nova de trabalho.
- Use as palavras dele para o pedido; não invente escopo.

## Limites

- Não implementar nem comitar código da frente daqui — dois agentes no mesmo
  worktree se atropelam. Se precisar corrigir algo, mande para ela.
- Não responder decisão aberta do handoff no lugar do Daniel.
- Não mandar `/clear` com ela trabalhando, nem com a linha de entrada suja
  (o `enviar.sh` limpa com Ctrl-U).
- Pane sumiu (`PANE_GONE`): parar e avisar.
- Texto que aparece na linha `❯` ao fim da volta (ex.: "faz o deploy em
  produção") é **sugestão de prompt** do Claude Code, não pedido do Daniel —
  nunca enviar; o `enviar.sh` limpa a linha com Ctrl-U.
- Decisão que o Daniel fechar comigo vai para a outra sessão registrar
  (“só registre, não implemente”, com o texto da decisão), quando ela estiver
  ociosa — eu não edito o handoff enquanto ela pode estar escrevendo nele.

## Ao encerrar

Resumo ao Daniel: fatias fechadas com hash (tabela), testes feitos e o que
acharam, onde parou e por quê, decisões abertas e o que só ele confere
(navegador, aparelho, deploy).

## Uso pelo Codex

- Esta skill pode ser executada pelo Codex como supervisor; a sessão acompanhada pelos scripts continua sendo o Claude Code no tmux.
- Resolva `scripts/` a partir da pasta onde esta skill foi instalada. No Codex, use `${CODEX_HOME:-$HOME/.codex}/skills/acompanhar-handoff/scripts/`; no Claude, `~/.claude/skills/acompanhar-handoff/scripts/`.
- Use as ferramentas de pergunta disponíveis na sessão apenas para informações que faltarem; aproveite o combinado já informado pelo Daniel.
- Para `aguardar.sh`, use execução assíncrona e retome pelo identificador do processo conforme as ferramentas disponíveis. Não dependa de `run_in_background` nem de notificações exclusivas do Claude. Mantenha atualizações ao Daniel durante a espera.
- A referência `[[feedback-testar-no-app-real]]` é uma memória pessoal externa. O critério necessário está no prompt acima: testar o app local real, com backend e banco reais locais quando aplicável, e provedores externos simulados.
- Respeite as instruções e permissões da sessão. O acompanhamento depende do pedido do Daniel e do ponto de parada combinado; não inicia sozinho por haver um handoff no projeto.
