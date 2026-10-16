#!/usr/bin/env bash
# focus — minimal focus timer with big digits and a session log
# Requires: bash >= 4.3 (bash 5 gives sub-second timing)
#
# Usage:  ./focus.sh [duration] [label...]     e.g.  ./focus.sh 50 deep work
#         ./focus.sh stats                      today, last 7 days, streak
# Duration: 25 (minutes, default) · 5m · 90s
# Keys:     space pause/resume · q abort
# Log:      ~/.local/share/focus/sessions.tsv   (completed sessions only)

B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'
[[ -t 1 ]] || { B=''; D=''; R=''; }            # plain output when piped
LOG=${FOCUS_LOG:-${XDG_DATA_HOME:-$HOME/.local/share}/focus/sessions.tsv}
declare -A GR=() DAY_S=() DAY_N=()
NOW=0; SECS=1500; label=''; t_s=0; t_n=0

# ── helpers ──────────────────────────────────────────────────────────
rep() { local s; printf -v s '%*s' "$2" ''; printf '%s' "${s// /$1}"; }

fmt_dur() {
  local s=$1
  if   ((s >= 3600)); then printf '%dh %02dm' $((s / 3600)) $((s % 3600 / 60))
  elif ((s >= 60));   then printf '%dm' $((s / 60))
  else                     printf '%ds' "$s"; fi
}

tick_ms() {
  if [[ -n ${EPOCHREALTIME:-} ]]; then
    local t=${EPOCHREALTIME/[.,]/}; NOW=$((t / 1000))
  else
    NOW=$((SECONDS * 1000))
  fi
}

