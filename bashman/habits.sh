#!/usr/bin/env bash
# habits — terminal habit tracker with streaks and a 12-week heatmap
# Requires: bash >= 4.3
#
# Run:   ./habits.sh
# Keys:  ↑/↓ or j/k select · space toggle · ←/→ change day · a add · x delete · q quit
# Data:  ~/.local/share/habits/   (plain text: list, log.tsv)

B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'; INV=$'\e[7m'; EL=$'\e[K\n'
DIR=${HABITS_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/habits}
MAXH=8; NDAYS=92
HABITS=(); declare -A DONE=(); declare -a DS=() CNT=()
DAYN=(Mon Tue Wed Thu Fri Sat Sun)
sel=0; off=0; NOW=0; msg=''; STK=0; KEY=''; LINE=''

# ── storage ──────────────────────────────────────────────────────────
clean() {                                      # strip characters that would break keys/files
  local s=$1 c
  for c in '[' ']' '$' '\' '"' "'" '`' $'\t' $'\r' $'\n'; do s=${s//"$c"/}; done
  s=${s#"${s%%[![:space:]]*}"}; s=${s%"${s##*[![:space:]]}"}
  printf '%s' "${s:0:24}"
}

load() {
  HABITS=(); DONE=()
  local h d
  if [[ -r $DIR/list ]]; then
    while IFS= read -r h; do [[ -n $h ]] && HABITS+=("$h"); done <"$DIR/list"
  fi
  if [[ -r $DIR/log.tsv ]]; then
    while IFS=$'\t' read -r d h; do
      [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && -n $h ]] && DONE["$d$h"]=1
    done <"$DIR/log.tsv"
  fi
}

save() {
  mkdir -p "$DIR" || return
  if ((${#HABITS[@]})); then printf '%s\n' "${HABITS[@]}" >"$DIR/list"; else : >"$DIR/list"; fi
  local k; for k in "${!DONE[@]}"; do printf '%s\t%s\n' "${k:0:10}" "${k:10}"; done | sort >"$DIR/log.tsv"
}

# ── model ────────────────────────────────────────────────────────────
refresh() {                                    # DS[i] = date i days ago, CNT[i] = habits done that day
  local hh mm ss i x cnt
  printf -v hh '%(%H)T' -1; printf -v mm '%(%M)T' -1; printf -v ss '%(%S)T' -1
  printf -v NOW '%(%s)T' -1
  NOW=$((NOW - (10#$hh * 3600 + 10#$mm * 60 + 10#$ss) + 43200))   # anchor at noon: safe across DST
  for ((i = 0; i < NDAYS; i++)); do
    printf -v "DS[$i]" '%(%F)T' $((NOW - i * 86400))
    cnt=0
    for x in "${HABITS[@]}"; do [[ -n ${DONE[${DS[i]}$x]:-} ]] && ((cnt++)); done
    CNT[i]=$cnt
  done
}

streak() {                                     # sets STK
  local x=$1 i=0; STK=0
  [[ -n ${DONE[${DS[0]}$x]:-} ]] || i=1        # today still open: streak counts from yesterday
  for ((; i < NDAYS; i++)); do
    [[ -n ${DONE[${DS[i]}$x]:-} ]] || break
    ((STK++))
  done
}

# ── render ───────────────────────────────────────────────────────────
render() {
  local n=${#HABITS[@]} cols nd i j x g box mark nm grid line c r ago pct rate=0 dsum=0 start wd o d pl=''
  read -r _ cols < <(stty size 2>/dev/null); [[ $cols =~ ^[0-9]+$ ]] || cols=80
  refresh
  nd=$((cols - 38)); ((nd > 28)) && nd=28; ((nd < 7)) && nd=7

  printf -v d '%(%a %d %b)T' $((NOW - off * 86400))
  ((off > 1)) && pl=s
  o="${EL}  ${B}HABITS${R}   ${B}${d}${R}"
  if ((off == 0)); then o+="  ${D}today${R}"; else o+="  ${D}${off} day${pl} ago${R}"; fi
  o+="${EL}${EL}"

  if ((n == 0)); then
    o+="  ${D}no habits yet · press ${R}${B}a${R}${D} to add one${R}${EL}"
  else
    printf -v line '%-14s  %-*s  %s' habit "$nd" "last $nd days" streak
    o+="       ${D}${line}${R}${EL}"
    for ((i = 0; i < n; i++)); do
      x=${HABITS[i]}; streak "$x"
      if [[ -n ${DONE[${DS[off]}$x]:-} ]]; then box='◉'; else box='○'; fi
      grid=''
      for ((j = nd - 1; j >= 0; j--)); do
        if [[ -n ${DONE[${DS[j]}$x]:-} ]]; then g="${B}■${R}"; else g="${D}·${R}"; fi
        ((j == off)) && g="${INV}${g}${R}"
        grid+=$g
      done
      printf -v nm '%-14s' "${x:0:14}"
      if ((i == sel)); then mark='›'; nm="${B}${nm}${R}"; else mark=' '; fi
      o+="  ${mark} ${box} ${nm}  ${grid}  $(printf '%3d' "$STK")d${EL}"
    done
  fi

  o+="${EL}  ${D}last 12 weeks${R}${EL}"
  printf -v wd '%(%u)T' "$NOW"
  start=$((11 * 7 + wd - 1))
  for ((r = 0; r < 7; r++)); do
    line="  ${D}${DAYN[r]}${R}  "
    for ((c = 0; c < 12; c++)); do
      ago=$((start - c * 7 - r))
      if ((ago < 0)); then line+='   '; continue; fi
      if ((n == 0)); then pct=0; else pct=$((100 * CNT[ago] / n)); fi
      if   ((pct == 0));  then g="${D}··${R}"
      elif ((pct <= 33)); then g='░░'
      elif ((pct <= 66)); then g='▒▒'
      elif ((pct < 100)); then g='▓▓'
      else                     g="${B}██${R}"; fi
      line+="$g "
    done
    o+="${line}${EL}"
  done

  if ((n)); then
    for ((i = 0; i < 30; i++)); do dsum=$((dsum + CNT[i])); done
    rate=$((100 * dsum / (n * 30)))
  fi
  o+="${EL}  ${D}30-day completion${R}  ${B}${rate}%${R}"
  [[ -n $msg ]] && o+="  ${D}· ${msg}${R}"
  o+="${EL}${EL}  ${D}↑↓ select · space toggle · ←→ day · a add · x delete · q quit${R}${EL}"
  printf '\e[H%s\e[J' "$o"
}

# ── input ────────────────────────────────────────────────────────────
readkey() {                                    # KEY = up|down|left|right|esc|<char>|'' (enter); rc>128 on timeout
  local k r rc
  KEY=''
  IFS= read -rsn1 -t "${1:-30}" k; rc=$?
  ((rc == 0)) || return $rc
  if [[ $k == $'\e' ]]; then
    r=''; IFS= read -rsn2 -t 0.01 r
    case $r in
      '[A') k=up ;; '[B') k=down ;; '[C') k=right ;; '[D') k=left ;; *) k=esc ;;
    esac
  fi
  KEY=$k
}

prompt_line() {                                # prompt_line <label> → LINE
  stty echo; printf '\e[?25h'
  IFS= read -r -p "  $1 › " LINE; local rc=$?
  stty -echo; printf '\e[?25l'
  return $rc
}

toggle() {
  local x key
  ((${#HABITS[@]})) || { msg='add a habit first'; return; }
  x=${HABITS[sel]}; key=${DS[off]}$x
  if [[ -n ${DONE[$key]:-} ]]; then unset "DONE[$key]"; else DONE[$key]=1; fi
  save
}

add_habit() {
  local name x
  ((${#HABITS[@]} < MAXH)) || { msg="max $MAXH habits"; return; }
  prompt_line 'new habit' || return
  name=$(clean "$LINE")
  [[ -n $name ]] || return
  for x in "${HABITS[@]}"; do [[ $x == "$name" ]] && { msg='already exists'; return; }; done
  HABITS+=("$name"); sel=$((${#HABITS[@]} - 1)); save
}

del_habit() {
  local x k c
  ((${#HABITS[@]})) || return
  x=${HABITS[sel]}
  stty echo; printf '  delete "%s" and its history? [y/N] ' "$x"
  IFS= read -rsn1 c; stty -echo
  [[ $c == y || $c == Y ]] || return
  HABITS=("${HABITS[@]:0:sel}" "${HABITS[@]:sel+1}")
  for k in "${!DONE[@]}"; do [[ ${k:10} == "$x" ]] && unset "DONE[$k]"; done
  ((sel >= ${#HABITS[@]})) && sel=$((${#HABITS[@]} - 1)); ((sel < 0)) && sel=0
  save
}

# ── main ─────────────────────────────────────────────────────────────
main() {
  [[ -t 0 && -t 1 ]] || { echo "habits: needs an interactive terminal" >&2; exit 1; }
  load
  printf '\e[?1049h\e[?25l'; stty -echo
  trap 'stty echo; printf "\e[?25h\e[?1049l"' EXIT
  trap 'exit 130' INT TERM
  trap ':' WINCH                               # a resize interrupts read → redraw
  local rc
  while :; do
    render; msg=''
    readkey 30; rc=$?
    if ((rc > 0 && rc <= 128)); then break; fi # EOF
    ((rc > 128)) && continue                   # timeout or resize: just redraw
    case $KEY in
      q | Q)       break ;;
      up | k)      ((sel > 0)) && ((sel--)) ;;
      down | j)    ((sel < ${#HABITS[@]} - 1)) && ((sel++)) ;;
      left | h)    ((off < 6)) && ((off++)) ;;
      right | l)   ((off > 0)) && ((off--)) ;;
      ' ' | '')    toggle ;;
      a | A)       add_habit ;;
      x | X)       del_habit ;;
    esac
  done
}

main
