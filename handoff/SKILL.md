---
name: handoff
description: Cria, continua e registra handoffs de projetos em fatias verificáveis, com decisões, dependências, critérios de aceite, validações e commits. Use ao planejar em fatias, criar um handoff ou retomar uma frente documentada.
---

# Handoff

Um handoff é a memória de uma frente: o que foi pedido, o que está decidido,
como o trabalho foi fatiado e onde parou. Ele existe porque cada conversa estoura
o contexto; a próxima retoma **só** pelo arquivo, sem depender da anterior.

O protocolo mora **aqui**, não em cada handoff. Handoff antigo que traz o
protocolo copiado e diverge desta skill ou do `AGENTS.md` (ex.: hunks por
`git apply --cached`) está desatualizado — vale a skill.

## Modos

| Pedido | Modo |
|---|---|
| "planeja isso em fatias", "cria um handoff de…", `/handoff novo <tema>` | **Novo** |
| "continue o `docs/X_HANDOFF.md`", "continue <frente>", `/handoff continuar` | **Continuar** |
| fatia acabou de ser comitada, `/handoff registrar` | **Registrar** |

---

## Novo

1. **Entender antes de fatiar.** Ler o código que a frente toca e o que já
   existe (não recriar). Dados de cliente: conferir fontes disponíveis com acesso de leitura autorizado; não inventar medições. Registrar o achado em "Estado conferido".
2. **Separar decisões em três grupos** — é o que evita reabrir assunto:
   - *Fechadas*: o Daniel disse. Com data. Nunca reabrir sem ele pedir.
   - *Padrões do planejamento*: escolha técnica sua; vale até ele dizer outra coisa.
   - *Abertas*: pergunta + impacto + fatias que ela trava. Perguntar ao Daniel
     **antes** de escrever o handoff o que ele consegue responder agora
     (ferramenta de perguntas disponível ou conversa); o resto fica aberto e as fatias independentes seguem.
3. **Fatiar por valor entregue**, não por camada. Cada fatia cabe numa conversa,
   tem aceite verificável e termina comitada sozinha. Ids curtos com prefixo da
   frente (`MB1`, `T7`, `E4`); subdivisão vira `E4a`/`E4b`, nunca renumera.
4. **Escrever** pelo esqueleto de [`references/modelo.md`](references/modelo.md),
   em `docs/<TEMA>_HANDOFF.md`. Nada de segredo no arquivo; referencie nomes das variáveis de ambiente.
5. **Ligar a frente:** referenciar o handoff no README ou AGENTS.md do projeto. Atualizar um roteador existente somente se aplicável. Não criar memória do Claude nem alterar outro repositório.
6. **Comitar o plano** (`docs(<área>): planejar <tema> em fatias`) e encerrar
   com: fatias, decisões abertas e o prompt de retomada. Planejar não implementa
   a primeira fatia na mesma conversa, salvo pedido.

## Continuar

Sem pedir confirmação entre os passos; só para quando um passo falha.

1. **Ler o estado:** cabeçalho, "Decisões", tabela "Fatias", `git status --short`
   e `git log --oneline -10`. Se o handoff cita um hash, confira que existe.
2. **Entrega em aberto primeiro.** Fatia `feita SEM commit` ou `em andamento`:
   revisar o diff contra o escopo dela, corrigir, rodar os testes que ela tocou,
   comitar só ela e registrar. Se não passar, pare aqui com o motivo escrito.
3. **Próxima fatia:** a primeira `pendente` cujas dependências estão comitadas e
   que não depende de decisão aberta. Ler a seção dela, "Onde mexe" e o código
   citado — o handoff pode estar velho; o código manda.
4. **Antes de tela**, usar a skill de design do produto; em identidade nova, `frontend-design` (e o mockup, se houver).
5. **Implementar só a fatia.** Grande demais para a conversa? Subdivida no
   handoff (`C3` → `C3a`, `C3b`, escopo de cada uma), faça e comite a primeira.
   Escopo novo que apareceu no caminho vira fatia nova ou "Pendências", não
   entra de carona.
6. **Revisar e testar** pela [`references/validacao.md`](references/validacao.md):
   o diff contra o escopo + os testes que a fatia tocou, com o índice validado
   num worktree limpo.
