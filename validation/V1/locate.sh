#!/usr/bin/env bash
#*******************************************************************************
# locate.sh: where each CARD gene lies in each genome (V1 round 3,
#            PREREGISTRATION_round3.md section 2)
#
# Every CARD 4.0.2 protein homolog reference is searched against the genome
# with BLASTN 2.17.0 (-task blastn, e-value 1e-10). Writes every HSP of
# >= 80% identity: the ARO, the reference length, and where it lies
# (contig, start, end). score_V1_round3.R decides "lies at a locus" and "is
# present" from this table.
#
# Usage:  bash validation/V1/locate.sh <genomes_dir> <truth_dir> [genome ...]
#         needs <truth_dir>/blastdb/nucleotide_fasta_protein_homolog_model.fasta
#         (made by truth_findable.sh); writes <truth_dir>/<genome>.locate.tsv
#*******************************************************************************
set -euo pipefail
gdir=$(cd "$1" && pwd); tdir=$(cd "$2" && pwd); shift 2
BLAST_IMAGE=quay.io/biocontainers/blast:2.17.0--hb02a186_1
blast() { docker run --rm --platform linux/amd64 -u "$(id -u):$(id -g)" -v "$gdir:/g:ro" -v "$tdir:/t" -w /t "$BLAST_IMAGE" "$@"; }
genomes=${*:-$(ls "$gdir" | sed -n 's/\.fna$//p')}
# Name each reference <ARO>_<n>: BLAST shortens "gb|...|ARO:...|name" names
# to the GenBank accession, which would lose the ARO.
awk '/^>/ { match($0, /ARO:[0-9]+/); print ">" substr($0, RSTART + 4, RLENGTH - 4) "_" ++n; next } { print }' \
    "$tdir/blastdb/nucleotide_fasta_protein_homolog_model.fasta" > "$tdir/blastdb/card_refs_by_aro.fasta"
for g in $genomes; do
    blast makeblastdb -in "/g/$g.fna" -dbtype nucl -out "blastdb/genome_$g" > /dev/null
    blast blastn -task blastn -query blastdb/card_refs_by_aro.fasta -db "blastdb/genome_$g" \
        -evalue 1e-10 -perc_identity 80 -max_target_seqs 50 -num_threads 6 \
        -outfmt '6 qseqid qlen sseqid sstart send pident length' > "$tdir/$g.locate.raw.tsv"
    # The ARO is the reference name up to its last underscore.
    awk -F'\t' 'BEGIN { OFS = "\t"; print "aro_accession", "ref_length", "contig", "start", "end", "identity", "aln_length" }
                { aro = $1; sub(/_[0-9]+$/, "", aro)
                  s = $4 < $5 ? $4 : $5; e = $4 < $5 ? $5 : $4
                  print aro, $2, $3, s, e, $6, $7 }' "$tdir/$g.locate.raw.tsv" > "$tdir/$g.locate.tsv"
    rm "$tdir/$g.locate.raw.tsv"
    echo "$g: $(($(wc -l < "$tdir/$g.locate.tsv") - 1)) HSPs >= 80% identity"
done
