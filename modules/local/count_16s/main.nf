/*
 * COUNT_16S: how many of a sample's reads come from 16S rRNA genes (D7)
 *
 * Not nf-core's SORTMERNA module: it always passes --paired_in for paired
 * reads, which counts both mates when only one matches 16S and so inflates
 * the denominator. Here every read is judged on its own (as RGI counts ARG
 * reads), from the SAM output (--num_alignments 1: one line per read):
 * reads_16s is the number of reads with an alignment; bases_16s the 16S
 * reference bases those alignments cover (CIGAR M, D, =, X). 16S copies are
 * counted from bases, not reads: a read overlapping a gene end, or a short
 * local hit, covers only part of a gene, and counting it as a whole read
 * overestimated 16S copies 1.25-1.34x (validation V1 round 1, D12, D13).
 * Reads are never written.
 */
process COUNT_16S {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/sortmerna:4.3.7--b730cad73fc42b8e'

    input:
    tuple val(meta), path(reads)
    path refs
    path index

    output:
    tuple val(meta), path("${meta.id}.16s.tsv"), emit: counts
    tuple val(meta), path("${meta.id}.16s.log"), emit: log
    tuple val("${task.process}"), val('sortmerna'), eval('sortmerna --version 2>&1 | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+" | head -1'), topic: versions

    script:
    def prefix = meta.id
    """
    sortmerna --index 0 \\
        ${refs.collect { r -> "--ref ${r}" }.join(' ')} \\
        --idx-dir ${index} \\
        ${[ reads ].flatten().collect { r -> "--reads ${r}" }.join(' ')} \\
        --workdir smr \\
        --aligned ${prefix}.16s \\
        --sam --num_alignments 1 \\
        --threads ${task.cpus}
    read n16 b16 < <(gzip -cdf ${prefix}.16s.sam* | awk '!/^@/ { n++; c = \$6
        while (match(c, /[0-9]+[MDX=]/)) { b += substr(c, RSTART, RLENGTH - 1); c = substr(c, RSTART + RLENGTH) } }
        END { print n + 0, b + 0 }')
    seen=\$(sed -n 's/.*Total reads = \\([0-9]*\\).*/\\1/p' ${prefix}.16s.log | head -1)
    printf 'sample\\treads_16s\\tbases_16s\\treads_seen\\n%s\\t%s\\t%s\\t%s\\n' ${prefix} "\$n16" "\$b16" "\$seen" > ${prefix}.16s.tsv
    rm -f ${prefix}.16s.sam*
    """
}
