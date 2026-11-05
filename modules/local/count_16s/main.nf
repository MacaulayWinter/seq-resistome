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
 * Two further corrections (D20): alignments covering fewer than
 * min_16s_bases reference bases are not counted (short local hits, often
 * from other genes, were ~3% of bases), and each alignment counts as its
 * covered bases divided by the length of the SILVA reference it hit, not a
 * fixed 1,542 bp (SILVA references run from ~1,200 to over 1,800 bp, which
 * biased copies by ~3%). copies_16s is that sum.
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
    val min_16s_bases

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
    # SortMeRNA's SAM has no @SQ lines: reference lengths come from the
    # SILVA FASTA files (first word of each header, as in the SAM).
    awk '/^>/ { if (id != "") print id "\\t" l; id = substr(\$1, 2); l = 0; next } { l += length(\$0) }
         END { if (id != "") print id "\\t" l }' ${refs.join(' ')} > ref_lengths.tsv
    gzip -cdf ${prefix}.16s.sam* | awk -F'\\t' -v minb=${min_16s_bases} '
        BEGIN { while ((getline line < "ref_lengths.tsv") > 0) { split(line, f, "\\t"); len[f[1]] = f[2] } }
        /^@/ { next }
        { c = \$6; al = 0
          while (match(c, /[0-9]+[MDX=]/)) { al += substr(c, RSTART, RLENGTH - 1); c = substr(c, RSTART + RLENGTH) }
          if (al < minb) { s++; next }
          if (!(\$3 in len)) { print "COUNT_16S: reference " \$3 " is not in the 16S reference FASTA" > "/dev/stderr"; exit 1 }
          n++; b += al; cp += al / len[\$3] }
        END { printf "%d %d %.6f %d\\n", n, b, cp, s }' > counts.txt
    read n16 b16 c16 short16 < counts.txt
    seen=\$(sed -n 's/.*Total reads = \\([0-9]*\\).*/\\1/p' ${prefix}.16s.log | head -1)
    printf 'sample\\treads_16s\\tbases_16s\\tcopies_16s\\tshort_16s\\treads_seen\\n%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' ${prefix} "\$n16" "\$b16" "\$c16" "\$short16" "\$seen" > ${prefix}.16s.tsv
    rm -f ${prefix}.16s.sam* ref_lengths.tsv counts.txt
    """
}
