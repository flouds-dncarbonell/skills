# Skills pessoais

Skills pessoais para planejar, retomar e acompanhar trabalho organizado em handoffs.

| Skill | Finalidade |
| --- | --- |
| [handoff](handoff/SKILL.md) | Planejar projetos em fatias, continuar a execução e registrar decisões, validações e commits. |
| [acompanhar-handoff](acompanhar-handoff/SKILL.md) | Acompanhar outra sessão do Claude Code pelo tmux, conferir entregas e continuar até o ponto combinado. |

## Instalação

Clone este repositório e copie as pastas para os diretórios de skills:

```bash
git clone https://github.com/flouds-dncarbonell/skills.git
mkdir -p ~/.codex/skills ~/.claude/skills
cp -R skills/handoff ~/.codex/skills/
cp -R skills/acompanhar-handoff ~/.codex/skills/
cp -R skills/acompanhar-handoff ~/.claude/skills/
```

A skill `acompanhar-handoff` requer Bash, tmux e Claude Code disponíveis no ambiente. Seus scripts interagem com uma sessão existente; `reabrir.sh` inicia o Claude com `--dangerously-skip-permissions`, conforme o fluxo pessoal original.

O conteúdo mantém as convenções pessoais de uso. Referências a projetos, memórias e ferramentas locais podem precisar de adaptação em outros ambientes. Os arquivos de apoio estão incluídos nas respectivas pastas.