parse_dur() {                                  # sets SECS, returns 1 if not a duration
  [[ $1 =~ ^([0-9]+)([sm]?)$ ]] || return 1
  local n=$((10#${BASH_REMATCH[1]})) u=${BASH_REMATCH[2]}
  ((n > 0)) || return 1
  if [[ $u == s ]]; then n=$n; else n=$((n * 60)); fi
  ((n <= 86400)) || return 1
  SECS=$n
}

load_log() {
  DAY_S=(); DAY_N=()
  [[ -r $LOG ]] || return 0
  local d t s l
  while IFS=$'\t' read -r d t s l; do
    [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && $s =~ ^[0-9]+$ ]] || continue
    DAY_S[$d]=$((${DAY_S[$d]:-0} + 10#$s)); DAY_N[$d]=$((${DAY_N[$d]:-0} + 1))
  done <"$LOG"
}

log_session() {
  local d t; printf -v d '%(%F)T' -1; printf -v t '%(%H:%M)T' -1
  mkdir -p "${LOG%/*}" 2>/dev/null
  printf '%s\t%s\t%d\t%s\n' "$d" "$t" "$SECS" "${label//[$'\t\n\r']/ }" >>"$LOG"
}

# ── big digits (5 rows, every cell doubled for a squarer look) ───────
init_font() {
  local -A F=(
    [0]='███|█ █|█ █|█ █|███'
    [1]=' █ |██ | █ | █ |███'
    [2]='███|  █|███|█  |███'
    [3]='███|  █|███|  █|███'
    [4]='█ █|█ █|███|  █|  █'
    [5]='███|█  |███|  █|███'
    [6]='███|█  |███|█ █|███'
    [7]='███|  █|  █|  █|  █'
    [8]='███|█ █|███|█ █|███'
    [9]='███|█ █|███|  █|███'
    [:]=' |█| |█| '
  )
  local k r row; local -a rows
  for k in "${!F[@]}"; do
    IFS='|' read -ra rows <<<"${F[$k]}"
    for r in 0 1 2 3 4; do
      row=${rows[r]}; row=${row//█/██}; row=${row// /  }
      GR["$k,$r"]=$row
    done
  done
}

big() {
  local text=$1 r i out
  for r in 0 1 2 3 4; do
    out=''
    for ((i = 0; i < ${#text}; i++)); do out+="${GR[${text:i:1},$r]}  "; done
    printf '    %s\e[K\n' "$out"
  done
}

# ── stats ────────────────────────────────────────────────────────────
show_stats() {
  load_log
  local now today i d dn s n mx=1 f streak=0 total=0
  printf -v now '%(%s)T' -1; printf -v today '%(%F)T' -1
  for ((i = 6; i >= 0; i--)); do
    printf -v d '%(%F)T' $((now - i * 86400))
    s=${DAY_S[$d]:-0}; total=$((total + s)); ((s > mx)) && mx=$s
  done
  s=${DAY_S[$today]:-0}; n=${DAY_N[$today]:-0}
  printf '\n  %sFOCUS%s  %sstats%s\n\n' "$B" "$R" "$D" "$R"
  if ((n == 0)); then printf '  %stoday%s   %sno sessions yet%s\n' "$D" "$R" "$D" "$R"
  else printf '  %stoday%s   %s%s%s · %d session%s\n' "$D" "$R" "$B" "$(fmt_dur "$s")" "$R" "$n" "$( ((n > 1)) && echo s)"; fi
  i=0; [[ -n ${DAY_S[$today]:-} ]] || i=1
  while ((i < 3650)); do
    printf -v d '%(%F)T' $((now - i * 86400))
    [[ -n ${DAY_S[$d]:-} ]] || break
    ((streak++)); ((i++))
  done
  printf '  %sstreak%s  %d day%s\n' "$D" "$R" "$streak" "$( ((streak != 1)) && echo s)"
  printf '  %sweek%s    %s\n\n' "$D" "$R" "$(fmt_dur "$total")"
  for ((i = 6; i >= 0; i--)); do
    printf -v d '%(%F)T' $((now - i * 86400)); printf -v dn '%(%a)T' $((now - i * 86400))
    s=${DAY_S[$d]:-0}; f=$((s * 24 / mx))
    printf '  %s%s%s  %s%s%s%s%s  %s\n' "$D" "$dn" "$R" "$B" "$(rep █ "$f")" "$R" "$D" "$(rep ░ $((24 - f)))$R" \
      "$( ((s)) && fmt_dur "$s" || echo "${D}—${R}")"
  done
  echo
}

# ── timer ────────────────────────────────────────────────────────────
restore() { stty echo 2>/dev/null; printf '\e[?25h\e[?1049l'; }

frame() {                                      # uses run_timer's locals (dynamic scope)
  local rem=$(((total_ms - el + 999) / 1000)) txt pct f w=34 hint today_txt
  ((rem < 0)) && rem=0
  printf -v txt '%02d:%02d' $((rem / 60)) $((rem % 60))
  pct=$((100 * el / total_ms)); ((pct > 100)) && pct=100
  f=$((w * pct / 100))
  if   ((fin));    then hint="${B}complete${R}  ${D}press any key${R}"
  elif ((paused)); then hint="${B}paused${R}  ${D}space resume · q abort${R}"
  else                  hint="${D}space pause · q abort${R}"; fi
  if ((t_s == 0)); then today_txt="first session today"
  else today_txt="today $(fmt_dur "$t_s") · session $((t_n + 1))"; fi
  printf '\e[K\n  %sFOCUS%s  %s%s%s\e[K\n\e[K\n' "$B" "$R" "$D" "${label:-untitled}" "$R"
  ((paused)) && printf '%s' "$D"
  big "$txt"
  printf '%s\e[K\n' "$R"
  printf '    %s%s%s%s%s%s  %3d%%\e[K\n\e[K\n' "$B" "$(rep ━ "$f")" "$R" "$D" "$(rep ─ $((w - f)))" "$R" "$pct"
  printf '    %s\e[K\n' "$hint"
  printf '    %s%s%s\e[K\n' "$D" "$today_txt" "$R"
}

run_timer() {
  [[ -t 0 && -t 1 ]] || { echo "focus: needs an interactive terminal (try: focus.sh stats)" >&2; exit 1; }
  local cols; cols=$(tput cols 2>/dev/null) || cols=80
  ((cols >= 44)) || { echo "focus: terminal too narrow (need 44 columns)" >&2; exit 1; }
  init_font; load_log
  local today; printf -v today '%(%F)T' -1
  t_s=${DAY_S[$today]:-0}; t_n=${DAY_N[$today]:-0}

  local total_ms=$((SECS * 1000)) el=0 paused=0 fin=0 k rc last
  printf '\e[?1049h\e[?25l'; stty -echo
  trap restore EXIT; trap 'exit 130' INT TERM
  tick_ms; last=$NOW
  while :; do
    tick_ms; ((paused)) || el=$((el + NOW - last)); last=$NOW
    ((el > total_ms)) && el=$total_ms
    printf '\e[H%s\e[J' "$(frame)"
    ((el >= total_ms)) && break
    IFS= read -rsn1 -t 0.2 k; rc=$?
    if ((rc == 0)); then
      case $k in
        q | Q)
          local left=$(((total_ms - el + 999) / 1000))
          restore
          printf '\n  %sfocus%s  aborted with %s left — not logged\n\n' "$B" "$R" "$(fmt_dur "$left")"
          exit 0 ;;
        ' ')   paused=$((1 - paused)) ;;
        $'\e') IFS= read -rsn2 -t 0.01 _ ;;
      esac
    elif ((rc <= 128)); then                   # stdin closed
      restore; exit 1
    fi
  done

  fin=1; log_session
  printf '\e[H%s\e[J' "$(frame)"; printf '\a'
  while :; do                                  # wait for a key, ring again every 15 s
    IFS= read -rsn1 -t 15 _; rc=$?
    ((rc <= 128)) && break
    printf '\a'
  done
  restore
  printf '\n  %s✓%s %s logged · today %s · %d session%s\n\n' "$B" "$R" "$(fmt_dur "$SECS")" \
    "$(fmt_dur $((t_s + SECS)))" $((t_n + 1)) "$( ((t_n + 1 > 1)) && echo s)"
}

# ── entry ────────────────────────────────────────────────────────────
case ${1:-} in
  stats)       show_stats; exit 0 ;;
  -h | --help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
esac
if [[ -n ${1:-} ]] && parse_dur "$1"; then shift; fi
label=$*
run_timer
