#!/usr/bin/env nextflow
/*
 * seq-resistome: entry point
 *
 * main.nf checks the inputs, decides which samples are analysed (and why
 * any are left out), makes sure CARD is in the cache, and hands over to
 * workflows/seq_resistome.nf (nf-core convention: the entry point handles
 * input, the workflow file handles logic).
 */

include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'
include { cardArchive } from './subworkflows/local/card_cache'
include { SEQ_RESISTOME } from './workflows/seq_resistome'

// Columns the pipeline reads. Everything else in the samplesheet is study
// metadata: carried through to the tables untouched, never interpreted in
// v0.1 (D4). seq-triage's own columns are recognised too, so the samplesheet
// given to seq-triage can be given here unchanged (D9).
def PIPELINE_COLUMNS() { [ 'sample', 'fastq_1', 'fastq_2' ] }
def TRIAGE_COLUMNS()   { [ 'bam', 'fastq_dir', 'platform', 'sample_type', 'molecule', 'library', 'target_taxid', 'genome_size', 'group' ] }

// D4 (from seq-triage D95): a header that looks like a pipeline column stops
// the run, so a typo can never be silently treated as study metadata (a
// missed fastq_2 would turn paired reads single-end). "Looks like": the same
// letters ignoring case and punctuation, one keystroke away, or a common
// synonym (R1, read1, sample_id ...).
def levenshtein(String a, String b) {
    def d = (0..b.size()).collect { j -> j }
    (1..a.size()).each { i ->
        def prev = d[0]
        d[0] = i
        (1..b.size()).each { j ->
            def tmp = d[j]
            d[j] = [ d[j] + 1, d[j - 1] + 1, prev + (a[i - 1] == b[j - 1] ? 0 : 1) ].min()
            prev = tmp
        }
    }
    return d[b.size()]
}
def normCol(String x) {
    return x.toLowerCase().replaceAll(/[^a-z0-9]/, '')
}
def checkHeaders(List header) {
    def known    = PIPELINE_COLUMNS() + TRIAGE_COLUMNS()
    def synonyms = [ sampleid: 'sample', samplename: 'sample', name: 'sample', id: 'sample',
                     r1: 'fastq_1', read1: 'fastq_1', reads1: 'fastq_1', fq1: 'fastq_1', forward: 'fastq_1',
                     r2: 'fastq_2', read2: 'fastq_2', reads2: 'fastq_2', fq2: 'fastq_2', reverse: 'fastq_2' ]
    def missing = [ 'sample', 'fastq_1' ].findAll { c -> !(c in header) && !(c == 'fastq_1' && params.triage_results) }
    def dup     = header.findAll { c -> header.count(c) > 1 }.unique()
    def near    = header.findAll { c -> !(c in known) }.collect { c ->
        def n   = normCol(c)
        def hit = known.find { k -> normCol(k) == n } ?: synonyms[n] ?: known.find { k -> levenshtein(normCol(k), n) <= 1 }
        hit ? "'${c}' looks like the pipeline column '${hit}'" : null
    }.findAll { p -> p }
    def problems = (missing ? [ "missing column(s) ${missing.join(', ')}" ] : []) +
                   (dup ? [ "column(s) named twice: ${dup.join(', ')}" ] : []) + near
    if (problems) {
        error("Samplesheet ${params.input}: " + problems.join('; ') + ". Nothing has been assumed: rename the column exactly as in the README " +
              "(sample, fastq_1, fastq_2); if it is your own study variable, give it a name that is not one keystroke from a pipeline column.")
    }
}

def readSheet(String path) {
    def f = file(path, checkIfExists: true)
    def header = f.withReader { r -> r.readLine() }?.replaceFirst(/^﻿/, '')?.split(',', -1)?.collect { c -> c.trim().replaceAll(/^"|"$/, '') } ?: []
    checkHeaders(header)
    def rows = f.splitCsv(header: true, strip: true).collect { r -> r.collectEntries { k, v -> [ k.replaceFirst(/^﻿/, ''), v == '' ? null : v ] } }
    rows.eachWithIndex { r, i ->
        if (!r.sample) {
            error("Samplesheet ${path}, row ${i + 2}: no sample name.")
        }
        if (!(r.sample ==~ /[A-Za-z0-9._-]+/)) {
            error("Samplesheet ${path}, row ${i + 2}: sample '${r.sample}' may only use letters, digits, '.', '_' and '-' (it becomes a file name).")
        }
    }
    return rows
}

