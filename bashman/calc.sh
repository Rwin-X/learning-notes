#!/usr/bin/env bash
# calc — minimal, fast, powerful CLI calculator
# Requires: bash >= 4, bc
# Usage:  ./calc.sh              interactive mode
#         ./calc.sh "2^10 + 1"   one-shot mode

set -u
command -v bc >/dev/null 2>&1 || { echo "calc: 'bc' is required (apt install bc / brew install bc)" >&2; exit 1; }

# ── style ────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  B=$'\e[1m'; D=$'\e[2m'; R=$'\e[0m'; RED=$'\e[31m'
else
  B=''; D=''; R=''; RED=''
fi

# ── engine ───────────────────────────────────────────────────────────
PRELUDE='
scale=12
pi=4*a(1)
e=e(1)
define sin(x){return s(x)}
define cos(x){return c(x)}
define tan(x){return s(x)/c(x)}
define atan(x){return a(x)}
define ln(x){return l(x)}
define log(x){return l(x)/l(10)}
define exp(x){return e(x)}
define abs(x){if(x<0)return -x;return x}
define pow(x,y){return e(y*l(x))}
define fact(n){auto r;r=1;while(n>1){r*=n;n-=1};return r}
define deg(x){return x*180/pi}
define rad(x){return x*pi/180}
'
STATE=''     # persistent variables (x=5; ans=...)
HIST=()

fmt() {
  local r=$1
  [[ $r == .* ]]  && r="0$r"
  [[ $r == -.* ]] && r="-0${r#-}"
  if [[ $r == *.* ]]; then
    r=${r%"${r##*[!0]}"}
    r=${r%.}
  fi
  [[ -z $r || $r == "-0" ]] && r=0
  printf '%s' "$r"
}

# eval_expr <expr>  → sets RESULT, returns 0 on success
eval_expr() {
  local expr=$1 out
  expr=${expr//×/*}; expr=${expr//÷//}
  expr=${expr//\*\*/^}
  # assignment: name=expression
  if [[ $expr =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[^=] ]]; then
    local name=${BASH_REMATCH[1]}
    out=$(printf '%s\n%s\n%s\nprint %s\n' "$PRELUDE" "$STATE" "$expr" "$name" \
          | BC_LINE_LENGTH=0 bc -l 2>&1)
    if [[ $out == *error* || $out == *Error* ]]; then RESULT=${out##*: }; return 1; fi
    RESULT=$(fmt "$out")
    STATE+="$name=$RESULT"$'\n'
    return 0
  fi
  out=$(printf '%s\n%s\n%s\n' "$PRELUDE" "$STATE" "$expr" | BC_LINE_LENGTH=0 bc -l 2>&1)
  if [[ -z $out ]]; then RESULT=""; return 0; fi
  if [[ $out == *error* || $out == *Error* ]]; then
    case $out in
      *"Divide by zero"*) RESULT="division by zero" ;;
      *"syntax error"*)   RESULT="syntax error" ;;
      *)                  RESULT="invalid expression" ;;
    esac
    return 1
  fi
  RESULT=$(fmt "${out##*$'\n'}")
  STATE+="ans=$RESULT"$'\n'
  return 0
}

# ── one-shot mode ────────────────────────────────────────────────────
if [[ $# -gt 0 ]]; then
  if eval_expr "$*"; then printf '%s\n' "$RESULT"; exit 0
  else printf 'calc: %s\n' "$RESULT" >&2; exit 1; fi
fi

# ── interactive mode ─────────────────────────────────────────────────
show_help() {
  cat <<EOF

  ${B}operators${R}   + - * / % ^ ( )        ${D}also ** × ÷${R}
  ${B}functions${R}   sqrt sin cos tan atan ln log exp abs pow fact deg rad
  ${B}constants${R}   pi e ans               ${D}ans = last result${R}
  ${B}variables${R}   x = 5*3                ${D}then: x^2${R}
  ${B}commands${R}    hex [n]  bin [n]  vars  history  clear  help  quit

EOF
}

to_base() { # to_base <obase> <value>
  local v=${2%%.*}
  printf 'obase=%s\n%s\n' "$1" "$v" | bc 2>/dev/null
}

printf '\n  %scalc%s  %s·  type help  ·  ctrl-d to exit%s\n\n' "$B" "$R" "$D" "$R"

while IFS= read -e -r -p $'  \e[2m›\e[0m ' line || { echo; break; }; do
  line=${line#"${line%%[![:space:]]*}"}; line=${line%"${line##*[![:space:]]}"}
  [[ -z $line ]] && continue
  history -s -- "$line"
  case $line in
    q|quit|exit) break ;;
    help|\?)     show_help; continue ;;
    clear)       printf '\e[2J\e[H'; continue ;;
    history)
      i=1; for h in "${HIST[@]}"; do printf '  %s%2d%s  %s\n' "$D" "$i" "$R" "$h"; ((i++)); done
      continue ;;
    vars)
      if [[ -z $STATE ]]; then printf '  %s(none)%s\n' "$D" "$R"
      else printf '%s' "$STATE" | awk -F= '!s[$1]++ || 1 {v[$1]=$2} END{for(k in v) printf "  %s = %s\n", k, v[k]}' | sort; fi
      continue ;;
    hex|hex\ *|bin|bin\ *)
      cmd=${line%% *}; arg=${line#"$cmd"}; arg=${arg# }
      if [[ -z $arg ]]; then arg=$(printf '%s' "$STATE" | grep '^ans=' | tail -1 | cut -d= -f2); arg=${arg:-0}
      else
        saved=$STATE   # conversion must not overwrite ans
        if eval_expr "$arg"; then arg=$RESULT; STATE=$saved
        else STATE=$saved; printf '  %s✗ %s%s\n' "$RED" "$RESULT" "$R"; continue; fi
      fi
      if [[ $cmd == hex ]]; then printf '  %s=%s 0x%s\n' "$D" "$R" "$(to_base 16 "$arg")"
      else printf '  %s=%s 0b%s\n' "$D" "$R" "$(to_base 2 "$arg")"; fi
      continue ;;
  esac

  HIST+=("$line")
  if eval_expr "$line"; then
    [[ -n $RESULT ]] && printf '  %s=%s %s%s%s\n' "$D" "$R" "$B" "$RESULT" "$R"
  else
    printf '  %s✗ %s%s\n' "$RED" "$RESULT" "$R"
  fi
done
