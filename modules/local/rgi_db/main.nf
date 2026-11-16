/*
 * RGI_DB: RGI's CARD database and kma index, built once per run (D20)
 *
 * nf-core's RGI_BWT loaded CARD and indexed it again in every sample's
 * task; here it is done once and every RGI_BWT task starts from a linked
 * copy. Output localDB/ is what `rgi load --local` writes, plus the kma
 * index where RGI looks for it (localDB/bwt/card_reference/kma.*), so
 * rgi bwt finds it and does not rebuild it.
 *
 * CARD's variants collection (WildCARD) was built into this step and then
 * removed: in development it made every validation mark worse (CLAUDE.md
 * D20 has the evidence and the reasons).
 *
 * Also writes card_alleles.tsv (D22): every pair of CARD references at
 * >= 80% DNA identity over >= 90% of the longer one (BLASTN megablast, all
 * against all; RGI's own BLAST+). RESISTOME_TABLES uses it to count reads
 * that split between near-identical alleles under the detected one.
 */
process RGI_DB {
    tag "CARD ${card_version}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/rgi_kma:e905ecb8305e2609'

    input:
    path card               // RGI_CARDANNOTATION's card_database_processed
    val card_version

    output:
    path 'localDB', emit: db
    path 'card_alleles.tsv', emit: alleles
    tuple val("${task.process}"), val('rgi'), eval("rgi main --version"), topic: versions
    tuple val("${task.process}"), val('kma'), eval("kma -v | sed 's/KMA-//'"), topic: versions
    tuple val("${task.process}"), val('blastn'), eval("blastn -version | head -1 | sed 's/^blastn: //; s/+.*//'"), topic: versions

    script:
    """
    DB_VERSION=\$(ls ${card}/card_database_*_all.fasta | sed "s/${card}\\/card_database_v\\([0-9].*[0-9]\\).*/\\1/")
    rgi load --local --debug \\
        --card_json ${card}/card.json \\
        --card_annotation ${card}/card_database_v\$DB_VERSION.fasta \\
        --card_annotation_all_models ${card}/card_database_v\$DB_VERSION\\_all.fasta

    [ -s localDB/card_reference.fasta ] || { echo "RGI_DB: rgi load wrote no localDB/card_reference.fasta" >&2; exit 1; }
    mkdir -p localDB/bwt/card_reference/kma
    kma index -i localDB/card_reference.fasta -o localDB/bwt/card_reference/kma

    # Alleles (D22): references named by their ARO accession.
    awk '/^>/ { match(\$0, /ARO:[0-9]+/); print ">" substr(\$0, RSTART + 4, RLENGTH - 4); next } { print }' \\
        localDB/card_reference.fasta > refs_by_aro.fasta
    makeblastdb -in refs_by_aro.fasta -dbtype nucl -out refs_by_aro > /dev/null
    blastn -task megablast -query refs_by_aro.fasta -db refs_by_aro -perc_identity 80 -evalue 1e-20 \\
        -max_target_seqs 500 -num_threads ${task.cpus} -outfmt '6 qseqid sseqid pident length qlen slen' > alleles.raw.tsv
    awk -F'\\t' 'BEGIN { OFS = "\\t"; print "aro_a", "aro_b", "identity", "aln_length", "length_a", "length_b" }
        \$1 != \$2 { m = \$5 > \$6 ? \$5 : \$6; k = \$1 SUBSEP \$2
                    if (\$4 >= 0.9 * m && (!(k in best) || \$3 / 100 > best[k])) { best[k] = \$3 / 100; line[k] = \$1 OFS \$2 OFS \$3 / 100 OFS \$4 OFS \$5 OFS \$6 } }
        END { for (k in line) print line[k] }' alleles.raw.tsv > card_alleles.tsv
    [ \$(wc -l < card_alleles.tsv) -gt 1 ] || { echo "RGI_DB: no allele pairs found in CARD" >&2; exit 1; }
    rm -f refs_by_aro.* alleles.raw.tsv
    """

    stub:
    """
    mkdir -p localDB/bwt/card_reference/kma
    touch localDB/card_reference.fasta
    printf 'aro_a\\taro_b\\tidentity\\taln_length\\tlength_a\\tlength_b\\n' > card_alleles.tsv
    """
}
