#!/usr/bin/env bash
# aguardar.sh <pane> [checagens=6] [intervalo=10]
# Espera a sessão do Claude no pane ficar ociosa: <checagens> leituras seguidas
# sem "esc to interrupt". Imprime IDLE + as últimas 80 linhas da tela.
# Saída 2 = o pane sumiu; saída 3 = o claude saiu do pane (caiu, ex.: falta de
# memória) e o pane voltou ao shell — ver "Se a sessão cair" no SKILL.md.
# Rode em segundo plano (run_in_background) para ser avisado quando terminar.
PANE="${1:?pane, ex.: %18}"; NEED="${2:-6}"; INT="${3:-10}"; n=0
while true; do
  out=$(tmux capture-pane -p -t "$PANE" 2>/dev/null) || { echo "PANE_GONE"; exit 2; }
  cmd=$(tmux display -p -t "$PANE" '#{pane_current_command}' 2>/dev/null)
  if [ "$cmd" != "claude" ]; then
    sleep 5; cmd=$(tmux display -p -t "$PANE" '#{pane_current_command}' 2>/dev/null)
    [ "$cmd" != "claude" ] && { echo "CLAUDE_EXITED ($cmd)"; tmux capture-pane -p -t "$PANE" -S -40 | tail -40; exit 3; }
  fi
  # Ocupada: turno rodando ("esc to interrupt"). Com tarefa própria em segundo
  # plano no rodapé ("· 1 shell"), ela pode acordar de novo — mas também pode ser
  # um processo esquecido, então só exige a tela parada por mais tempo (x5).
  need=$NEED; tail -3 <<<"$out" | grep -qE '[0-9]+ (shells?|monitors?)' && need=$((NEED*5))
  h=$(md5sum <<<"$out")
  if grep -q "esc to interrupt" <<<"$out" || [ "$h" != "${last:-}" ]; then n=0; else n=$((n+1)); fi
  last=$h
  NEEDNOW=$need
  if [ "$n" -ge "${NEEDNOW:-$NEED}" ]; then
    echo IDLE; tmux capture-pane -p -t "$PANE" -S -80 | tail -80; exit 0
  fi
  sleep "$INT"
done