// seq-triage's verdicts, one row per sample (D9).
def readTriage(String dir) {
    def f = file("${dir}/triage_summary.tsv")
    if (!f.exists()) {
        error("--triage_results ${dir}: no triage_summary.tsv there. Give the folder seq-triage wrote its results to (its --outdir).")
    }
    return f.splitCsv(header: true, sep: '\t').collectEntries { r -> [ r.sample, r ] }
}

// Why a sample is left out, or null if it is analysed (D9). v0.1 analyses
// short-read shotgun metagenomes given as FASTQ.
def SHORT_READ_PLATFORMS() { [ 'illumina', 'dnbseq', 'element' ] }
def leftOutReason(String sample, List rows, Map triage) {
    if (triage != null) {
        def t = triage[sample]
        if (t == null) {
            return null   // caught by the cross-check in the workflow block
        }
        if (!(t.verdict in [ 'PASS', 'WARN' ])) {
            return "seq-triage verdict ${t.verdict}: ${t.verdict_reason ?: 'see triage_summary.md'}"
        }
        if (t.detected_type != 'metagenome') {
            return "seq-triage found this is not a metagenome (detected type: ${t.detected_type ?: 'none'}${t.type_reason ? '; ' + t.type_reason : ''})"
        }
        if (!(t.detected_platform in SHORT_READ_PLATFORMS())) {
            return "platform ${t.detected_platform}: v0.1 analyses short reads only (Illumina, DNBSEQ, Element)"
        }
    }
    if (rows.any { r -> !r.fastq_1 }) {
        return rows.any { r -> r.bam } ? 'given as BAM/CRAM: v0.1 takes FASTQ only (convert with samtools fastq)'
             : rows.any { r -> r.fastq_dir } ? 'given as a fastq_dir folder: v0.1 takes fastq_1/fastq_2 file paths only'
             : 'no fastq_1'
    }
    if (rows.collect { r -> r.fastq_2 != null }.unique().size() > 1) {
        return 'some files of this sample are paired and some single-end'
    }
    return null
}

workflow {
    // --help: nf-schema has already printed it (from nextflow_schema.json).
    if (params.containsKey('help') || params.containsKey('helpFull')) {
        exit(0)
    }
    validateParameters()
    log.info paramsSummaryLog(workflow)

    def rows   = readSheet(params.input)
    def triage = params.triage_results ? readTriage(params.triage_results) : null
    if (triage != null) {
        def inSheet  = rows.collect { r -> r.sample }.unique()
        def onlySheet  = inSheet - triage.keySet()
        def onlyTriage = triage.keySet() - inSheet
        if (onlySheet || onlyTriage) {
            error("--input and --triage_results do not describe the same samples" +
                  (onlySheet ? "; in the samplesheet only: ${onlySheet.join(', ')}" : '') +
                  (onlyTriage ? "; in seq-triage's results only: ${onlyTriage.join(', ')}" : '') +
                  ". Give the samplesheet seq-triage was run with.")
        }
    }

    // Several rows with one sample name are one sample in several files
    // (lanes, top-up runs): concatenated in samplesheet order (D4).
    def bySample = rows.groupBy { r -> r.sample }
    def analysed = []
    def leftOut  = []
    bySample.each { sample, rs ->
        def why = leftOutReason(sample, rs, triage)
        if (why) {
            leftOut << [ sample, why ]
        } else {
            def single = rs[0].fastq_2 == null
            def files  = rs.collectMany { r -> single ? [ file(r.fastq_1, checkIfExists: true) ] : [ file(r.fastq_1, checkIfExists: true), file(r.fastq_2, checkIfExists: true) ] }
            analysed << [ [ id: sample, single_end: single, n_files: rs.size() ], files ]
        }
    }
    if (!analysed) {
        error("No sample is left to analyse: " + leftOut.collect { s, why -> "${s} (${why})" }.join('; '))
    }
    leftOut.each { s, why -> log.warn("Sample ${s} is left out: ${why}") }

    def cacheDir = params.card_cache ?: "${System.getProperty('user.home')}/.seq-resistome/card"
    def (archive, version, validated, sha, action) = cardArchive(params.card_version, cacheDir, params.card_versions,
                                                                   'https://card.mcmaster.ca/download', 'https://card.mcmaster.ca/download/0/')
    log.info "CARD ${version} (${validated ? 'validated with this pipeline version' : 'NOT validated by the pipeline authors'}): ${action}. ${archive}, SHA-256 ${sha}"

    SEQ_RESISTOME(
        channel.fromList(analysed),
        leftOut,
        file(params.input),
        [ archive: archive, version: version, validated: validated, sha256: sha ]
    )
}
