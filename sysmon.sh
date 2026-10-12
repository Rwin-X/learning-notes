#!/usr/bin/env bash
# sysmon — live system dashboard in pure bash (reads /proc, no dependencies)
# Linux only. Requires bash >= 4.3. Uses ps and df if present.
#
# Usage:  ./sysmon.sh           live view
#         ./sysmon.sh --once    print one frame and exit
# Keys:   q quit · space pause · + / - refresh rate

[[ -r /proc/stat ]] || { echo "sysmon: needs Linux (/proc)" >&2; exit 1; }

B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'; RED=$'\e[31m'
E=$'\e[K\n'                       # end-of-line: clear rest, newline
HW=40                             # sparkline width (samples)
IV=(0.25 0.5 1 2 5); ivi=2        # refresh intervals (seconds)
GLYPH=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

declare -a prev_t prev_i usage cpuH memH rxH txH
NCPU=0 tickn=0 rxr=0 txr=0 prx='' ptx='' last_ms=0
mt=1 ma=0 mu=0 mp=0 swt=0 swf=0 su=0 DISK='0 0 0%' TOP='' UP='' LOAD=''

read -r HOST </proc/sys/kernel/hostname
read -r KERN </proc/sys/kernel/osrelease

# ── helpers ──────────────────────────────────────────────────────────
rep() { local s; printf -v s '%*s' "$2" ''; printf '%s' "${s// /$1}"; }

push() { local -n _a=$1; _a+=("$2"); ((${#_a[@]} > HW)) && _a=("${_a[@]: -HW}"); }

hk() {                            # kB → human
  local v=$1
  if   ((v >= 1048576)); then printf '%d.%dG' $((v / 1048576)) $((v % 1048576 * 10 / 1048576))
  elif ((v >= 1024));    then printf '%dM' $((v / 1024))
  else                        printf '%dK' "$v"; fi
}

hr() {                            # bytes/s → human
  local v=$1
  if   ((v >= 1048576)); then printf '%d.%d MB/s' $((v / 1048576)) $((v % 1048576 * 10 / 1048576))
  elif ((v >= 1024));    then printf '%d.%d KB/s' $((v / 1024)) $((v % 1024 * 10 / 1024))
  else                        printf '%d B/s' "$v"; fi
}

bar() {                           # bar <pct> <width>
  local p=$1 w=$2 f col=''
  ((p > 100)) && p=100; ((p < 0)) && p=0
  f=$((p * w / 100)); ((p >= 90)) && col=$RED
  printf '%s%s%s%s%s%s' "$col$B" "$(rep █ "$f")" "$R" "$D" "$(rep ░ $((w - f)))" "$R"
}

sp() {                            # sp <array-name> [max] → right-aligned sparkline
  local -n _s=$1; local max=${2:-} v i out='' n=${#_s[@]}
  if [[ -z $max ]]; then
    max=1024; for v in "${_s[@]}"; do ((v > max)) && max=$v; done
  fi
  for v in "${_s[@]}"; do
    i=$((v * 8 / (max + 1))); ((i > 7)) && i=7; ((i < 0)) && i=0
    out+=${GLYPH[i]}
  done
  printf '%s%s%s%s' "$(rep ' ' $((HW - n)))" "$D" "$out" "$R"
}

# ── samplers ─────────────────────────────────────────────────────────
sample_cpu() {
  local name u n s i w q sq st rest idx t idle dt di
  while read -r name u n s i w q sq st rest; do
    [[ $name == cpu* ]] || break
    if [[ $name == cpu ]]; then idx=0; else idx=$((${name#cpu} + 1)); fi
    t=$((u + n + s + i + w + q + sq + st)); idle=$((i + w))
    if [[ -n ${prev_t[idx]:-} ]]; then
      dt=$((t - prev_t[idx])); di=$((idle - prev_i[idx]))
      usage[idx]=$((dt > 0 ? 100 * (dt - di) / dt : 0))
    else
      usage[idx]=0
    fi
    prev_t[idx]=$t; prev_i[idx]=$idle
  done </proc/stat
  NCPU=$((${#usage[@]} - 1))
}

sample_mem() {
  local k v rest
  while read -r k v rest; do
    case $k in
      MemTotal:)     mt=$v ;;
      MemAvailable:) ma=$v ;;
      SwapTotal:)    swt=$v ;;
      SwapFree:)     swf=$v ;;
    esac
  done </proc/meminfo
  mu=$((mt - ma)); mp=$((100 * mu / mt)); su=$((swt - swf))
}

find_iface() {
  IFACE=$(awk '$2=="00000000"{print $1; exit}' /proc/net/route 2>/dev/null)
  [[ -n $IFACE ]] || IFACE=$(awk -F'[: ]+' 'NR>2 && $2!="lo"{print $2; exit}' /proc/net/dev 2>/dev/null)
}

sample_net() {
  local l rx tx now el=1000
  if [[ -n ${EPOCHREALTIME:-} ]]; then
    now=$((${EPOCHREALTIME/[.,]/} / 1000)); ((last_ms)) && el=$((now - last_ms)); last_ms=$now
  fi
  ((el < 1)) && el=1
  [[ -n $IFACE ]] || { rxr=0; txr=0; return; }
  while read -r l; do
    if [[ $l == "$IFACE:"* ]]; then
      l=${l#*:}; set -- $l; rx=$1; tx=$9
      if [[ -n $prx ]]; then
        rxr=$(((rx - prx) * 1000 / el)); txr=$(((tx - ptx) * 1000 / el))
        ((rxr < 0)) && rxr=0; ((txr < 0)) && txr=0
      fi
      prx=$rx; ptx=$tx
      break
    fi
  done </proc/net/dev
}

sample_misc() {
  local up s d h m
  read -r up _ </proc/uptime; s=${up%.*}
  d=$((s / 86400)); h=$((s % 86400 / 3600)); m=$((s % 3600 / 60))
  UP="${d}d ${h}h ${m}m"
  read -r l1 l5 l15 _ </proc/loadavg; LOAD="$l1  $l5  $l15"
  if ((tickn % 5 == 0)); then
    DISK=$(df -P / 2>/dev/null | awk 'NR==2{print $2" "$3" "$5}')
    [[ -n $DISK ]] || DISK='0 0 0%'
  fi
  TOP=$(ps -eo pmem=,rss=,comm= --sort=-rss 2>/dev/null | head -5)
}

tick() {
  sample_cpu; sample_mem; sample_net; sample_misc
  push cpuH "${usage[0]}"; push memH "$mp"; push rxH "$rxr"; push txH "$txr"
  ((tickn++))
}

# ── render ───────────────────────────────────────────────────────────
render() {
  local o='' i g now dt du dp pm rss comm
  printf -v now '%(%H:%M:%S)T' -1
  o+="${E}  ${B}SYSMON${R}  ${D}${HOST} · linux ${KERN} · up ${UP}${R}${E}"
  o+="  ${D}load ${LOAD}   ·   ${NCPU} cores   ·   ${now}${R}${E}${E}"

  o+="  ${D}cpu${R}    $(bar "${usage[0]}" 24) $(printf '%3d%%' "${usage[0]}")  $(sp cpuH 100)${E}"
  o+="  ${D}cores${R}  "
  for ((i = 1; i <= NCPU && i <= 48; i++)); do
    g=$((usage[i] * 8 / 101)); o+="${GLYPH[g]}"
  done
  o+="${E}${E}"

  o+="  ${D}mem${R}    $(bar "$mp" 24) $(printf '%3d%%' "$mp")  $(sp memH 100)${E}"
  o+="         ${D}$(hk "$mu") of $(hk "$mt")${R}${E}"
  if ((swt > 0)); then
    o+="  ${D}swap${R}   $(bar $((100 * su / swt)) 24) $(printf '%3d%%' $((100 * su / swt)))  ${D}$(hk "$su") of $(hk "$swt")${R}${E}"
  else
    o+="  ${D}swap   off${R}${E}"
  fi
  read -r dt du dp <<<"$DISK"
  o+="  ${D}disk${R}   $(bar "${dp%\%}" 24) $(printf '%3s' "$dp")  ${D}$(hk "$du") of $(hk "$dt") on /${R}${E}${E}"

  o+="  ${D}net${R}    ${D}${IFACE:-none}${R}${E}"
  o+="         ↓ $(printf '%-11s' "$(hr "$rxr")") $(sp rxH)${E}"
  o+="         ↑ $(printf '%-11s' "$(hr "$txr")") $(sp txH)${E}${E}"

  o+="  ${D}top by memory${R}${E}"
  while read -r pm rss comm; do
    [[ -n $comm ]] || continue
    o+="  $(printf '%6s%%  %7s  %s' "$pm" "$(hk "$rss")" "${comm:0:24}")${E}"
  done <<<"$TOP"
  o+="${E}  ${D}q quit · space pause · +/- refresh (${IV[ivi]}s)${R}${E}"
  printf '%s' "$o"
}

# ── modes ────────────────────────────────────────────────────────────
run_once() {
  [[ -t 1 ]] || { B=''; D=''; R=''; RED=''; }
  E=$'\n'
  find_iface; tick; sleep 1; tick; render
}

run_live() {
  [[ -t 0 && -t 1 ]] || { echo "sysmon: needs a terminal (try --once)" >&2; exit 1; }
  printf '\e[?1049h\e[?25l'; stty -echo
  trap 'stty echo; printf "\e[?25h\e[?1049l"' EXIT
  trap 'exit 130' INT TERM
  local k paused=0
  find_iface; tick
  while :; do
    ((paused)) || tick
    printf '\e[H%s\e[J' "$(render)"
    if IFS= read -rsn1 -t "${IV[ivi]}" k; then
      case $k in
        q | Q)  break ;;
        ' ')    paused=$((1 - paused)) ;;
        + | =)  ((ivi < 4)) && ((ivi++)) ;;
        - | _)  ((ivi > 0)) && ((ivi--)) ;;
        $'\e')  IFS= read -rsn2 -t 0.01 _ ;;
      esac
    fi
  done
}

case ${1:-} in
  --once)    run_once ;;
  -h | --help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
  *)         run_live ;;
esac
