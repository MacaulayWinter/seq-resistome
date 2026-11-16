#!/usr/bin/env bash
#*******************************************************************************
# run_V3.sh: validation V3, end to end (PREREGISTRATION.md; protein mode, identity band)
#
# Applies the pre-registered data rules (section 3), builds the samples, the
# truth and the simulated depths, runs the pipeline (marks 1-4 with score_V3.R,
# mark 5 the CARD cache) and E4. Written from run_round4.sh. Each step skips
# work already done, so it can be run again after an interruption.
#
# Refuses to start while the pre-registration is a draft or changed since its
# commit, before Addendum A, or if the pipeline files differ from the commit
# Addendum A names.
#
# Data rules, as written (section 3):
#   spikes      per species (Serratia marcescens 615, Staphylococcus aureus 1280,
#               Stenotrophomonas maltophilia 40324, Salmonella enterica 28901): RefSeq
#               Complete Genome assemblies released on or after the in-force date
#               (2026-11-14), else the window one month earlier, and so on back;
#               ordered by accession, set.seed(20261115), sample(), the first.
#   backgrounds per type, candidates_<type>.tsv in draw order after the run V2
#               used; the first paired-end Illumina run that can be fetched;
#               its first 1,000,000 pairs
#   simulation  ART seed 20261115; E3 = HG002 (SRR37356339) pairs 1,000,001-1,200,000;
#               E4 = V3's first spike genome
#
# Usage:  [PROFILE=docker,arm64] bash validation/V3/run_V3.sh <V3 scratch dir> <seq-triage repo> <kraken2 db dir>
#*******************************************************************************
set -euo pipefail
v3=$(mkdir -p "$1" && cd "$1" && pwd); triage_src=$(cd "$2" && pwd); k2=$(cd "$3" && pwd)
repo=$(cd "$(dirname "$0")/../.." && pwd); here="$repo/validation/V1"; hv3="$repo/validation/V3"
export PROFILE=${PROFILE:-docker,arm64}
card=${CARD_ARCHIVE:-$HOME/.seq-resistome/card/broadstreet-v4.0.2.tar.bz2}
E1E2_GENOMES=${E1E2_GENOMES:-$HOME/seqresistome-scratch/V1r3/genomes}
TRIAGE_COMMIT=fbf74dd
PIPELINE_COMMIT=93eb4e8
IN_FORCE=2026-11-14
R_IMAGE=docker.io/rocker/r-ver:4.5.2@sha256:fd4ccdd3a4a6f7ef805e2daeee2a0fe3bf126bc231f36351223baecf5a595a4c
SPECIES="615:Serratia_marcescens 1280:Staphylococcus_aureus 40324:Stenotrophomonas_maltophilia 28901:Salmonella_enterica"
CONF=(-c "$hv3/v3.config")
log() { echo "== $(date '+%Y-%m-%d %H:%M') $*"; }

grep -q "IN FORCE from the commit that contains this sentence" "$hv3/PREREGISTRATION.md" ||
    { echo "run_V3.sh: PREREGISTRATION.md is not in force; commit it in force first." >&2; exit 1; }
[ "$PIPELINE_COMMIT" != "__ADDENDUM_A__" ] && [ -s "$hv3/ADDENDUM_A.md" ] ||
    { echo "run_V3.sh: Addendum A is not committed (no pipeline commit named)." >&2; exit 1; }
git -C "$repo" diff --quiet HEAD -- "$hv3/PREREGISTRATION.md" "$hv3/ADDENDUM_A.md" "$hv3/score_V3.R" "$hv3/repeats.sh" ||
    { echo "run_V3.sh: PREREGISTRATION.md, ADDENDUM_A.md, score_V3.R or repeats.sh has uncommitted changes." >&2; exit 1; }
