/*
 * RGI_BWT: reads mapped to CARD (and its variants) by rgi bwt with kma
 *
 * Replaces nf-core's RGI_BWT (D20), which loaded and indexed CARD in every
 * task: here each task starts from RGI_DB's database, linked in (cp -rs:
 * every file a link, so nothing is copied and RGI's own new files land in
 * this task's folder). rgi bwt finds the kma index and does not rebuild it.
 *
 * Also writes per-reference read statistics (bin/rgi_read_stats.sh; D19,
 * D20) against the same FASTA kma aligned to. RGI's SAM/BAM files and the
 * linked database are deleted when the task ends (conf/modules.config; D14).
 */
process RGI_BWT {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/rgi_kma:e905ecb8305e2609'

    input:
    tuple val(meta), path(reads, arity: '1..2')
    path db, name: 'rgi_db'
    val reference           // card_reference or card_wildcard_reference (RGI_DB)

    output:
    tuple val(meta), path("*.json")          , emit: json
    tuple val(meta), path("*.txt")           , emit: tsv
    tuple val(meta), path("*.read_stats.tsv"), emit: read_stats
    tuple val("${task.process}"), val('rgi'), eval("rgi main --version"), topic: versions
    tuple val("${task.process}"), val('kma'), eval("kma -v | sed 's/KMA-//'"), topic: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def wild   = reference == 'card_wildcard_reference' ? '--include_wildcard' : ''
    def r2     = reads.size() > 1 ? "--read_two ${reads[1]}" : ''
    """
    cp -rs "\$(readlink -f rgi_db)" localDB

    rgi bwt \\
        ${args} \\
        ${wild} \\
        --local \\
        --threads ${task.cpus} \\
        --output_file ${prefix} \\
        --read_one ${reads[0]} \\
        ${r2}

    rgi_read_stats.sh ${prefix}.sorted.temp.bam localDB/${reference}.fasta > ${prefix}.read_stats.tsv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.allele_mapping_data.json ${prefix}.gene_mapping_data.txt ${prefix}.read_stats.tsv
    """
}
