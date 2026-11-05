/*
 * SORTMERNA_INDEX: index the 16S references once per run (D7)
 */
process SORTMERNA_INDEX {
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/sortmerna:4.3.7--b730cad73fc42b8e'

    input:
    path refs

    output:
    path 'idx', emit: index
    tuple val("${task.process}"), val('sortmerna'), eval('sortmerna --version 2>&1 | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+" | head -1'), topic: versions

    script:
    """
    sortmerna --index 1 ${refs.collect { r -> "--ref ${r}" }.join(' ')} --idx-dir idx --workdir . --threads ${task.cpus}
    """
}
