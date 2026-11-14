#!/usr/bin/env bash
#*******************************************************************************
# run_V2.sh: validation V2, end to end (PREREGISTRATION.md; protein mode, rule "or")
#
# Applies the pre-registered data rules (section 3), builds the samples, the
# truth and the simulated depths, runs the pipeline (marks 1-4 with score_V2.R,
# mark 5 the CARD cache) and E4. Written from run_round4.sh. Each step skips
# work already done, so it can be run again after an interruption.
#
# Refuses to start while the pre-registration is a draft or changed since its
# commit, or if the pipeline files differ from the commit it names.
#
# Data rules, as written (section 3):
#   spikes      per species (Citrobacter freundii 546, Pseudomonas aeruginosa 287,
#               Acinetobacter baumannii 470, Enterococcus faecium 1352): RefSeq
#               Complete Genome assemblies released on or after the in-force date
#               (2026-11-14), else the window one month earlier, and so on back;
#               ordered by accession, set.seed(20261111), sample(), the first.
#   backgrounds per type, candidates_<type>.tsv in draw order after the run V1
#               round 4 used; the first paired-end Illumina run that can be
#               fetched; its first 1,000,000 pairs
#   simulation  ART seed 20261111; E3 = HG002 (SRR37356339) pairs 800,001-1,000,000;
#               E4 = V2's first spike genome
#
# Usage:  [PROFILE=docker,arm64] bash validation/V2/run_V2.sh <V2 scratch dir> <seq-triage repo> <kraken2 db dir>
#*******************************************************************************
set -euo pipefail
v2=$(mkdir -p "$1" && cd "$1" && pwd); triage_src=$(cd "$2" && pwd); k2=$(cd "$3" && pwd)
repo=$(cd "$(dirname "$0")/../.." && pwd); here="$repo/validation/V1"; hv2="$repo/validation/V2"
export PROFILE=${PROFILE:-docker,arm64}
card=${CARD_ARCHIVE:-$HOME/.seq-resistome/card/broadstreet-v4.0.2.tar.bz2}
E1E2_GENOMES=${E1E2_GENOMES:-$HOME/seqresistome-scratch/V1r3/genomes}
TRIAGE_COMMIT=fbf74dd
PIPELINE_COMMIT=f20ef13
IN_FORCE=2026-11-14
R_IMAGE=docker.io/rocker/r-ver:4.5.2@sha256:fd4ccdd3a4a6f7ef805e2daeee2a0fe3bf126bc231f36351223baecf5a595a4c
SPECIES="546:Citrobacter_freundii 287:Pseudomonas_aeruginosa 470:Acinetobacter_baumannii 1352:Enterococcus_faecium"
CONF=(-c "$hv2/v2.config")
log() { echo "== $(date '+%Y-%m-%d %H:%M') $*"; }

grep -q "IN FORCE from the commit that contains this sentence" "$hv2/PREREGISTRATION.md" ||
    { echo "run_V2.sh: PREREGISTRATION.md is not in force; commit it in force first." >&2; exit 1; }
git -C "$repo" diff --quiet HEAD -- "$hv2/PREREGISTRATION.md" "$hv2/score_V2.R" ||
    { echo "run_V2.sh: PREREGISTRATION.md or score_V2.R has uncommitted changes." >&2; exit 1; }
git -C "$repo" merge-base --is-ancestor "$PIPELINE_COMMIT" HEAD || { echo "run_V2.sh: $PIPELINE_COMMIT is not in this history." >&2; exit 1; }
git -C "$repo" diff --quiet "$PIPELINE_COMMIT" HEAD -- main.nf nextflow.config nextflow_schema.json bin conf modules subworkflows workflows assets lib ||
    { echo "run_V2.sh: pipeline files differ from the pre-registered commit $PIPELINE_COMMIT." >&2; exit 1; }
git -C "$repo" diff --quiet HEAD -- main.nf nextflow.config bin conf modules subworkflows workflows assets ||
    { echo "run_V2.sh: pipeline files have uncommitted changes." >&2; exit 1; }
