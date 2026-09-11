#!/usr/bin/env bash
# Renders configs/starship.toml against throwaway fixture repos and asserts that
# each prompt segment appears when — and only when — it should.
#
#   Usage: tests/test_prompt.sh
#   Needs: starship, git, perl (all present on a Ghostforge machine)
#
# Fixtures live in a mktemp dir and are removed on exit. Nothing here touches
# ~/.config or the real shell. Node/pnpm/yarn/bun versions are machine-specific,
# so tests assert on the segment's glyph and a version *shape*, never a value.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
export STARSHIP_CONFIG="$REPO/configs/starship.toml"
export STARSHIP_SHELL=zsh   # mirror real usage; custom modules pin their own shell
export LC_ALL=en_US.UTF-8

# --- Glyphs the config is expected to emit (Nerd Font v3 code points) ----------
# Built from code points, not pasted icons, so a stray look-alike glyph cannot
# make a test pass by accident.
glyph() { perl -CS -e 'print chr(hex $ARGV[0])' "$1"; }
G_APPLE=$(glyph F179)     G_FOLDER=$(glyph F07B)    G_BRANCH=$(glyph E725)    G_CHECK=$(glyph F00C)
G_STAGED=$(glyph F067)    G_MODIFIED=$(glyph F040)  G_UNTRACKED=$(glyph F128) G_AHEAD=$(glyph F062)
G_NODE=$(glyph E718)      G_BUN=$(glyph E76F)       G_PNPM=$(glyph F03D7)     G_YARN=$(glyph E6A7)
G_NPM=$(glyph E616)       G_PKG=$(glyph F487)       G_CLOCK=$(glyph F017)     G_HOURGLASS=$(glyph F252)
G_STATUS=$(glyph F00D)    G_JOBS=$(glyph F013)

# --- Harness -------------------------------------------------------------------
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  \033[32m✔\033[0m %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  \033[31m✘\033[0m %s\n      got: %s\n' "$1" "$2"; }
# has DESC HAYSTACK NEEDLE      — NEEDLE is a fixed string
has()  { case "$2" in *"$3"*) ok "$1";; *) bad "$1" "$2";; esac; }
# lacks DESC HAYSTACK NEEDLE
lacks(){ case "$2" in *"$3"*) bad "$1" "$2";; *) ok "$1";; esac; }
# matches DESC HAYSTACK ERE
matches(){ if printf '%s' "$2" | grep -Eq "$3"; then ok "$1"; else bad "$1" "$2"; fi; }

strip() { perl -pe 's/\e\[[0-9;]*m//g; s/%\{|%\}//g'; }
# render DIR [STATUS] [DURATION_MS] [JOBS] → ANSI-stripped first prompt line + second line
render()     { (cd "$1" && starship prompt -s "${2:-0}" -d "${3:-0}" -j "${4:-0}") | strip; }
render_raw() { (cd "$1" && starship prompt -s "${2:-0}" -d "${3:-0}" -j "${4:-0}") | perl -pe 's/%\{|%\}//g'; }

# --- Fixtures ------------------------------------------------------------------
FX="$(mktemp -d)"; trap 'rm -rf "$FX"' EXIT
g() { git -c user.email=t@t -c user.name=t -c init.defaultBranch=main -c commit.gpgsign=false "$@"; }

mk() { mkdir -p "$FX/$1" && cd "$FX/$1"; }
( mk clean && g init -q && echo a > a.txt && g add . && g commit -qm init )
( mk dirty && g init -q && printf 'a\n' > a.txt && printf 'b\n' > b.txt && g add . && g commit -qm init \
    && g checkout -qb feat/prompt-colors && printf 'a2\n' > a.txt && printf 'b2\n' > b.txt && g add b.txt && echo u > u.txt )
( mk ahead && g clone -q "$FX/clean" . && echo b > b.txt && g add . && g commit -qm second )
( mk pnpm && g init -q && echo '{"name":"demo","version":"1.2.3","engines":{"node":">=99"}}' > package.json \
    && : > pnpm-lock.yaml && g add . && g commit -qm init )
( mk bun  && echo '{"name":"bun-demo","version":"0.1.0"}'  > package.json && : > bun.lock )
( mk yarn && echo '{"name":"yarn-demo","version":"2.0.0"}' > package.json && : > yarn.lock )
( mk npm  && echo '{"name":"npm-demo","version":"3.0.0"}'  > package.json && : > package-lock.json )
mkdir -p "$FX/plain"
cd "$REPO"

# --- 1. Config parses cleanly ----------------------------------------------------
echo "config"
ERR="$(starship print-config 2>&1 >/dev/null)"
if [ -z "$ERR" ]; then ok "starship.toml parses with no warnings"; else bad "starship.toml parses with no warnings" "$ERR"; fi

