/*
 * RESISTOME_TABLES: every sample's ARG counts, normalised, with the
 * denominators (bin/resistome_tables.R; CLAUDE.md D7, D8)
 *
 * One task over all samples: it checks that every analysed sample has its
 * RGI and 16S outputs and that no sample has gone missing on the way.
 */
process RESISTOME_TABLES {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container 'docker.io/rocker/r-ver:4.5.2@sha256:fd4ccdd3a4a6f7ef805e2daeee2a0fe3bf126bc231f36351223baecf5a595a4c'

    input:
    path rgi, stageAs: 'rgi/*'      // per analysed sample: <sample>.read_stats.tsv and the gene table (<sample>.gene_mapping_data.txt from RGI, or <sample>.protein_genes.tsv from DIAMOND)
    path rrna, stageAs: 'rrna/*'    // <sample>.16s.tsv per analysed sample
    path read_flow, stageAs: 'input/read_flow.tsv'   // every sample, analysed or emptied
    path left_out, stageAs: 'input/samples_left_out.tsv'
    path samplesheet, stageAs: 'input/samplesheet.csv'
    val card_version
    val card_validated
    val length_16s
    val min_arg_reads
    val min_breadth_ratio
    val min_read_identity           // the gene-level identity a gene must reach
    path alleles, stageAs: 'input/card_alleles.tsv'   // allele pairs (D22), from RGI_DB or DIAMOND_DB
    val min_allele_identity
    val min_identity_share
    val count_mode                  // protein or dna (D27)
    val read_filter_identity        // the identity each read must reach (protein: min_protein_read_identity)

    output:
    path 'arg_long.tsv',            emit: long
    path 'arg_*.tsv',               emit: matrices
    path 'denominators.tsv',        emit: denominators
    path 'samples_left_out.tsv',    emit: left_out
    path 'resistome_summary.md',    emit: summary
    tuple val("${task.process}"), val('R'), eval("Rscript --version 2>&1 | sed 's/^.*version //; s/ .*//'"), topic: versions

    script:
    """
    resistome_tables.R rgi rrna input/read_flow.tsv input/samples_left_out.tsv input/samplesheet.csv \\
        '${card_version}' ${card_validated} ${length_16s} ${min_arg_reads} ${min_breadth_ratio} ${workflow.manifest.version} ${min_read_identity} \\
        input/card_alleles.tsv ${min_allele_identity} ${min_identity_share} ${count_mode} ${read_filter_identity}
    """
}
