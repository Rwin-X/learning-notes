#!/usr/bin/env bash
# cipher — a small crypto toolbox in pure bash
# Requires: bash >= 4, coreutils (tr, od, base64, sha*sum or shasum), awk, sed
#
# Run:  ./cipher.sh                 interactive
#       ./cipher.sh pass 24         one-shot (plain output when piped)
# Commands: pass entropy hash b64 hex caesar rot13 vig rand help quit
# Note: arguments typed on a command line land in shell history. For real
#       passwords use `entropy` with no argument (hidden prompt).

if [[ -t 1 ]]; then B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'; RED=$'\e[31m'; TTY=1
else B=''; D=''; R=''; RED=''; TTY=0; fi

W=''; T=''; NOTES=(); COMMON_HIT=0
COMMON=(password passw0rd 123456 12345678 qwerty letmein admin welcome iloveyou abc123 111111 monkey dragon football master login princess)
SYMBOLS='!@#$%^&*()_=+[]{};:,.<>?/-'

# ── helpers ──────────────────────────────────────────────────────────
has()  { command -v "$1" >/dev/null 2>&1; }
err()  { printf '  %s✗ %s%s\n' "$RED" "$1" "$R" >&2; return 1; }
rep()  { local s; printf -v s '%*s' "$2" ''; printf '%s' "${s// /$1}"; }
trim() { local s=$1; s=${s#"${s%%[![:space:]]*}"}; s=${s%"${s##*[![:space:]]}"}; printf '%s' "$s"; }

split1() {                                     # first word → W, remainder → T
  local s; s=$(trim "$1")
  W=${s%%[[:space:]]*}
  if [[ $s == "$W" ]]; then T=''; else T=$(trim "${s#"$W"}"); fi
}

emit() {                                       # emit <label> <value>: labelled on a tty, bare when piped
  if ((TTY)); then printf '  %s%-8s%s %s\n' "$D" "$1" "$R" "$2"; else printf '%s\n' "$2"; fi
}

# ── entropy maths ────────────────────────────────────────────────────
calc_bits() { awk -v l="$1" -v p="$2" 'BEGIN { if (p < 2) printf "0.0"; else printf "%.1f", l * log(p) / log(2) }'; }

rating() {
  local b=${1%.*}
  if   ((b < 28)); then echo "very weak"
  elif ((b < 36)); then echo "weak"
  elif ((b < 60)); then echo "fair"
  elif ((b < 80)); then echo "strong"
  else                  echo "excellent"; fi
}

crack_time() {                                 # average case, 10 billion guesses/s (fast offline hash)
  awk -v b="$1" 'BEGIN {
    s = 2^(b - 1) / 1e10; y = s / 31557600
    if      (y >= 1e9)   print "> 1 billion years"
    else if (y >= 1e6)   printf "%.0f million years\n", y / 1e6
    else if (y >= 1000)  printf "%.0f thousand years\n", y / 1e3
    else if (y >= 1)     printf "%.0f years\n", y
    else if (s >= 86400) printf "%.0f days\n", s / 86400
    else if (s >= 3600)  printf "%.0f hours\n", s / 3600
    else if (s >= 60)    printf "%.0f minutes\n", s / 60
    else if (s >= 1)     printf "%.0f seconds\n", s
    else                 print "instant"
  }'
}

meter() {
  local b=${1%.*} w=30 f
  f=$((b * w / 128)); ((f > w)) && f=$w; ((f < 0)) && f=0
  printf '%s%s%s%s%s' "$B" "$(rep █ "$f")" "$R$D" "$(rep ░ $((w - f)))" "$R"
}

pool_of() {                                    # size of the character pool an attacker must assume
  local LC_ALL=C s=$1 p=0
  [[ $s == *[[:lower:]]* ]]         && p=$((p + 26))
  [[ $s == *[[:upper:]]* ]]         && p=$((p + 26))
  [[ $s == *[[:digit:]]* ]]         && p=$((p + 10))
  [[ $s == *[[:punct:][:space:]]* ]] && p=$((p + 33))
  [[ $s == *[![:print:]]* ]]        && p=$((p + 100))   # non-ASCII
  echo "$p"
}

weak_notes() {                                 # fills NOTES and COMMON_HIT
  NOTES=(); COMMON_HIT=0
  local s=${1,,} len=${#1} w i c p up=1 dn=1 eq=1 u=0 d=0 e=0
  ((len < 8)) && NOTES+=("shorter than 8 characters")
  for w in "${COMMON[@]}"; do
    if [[ $s == *"$w"* ]]; then NOTES+=("contains a common password: $w"); COMMON_HIT=1; break; fi
  done
  local LC_ALL=C
  for ((i = 1; i < ${#s}; i++)); do
    printf -v c '%d' "'${s:i:1}"; printf -v p '%d' "'${s:i-1:1}"
    if ((c - p == 1)); then ((up++)); else up=1; fi
    if ((p - c == 1)); then ((dn++)); else dn=1; fi
    if ((c == p));     then ((eq++)); else eq=1; fi
    ((up >= 4)) && u=1; ((dn >= 4)) && d=1; ((eq >= 4)) && e=1
  done
  ((u)) && NOTES+=("ascending run (abcd, 1234)")
  ((d)) && NOTES+=("descending run (dcba, 4321)")
  ((e)) && NOTES+=("repeated character (aaaa)")
  [[ $1 =~ ^[[:alpha:]]{12,}$ ]] && NOTES+=("letters only: if these are dictionary words, real strength is far lower")
}

# ── commands ─────────────────────────────────────────────────────────
cmd_pass() {
  local len=20 simple=0 w classes=('a-z' 'A-Z' '0-9') set pool c pw ok n=0 bits
  for w in $1; do
    if [[ $w =~ ^[0-9]+$ ]]; then len=$((10#$w))
    elif [[ $w == simple ]]; then simple=1
    else err "usage: pass [length 8-128] [simple]"; return 1; fi
  done
  ((len >= 8 && len <= 128)) || { err "length must be 8–128"; return 1; }
  pool=62
  if ((!simple)); then classes+=("$SYMBOLS"); pool=$((pool + ${#SYMBOLS})); fi
  set=$(printf '%s' "${classes[@]}")
  while :; do                                  # resample until every class is present
    pw=$(LC_ALL=C tr -dc "$set" </dev/urandom 2>/dev/null | head -c "$len")
    ok=1
    for c in "${classes[@]}"; do
      [[ -n $(printf '%s' "$pw" | LC_ALL=C tr -dc "$c") ]] || { ok=0; break; }
    done
    ((ok)) && break
    ((++n > 200)) && { err "could not generate a password"; return 1; }
  done
  if ((!TTY)); then printf '%s\n' "$pw"; return; fi
  bits=$(calc_bits "$len" "$pool")
  printf '\n  %s%s%s\n\n' "$B" "$pw" "$R"
  printf '  %sentropy%s  %s  %s%s bits%s  %s\n' "$D" "$R" "$(meter "$bits")" "$B" "$bits" "$R" "$(rating "$bits")"
  printf '  %sdetail%s   length %d · pool %d · cracking ≈ %s\n\n' "$D" "$R" "$len" "$pool" "$(crack_time "$bits")"
}

cmd_entropy() {
  local text=$1 len pool bits shown label ct n
  if [[ -z $text ]]; then
    ((TTY)) || { err "no input"; return 1; }
    IFS= read -rsp '  password (hidden) › ' text; echo
  fi
  [[ -n $text ]] || { err "empty input"; return 1; }
  len=${#text}; pool=$(pool_of "$text"); bits=$(calc_bits "$len" "$pool")
  weak_notes "$text"
  if ((!TTY)); then
    if ((COMMON_HIT)); then printf '0.0\n'; else printf '%s\n' "$bits"; fi
    return
  fi
  shown="$bits bits"
  if ((COMMON_HIT)); then                      # a listed password has no real entropy
    label="very weak"; ct="instant (dictionary attack)"; shown="listed password"; bits=0
  else
    label=$(rating "$bits"); ct="≈ $(crack_time "$bits")"
  fi
  printf '\n  %sentropy%s  %s  %s%s%s  %s\n' "$D" "$R" "$(meter "$bits")" "$B" "$shown" "$R" "$label"
  printf '  %sdetail%s   length %d · pool %d · cracking %s\n' "$D" "$R" "$len" "$pool" "$ct"
  for n in "${NOTES[@]}"; do printf '  %snote%s     %s\n' "$D" "$R" "$n"; done
  printf '  %sbits are an upper bound: they assume every character was picked at random%s\n\n' "$D" "$R"
}

digest() {                                     # stdin → hex digest
  local n
  case $1 in
    md5)
      if   has md5sum; then md5sum
      elif has md5;    then md5 -q
      else openssl dgst -md5 -r; fi ;;
    sha1 | sha256 | sha512)
      n=${1#sha}
      if   has "${1}sum"; then "${1}sum"
      elif has shasum;    then shasum -a "$n"
      else openssl dgst -"$1" -r; fi ;;
  esac | awk '{print $1}'
}

cmd_hash() {
  local algo=sha256 s f out
  split1 "$1"; s=$(trim "$1")
  case $W in md5 | sha1 | sha256 | sha512) algo=$W; s=$T ;; esac
  [[ -n $s ]] || { err "usage: hash [md5|sha1|sha256|sha512] <text>  |  hash [algo] -f <file>"; return 1; }
  if [[ $s == "-f "* ]]; then
    f=$(trim "${s#-f }"); f=${f/#\~/$HOME}
    [[ -f $f && -r $f ]] || { err "cannot read file: $f"; return 1; }
    out=$(digest "$algo" <"$f")
  else
    out=$(printf '%s' "$s" | digest "$algo")
  fi
  emit "$algo" "$out"
}

cmd_b64() {
  local mode s out
  split1 "$1"; mode=$W; s=$T
  case $mode in
    enc) out=$(printf '%s' "$s" | base64 | tr -d '\n') ;;
    dec) out=$(printf '%s' "$s" | base64 -d 2>/dev/null) || { err "invalid base64"; return 1; } ;;
    *)   err "usage: b64 enc|dec <text>"; return 1 ;;
  esac
  emit base64 "$out"
}

cmd_hex() {
  local mode s out
  split1 "$1"; mode=$W; s=$T
  case $mode in
    enc) out=$(printf '%s' "$s" | od -An -v -tx1 | tr -d ' \n') ;;
    dec)
      s=${s// /}
      [[ $s =~ ^([0-9a-fA-F]{2})+$ ]] || { err "invalid hex (need an even number of hex digits)"; return 1; }
      out=$(printf '%b' "$(sed 's/../\\x&/g' <<<"$s")") ;;
    *)   err "usage: hex enc|dec <text>"; return 1 ;;
  esac
  emit hex "$out"
}

rotn() {                                       # rotn <shift> <text>
  local s l u
  s=$(((($1 % 26) + 26) % 26))
  l=abcdefghijklmnopqrstuvwxyz; u=ABCDEFGHIJKLMNOPQRSTUVWXYZ
  printf '%s' "$2" | LC_ALL=C tr "$l$u" "${l:s}${l:0:s}${u:s}${u:0:s}"
}

cmd_caesar() {
  split1 "$1"
  [[ $W =~ ^-?[0-9]+$ && -n $T ]] || { err "usage: caesar <shift> <text>"; return 1; }
  emit caesar "$(rotn "$W" "$T")"
}

vig() {                                        # vig <enc|dec> <key> <text>
  local LC_ALL=C mode=$1 key=${2^^} text=$3 out='' c o b k i ki=0
  key=${key//[^A-Z]/}
  ((${#key})) || return 1
  for ((i = 0; i < ${#text}; i++)); do
    c=${text:i:1}
    if [[ $c == [A-Za-z] ]]; then
      printf -v o '%d' "'$c"
      if ((o >= 97)); then b=97; else b=65; fi
      printf -v k '%d' "'${key:ki % ${#key}:1}"; k=$((k - 65)); ((ki++))
      [[ $mode == dec ]] && k=$((26 - k))
      o=$(((o - b + k) % 26 + b))
      printf -v c "\\$(printf '%03o' "$o")"
    fi
    out+=$c
  done
  printf '%s' "$out"
}

cmd_vig() {
  local mode key s
  split1 "$1"; mode=$W
  split1 "$T"; key=$W; s=$T
  [[ $mode == enc || $mode == dec ]] && [[ -n $s ]] || { err "usage: vig enc|dec <key> <text>"; return 1; }
  [[ ${key^^} == *[A-Z]* ]] || { err "key must contain letters"; return 1; }
  emit vigenere "$(vig "$mode" "$key" "$s")"
}

cmd_rand() {
  local n=${1:-32} out
  [[ $n =~ ^[0-9]+$ ]] && ((n >= 1 && n <= 1024)) || { err "usage: rand [bytes 1-1024]"; return 1; }
  out=$(head -c "$n" /dev/urandom | od -An -v -tx1 | tr -d ' \n')
  emit hex "$out"
  ((TTY)) && printf '  %sentropy%s  %d bits\n' "$D" "$R" $((n * 8))
  return 0
}

show_help() {
  cat <<EOF

  ${B}pass${R} [len] [simple]        random password, guaranteed to use every class   ${D}pass 24${R}
  ${B}entropy${R} [text]             strength estimate; no argument = hidden prompt
  ${B}hash${R} [algo] <text|-f file> md5 sha1 sha256 (default) sha512        ${D}hash sha512 -f ~/file${R}
  ${B}b64${R} enc|dec <text>         base64
  ${B}hex${R} enc|dec <text>         hexadecimal
  ${B}caesar${R} <shift> <text>      Caesar shift (negative shifts decode)    ${D}rot13 <text> too${R}
  ${B}vig${R} enc|dec <key> <text>   Vigenère cipher
  ${B}rand${R} [bytes]               random hex token from /dev/urandom (default 32 bytes)
  ${B}clear${R} · ${B}quit${R}

  ${D}classic ciphers are for learning, not for protecting anything${R}

EOF
}

dispatch() {
  local cmd=$1 rest=$2
  case $cmd in
    pass)         cmd_pass "$rest" ;;
    entropy)      cmd_entropy "$rest" ;;
    hash)         cmd_hash "$rest" ;;
    b64 | base64) cmd_b64 "$rest" ;;
    hex)          cmd_hex "$rest" ;;
    caesar)       cmd_caesar "$rest" ;;
    rot13)        [[ -n $rest ]] && emit rot13 "$(rotn 13 "$rest")" || err "usage: rot13 <text>" ;;
    vig)          cmd_vig "$rest" ;;
    rand)         cmd_rand "$rest" ;;
    help | '?')   show_help ;;
    *)            err "unknown command: $cmd (type help)" ;;
  esac
}

repl() {
  local line cmd rest prompt=$'  \001\e[2m\002›\001\e[0m\002 '
  set -o history
  printf '\n  %scipher%s  %s·  type help  ·  ctrl-d to exit%s\n\n' "$B" "$R" "$D" "$R"
  while IFS= read -e -r -p "$prompt" line || { echo; break; }; do
    line=$(trim "$line"); [[ -z $line ]] && continue
    cmd=${line%%[[:space:]]*}; rest=$(trim "${line#"$cmd"}")
    case $cmd in
      q | quit | exit) break ;;
      clear)           printf '\e[2J\e[H'; continue ;;
    esac
    [[ $cmd == entropy && -n $rest ]] || history -s -- "$line"   # never keep typed passwords in history
    dispatch "$cmd" "$rest"
  done
}

if (($#)); then dispatch "$1" "${*:2}"; exit $?; else repl; fi
