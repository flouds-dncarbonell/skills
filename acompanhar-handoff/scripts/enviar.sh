#!/usr/bin/env bash
# enviar.sh <pane> [--nova] "<mensagem>"
# Digita a mensagem no pane e aperta Enter. Com --nova, manda /clear antes
# (conversa nova). Limpa a linha de entrada antes de digitar.
PANE="${1:?pane}"; shift
NOVA=0; [ "$1" = "--nova" ] && { NOVA=1; shift; }
MSG="${1:?mensagem}"
tmux display -p -t "$PANE" "#{pane_id}" >/dev/null 2>&1 || { echo "PANE_GONE"; exit 2; }
tmux send-keys -t "$PANE" C-u; sleep 1
if [ "$NOVA" = 1 ]; then tmux send-keys -t "$PANE" "/clear" Enter; sleep 3; fi
tmux send-keys -t "$PANE" -l "$MSG"; sleep 1
tmux send-keys -t "$PANE" Enter; sleep 8
tmux capture-pane -p -t "$PANE" | grep -v '^\s*$' | tail -8
