/*
 * RGI_DB: RGI's database and kma index, built once per run (D20)
 *
 * nf-core's RGI_BWT loads CARD and indexes it again in every sample's task.
 * With CARD's variants collection (WildCARD: CARD's genes as they occur in
 * sequenced genomes, hundreds of thousands of sequences) that index takes
 * minutes and gigabytes per sample, so it is built here once and every
 * RGI_BWT task starts from a linked copy.
 *
 * variants: the cached prevalence-vX.Y.Z.tar.bz2, or [] for CARD alone.
 * Only the files rgi wildcard_annotation reads are extracted (the index of
 * variant sequences and the four *_variants.fasta files); the k-mer files,
 * the largest part of the archive, are used by rgi kmer_query, not here.
 * They are annotated under CARD's own version so that RGI's file names
 * match, and the variants release is recorded with --wildcard_version.
 *
 * Output localDB/ is what `rgi load --local` writes, plus the kma index
 * where RGI looks for it (localDB/bwt/<reference>/kma.*), so rgi bwt finds
 * it and does not rebuild it. reference.txt names the FASTA kma indexed.
 */
process RGI_DB {
    tag "${variants ? "CARD ${card_version} + variants ${variants_version}" : "CARD ${card_version}"}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/rgi_kma:e905ecb8305e2609'

    input:
    path card               // RGI_CARDANNOTATION's card_database_processed
    path variants           // prevalence archive, or []
    val card_version
    val variants_version

    output:
    path 'localDB'      , emit: db
    path 'reference.txt', emit: reference
    tuple val("${task.process}"), val('rgi'), eval("rgi main --version"), topic: versions
    tuple val("${task.process}"), val('kma'), eval("kma -v | sed 's/KMA-//'"), topic: versions

    script:
    def wild = variants ? 'yes' : ''
    """
    DB_VERSION=\$(ls ${card}/card_database_*_all.fasta | sed "s/${card}\\/card_database_v\\([0-9].*[0-9]\\).*/\\1/")
    WILD=""
    REF=card_reference
    if [ -n "${wild}" ]; then
        mkdir variants
        # Members are gzipped (./index-for-model-sequences.txt.gz ...) in
        # 4.0.2; plain or in a subfolder is accepted too. RGI wants them flat
        # and uncompressed.
        tar -xjf ${variants} -C variants --wildcards --no-anchored \\
            '*index-for-model-sequences.txt*' '*nucleotide_fasta_*_variants.fasta*'
        find variants -mindepth 2 -type f -exec mv {} variants/ \\;
        find variants -name '*.gz' -exec gunzip {} +
        for f in index-for-model-sequences.txt nucleotide_fasta_protein_homolog_model_variants.fasta; do
            [ -s variants/\$f ] || { echo "RGI_DB: ${variants} has no \$f" >&2; exit 1; }
        done
        rgi wildcard_annotation --input_directory variants --card_json ${card}/card.json --version \$DB_VERSION > wildcard_annotation.log
        WILD="--wildcard_index variants/index-for-model-sequences.txt --wildcard_version ${variants_version}
              --wildcard_annotation wildcard_database_v\$DB_VERSION.fasta
              --wildcard_annotation_all_models wildcard_database_v\$DB_VERSION\\_all.fasta"
        REF=card_wildcard_reference
    fi

    rgi load --local --debug \\
        --card_json ${card}/card.json \\
        --card_annotation ${card}/card_database_v\$DB_VERSION.fasta \\
        --card_annotation_all_models ${card}/card_database_v\$DB_VERSION\\_all.fasta \\
        \$WILD

    [ -s localDB/\$REF.fasta ] || { echo "RGI_DB: rgi load wrote no localDB/\$REF.fasta" >&2; exit 1; }
    mkdir -p localDB/bwt/\$REF/kma
    kma index -i localDB/\$REF.fasta -o localDB/bwt/\$REF/kma
    echo \$REF > reference.txt
    rm -rf variants wildcard_database_v*.fasta
    """

    stub:
    """
    mkdir -p localDB/bwt/card_reference/kma
    touch localDB/card_reference.fasta
    echo card_reference > reference.txt
    """
}
