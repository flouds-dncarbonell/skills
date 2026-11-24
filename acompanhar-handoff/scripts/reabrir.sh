#!/usr/bin/env bash
# reabrir.sh <pane> "<mensagem>"
# A sessão do Claude caiu e o pane voltou ao shell: sobe o claude de novo no
# mesmo diretório (mesmas flags) e manda a mensagem (em geral o "Continue o …").
PANE="${1:?pane}"; MSG="${2:?mensagem}"
cmd=$(tmux display -p -t "$PANE" '#{pane_current_command}' 2>/dev/null) || { echo "PANE_GONE"; exit 2; }
[ "$cmd" = "claude" ] && { echo "claude ainda está rodando no $PANE"; exit 1; }
tmux send-keys -t "$PANE" C-c; sleep 1
DIR=$(tmux display -p -t "$PANE" "#{pane_current_path}")
tmux send-keys -t "$PANE" -l "cd \"$DIR\" && claude --dangerously-skip-permissions"
tmux send-keys -t "$PANE" Enter
for i in $(seq 1 30); do
  sleep 2
  tmux capture-pane -p -t "$PANE" | grep -q "bypass permissions" && break
done
sleep 3
tmux send-keys -t "$PANE" -l "$MSG"; sleep 1; tmux send-keys -t "$PANE" Enter; sleep 8
tmux capture-pane -p -t "$PANE" | grep -v '^\s*$' | tail -8
