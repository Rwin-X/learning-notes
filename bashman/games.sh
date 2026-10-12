#!/usr/bin/env bash
# games — four small terminal games in pure bash
# Snake · Tic-Tac-Toe · Guess · Hangman
# Requires: bash >= 4.3 (bash 5 gives smoother Snake timing)
# Run:      ./games.sh

B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'; INV=$'\e[7m'
BEST_SNAKE=0
TT_W=0; TT_L=0; TT_D=0

# ── helpers ──────────────────────────────────────────────────────────
hide()         { printf '\e[?25l'; }
show()         { printf '\e[?25h'; }
clear_screen() { printf '\e[2J\e[H'; }
at()           { printf '\e[%d;%dH' "$1" "$2"; }
rep()          { local s='' i; for ((i = 0; i < $2; i++)); do s+=$1; done; printf '%s' "$s"; }
title()        { printf '\n  %s%s%s  %s%s%s\n\n' "$B" "$1" "$R" "$D" "$2" "$R"; }

# getkey [timeout]  →  KEY = up|down|left|right|esc|<char>|'' (enter)
getkey() {
  local k r
  KEY=''
  if [[ -n ${1:-} ]]; then
    IFS= read -rsn1 -t "$1" k || return 1
  else
    IFS= read -rsn1 k || return 1
  fi
  if [[ $k == $'\e' ]]; then
    r=''
    IFS= read -rsn2 -t 0.01 r || true
    case $r in
      '[A') k=up ;;  '[B') k=down ;;
      '[C') k=right ;; '[D') k=left ;;
      *)   k=esc ;;
    esac
  fi
  KEY=$k
}

# again → 0 = play again, 1 = back to menu
again() {
  printf '\n  %s[r] again   [q] menu%s\n' "$D" "$R"
  while getkey; do
    case $KEY in r) return 0 ;; q | esc) return 1 ;; esac
  done
  return 1
}

# ── 1 · snake ────────────────────────────────────────────────────────
snake_cell()  { at $((5 + $2)) $((4 + $1 * 2)); printf '%s' "$3"; }
snake_score() { at $((6 + H)) 3; printf 'score %s%d%s   best %s%d%s   ' "$B" "$score" "$R" "$B" "$BEST_SNAKE" "$R"; }
snake_food() {
  local ok j
  while :; do
    fx=$((RANDOM % W)); fy=$((RANDOM % H)); ok=1
    for ((j = 0; j < ${#sx[@]}; j++)); do
      if ((sx[j] == fx && sy[j] == fy)); then ok=0; break; fi
    done
    ((ok)) && break
  done
  snake_cell "$fx" "$fy" "${B}◆ ${R}"
}
snake_key() {
  case $KEY in
    up | w)    [[ $dir != down ]]  && nd=up ;;
    down | s)  [[ $dir != up ]]    && nd=down ;;
    left | a)  [[ $dir != right ]] && nd=left ;;
    right | d) [[ $dir != left ]]  && nd=right ;;
    q)         quit=1 ;;
  esac
}

