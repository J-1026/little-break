#!/usr/bin/env bash
# Little Break — 干活间隙玩一会
# Used by the Codex / Claude Code hook (UserPromptSubmit) and by the skill.
#
#   little-break.sh hook        read hook JSON on stdin, maybe ask "要不要玩一会？"
#   little-break.sh offer       ask now (respects snooze)
#   little-break.sh play        open the game now
#   little-break.sh snooze 30   don't ask for 30 minutes
#   little-break.sh today       don't ask again today
#   little-break.sh resume      ask again
#   little-break.sh status      print current state
#
# Env: LB_URL (game launcher), LB_GAP_MIN (min minutes between asks, default 5),
#      LB_DRY_RUN=1 (print instead of showing UI)

LB_URL="${LB_URL:-https://j-1026.github.io/little-break/}"
LB_GAP_MIN="${LB_GAP_MIN:-5}"
LB_HOME="${LB_HOME:-$HOME/.little-break}"
SNOOZE_FILE="$LB_HOME/snooze_until"
LAST_FILE="$LB_HOME/last_offer"

mkdir -p "$LB_HOME" 2>/dev/null

now() { date +%s; }
read_num() { [ -f "$1" ] && tr -cd '0-9' < "$1" || echo 0; }

# Keep a stable copy of this script at ~/.little-break/little-break.sh
self="${BASH_SOURCE[0]}"
if [ -f "$self" ] && [ "$(cd "$(dirname "$self")" && pwd)/$(basename "$self")" != "$LB_HOME/little-break.sh" ]; then
  cp "$self" "$LB_HOME/little-break.sh" 2>/dev/null && chmod +x "$LB_HOME/little-break.sh" 2>/dev/null
fi

is_snoozed() {
  local until; until=$(read_num "$SNOOZE_FILE"); [ -z "$until" ] && until=0
  [ "$(now)" -lt "$until" ]
}

open_game() {
  if [ "$LB_DRY_RUN" = "1" ]; then echo "[dry-run] open $LB_URL"; return; fi
  case "$(uname -s)" in
    Darwin) open "$LB_URL" ;;
    Linux) (xdg-open "$LB_URL" >/dev/null 2>&1 &) ;;
    *) echo "$LB_URL" ;;
  esac
}

snooze_minutes() {
  local m="${1:-30}"; case "$m" in ''|*[!0-9]*) m=30 ;; esac
  echo $(( $(now) + m * 60 )) > "$SNOOZE_FILE"
}

snooze_today() {
  local midnight
  if midnight=$(date -v+1d -v0H -v0M -v0S +%s 2>/dev/null); then :;     # macOS
  else midnight=$(date -d 'tomorrow 00:00' +%s 2>/dev/null || echo $(( $(now) + 86400 ))); fi
  echo "$midnight" > "$SNOOZE_FILE"
}

handle_choice() {
  case "$1" in
    *来一局*) open_game ;;
    *30*) snooze_minutes 30 ;;
    *今天*) snooze_today ;;
  esac
}

ask() {
  if [ "$LB_DRY_RUN" = "1" ]; then echo "[dry-run] ask"; return; fi
  case "$(uname -s)" in
    Darwin)
      local out
      out=$(osascript \
        -e 'display dialog "任务在跑，要不要玩一会？" & return & "打一把再回来看结果。" with title "Little Break" buttons {"今天别问", "30 分钟内别问", "来一局"} default button "来一局" giving up after 45' \
        2>/dev/null)
      handle_choice "$out"
      ;;
    Linux)
      if command -v zenity >/dev/null 2>&1; then
        local out
        out=$(zenity --question --title="Little Break" --text="任务在跑，要不要玩一会？" \
          --ok-label="来一局" --cancel-label="不用了" --extra-button="30 分钟内别问" --extra-button="今天别问" \
          --timeout=45 2>/dev/null; echo "rc=$?")
        case "$out" in *30*|*今天*) handle_choice "$out" ;; *rc=0*) open_game ;; esac
      fi
      ;;
  esac
}

offer() {
  is_snoozed && return 0
  local last; last=$(read_num "$LAST_FILE"); [ -z "$last" ] && last=0
  [ $(( $(now) - last )) -lt $(( LB_GAP_MIN * 60 )) ] && return 0
  now > "$LAST_FILE"
  if [ "$LB_DRY_RUN" = "1" ]; then ask; else ( ask >/dev/null 2>&1 & ) ; fi
}

prompt_is_task() {
  # Skip very short prompts (greetings, "ok", "继续"...). Needs python3; otherwise assume task.
  local input="$1"
  command -v python3 >/dev/null 2>&1 || return 0
  printf '%s' "$input" | python3 -c '
import json, sys
try:
    p = (json.load(sys.stdin).get("prompt") or "").strip()
except Exception:
    sys.exit(0)
sys.exit(0 if len(p) >= 8 else 1)
' 2>/dev/null
}

case "$1" in
  hook)
    input="$(cat 2>/dev/null)"
    prompt_is_task "$input" && offer
    exit 0 ;;
  offer)  offer ;;
  play)   open_game; echo "已打开 Little Break：$LB_URL" ;;
  snooze) snooze_minutes "$2"; echo "好，${2:-30} 分钟内不再问。" ;;
  today)  snooze_today; echo "好，今天不再问。" ;;
  resume) rm -f "$SNOOZE_FILE"; echo "好，又会问了。" ;;
  status)
    if is_snoozed; then echo "snoozed until $(read_num "$SNOOZE_FILE")"; else echo "active"; fi ;;
  *) echo "usage: little-break.sh hook|offer|play|snooze [min]|today|resume|status" ;;
esac
exit 0
