/*
 * DIAMOND_BLASTX: reads searched against CARD's proteins (protein mode;
 * CLAUDE.md D26, D27)
 *
 * Each mate file is searched on its own (each mate counts as a read, as in
 * DNA mode), translated in all six frames, against DIAMOND_DB's database.
 * Every hit tied with a read's best bitscore is kept (--top 0, set in
 * conf/modules.config), so bin/protein_read_stats.sh can settle ties between
 * alleles. That script writes the per-ARO read statistics in the columns
 * RGI_BWT writes, and the gene table. The raw hits are deleted when the task
 * ends (conf/modules.config; D14).
 */
process DIAMOND_BLASTX {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/diamond:2.2.8--eed209e94c781649'

    input:
    tuple val(meta), path(reads, arity: '1..2')
    path db
    path annotation
    val min_read_identity   // reads below this amino-acid identity are left out (rule f70g90's first stage)

    output:
    tuple val(meta), path("*.protein_genes.tsv"), emit: genes
    tuple val(meta), path("*.read_stats.tsv")   , emit: read_stats
    tuple val("${task.process}"), val('diamond'), eval("diamond version | sed 's/^diamond version //'"), topic: versions

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def mates  = (1..reads.size()).collect { m -> "${prefix}.hits_${m}.tsv" }.join(' ')
    """
    m=0
    for r in ${reads.join(' ')}; do
        m=\$((m + 1))
        diamond blastx \\
            ${args} \\
            --query "\$r" \\
            --db ${db} \\
            --threads ${task.cpus} \\
            --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore slen \\
            --out ${prefix}.hits_\$m.tsv
    done

    protein_read_stats.sh ${prefix} ${annotation} ${min_read_identity} ${mates}
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.protein_genes.tsv ${prefix}.read_stats.tsv
    """
}