# --- 2. Non-repo directory: only the frame ------------------------------------
echo "plain directory"
OUT="$(render "$FX/plain")"
has    "OS glyph"                 "$OUT" "$G_APPLE"
has    "folder glyph before path" "$OUT" "$G_FOLDER"
has    "directory name"           "$OUT" "plain"
matches "clock with HH:MM"        "$OUT" "$G_CLOCK [0-9]{2}:[0-9]{2}"
lacks  "no branch glyph"          "$OUT" "$G_BRANCH"
lacks  "no clean check"           "$OUT" "$G_CHECK"
lacks  "no node glyph"            "$OUT" "$G_NODE"
has    "success prompt char ◎"    "$OUT" "◎"

# --- 3. Clean repo on main ------------------------------------------------------
echo "clean repo on main"
OUT="$(render "$FX/clean")"
has   "branch shown even on main" "$OUT" "${G_BRANCH} main"
has   "clean check mark"          "$OUT" "$G_CHECK"
lacks "no modified glyph"         "$OUT" "$G_MODIFIED"
lacks "no untracked glyph"        "$OUT" "$G_UNTRACKED"
lacks "no staged glyph"           "$OUT" "$G_STAGED"

# --- 4. Dirty feature branch ----------------------------------------------------
echo "dirty repo: 1 staged, 1 modified, 1 untracked"
OUT="$(render "$FX/dirty")"
has   "full branch name (no truncation at 11)" "$OUT" "feat/prompt-colors"
has   "staged count"     "$OUT" "${G_STAGED} 1"
has   "modified count"   "$OUT" "${G_MODIFIED} 1"
has   "untracked count"  "$OUT" "${G_UNTRACKED} 1"
lacks "no clean check"   "$OUT" "$G_CHECK"
has   "lines added +2"   "$OUT" "+2"
has   "lines deleted -2" "$OUT" "-2"

# --- 5. Ahead of upstream -------------------------------------------------------
echo "repo ahead of origin"
OUT="$(render "$FX/ahead")"
has   "ahead count" "$OUT" "${G_AHEAD} 1"
has   "clean check (tree is clean, only ahead)" "$OUT" "$G_CHECK"

# --- 6. Node projects -----------------------------------------------------------
echo "pnpm project (package.json engines mismatch)"
OUT="$(render "$FX/pnpm")"
matches "node glyph + version"   "$OUT" "${G_NODE} ?[0-9]+\.[0-9]+\.[0-9]+"
has     "pnpm badge"             "$OUT" "${G_PNPM} pnpm"
lacks   "no yarn badge"          "$OUT" "${G_YARN} yarn"
lacks   "no npm badge"           "$OUT" "${G_NPM} npm"
has     "package version"        "$OUT" "${G_PKG} 1.2.3"
RAW="$(render_raw "$FX/pnpm")"
matches "node segment turns red when engines.node is unsatisfied" "$RAW" $'\e\\[[0-9;]*31m'"${G_NODE}"

echo "yarn project"
OUT="$(render "$FX/yarn")"
has   "yarn badge"  "$OUT" "${G_YARN} yarn"
has   "node glyph"  "$OUT" "$G_NODE"
has   "package version" "$OUT" "${G_PKG} 2.0.0"

echo "npm project"
OUT="$(render "$FX/npm")"
has   "npm badge"   "$OUT" "${G_NPM} npm"
has   "node glyph"  "$OUT" "$G_NODE"

echo "bun project"
OUT="$(render "$FX/bun")"
matches "bun glyph + version" "$OUT" "${G_BUN} ?[0-9]+\.[0-9]+\.[0-9]+"
lacks   "node hidden in bun projects" "$OUT" "$G_NODE"
lacks   "no npm badge"  "$OUT" "${G_NPM} npm"

# --- 7. Exit status, duration, jobs --------------------------------------------
echo "failed command, 3.4s, 2 jobs"
OUT="$(render "$FX/plain" 127 3400 2)"
has "exit code shown"      "$OUT" "${G_STATUS} 127"
has "duration shown"       "$OUT" "${G_HOURGLASS} 3s"
has "error prompt char ○"  "$OUT" "○"
has "jobs count"           "$OUT" "${G_JOBS} 2"
OUT="$(render "$FX/plain" 0 500)"
lacks "sub-2s duration hidden" "$OUT" "$G_HOURGLASS"
lacks "exit 0 hidden"          "$OUT" "$G_STATUS"

# --- 8. Latency budget ----------------------------------------------------------
echo "latency (pnpm fixture, 5 renders)"
T0=$(python3 -c 'import time;print(int(time.time()*1000))')
for _ in 1 2 3 4 5; do render "$FX/pnpm" >/dev/null; done
T1=$(python3 -c 'import time;print(int(time.time()*1000))')
AVG=$(( (T1 - T0) / 5 ))
if [ "$AVG" -lt 150 ]; then ok "average render ${AVG}ms < 150ms"; else bad "average render under 150ms" "${AVG}ms"; fi

# --- Summary --------------------------------------------------------------------
echo
printf '%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
