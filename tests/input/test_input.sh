#!/usr/bin/env bash
#*******************************************************************************
# test_input.sh: the samplesheet and --triage_results checks in main.nf (D4, D9)
#
# Each bad input must stop the run before any work, with a message naming
# the problem; the good ones must pass the checks. Runs Nextflow with
# -preview, so no task is run and no data downloaded.
#
# Usage (repository root, Nextflow on PATH):  bash tests/input/test_input.sh
#*******************************************************************************
set -u
root=$(pwd)
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
pass=0; fail=0
touch "$t/a_1.fastq.gz" "$t/a_2.fastq.gz" "$t/b_1.fastq.gz"

# expect <name> <stop|pass> <text the output must contain> <samplesheet lines...>
expect() {
    local name=$1 want=$2 text=$3; shift 3
    printf '%s\n' "$@" > "$t/sheet.csv"
    out=$(nextflow -q run "$root/main.nf" -preview -profile docker --input "$t/sheet.csv" --outdir "$t/out" \
          -work-dir "$t/work" ${EXTRA:-} 2>&1); rc=$?
    if { [ "$want" = stop ] && [ $rc -ne 0 ]; } || { [ "$want" = pass ] && [ $rc -eq 0 ]; } && [[ $out == *"$text"* ]]; then
        pass=$((pass + 1)); echo "  ok:   $name"
    else
        fail=$((fail + 1)); echo "  FAIL: $name (exit $rc)"; echo "$out" | grep -v '^\s*$' | tail -5 | sed 's/^/        /'
    fi
}
A="$t/a_1.fastq.gz"; B="$t/a_2.fastq.gz"
echo "test_input.sh"
expect "a typo of fastq_2 stops"            stop "'fastq2' looks like the pipeline column 'fastq_2'" "sample,fastq_1,fastq2" "s1,$A,$B"
expect "a synonym (R1) stops"               stop "'R1' looks like the pipeline column 'fastq_1'"     "sample,R1,fastq_2" "s1,$A,$B"
expect "a case-only difference stops"       stop "'Sample' looks like the pipeline column 'sample'"  "Sample,sample,fastq_1" "x,s1,$A"
expect "a missing sample column stops"      stop "missing column(s) sample"                         "name_of_sample,fastq_1" "s1,$A"
expect "a column named twice stops"         stop "column(s) named twice: site"                      "sample,fastq_1,site,site" "s1,$A,a,b"
expect "a sample name with a space stops"   stop "may only use letters, digits"                     "sample,fastq_1" "s 1,$A"
expect "an empty sample name stops"         stop "no sample name"                                   "sample,fastq_1" ",$A"
expect "a missing file stops"               stop "No such file or directory"                         "sample,fastq_1" "s1,$t/nope.fastq.gz"
expect "paired and single lanes of one sample are left out" stop "some files of this sample are paired and some single-end" \
                                            "sample,fastq_1,fastq_2" "s1,$A,$B" "s1,$t/b_1.fastq.gz,"
expect "study metadata columns pass"        pass "SUCCESS"                                          "sample,fastq_1,fastq_2,site,day,treatment_group" "s1,$A,$B,gut,1,ctrl"
expect "seq-triage's own columns pass"      pass "SUCCESS"                                          "sample,fastq_1,fastq_2,platform,sample_type,target_taxid" "s1,$A,$B,illumina,metagenome,"
expect "a UTF-8 byte-order mark passes"     pass "SUCCESS"                                          $'\xEF\xBB\xBFsample,fastq_1' "s1,$A"

mkdir -p "$t/triage"
printf 'sample\tverdict\tverdict_reason\tdetected_type\ttype_reason\tdetected_platform\ns1\tPASS\t\tmetagenome\t\tillumina\ns2\tPASS\t\tmetagenome\t\tillumina\n' > "$t/triage/triage_summary.tsv"
EXTRA="--triage_results $t/triage" expect "a sample missing from seq-triage's results stops" stop "in seq-triage's results only: s2" "sample,fastq_1" "s1,$A"
EXTRA="--triage_results $t/nowhere" expect "a --triage_results folder that does not exist stops" stop "does not exist" "sample,fastq_1" "s1,$A"
mkdir -p "$t/empty"
EXTRA="--triage_results $t/empty" expect "a folder without triage_summary.tsv stops" stop "no triage_summary.tsv there" "sample,fastq_1" "s1,$A"

echo "test_input.sh: $pass passed, $fail failed"
[ "$fail" = 0 ]
