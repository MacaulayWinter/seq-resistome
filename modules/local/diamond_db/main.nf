/*
 * DIAMOND_DB: CARD's protein homolog proteins as a DIAMOND database, built
 * once per run (protein mode; CLAUDE.md D26, D27)
 *
 * From the CARD archive (UNTAR_CARD), nothing new downloaded:
 *   card_protein.dmnd              protein_fasta_protein_homolog_model.fasta,
 *                                  the same models RGI bwt searches in DNA mode
 *   card_protein_annotation.tsv    per ARO: name, AMR gene family, drug class,
 *                                  resistance mechanism (CARD's aro_index.tsv)
 *                                  and protein length
 *   card_protein_alleles.tsv       pairs of CARD proteins >= 80% identical over
 *                                  >= 90% of the longer one (DIAMOND blastp,
 *                                  all against all): allele merging at protein
 *                                  level (D22), in the columns RGI_DB writes
 */
process DIAMOND_DB {
    tag "CARD ${card_version}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/diamond:2.2.8--eed209e94c781649'

    input:
    path card               // the unpacked CARD archive
    val card_version

    output:
    path 'card_protein.dmnd',            emit: db
    path 'card_protein_annotation.tsv',  emit: annotation
    path 'card_protein_alleles.tsv',     emit: alleles
    tuple val("${task.process}"), val('diamond'), eval("diamond version | sed 's/^diamond version //'"), topic: versions
    // The CARD release inside the archive itself (card.json), so the tables'
    // stated release can be checked against what was searched.
    tuple val("${task.process}"), val('card-database'), eval("grep -o '\"_version\": *\"[^\"]*\"' ${card}/card.json | sed 's/.*: *\"//; s/\"\$//'"), topic: versions

    script:
    """
    fa=${card}/protein_fasta_protein_homolog_model.fasta
    [ -s "\$fa" ] && [ -s ${card}/aro_index.tsv ] || { echo "DIAMOND_DB: the CARD archive lacks protein_fasta_protein_homolog_model.fasta or aro_index.tsv" >&2; exit 1; }

    diamond makedb --in "\$fa" --db card_protein --threads ${task.cpus} --quiet

    # Protein lengths per ARO, then CARD's annotation of each.
    awk '/^>/ { if (a != "") print a "\\t" n; match(\$0, /ARO:[0-9]+/); a = substr(\$0, RSTART + 4, RLENGTH - 4); n = 0; next }
         { gsub(/[^A-Za-z]/, ""); n += length(\$0) } END { if (a != "") print a "\\t" n }' "\$fa" > lengths.tsv
    awk -F'\\t' -v OFS='\\t' 'NR == FNR { len[\$1] = \$2; next }
        FNR == 1 { for (i = 1; i <= NF; i++) c[\$i] = i
                   print "aro_accession", "aro_term", "amr_gene_family", "drug_class", "resistance_mechanism", "protein_length"; next }
        { a = \$c["ARO Accession"]; sub(/^ARO:/, "", a)
          if ((a in len) && !(a in done)) { done[a] = 1
            print a, \$c["ARO Name"], \$c["AMR Gene Family"], \$c["Drug Class"], \$c["Resistance Mechanism"], len[a] } }' \\
        lengths.tsv ${card}/aro_index.tsv > card_protein_annotation.tsv
    n_fa=\$(wc -l < lengths.tsv); n_an=\$(( \$(wc -l < card_protein_annotation.tsv) - 1 ))
    [ "\$n_fa" -eq "\$n_an" ] || { echo "DIAMOND_DB: \$n_fa CARD proteins but \$n_an annotated in aro_index.tsv" >&2; exit 1; }

    # Alleles (D22), at protein level.
    diamond blastp --query "\$fa" --db card_protein --threads ${task.cpus} --quiet --sensitive \\
        --id 80 --max-target-seqs 500 --evalue 1e-20 --outfmt 6 qseqid sseqid pident length qlen slen > alleles.raw.tsv
    awk -F'\\t' 'BEGIN { OFS = "\\t"; print "aro_a", "aro_b", "identity", "aln_length", "length_a", "length_b" }
        { match(\$1, /ARO:[0-9]+/); a = substr(\$1, RSTART + 4, RLENGTH - 4); match(\$2, /ARO:[0-9]+/); b = substr(\$2, RSTART + 4, RLENGTH - 4)
          if (a == b) next
          m = \$5 > \$6 ? \$5 : \$6; k = a SUBSEP b
          if (\$4 >= 0.9 * m && (!(k in best) || \$3 / 100 > best[k])) { best[k] = \$3 / 100; line[k] = a OFS b OFS \$3 / 100 OFS \$4 OFS \$5 OFS \$6 } }
        END { for (k in line) print line[k] }' alleles.raw.tsv > card_protein_alleles.tsv
    [ \$(wc -l < card_protein_alleles.tsv) -gt 1 ] || { echo "DIAMOND_DB: no allele pairs found in CARD" >&2; exit 1; }
    rm -f lengths.tsv alleles.raw.tsv
    """

    stub:
    """
    touch card_protein.dmnd
    printf 'aro_accession\\taro_term\\tamr_gene_family\\tdrug_class\\tresistance_mechanism\\tprotein_length\\n' > card_protein_annotation.tsv
    printf 'aro_a\\taro_b\\tidentity\\taln_length\\tlength_a\\tlength_b\\n' > card_protein_alleles.tsv
    """
}
