#!/usr/bin/env bash
#*******************************************************************************
# truth_findable.sh: which truth genes reads can find (V1 round 2,
#                    PREREGISTRATION_round2.md section 1)
#
# For each <genome>.strict.txt from truth.sh: the predicted DNA of every
# Perfect/Strict protein homolog hit is searched with BLASTN (2.17.0,
# -task blastn) against CARD's protein homolog reference DNA. A hit is
# findable if one HSP has >= 80% identity over >= 80% of the gene's length;
# otherwise it is protein-only (listed, never scored).
#
# Usage:  bash validation/V1/truth_findable.sh <truth_dir> <card_archive.tar.bz2> [genome ...]
#         writes <truth_dir>/<genome>.findable.tsv
#*******************************************************************************
set -euo pipefail
tdir=$(cd "$1" && pwd); card=$(cd "$(dirname "$2")" && pwd)/$(basename "$2"); shift 2
BLAST_IMAGE=quay.io/biocontainers/blast:2.17.0--hb02a186_1
mkdir -p "$tdir/blastdb"
tar -xjf "$card" -C "$tdir/blastdb" ./nucleotide_fasta_protein_homolog_model.fasta
blast() { docker run --rm --platform linux/amd64 -u "$(id -u):$(id -g)" -v "$tdir:/t" -w /t "$BLAST_IMAGE" "$@"; }
blast makeblastdb -in blastdb/nucleotide_fasta_protein_homolog_model.fasta -dbtype nucl -out blastdb/card_homolog > /dev/null
genomes=${*:-$(ls "$tdir" | sed -n 's/\.strict\.txt$//p')}
for g in $genomes; do
    # Perfect/Strict protein homolog hits: ORF_ID and Predicted_DNA, by header name.
    awk -F'\t' 'NR == 1 { for (i = 1; i <= NF; i++) h[$i] = i; next }
                $h["Model_type"] == "protein homolog model" && ($h["Cut_Off"] == "Perfect" || $h["Cut_Off"] == "Strict") {
                    id = $h["ORF_ID"]; sub(/ .*/, "", id); print ">" id; print $h["Predicted_DNA"] }' \
        "$tdir/$g.strict.txt" > "$tdir/$g.truth_genes.fna"
    blast blastn -task blastn -query "$g.truth_genes.fna" -db blastdb/card_homolog -outfmt '6 qseqid sseqid pident length qlen' \
        -max_target_seqs 50 -evalue 1e-10 > "$tdir/$g.blastn.tsv"
    awk -F'\t' 'FNR == NR { if (/^>/) q[substr($0, 2)] = 1; next }
                { if ($3 >= 80 && $4 >= 0.8 * $5) ok[$1] = 1; if ($3 > best[$1]) { best[$1] = $3; cov[$1] = $4 / $5 } }
                END { print "orf_id\tbest_identity\tbest_cover\tfindable"
                      for (k in q) printf "%s\t%s\t%s\t%s\n", k, (k in best) ? best[k] : "NA", (k in cov) ? sprintf("%.3f", cov[k]) : "NA", (k in ok) ? "TRUE" : "FALSE" }' \
        "$tdir/$g.truth_genes.fna" "$tdir/$g.blastn.tsv" > "$tdir/$g.findable.tsv"
    echo "$g: $(grep -c TRUE "$tdir/$g.findable.tsv" || true) findable, $(grep -c FALSE "$tdir/$g.findable.tsv" || true) protein-only"
done