prereg_commit=$(git -C "$repo" log -1 --format=%H -- validation/V2/PREREGISTRATION.md)
{ echo "date: $(date '+%F %T')"; echo "pipeline commit under test: $PIPELINE_COMMIT (HEAD $(git -C "$repo" rev-parse --short HEAD))"
  echo "pre-registration commit: $prereg_commit"
  echo "PREREGISTRATION.md sha256: $( (shasum -a 256 "$hv2/PREREGISTRATION.md" 2>/dev/null || sha256sum "$hv2/PREREGISTRATION.md") | cut -d' ' -f1)"
  echo "score_V2.R sha256: $( (shasum -a 256 "$hv2/score_V2.R" 2>/dev/null || sha256sum "$hv2/score_V2.R") | cut -d' ' -f1)"; } | tee -a "$v2/V2_run_record.txt"
mkdir -p "$v2/genomes" "$v2/reads" "$v2/truth"

# 1. Spike genomes: list, draw, fetch ---------------------------------------------------
if [ ! -s "$v2/genomes_V2.tsv" ]; then
    printf 'species\ttaxid\taccession\torganism\trelease_date\twindow_start\twindow_months_back\tn_candidates\tdraw\n' > "$v2/genomes_V2.tsv"
    for sp in $SPECIES; do
        taxid=${sp%%:*}; name=${sp##*:}
        python3 -I - "$taxid" "$IN_FORCE" "$v2/candidates_${name}.tsv" <<'PY'
import sys, json, urllib.request, datetime, calendar
taxid, in_force, out = sys.argv[1], datetime.date.fromisoformat(sys.argv[2]), sys.argv[3]
def back(d, k):
    m = d.month - 1 - k; y = d.year + m // 12; m = m % 12 + 1
    return datetime.date(y, m, min(d.day, calendar.monthrange(y, m)[1]))
def fetch(start, end):
    rows, tok = [], ""
    while True:
        u = ("https://api.ncbi.nlm.nih.gov/datasets/v2/genome/taxon/%s/dataset_report?filters.assembly_source=refseq"
             "&filters.assembly_level=complete_genome&filters.first_release_date=%sT00:00:00.000Z&filters.last_release_date=%sT23:59:59.000Z&page_size=1000%s"
             % (taxid, start, end, ("&page_token=" + tok) if tok else ""))
        d = json.load(urllib.request.urlopen(u, timeout=120))
        for r in d.get("reports", []):
            a = r["assembly_info"]
            if r["accession"].startswith("GCF_") and a.get("assembly_level") == "Complete Genome" and start <= a.get("release_date", "") <= end:
                rows.append((r["accession"], r["organism"].get("organism_name", ""), a["release_date"]))
        tok = d.get("next_page_token", "")
        if not tok: return rows
today = datetime.date.today()
for k in range(0, 60):
    start = back(in_force, k); end = today if k == 0 else back(in_force, k - 1) - datetime.timedelta(days=1)
    rows = sorted(set(fetch(start.isoformat(), end.isoformat())))
    if rows: break
else:
    sys.exit("no Complete Genome RefSeq assembly in 60 months")
with open(out, "w") as f:
    f.write("accession\torganism\trelease_date\twindow_start\twindow_months_back\n")
    for r in rows: f.write("%s\t%s\t%s\t%s\t%d\n" % (r + (start.isoformat(), k)))
PY
        docker run --rm -u "$(id -u):$(id -g)" -v "$v2:/v" -w /v "$R_IMAGE" Rscript -e '
            x <- read.delim("candidates_'"$name"'.tsv", stringsAsFactors = FALSE); x <- x[order(x$accession), ]
            set.seed(20261111); x$draw <- NA_integer_; x$draw[sample(nrow(x))] <- seq_len(nrow(x)); x <- x[order(x$draw), ]
            write.table(x, "candidates_'"$name"'.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
        awk -F'\t' -v sp="$name" -v tx="$taxid" 'NR == 2 { printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%s\n", sp, tx, $1, $2, $3, $4, $5, n, $6 } END {}' n="$(($(wc -l < "$v2/candidates_${name}.tsv") - 1))" \
            "$v2/candidates_${name}.tsv" >> "$v2/genomes_V2.tsv"
    done
fi
spikes=$(awk -F'\t' 'NR > 1 { printf "%s%s", (NR > 2 ? "," : ""), $3 }' "$v2/genomes_V2.tsv")
log "1. spikes: $spikes"; cat "$v2/genomes_V2.tsv"
fetch_genome() {   # fetch_genome <accession>
    local g=$1 d; [ -s "$v2/genomes/$g.fna" ] && return
    d=$(mktemp -d)
    curl -sSfL -o "$d/g.zip" "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$g/download?include_annotation_type=GENOME_FASTA"
    unzip -q -o "$d/g.zip" -d "$d"; cat "$d"/ncbi_dataset/data/"$g"/*.fna > "$v2/genomes/$g.fna"; rm -rf "$d"
    [ "$(grep -c '^>' "$v2/genomes/$g.fna")" -ge 1 ] || { echo "run_V2.sh: $g downloaded no sequence" >&2; exit 1; }
}
for g in ${spikes//,/ }; do fetch_genome "$g"; done
for g in NC_000908.2 NC_001416.1; do
    if [ -s "$E1E2_GENOMES/$g.fna" ]; then cp -n "$E1E2_GENOMES/$g.fna" "$v2/genomes/"; else fetch_genome "$g"; fi
done

# 2. Backgrounds and E3 -----------------------------------------------------------------
: > "$v2/backgrounds_V2.tsv.new"
for t in human_gut:gut:SRR34941164 wastewater:wastewater:SRR20705917; do
    type=${t%%:*}; rest=${t#*:}; short=${rest%%:*}; r4=${rest##*:}   # r4: the run V1 round 4 used
    [ -s "$v2/reads/bg_${short}_1.fastq.gz" ] && continue
    picked=""
    while IFS=$'\t' read -r run model ftp; do
        case $model in *Illumina*|*NextSeq*|*NovaSeq*|*HiSeq*|*MiSeq*) ;; *) echo "  $run: $model, not Illumina; next"; continue ;; esac
        case $ftp in *_1.fastq.gz*_2.fastq.gz*) ;; *) echo "  $run: not paired-end; next"; continue ;; esac
        if bash "$here/fetch_reads.sh" "$run" 1000000 "$v2/reads/bg_${short}"; then picked=$run; break; fi
        echo "  $run: could not be fetched; next"
    done < <(awk -F'\t' -v r4="$r4" 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next }
                         { r[$h["draw"]] = $h["run_accession"] "\t" $h["instrument_model"] "\t" $h["fastq_ftp"]; if ($h["run_accession"] == r4) d4 = $h["draw"] }
                         END { for (d = d4 + 1; d in r; d++) print r[d] }' "$here/candidates_${type}.tsv")
    [ -n "$picked" ] || { echo "run_V2.sh: no $type background could be fetched" >&2; exit 1; }
    printf '%s\t%s\n' "$type" "$picked" >> "$v2/backgrounds_V2.tsv"
done
rm -f "$v2/backgrounds_V2.tsv.new"
log "2. backgrounds: $(tr '\n' ' ' < "$v2/backgrounds_V2.tsv")"
[ -s "$v2/reads/E3_host_1.fastq.gz" ] || SKIP=800000 bash "$here/fetch_reads.sh" SRR37356339 200000 "$v2/reads/E3_host"

# 3. Samples (ART seed 20261111) ----------------------------------------------------------
log "3. samples"
SEED=20261111 bash "$here/build_samples.sh" "$v2/genomes" "$v2/reads" "$spikes"

# 4. Truth ------------------------------------------------------------------------------------
log "4. truth"
bash "$here/truth.sh" "$v2/genomes" "$card" "$v2/truth"
bash "$here/truth_findable.sh" "$v2/truth" "$card"
bash "$here/locate.sh" "$v2/genomes" "$v2/truth"

# 5. Simulated depth ------------------------------------------------------------------------
log "5. simulated depth"
bash "$here/simulated_depth.sh" "$v2"

# 6. Pipeline (protein mode, defaults), marks 1-4 (score_V2.R) and mark 5 (the CARD cache) --------
log "6. pipeline, marks 1-5"
SCORER=../V2/score_V2.R bash "$here/run_V1.sh" "$v2" "${CONF[@]}"

# 7. E4 ---------------------------------------------------------------------------------------
log "7. E4"
if [ ! -d "$v2/seq-triage" ]; then
    git clone -q "$triage_src" "$v2/seq-triage"; git -C "$v2/seq-triage" checkout -q "$TRIAGE_COMMIT"
fi
E4_GENOME=${spikes%%,*} bash "$here/run_E4.sh" "$v2" "$v2/seq-triage" "$k2" -c "$hv2/v2_e4.config"
log "done"
