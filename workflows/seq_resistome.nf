/*
 * SEQ_RESISTOME: QC -> host removal -> ARG reads (RGI bwt / CARD)
 *                                   -> 16S reads (SortMeRNA)  -> tables
 *
 * The channel diagram in CLAUDE.md ("Architecture") is the map for this
 * file. Every standard tool is an nf-core module; our own code is the read
 * bookkeeping, the 16S count and the tables (bin/resistome_tables.R).
 */

include { CAT_FASTQ          } from '../modules/nf-core/cat/fastq/main'
include { FASTP              } from '../modules/nf-core/fastp/main'
include { HOSTILE_CLEAN      } from '../modules/nf-core/hostile/clean/main'
include { UNTAR as UNTAR_CARD } from '../modules/nf-core/untar/main'
include { RGI_CARDANNOTATION } from '../modules/nf-core/rgi/cardannotation/main'
include { RGI_BWT            } from '../modules/nf-core/rgi/bwt/main'
include { HOST_INDEX         } from '../modules/local/host_index/main'
include { HOST_FETCH         } from '../modules/local/host_fetch/main'
include { SORTMERNA_INDEX    } from '../modules/local/sortmerna_index/main'
include { COUNT_16S          } from '../modules/local/count_16s/main'
include { RESISTOME_TABLES   } from '../modules/local/resistome_tables/main'

// Read counts from fastp's JSON report: before and after QC (each mate
// counted as one read, as RGI and SortMeRNA count them), and the mean read
// length after QC, which turns read counts into gene copies (D7).
def fastpCounts(json) {
    def s   = new groovy.json.JsonSlurper().parse(json.toFile()).summary
    def a   = s.after_filtering
    def len = a.read2_mean_length ? (a.read1_mean_length + a.read2_mean_length) / 2 : a.read1_mean_length
    return [ reads_raw: s.before_filtering.total_reads, reads_after_qc: a.total_reads, mean_read_length: len ]
}

// Reads hostile removed and kept.
def hostileCounts(json) {
    def h = new groovy.json.JsonSlurper().parse(json.toFile())[0]
    return [ host_reads_removed: h.reads_removed, reads_analysed: h.reads_out ]
}

def FLOW_COLUMNS() { [ 'sample', 'layout', 'n_files', 'reads_raw', 'reads_after_qc', 'mean_read_length', 'host_removal', 'host_reads_removed', 'reads_analysed' ] }

