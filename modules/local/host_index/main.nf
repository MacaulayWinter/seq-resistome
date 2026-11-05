/*
 * HOST_INDEX: a bowtie2 index of the user's own host genome (--host_fasta)
 *
 * hostile's standard indexes cover human; any other host needs its own.
 * Built in hostile's own container (which has bowtie2), laid out the way
 * hostile reads its cache: <dir>/<name>.*.bt2, used as --index <name> (D6).
 */
process HOST_INDEX {
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/hostile:2.0.2--a7f5e5d341b6b94b'

    input:
    path fasta

    output:
    tuple val('host'), path('reference'), emit: index
    tuple val("${task.process}"), val('bowtie2'), eval("bowtie2-build --version | sed -n '1s/.*version //p'"), topic: versions

    script:
    """
    mkdir reference
    bowtie2-build --threads ${task.cpus} ${fasta} reference/host
    """
}