snake_round() {
  local W=24 H=14 score=0 dead=0 quit=0 dir=right nd=right
  local -a sx=(12 11 10) sy=(7 7 7)
  local fx=0 fy=0 i hx hy eat limit delay end rem last j

  if (($(tput cols) < 54 || $(tput lines) < 24)); then
    clear_screen
    printf '\n  %sterminal too small%s  (need 54x24)\n' "$B" "$R"
    getkey; return 1
  fi

  clear_screen; hide
  title SNAKE "arrows or wasd · q to quit"
  at 4 3;            printf '%s┌%s┐%s' "$D" "$(rep ── "$W")" "$R"
  for ((i = 0; i < H; i++)); do
    at $((5 + i)) 3; printf '%s│%s│%s' "$D" "$(rep '  ' "$W")" "$R"
  done
  at $((5 + H)) 3;   printf '%s└%s┘%s' "$D" "$(rep ── "$W")" "$R"
  for ((i = 0; i < ${#sx[@]}; i++)); do
    if ((i == 0)); then snake_cell "${sx[i]}" "${sy[i]}" "${B}██${R}"
    else snake_cell "${sx[i]}" "${sy[i]}" "▓▓"; fi
  done
  snake_food; snake_score

  while ((!dead && !quit)); do
    delay=$((130 - score * 3)); ((delay < 55)) && delay=55
    if [[ -n ${EPOCHREALTIME:-} ]]; then
      end=$((${EPOCHREALTIME/[.,]/} / 1000 + delay))
      while :; do
        rem=$((end - ${EPOCHREALTIME/[.,]/} / 1000))
        ((rem <= 0)) && break
        getkey "0.$(printf '%03d' "$rem")" && snake_key
        ((quit)) && break
      done
    else
      getkey "0.$(printf '%03d' "$delay")" && snake_key
    fi
    ((quit)) && break

    dir=$nd; hx=${sx[0]}; hy=${sy[0]}
    case $dir in up) ((hy--)) ;; down) ((hy++)) ;; left) ((hx--)) ;; right) ((hx++)) ;; esac
    if ((hx < 0 || hx >= W || hy < 0 || hy >= H)); then dead=1; break; fi

    eat=0; ((hx == fx && hy == fy)) && eat=1
    limit=$((${#sx[@]} - (1 - eat)))          # the tail moves away unless we eat
    for ((j = 0; j < limit; j++)); do
      if ((sx[j] == hx && sy[j] == hy)); then dead=1; break; fi
    done
    ((dead)) && break

    if ((!eat)); then                         # erase tail first, then draw head
      last=$((${#sx[@]} - 1))
      snake_cell "${sx[last]}" "${sy[last]}" "  "
      sx=("${sx[@]:0:last}"); sy=("${sy[@]:0:last}")
    fi
    snake_cell "${sx[0]}" "${sy[0]}" "▓▓"
    sx=("$hx" "${sx[@]}"); sy=("$hy" "${sy[@]}")
    snake_cell "$hx" "$hy" "${B}██${R}"
    if ((eat)); then
      ((score++)); ((score > BEST_SNAKE)) && BEST_SNAKE=$score
      snake_food; snake_score
    fi
  done

  ((quit)) && return 1
  at $((7 + H)) 3; printf '%sgame over%s  ·  %d eaten' "$B" "$R" "$score"
  return 0
}

# ── 2 · tic-tac-toe (you X, computer O) ──────────────────────────────
WINS=("0 1 2" "3 4 5" "6 7 8" "0 3 6" "1 4 7" "2 5 8" "0 4 8" "2 4 6")

ttt_check() {                                  # sets RES (X|O|draw|'') and HL
  local l a b c i
  RES=''; HL=''
  for l in "${WINS[@]}"; do
    read -r a b c <<<"$l"
    if [[ ${bd[a]} != ' ' && ${bd[a]} == "${bd[b]}" && ${bd[a]} == "${bd[c]}" ]]; then
      RES=${bd[a]}; HL=" $l "; return
    fi
  done
  for i in 0 1 2 3 4 5 6 7 8; do [[ ${bd[i]} == ' ' ]] && return; done
  RES=draw
}

ttt_ai() {
  local p l a b c i cnt empty m r k
  local -a corners=(0 2 6 8)
  for p in O X; do                             # win first, then block
    for l in "${WINS[@]}"; do
      read -r a b c <<<"$l"
      cnt=0; empty=-1
      for i in $a $b $c; do
        [[ ${bd[i]} == "$p" ]] && ((cnt++))
        [[ ${bd[i]} == ' ' ]] && empty=$i
      done
      if ((cnt == 2 && empty >= 0)); then bd[empty]=O; return; fi
    done
  done
  [[ ${bd[4]} == ' ' ]] && { bd[4]=O; return; }
  r=$((RANDOM % 4))
  for ((k = 0; k < 4; k++)); do
    m=${corners[(r + k) % 4]}
    [[ ${bd[m]} == ' ' ]] && { bd[m]=O; return; }
  done
  for m in 1 3 5 7; do [[ ${bd[m]} == ' ' ]] && { bd[m]=O; return; }; done
}

ttt_cell() {
  local i=$1 v=${bd[$1]}
  if [[ $v == ' ' ]]; then printf '%s%d%s' "$D" $((i + 1)) "$R"
  elif [[ $HL == *" $i "* ]]; then printf '%s%s%s' "$INV$B" "$v" "$R"
  elif [[ $v == X ]]; then printf '%s%s%s' "$B" "$v" "$R"
  else printf '%s' "$v"; fi
}

ttt_draw() {
  clear_screen
  title "TIC-TAC-TOE" "you X · computer O · q quits"
  printf '   %s │ %s │ %s\n'   "$(ttt_cell 0)" "$(ttt_cell 1)" "$(ttt_cell 2)"
  printf '%s  ───┼───┼───%s\n' "$D" "$R"
  printf '   %s │ %s │ %s\n'   "$(ttt_cell 3)" "$(ttt_cell 4)" "$(ttt_cell 5)"
  printf '%s  ───┼───┼───%s\n' "$D" "$R"
  printf '   %s │ %s │ %s\n'   "$(ttt_cell 6)" "$(ttt_cell 7)" "$(ttt_cell 8)"
  printf '\n  %swin %d · draw %d · loss %d%s\n' "$D" "$TT_W" "$TT_D" "$TT_L" "$R"
}

ttt_round() {
  local -a bd=(' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ')
  local RES='' HL='' i
  hide
  while :; do
    ttt_draw
    [[ -n $RES ]] && break
    printf '\n  %syour move (1-9)%s\n' "$D" "$R"
    getkey || return 1
    case $KEY in q | esc) return 1 ;; esac
    [[ $KEY =~ ^[1-9]$ ]] || continue
    i=$((KEY - 1))
    [[ ${bd[i]} == ' ' ]] || continue
    bd[i]=X; ttt_check
    if [[ -z $RES ]]; then ttt_ai; ttt_check; fi
  done
  case $RES in
    X)    ((TT_W++)); printf '\n  %syou win%s\n' "$B" "$R" ;;
    O)    ((TT_L++)); printf '\n  %scomputer wins%s\n' "$B" "$R" ;;
    draw) ((TT_D++)); printf '\n  %sdraw%s\n' "$B" "$R" ;;
  esac
  return 0
}

# ── 3 · guess ────────────────────────────────────────────────────────
guess_round() {
  local n=$((RANDOM % 100 + 1)) lo=1 hi=100 tries=0 max=7 g msg='' bar c s e
  while ((tries < max)); do
    s=$(((lo - 1) / 2)); e=$(((hi - 1) / 2)); bar=''
    for ((c = 0; c < 50; c++)); do
      if ((c >= s && c <= e)); then bar+="${B}█${R}"; else bar+="${D}·${R}"; fi
    done
    clear_screen
    title GUESS "a number from 1 to 100 · q quits"
    printf '  %s\n\n  range  %s%d – %d%s\n  tries  %s\n\n' "$bar" "$B" "$lo" "$hi" "$R" \
      "$(rep '● ' $((max - tries)))$D$(rep '○ ' "$tries")$R"
    [[ -n $msg ]] && printf '  %s\n\n' "$msg"
    show; stty echo
    IFS= read -r -p $'  \e[2m›\e[0m ' g || { stty -echo; return 1; }
    stty -echo; hide
    [[ $g == q ]] && return 1
    if [[ ! $g =~ ^[0-9]{1,3}$ ]] || ((10#$g < 1 || 10#$g > 100)); then
      msg="${D}enter a number from 1 to 100${R}"; continue
    fi
    g=$((10#$g)); ((tries++))
    if ((g == n)); then
      printf '\n  %sgot it%s — %d in %d tries\n' "$B" "$R" "$n" "$tries"
      return 0
    elif ((g < n)); then lo=$((g + 1 > lo ? g + 1 : lo)); msg="${B}$g${R} is too low"
    else                 hi=$((g - 1 < hi ? g - 1 : hi)); msg="${B}$g${R} is too high"
    fi
  done
  printf '\n  %sout of tries%s — it was %s%d%s\n' "$B" "$R" "$B" "$n" "$R"
  return 0
}

# ── 4 · hangman ──────────────────────────────────────────────────────
HANG_WORDS=(terminal kernel cipher binary network system shadow cosmos entropy quantum
  matrix vector signal static pattern library compile thread socket buffer filter
  mirror silent random packet proxy daemon module syntax object)

hang_draw() {
  local n=$1 h=' ' la=' ' b=' ' ra=' ' ll=' ' rl=' '
  ((n >= 1)) && h=O;   ((n >= 2)) && b='│'
  ((n >= 3)) && la='/'; ((n >= 4)) && ra='\'
  ((n >= 5)) && ll='/'; ((n >= 6)) && rl='\'
  printf '  ┌──┐\n  │  %s\n  │ %s%s%s\n  │ %s %s\n──┴──\n' "$h" "$la" "$b" "$ra" "$ll" "$rl"
}

hangman_round() {
  local word=${HANG_WORDS[RANDOM % ${#HANG_WORDS[@]}]} used='' wrong=0 max=6
  local shown won i ch missed
  while :; do
    shown=''; won=1; missed=''
    for ((i = 0; i < ${#word}; i++)); do
      ch=${word:i:1}
      if [[ $used == *"$ch"* ]]; then shown+="$B$ch$R "; else shown+="${D}_${R} "; won=0; fi
    done
    for ((i = 0; i < ${#used}; i++)); do
      ch=${used:i:1}; [[ $word == *"$ch"* ]] || missed+="$ch "
    done
    clear_screen
    title HANGMAN "type a letter · esc quits"
    hang_draw "$wrong"
    printf '\n  %s\n\n  %smissed%s  %s\n  %slives%s   %s%s%s%s\n' "$shown" "$D" "$R" "$missed" \
      "$D" "$R" "$(rep '● ' $((max - wrong)))" "$D" "$(rep '○ ' "$wrong")" "$R"
    if ((won)); then printf '\n  %ssolved%s\n' "$B" "$R"; return 0; fi
    if ((wrong >= max)); then
      printf '\n  %sout of tries%s — the word was %s%s%s\n' "$B" "$R" "$B" "$word" "$R"; return 0
    fi
    getkey || return 1
    [[ $KEY == esc ]] && return 1
    KEY=${KEY,,}
    [[ $KEY =~ ^[a-z]$ ]] || continue
    [[ $used == *"$KEY"* ]] && continue
    used+=$KEY
    [[ $word == *"$KEY"* ]] || ((wrong++))
  done
}

# ── menu ─────────────────────────────────────────────────────────────
menu() {
  while :; do
    clear_screen; hide
    printf '\n  %sGAMES%s  %sfour small ones · pure bash%s\n\n' "$B" "$R" "$D" "$R"
    printf '  %s1%s  Snake\n  %s2%s  Tic-Tac-Toe\n  %s3%s  Guess\n  %s4%s  Hangman\n\n  %sq%s  quit\n' \
      "$B" "$R" "$B" "$R" "$B" "$R" "$B" "$R" "$B" "$R"
    getkey || break
    case $KEY in
      1) while snake_round   && again; do :; done ;;
      2) while ttt_round     && again; do :; done ;;
      3) while guess_round   && again; do :; done ;;
      4) while hangman_round && again; do :; done ;;
      q | esc) break ;;
    esac
  done
  clear_screen
}

main() {
  if [[ ! -t 0 || ! -t 1 ]]; then echo "games: needs an interactive terminal" >&2; exit 1; fi
  stty -echo                                   # no stray echo between key reads
  trap 'stty echo; printf "\e[?25h\e[0m"' EXIT
  trap 'exit 130' INT TERM
  menu
}

# run only when executed, not when sourced (handy for testing)
[[ ${BASH_SOURCE[0]} == "$0" ]] && main