workflow SEQ_RESISTOME {

    take:
    ch_samples    // [ meta, [ fastq ... ] ]
    left_out      // [ [ sample, reason ] ... ]: samples not analysed, and why
    samplesheet   // the --input file: study metadata is read from it
    card          // [ archive, version, validated, sha256 ] from the CARD cache

    main:

    // 1. Several files per sample (lanes): one file per mate.
    def ch_split = ch_samples.branch { meta, _files ->
        multi: meta.n_files > 1
        single: true
    }
    CAT_FASTQ(ch_split.multi)
    def ch_reads = ch_split.single.mix(CAT_FASTQ.out.reads)

    // 2. Read QC with fastp (adapters, quality, length; nf-core defaults).
    FASTP(ch_reads.map { meta, reads -> [ meta, reads, [] ] }, false, false, false)
    def ch_qc_counts = FASTP.out.json.map { meta, json -> [ meta.id, fastpCounts(json) ] }

    // 3. Host removal with hostile (D6): a standard index fetched once into
    //    the cache, or the user's own host genome; or none at all.
    def ch_clean
    def ch_host_counts
    if (params.skip_host_removal) {
        ch_clean       = FASTP.out.reads
        ch_host_counts = ch_qc_counts.map { id, c -> [ id, [ host_removal: 'skipped', host_reads_removed: 0, reads_analysed: c.reads_after_qc ] ] }
    } else {
        def ch_index
        if (params.host_fasta) {
            HOST_INDEX(file(params.host_fasta, checkIfExists: true))
            ch_index = HOST_INDEX.out.index
        } else {
            HOST_FETCH(params.host_index)
            ch_index = HOST_FETCH.out.reference.map { dir -> [ params.host_index, dir ] }
        }
        HOSTILE_CLEAN(FASTP.out.reads, ch_index)
        ch_clean       = HOSTILE_CLEAN.out.fastq
        def host_name  = params.host_fasta ? "own genome (${file(params.host_fasta).name})" : "hostile ${params.host_index}"
        ch_host_counts = HOSTILE_CLEAN.out.json.map { meta, json -> [ meta.id, [ host_removal: host_name ] + hostileCounts(json) ] }
    }

    // Every sample's read flow, one row each, whatever happens to it next.
    def ch_flow = ch_qc_counts.join(ch_host_counts, failOnMismatch: true, failOnDuplicate: true)
        .map { id, qc, host -> [ id, qc + host ] }
    def ch_meta_by_id = ch_reads.map { meta, _r -> [ meta.id, meta ] }
    def ch_flow_rows = ch_meta_by_id.join(ch_flow, failOnMismatch: true, failOnDuplicate: true)
        .map { id, meta, c ->
            def row = c + [ sample: id, layout: meta.single_end ? 'single' : 'paired', n_files: meta.n_files ]
            FLOW_COLUMNS().collect { k -> row[k] }.join('\t')
        }
        .collectFile(name: 'read_flow.tsv', seed: FLOW_COLUMNS().join('\t'), newLine: true, sort: true)

    // 4. Samples with no reads left after QC and host removal skip RGI and
    //    SortMeRNA: they are reported with zero ARGs and a missing 16S
    //    denominator, never dropped (D8).
    def ch_to_count = ch_clean.map { meta, reads -> [ meta.id, meta, reads ] }
        .join(ch_flow, failOnMismatch: true, failOnDuplicate: true)
        .filter { _id, _meta, _reads, c -> c.reads_analysed > 0 }
        .map { _id, meta, reads, _c -> [ meta, reads ] }

    // 5. ARG reads: RGI bwt against CARD's protein homolog models (D8).
    UNTAR_CARD(channel.of([ [ id: "card-${card.version}" ], card.archive ]))
    RGI_CARDANNOTATION(UNTAR_CARD.out.untar.map { _meta, dir -> dir })
    RGI_BWT(ch_to_count, RGI_CARDANNOTATION.out.db.first(), [])

    // 6. 16S reads: SortMeRNA against SILVA 16S (D7). Index built once.
    def ch_16s_refs = channel.fromList(params.rrna_16s.tokenize(',').collect { u -> file(u.trim(), checkIfExists: true) }).collect()
    SORTMERNA_INDEX(ch_16s_refs)
    COUNT_16S(ch_to_count, ch_16s_refs, SORTMERNA_INDEX.out.index)

    // 7. Tables: counts, RPM, RPKM, copies per 16S copy, denominators.
    // The header is an item of its own, so the file exists when no sample is left out.
    def ch_left_out = channel.fromList([ [ 'sample', 'reason' ] ] + left_out)
        .map { s, why -> "${s}\t${why.toString().replaceAll(/[\t\r\n]+/, ' ')}" }
        .collectFile(name: 'samples_left_out.tsv', newLine: true, sort: false)
    RESISTOME_TABLES(
        RGI_BWT.out.tsv.map { _meta, files -> files.find { f -> f.name.endsWith('.gene_mapping_data.txt') } }.collect().ifEmpty([]),
        COUNT_16S.out.counts.map { _meta, f -> f }.collect().ifEmpty([]),
        ch_flow_rows,
        ch_left_out,
        samplesheet,
        card.version,
        card.validated,
        params.length_16s,
        params.min_arg_reads,
        params.min_breadth_ratio
    )

    // Every tool's version, from the nf-core 'versions' topic.
    channel.topic('versions')
        .map { process, tool, version -> "${process.tokenize(':')[-1]}\t${tool}\t${version}" }
        .unique()
        .collectFile(name: 'software_versions.tsv', storeDir: "${params.outdir}/pipeline_info",
                     seed: "process\ttool\tversion", newLine: true, sort: true)

    emit:
    summary = RESISTOME_TABLES.out.summary
}