7. **Comitar só a entrega** (mesma referência): blob do HEAD com os blocos da
   fatia, `git update-index --cacheinfo`, nunca `-U0`; sem `Co-Authored-By`.
8. **Registrar** (modo abaixo).
9. **Encerrar** dizendo: o que foi comitado (hash), o que ficou sem commit e
   por quê, decisões abertas que surgiram e a próxima fatia.

Uma fatia por conversa é o padrão. Se o projeto tiver um loop de execução explicitamente invocado, seguir seu contrato.

## Registrar

O registro é parte da entrega: é por ele que a próxima conversa — e o mapa do
`handoff-loop.sh` — acha onde parou.

1. **Tabela "Fatias":** estado no vocabulário fixo abaixo, com hash.
2. **Cabeçalho:** `**Próxima fatia: X.**` atualizado.
3. **"Entregas":** seção `### X — comitada (`hash`, AAAA-MM-DD)` com escopo
   final (o que difere do plano), arquivos compartilhados tocados, contrato/API
   (operação nova, ou por que não houve), comandos de validação e resultado,
   falhas que já existiam no HEAD (com o hash onde foram vistas) e limites reais
   (o que só o navegador ou o aparelho confere).
4. **Notas para as próximas fatias**, quando a fatia descobriu algo que muda o
   plano das seguintes: escreva na seção da fatia afetada, não só na entrega.
5. **Índice da frente:** atualizar referências existentes no projeto quando mudar o estado, sem criar dependência de memória externa.
6. **Comitar o registro** (`docs(<área>): registrar <fatia>`). Pode ir junto com
   o commit da fatia seguinte quando ela vem na mesma conversa.
7. **Frente concluída:** `Concluída em AAAA-MM-DD` no cabeçalho, na memória e no
   roteador; o que só o Daniel confere (navegador, deploy, cliente) vai em
   "Pendências" — não deixa a frente "em andamento".

### Vocabulário de estado

Use exatamente estas formas na coluna "Estado" — o mapa do loop lê por elas:

| Estado | Quando |
|---|---|
| `pendente` | não começou |
| `em andamento` | começou e a conversa acabou no meio (descreva onde) |
| `feita SEM commit — <motivo>` | pronta, mas teste vermelho ou decisão aberta impede o commit |
| `comitada (`hash`)` | entregue; subdividida: `subdividida em E4a, E4b` e as filhas na tabela |
| `bloqueada — <o quê>` | depende de decisão, credencial, cliente ou aparelho |
| `sem código (`hash` da doc)` | investigação/decisão que terminou em documento |

"Não comitar" não é o lugar seguro: `feita SEM commit` só com motivo escrito.

## Tipos de frente

O esqueleto é o mesmo; muda o que é uma fatia.

- **Feature:** fatia = comportamento entregue de ponta a ponta (migration,
  API, tela, testes). Avaliar uso por automações em cada operação nova
  (`AGENTS.md` §API).
- **Investigação / incidente:** fatia = hipótese testada ou correção. Registre
  evidência (consulta, log, hash) e o que foi descartado; a conclusão vira
  `docs/<TEMA>_<AAAA-MM-DD>.md` quando outra frente precisar dela.
- **Migração / importação de cliente:** fatias de leitura → ensaio em cópia →
  corte. Contagens antes/depois, backup nomeado (`schema <x>_bkp_<data>`),
  comando de rollback. Ensaio em produção só dentro de `BEGIN … ROLLBACK`.
- **Operação / deploy:** fatia = mudança verificável no ambiente; registre o
  estado anterior e como voltar. Nada destrutivo sem o ok do Daniel na conversa.

## Adaptação para Codex

- Respeitar instruções da sessão e o AGENTS.md aplicável. Os exemplos do Chatme não impõem stack, i18n, RLS ou acesso a produção em outros projetos.
- Fatias não autorizam envio de mensagens, deploy ou alteração de outro sistema por si só.
- Em pasta sem Git, inicializar um repositório local se necessário à entrega; nunca versionar dados privados, credenciais ou artefatos gerados.
- Se o usuário pedir implementação junto do planejamento, implementar a primeira fatia independente e atualizar o handoff.