git -C "$repo" merge-base --is-ancestor "$PIPELINE_COMMIT" HEAD || { echo "run_V3.sh: $PIPELINE_COMMIT is not in this history." >&2; exit 1; }
git -C "$repo" diff --quiet "$PIPELINE_COMMIT" HEAD -- main.nf nextflow.config nextflow_schema.json bin conf modules subworkflows workflows assets lib ||
    { echo "run_V3.sh: pipeline files differ from the pre-registered commit $PIPELINE_COMMIT." >&2; exit 1; }
git -C "$repo" diff --quiet HEAD -- main.nf nextflow.config bin conf modules subworkflows workflows assets ||
    { echo "run_V3.sh: pipeline files have uncommitted changes." >&2; exit 1; }
prereg_commit=$(git -C "$repo" log -1 --format=%H -- validation/V3/PREREGISTRATION.md)
{ echo "date: $(date '+%F %T')"; echo "pipeline commit under test: $PIPELINE_COMMIT (HEAD $(git -C "$repo" rev-parse --short HEAD))"
  echo "pre-registration commit: $prereg_commit"
  echo "PREREGISTRATION.md sha256: $( (shasum -a 256 "$hv3/PREREGISTRATION.md" 2>/dev/null || sha256sum "$hv3/PREREGISTRATION.md") | cut -d' ' -f1)"
  echo "ADDENDUM_A.md sha256: $( (shasum -a 256 "$hv3/ADDENDUM_A.md" 2>/dev/null || sha256sum "$hv3/ADDENDUM_A.md") | cut -d' ' -f1)"
  echo "score_V3.R sha256: $( (shasum -a 256 "$hv3/score_V3.R" 2>/dev/null || sha256sum "$hv3/score_V3.R") | cut -d' ' -f1)"; } | tee -a "$v3/V3_run_record.txt"
mkdir -p "$v3/genomes" "$v3/reads" "$v3/truth"

