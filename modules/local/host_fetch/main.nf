/*
 * HOST_FETCH: fetch a hostile standard index once, into a cache kept
 * between runs (D6)
 *
 * Not nf-core's HOSTILE_FETCH: Nextflow's storeDir (the permanent cache:
 * the task is skipped when the folder already holds its outputs) only
 * accepts plain file outputs, and the nf-core module also reports its
 * version through an eval output (found by the first run with the default
 * human index, D6). hostile's version is recorded by HOSTILE_CLEAN.
 * Only the bowtie2 index is fetched: short reads always use bowtie2.
 */
process HOST_FETCH {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/hostile:2.0.2--a7f5e5d341b6b94b'

    input:
    val index_name

    output:
    path 'reference', emit: reference

    script:
    """
    mkdir reference
    HOSTILE_CACHE_DIR=./reference hostile index fetch --name ${index_name} --bowtie2
    """
}
