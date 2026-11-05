#!/usr/bin/env bash
#*******************************************************************************
# test_card_cache.sh: the CARD cache (CLAUDE.md D5; validation V1 mark 5)
#
# CARD's download site is replaced by local files, so the test is offline and
# never touches card.mcmaster.ca. Checks: first use downloads; a second run
# reuses without downloading; a damaged cache is detected, reported and
# fetched again; a download that does not match the pinned checksum stops the
# run; 'latest' finds the newest release, labels it not validated, records
# its checksum and catches damage against it; an unreachable site stops with
# a clear message.
#
# Usage (repository root, Nextflow on PATH):  bash tests/card_cache/test_card_cache.sh
#*******************************************************************************
set -u
root=$(pwd)
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
pass=0; fail=0
ok()  { pass=$((pass + 1)); echo "  ok:   $1"; }
bad() { fail=$((fail + 1)); echo "  FAIL: $1"; }
sha() { shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1 || sha256sum "$1" | cut -d' ' -f1; }

# A stand-in CARD site: two releases and a download page naming them.
mkdir -p "$t/site"
printf 'card release 4.0.2\n' > "$t/site/broadstreet-v4.0.2.tar.bz2"
printf 'card release 4.1.0\n' > "$t/site/broadstreet-v4.1.0.tar.bz2"
printf '<a href="download/0/broadstreet-v4.0.2.tar.bz2">4.0.2</a> <a href="download/0/broadstreet-v4.1.0.tar.bz2">4.1.0</a> <a href="download/0/broadstreet-v3.9.9.tar.bz2">old</a>\n' > "$t/site/download.html"
good=$(sha "$t/site/broadstreet-v4.0.2.tar.bz2")
printf 'version,status,url,sha256,released,note\n4.0.2,validated,file://%s/site/broadstreet-v4.0.2.tar.bz2,%s,2026-08-11,test\n' "$t" "$good" > "$t/versions.csv"
printf 'version,status,url,sha256,released,note\n4.0.2,validated,file://%s/site/broadstreet-v4.0.2.tar.bz2,%s,2026-08-11,test\n' "$t" "$(printf 0 | sha /dev/stdin)" > "$t/versions_wrong.csv"

run() {   # run <which> <cache> <csv> [page]; prints the RESULT line or the error
    rm -f "$t/nf.log"
    nextflow -log "$t/nf.log" -q run "$root/tests/card_cache/card_cache_test.nf" -work-dir "$t/work" \
        --which "$1" --cache "$2" --csv "$3" --page "${4:-file://$t/site/download.html}" --base "file://$t/site/" > "$t/out.txt" 2>&1
    echo $? > "$t/rc.txt"
    cat "$t/out.txt"
    grep -h 'WARN' "$t/nf.log" 2>/dev/null   # warnings go to the log under -q

}

echo "test_card_cache.sh"
out=$(run validated "$t/cache" "$t/versions.csv")
[[ $out == *$'\t4.0.2\ttrue\t'"$good"$'\tdownloaded into the cache (first use)'* ]] && ok "first use downloads into the cache" || bad "first use: $out"
[ "$(sha "$t/cache/broadstreet-v4.0.2.tar.bz2")" = "$good" ] && ok "cached archive matches the pinned checksum" || bad "cached archive checksum"
touch -t 202001010000 "$t/cache/broadstreet-v4.0.2.tar.bz2"
out=$(run validated "$t/cache" "$t/versions.csv")
[[ $out == *'reused from the cache (checksum matches; nothing downloaded)'* ]] && ok "second run reuses the cache" || bad "second run: $out"
[ "$(date -r "$t/cache/broadstreet-v4.0.2.tar.bz2" +%Y)" = 2020 ] && ok "second run did not rewrite the archive" || bad "archive rewritten on reuse"

printf 'damage' >> "$t/cache/broadstreet-v4.0.2.tar.bz2"
out=$(run validated "$t/cache" "$t/versions.csv")
[[ $out == *'does not match the recorded'*'fetching it again'* && $out == *'fetched again (the cached copy failed its checksum)'* ]] && ok "damaged cache is reported and fetched again" || bad "damaged cache: $out"
[ "$(sha "$t/cache/broadstreet-v4.0.2.tar.bz2")" = "$good" ] && ok "refetched archive matches the pinned checksum" || bad "refetched checksum"

out=$(run validated "$t/cache_wrong" "$t/versions_wrong.csv")
[ "$(cat "$t/rc.txt")" != 0 ] && [[ $out == *'not the pinned'*'Nothing was run'* ]] && ok "a download not matching the pinned checksum stops the run" || bad "wrong pinned checksum: $out"

out=$(run latest "$t/cache" "$t/versions.csv")
[[ $out == *$'\t4.1.0\tfalse\t'*'downloaded into the cache (first use)'* ]] && ok "'latest' finds 4.1.0, not validated, downloads it" || bad "latest first: $out"
[ "$(cat "$t/cache/broadstreet-v4.1.0.tar.bz2.sha256")" = "$(sha "$t/site/broadstreet-v4.1.0.tar.bz2")" ] && ok "'latest' records its checksum at first download" || bad "latest sidecar"
out=$(run latest "$t/cache" "$t/versions.csv")
[[ $out == *'reused from the cache'* ]] && ok "'latest' reuses its cache" || bad "latest reuse: $out"
printf 'damage' >> "$t/cache/broadstreet-v4.1.0.tar.bz2"
out=$(run latest "$t/cache" "$t/versions.csv")
[[ $out == *'fetched again'* ]] && [ "$(sha "$t/cache/broadstreet-v4.1.0.tar.bz2")" = "$(sha "$t/site/broadstreet-v4.1.0.tar.bz2")" ] && ok "'latest' damage caught against the recorded checksum" || bad "latest damage: $out"
[ -f "$t/cache/broadstreet-v4.0.2.tar.bz2" ] && ok "validated and latest releases are cached side by side" || bad "validated release missing after latest"

out=$(run latest "$t/cache" "$t/versions.csv" "file://$t/site/nothing_here.html")
[ "$(cat "$t/rc.txt")" != 0 ] && [[ $out == *'Could not reach'* ]] && ok "unreachable download page stops with a clear message" || bad "unreachable page: $out"
leftovers=$(find "$t/cache" -name '*.part-*' | wc -l | tr -d ' ')
[ "$leftovers" = 0 ] && ok "no half-written downloads left in the cache" || bad "$leftovers .part files left"

echo "test_card_cache.sh: $pass passed, $fail failed"
[ "$fail" = 0 ]