# 1. Spike genomes: list, draw, fetch ---------------------------------------------------
if [ ! -s "$v3/genomes_V3.tsv" ]; then
    printf 'species\ttaxid\taccession\torganism\trelease_date\twindow_start\twindow_months_back\tn_candidates\tdraw\n' > "$v3/genomes_V3.tsv"
    for sp in $SPECIES; do
        taxid=${sp%%:*}; name=${sp##*:}
        python3 -I - "$taxid" "$IN_FORCE" "$v3/candidates_${name}.tsv" <<'PY'
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
        docker run --rm -u "$(id -u):$(id -g)" -v "$v3:/v" -w /v "$R_IMAGE" Rscript -e '
            x <- read.delim("candidates_'"$name"'.tsv", stringsAsFactors = FALSE); x <- x[order(x$accession), ]
            set.seed(20261115); x$draw <- NA_integer_; x$draw[sample(nrow(x))] <- seq_len(nrow(x)); x <- x[order(x$draw), ]
            write.table(x, "candidates_'"$name"'.tsv", sep = "\t", quote = FALSE, row.names = FALSE)'
        awk -F'\t' -v sp="$name" -v tx="$taxid" 'NR == 2 { printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%d\t%s\n", sp, tx, $1, $2, $3, $4, $5, n, $6 } END {}' n="$(($(wc -l < "$v3/candidates_${name}.tsv") - 1))" \
            "$v3/candidates_${name}.tsv" >> "$v3/genomes_V3.tsv"
    done
fi
spikes=$(awk -F'\t' 'NR > 1 { printf "%s%s", (NR > 2 ? "," : ""), $3 }' "$v3/genomes_V3.tsv")
log "1. spikes: $spikes"; cat "$v3/genomes_V3.tsv"
fetch_genome() {   # fetch_genome <accession>
    local g=$1 d; [ -s "$v3/genomes/$g.fna" ] && return
    d=$(mktemp -d)
    curl -sSfL -o "$d/g.zip" "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/$g/download?include_annotation_type=GENOME_FASTA"
    unzip -q -o "$d/g.zip" -d "$d"; cat "$d"/ncbi_dataset/data/"$g"/*.fna > "$v3/genomes/$g.fna"; rm -rf "$d"
    [ "$(grep -c '^>' "$v3/genomes/$g.fna")" -ge 1 ] || { echo "run_V3.sh: $g downloaded no sequence" >&2; exit 1; }
}
for g in ${spikes//,/ }; do fetch_genome "$g"; done
for g in NC_000908.2 NC_001416.1; do
    if [ -s "$E1E2_GENOMES/$g.fna" ]; then cp -n "$E1E2_GENOMES/$g.fna" "$v3/genomes/"; else fetch_genome "$g"; fi
done

# 2. Backgrounds and E3 -----------------------------------------------------------------
: > "$v3/backgrounds_V3.tsv.new"
for t in human_gut:gut:SRR13839986 wastewater:wastewater:SRR11809761; do
    type=${t%%:*}; rest=${t#*:}; short=${rest%%:*}; r4=${rest##*:}   # r4: the run V2 used
    [ -s "$v3/reads/bg_${short}_1.fastq.gz" ] && continue
    picked=""
    while IFS=$'\t' read -r run model ftp; do
        case $model in *Illumina*|*NextSeq*|*NovaSeq*|*HiSeq*|*MiSeq*) ;; *) echo "  $run: $model, not Illumina; next"; continue ;; esac
        case $ftp in *_1.fastq.gz*_2.fastq.gz*) ;; *) echo "  $run: not paired-end; next"; continue ;; esac
        if bash "$here/fetch_reads.sh" "$run" 1000000 "$v3/reads/bg_${short}"; then picked=$run; break; fi
        echo "  $run: could not be fetched; next"
    done < <(awk -F'\t' -v r4="$r4" 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next }
                         { r[$h["draw"]] = $h["run_accession"] "\t" $h["instrument_model"] "\t" $h["fastq_ftp"]; if ($h["run_accession"] == r4) d4 = $h["draw"] }
                         END { for (d = d4 + 1; d in r; d++) print r[d] }' "$here/candidates_${type}.tsv")
    [ -n "$picked" ] || { echo "run_V3.sh: no $type background could be fetched" >&2; exit 1; }
    printf '%s\t%s\n' "$type" "$picked" >> "$v3/backgrounds_V3.tsv"
done
rm -f "$v3/backgrounds_V3.tsv.new"
log "2. backgrounds: $(tr '\n' ' ' < "$v3/backgrounds_V3.tsv")"
[ -s "$v3/reads/E3_host_1.fastq.gz" ] || SKIP=1000000 bash "$here/fetch_reads.sh" SRR37356339 200000 "$v3/reads/E3_host"

# 3. Samples (ART seed 20261111) ----------------------------------------------------------
log "3. samples"
SEED=20261115 bash "$here/build_samples.sh" "$v3/genomes" "$v3/reads" "$spikes"

# 4. Truth ------------------------------------------------------------------------------------
log "4. truth"
bash "$here/truth.sh" "$v3/genomes" "$card" "$v3/truth"
bash "$here/truth_findable.sh" "$v3/truth" "$card"
bash "$here/locate.sh" "$v3/genomes" "$v3/truth"
bash "$hv3/repeats.sh" "$v3/genomes" "$v3/truth" ${spikes//,/ }   # V3: loci with another copy in their genome (mark 3)

# 5. Simulated depth ------------------------------------------------------------------------
log "5. simulated depth"
bash "$here/simulated_depth.sh" "$v3"

# 6. Pipeline (protein mode, defaults), marks 1-4 (score_V3.R) and mark 5 (the CARD cache) --------
log "6. pipeline, marks 1-5"
SCORER=../V3/score_V3.R bash "$here/run_V1.sh" "$v3" "${CONF[@]}"

# 7. E4 ---------------------------------------------------------------------------------------
log "7. E4"
if [ ! -d "$v3/seq-triage" ]; then
    git clone -q "$triage_src" "$v3/seq-triage"; git -C "$v3/seq-triage" checkout -q "$TRIAGE_COMMIT"
fi
E4_GENOME=${spikes%%,*} bash "$here/run_E4.sh" "$v3" "$v3/seq-triage" "$k2" -c "$hv3/v3_e4.config"
log "done"
