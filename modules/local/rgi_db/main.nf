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
    tuple val("${task.process}"), val('rgi'), eval("rgi main --version"), topic: versions
    tuple val("${task.process}"), val('kma'), eval("kma -v | sed 's/KMA-//'"), topic: versions

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
    """

    stub:
    """
    mkdir -p localDB/bwt/card_reference/kma
    touch localDB/card_reference.fasta
    """
}
