#!/usr/bin/env Rscript
#*******************************************************************************
# resistome_tables.R: ARG counts, normalised four ways, with their
#                     denominators (CLAUDE.md D7, D8)
#
# WHAT IT DOES  Reads RGI bwt's gene table for each sample, the 16S read
#               counts, the read flow (raw, after QC, after host removal) and
#               the samplesheet, and writes:
#                 arg_long.tsv            one row per sample and CARD gene hit,
#                                         every measure, the detection call and
#                                         the study metadata (the table v0.2
#                                         reads)
#                 arg_<measure>.tsv       gene x sample matrices of detected
#                                         genes: reads, rpm, rpkm,
#                                         copies_per_16s
#                 denominators.tsv        per sample: every number the measures
#                                         divide by
#                 samples_left_out.tsv    samples not analysed, and why
#                 resistome_summary.md    a plain-language summary
#
# MEASURES      reads           reads mapped to the gene (each mate counted)
#               rpm             reads per million reads analysed (after QC
#                               and host removal)
#               rpkm            reads per kilobase of the CARD reference gene
#                               per million reads analysed
#               copies_per_16s  ARG copies per 16S rRNA gene copy:
#                               (reads x mean read length / gene length) /
#                               (16S aligned bases / 16S length), counting
#                               only the 16S bases reads actually cover (D13).
#                               Missing (NA), never infinite, when a sample
#                               has no 16S reads.
#
# DETECTED      reads >= min_arg_reads, and the gene covered at least
#               min_breadth_ratio of the breadth reads landing at random would
#               cover: 1 - exp(-reads x read length / gene length). Reads piled
#               on one shared domain of a gene that is not there cover far
#               less than that (D8). Every hit is kept in arg_long.tsv with
#               its call and reason; the matrices hold detected genes only.
#
# Usage:  resistome_tables.R <rgi_dir> <rrna_dir> <read_flow.tsv>
#             <samples_left_out.tsv> <samplesheet.csv> <card_version>
#             <card_validated true|false> <length_16s> <min_arg_reads>
#             <min_breadth_ratio> [pipeline_version]
#*******************************************************************************

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 10) stop("Usage: resistome_tables.R <rgi_dir> <rrna_dir> <read_flow.tsv> <samples_left_out.tsv> <samplesheet.csv> <card_version> <card_validated> <length_16s> <min_arg_reads> <min_breadth_ratio> [pipeline_version]")
rgi_dir      <- args[1]
rrna_dir     <- args[2]
flow_file    <- args[3]
left_file    <- args[4]
sheet_file   <- args[5]
card_version <- args[6]
card_ok      <- tolower(args[7]) == "true"
length_16s   <- as.numeric(args[8])
min_reads    <- as.numeric(args[9])
min_ratio    <- as.numeric(args[10])
pipe_version <- if (length(args) >= 11) args[11] else "dev"

# Pipeline columns (main.nf): never study metadata.
PIPELINE_COLUMNS <- c("sample", "fastq_1", "fastq_2", "bam", "fastq_dir", "platform", "sample_type",
                      "molecule", "library", "target_taxid", "genome_size", "group")

read_tsv <- function(f) read.delim(f, sep = "\t", quote = "", check.names = FALSE, stringsAsFactors = FALSE,
                                   colClasses = "character", na.strings = character(0), comment.char = "")
num <- function(x) as.numeric(x)

# 1. Read flow and left-out samples ----------------------------------------------
flow <- read_tsv(flow_file)
for (k in c("n_files", "reads_raw", "reads_after_qc", "mean_read_length", "host_reads_removed", "reads_analysed"))
  flow[[k]] <- num(flow[[k]])
flow <- flow[order(flow$sample), ]
left <- read_tsv(left_file)

# 2. 16S counts ------------------------------------------------------------------
rrna_files <- list.files(rrna_dir, pattern = "\\.16s\\.tsv$", full.names = TRUE)
rrna <- if (length(rrna_files)) do.call(rbind, lapply(rrna_files, read_tsv)) else
  data.frame(sample = character(0), reads_16s = character(0), bases_16s = character(0), reads_seen = character(0))
rrna$reads_16s  <- num(rrna$reads_16s)
rrna$bases_16s  <- num(rrna$bases_16s)
rrna$reads_seen <- num(rrna$reads_seen)

# 3. RGI gene tables --------------------------------------------------------------
RGI_COLS <- c(aro_term = "ARO Term", aro_accession = "ARO Accession", model_type = "Reference Model Type",
              reads = "All Mapped Reads", completely_mapped_reads = "Completely Mapped Reads",
              average_percent_coverage = "Average Percent Coverage", average_mapq = "Average MAPQ (Completely Mapped Reads)",
              reference_length_bp = "Reference Length", amr_gene_family = "AMR Gene Family",
              drug_class = "Drug Class", resistance_mechanism = "Resistance Mechanism")
rgi_files <- list.files(rgi_dir, pattern = "\\.gene_mapping_data\\.txt$", full.names = TRUE)
hits <- do.call(rbind, c(list(as.data.frame(setNames(replicate(length(RGI_COLS) + 1, character(0), simplify = FALSE),
                                                     c("sample", names(RGI_COLS))))),
  lapply(rgi_files, function(f) {
    g <- read_tsv(f)
    miss <- setdiff(RGI_COLS, names(g))
    if (length(miss)) stop(basename(f), ": RGI output lacks column(s) ", paste(miss, collapse = ", "),
                           ". RGI's output format may have changed; nothing was written.")
    out <- g[, RGI_COLS, drop = FALSE]
    names(out) <- names(RGI_COLS)
    cbind(sample = rep(sub("\\.gene_mapping_data\\.txt$", "", basename(f)), nrow(out)), out, stringsAsFactors = FALSE)
  })))
for (k in c("reads", "completely_mapped_reads", "average_percent_coverage", "average_mapq", "reference_length_bp"))
  hits[[k]] <- num(hits[[k]])

# 4. Bookkeeping checks: every analysed sample has its outputs, and nothing
#    else does; SortMeRNA saw exactly the reads the read flow says. A broken
#    join would otherwise give wrong numbers silently.
analysed <- flow$sample[flow$reads_analysed > 0]
rgi_samples <- sub("\\.gene_mapping_data\\.txt$", "", basename(rgi_files))
problems <- c(
  if (length(setdiff(analysed, rgi_samples))) paste("no RGI output for", paste(setdiff(analysed, rgi_samples), collapse = ", ")),
  if (length(setdiff(rgi_samples, analysed))) paste("RGI output for samples with no reads analysed:", paste(setdiff(rgi_samples, analysed), collapse = ", ")),
  if (length(setdiff(analysed, rrna$sample))) paste("no 16S count for", paste(setdiff(analysed, rrna$sample), collapse = ", ")),
  if (length(setdiff(rrna$sample, analysed))) paste("16S count for samples with no reads analysed:", paste(setdiff(rrna$sample, analysed), collapse = ", ")))
seen <- merge(flow[, c("sample", "reads_analysed")], rrna[, c("sample", "reads_seen")], by = "sample")
bad_seen <- seen$sample[seen$reads_seen != seen$reads_analysed]
if (length(bad_seen)) problems <- c(problems, paste0("SortMeRNA read a different number of reads than were analysed for ",
                                                     paste(bad_seen, collapse = ", ")))
if (length(problems)) stop("Bookkeeping check failed: ", paste(problems, collapse = "; "), ". Nothing was written.")

# 5. Study metadata: every samplesheet column the pipeline does not use, one
#    value per sample, carried through untouched (D4).
sheet <- read.csv(sheet_file, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character",
                  na.strings = character(0), strip.white = TRUE, fileEncoding = "UTF-8-BOM")
meta_cols <- setdiff(names(sheet), PIPELINE_COLUMNS)
OUTPUT_COLS <- c("sample", "aro_accession", "aro_term", "amr_gene_family", "drug_class", "resistance_mechanism",
                 "model_type", "reference_length_bp", "reads", "completely_mapped_reads", "average_percent_coverage",
                 "expected_percent_coverage", "breadth_ratio", "average_mapq", "detected", "detection_note", "rpm",
                 "rpkm", "arg_copies", "copies_per_16s", "reads_analysed", "mean_read_length", "reads_16s",
                 "bases_16s", "copies_16s", "card_version", "card_validated", "layout", "n_files", "reads_raw", "reads_after_qc",
                 "host_removal", "host_reads_removed", "status", "note")
clash <- intersect(meta_cols, OUTPUT_COLS)
if (length(clash)) stop("Samplesheet column(s) ", paste(clash, collapse = ", "), " have the same name as an output column. ",
                        "Rename them in the samplesheet; nothing has been renamed for you.")
meta <- unique(sheet[, c("sample", meta_cols), drop = FALSE])
dup <- unique(meta$sample[duplicated(meta$sample)])
if (length(dup)) stop("Samplesheet rows of the same sample disagree on study metadata: ", paste(dup, collapse = ", "),
                      ". Each sample has one value per column; nothing has been assumed.")

# 6. Denominators, per sample ------------------------------------------------------
den <- merge(flow, rrna[, c("sample", "reads_16s", "bases_16s")], by = "sample", all.x = TRUE)
den$copies_16s <- den$bases_16s / length_16s
den$status <- ifelse(den$reads_after_qc == 0, "no reads left after QC",
              ifelse(den$reads_analysed == 0, "no reads left after host removal", "analysed"))
den$note <- ifelse(den$status != "analysed", "Zero ARGs (no reads to look in); copies per 16S copy missing (NA).",
            ifelse(den$reads_16s == 0, "No 16S reads: copies per 16S copy are missing (NA), not zero or infinite.", ""))
den$card_version   <- card_version
den$card_validated <- card_ok

# 7. Measures and the detection call, per hit --------------------------------------
long <- merge(hits, den[, c("sample", "reads_analysed", "mean_read_length", "reads_16s", "bases_16s", "copies_16s")], by = "sample")
L <- long$reference_length_bp
long$expected_percent_coverage <- 100 * (1 - exp(-long$reads * long$mean_read_length / L))
long$breadth_ratio <- long$average_percent_coverage / long$expected_percent_coverage
long$detected <- long$reads >= min_reads & long$breadth_ratio >= min_ratio
long$detection_note <- ifelse(long$detected, "",
  ifelse(long$reads < min_reads, sprintf("fewer than %g reads", min_reads),
         sprintf("reads cover %.0f%% of the gene; reads landing at random would cover %.0f%% (ratio %.2f < %g): likely a shared domain of another gene",
                 long$average_percent_coverage, long$expected_percent_coverage, long$breadth_ratio, min_ratio)))
long$rpm  <- long$reads / long$reads_analysed * 1e6
long$rpkm <- long$reads / (L / 1e3) / (long$reads_analysed / 1e6)
long$arg_copies <- long$reads * long$mean_read_length / L
long$copies_per_16s <- ifelse(long$reads_16s > 0, long$arg_copies / long$copies_16s, NA)
long$card_version   <- rep(card_version, nrow(long))
long$card_validated <- rep(card_ok, nrow(long))
long <- merge(long, den[, c("sample", "layout", "n_files", "reads_raw", "reads_after_qc", "host_removal",
                            "host_reads_removed", "status", "note")], by = "sample")
long <- merge(long, meta, by = "sample", all.x = TRUE)
long <- long[order(long$sample, -long$reads, long$aro_term), c(OUTPUT_COLS, meta_cols)]
den  <- merge(den, meta, by = "sample", all.x = TRUE)

# 8. Write --------------------------------------------------------------------------
fmt <- function(d) {
  for (k in names(d)) if (is.numeric(d[[k]])) d[[k]] <- ifelse(is.na(d[[k]]), "NA", format(signif(d[[k]], 6), scientific = FALSE, trim = TRUE, drop0trailing = TRUE))
  d
}
card_line <- if (card_ok) sprintf("CARD %s (the release this pipeline version was validated with)", card_version) else
  sprintf("CARD %s: not validated by the pipeline authors", card_version)
CAVEAT_16S <- paste("copies_per_16s counts ARG copies per 16S rRNA gene copy. Bacterial genomes carry 1 to about 15",
                    "16S copies (most 1 to 7), so this is not ARGs per cell or per genome, and communities whose",
                    "members carry more 16S copies look poorer in ARGs.")
write_out <- function(d, f, what) {
  con <- file(f, "w")
  writeLines(c(sprintf("# seq-resistome %s | %s | %s", pipe_version, card_line, what), paste("#", CAVEAT_16S)), con)
  write.table(fmt(d), con, sep = "\t", quote = FALSE, row.names = FALSE, na = "NA")
  close(con)
}
write_out(long, "arg_long.tsv", "one row per sample and CARD gene with any mapped read; detected = the gene counts as present")

GENE_COLS <- c("aro_accession", "aro_term", "amr_gene_family", "drug_class", "resistance_mechanism", "reference_length_bp")
genes <- unique(long[long$detected, GENE_COLS])
genes <- genes[order(genes$aro_term), ]
for (m in c("reads", "rpm", "rpkm", "copies_per_16s")) {
  mat <- genes
  for (s in den$sample) {
    v <- long[long$detected & long$sample == s, c("aro_accession", m)]
    x <- v[[m]][match(genes$aro_accession, v$aro_accession)]
    # An undetected gene is 0, except copies per 16S copy in a sample with
    # no 16S denominator, which stays missing for every gene.
    no16 <- den$reads_16s[den$sample == s]
    mat[[s]] <- if (m == "copies_per_16s" && (is.na(no16) || no16 == 0)) rep(NA_real_, nrow(genes)) else ifelse(is.na(x), 0, x)
  }
  write_out(mat, sprintf("arg_%s.tsv", m), sprintf("%s of detected genes; one column per sample (including samples with none)", m))
}
write_out(den[, c("sample", "status", "note", "layout", "n_files", "reads_raw", "reads_after_qc", "host_removal",
                  "host_reads_removed", "reads_analysed", "mean_read_length", "reads_16s", "bases_16s", "copies_16s",
                  "card_version", "card_validated", meta_cols)],
          "denominators.tsv", "per sample: the numbers every measure divides by")
write_out(left, "samples_left_out.tsv", "samples not analysed, and why")

# 9. Summary --------------------------------------------------------------------------
pct <- function(a, b) ifelse(b > 0, sprintf("%.1f%%", 100 * a / b), "-")
per <- lapply(den$sample, function(s) {
  d <- den[den$sample == s, ]
  h <- long[long$sample == s & long$detected, ]
  c(sample = s, status = d$status, reads_analysed = format(d$reads_analysed, big.mark = ","),
    host_removed = pct(d$host_reads_removed, d$reads_after_qc), reads_16s = ifelse(is.na(d$reads_16s), "-", d$reads_16s),
    args = nrow(h), copies = if (is.na(d$reads_16s) || d$reads_16s == 0) "NA" else sprintf("%.3g", sum(h$copies_per_16s)))
})
per <- as.data.frame(do.call(rbind, per), stringsAsFactors = FALSE)
md <- c("# seq-resistome summary", "",
        sprintf("seq-resistome %s. %s.", pipe_version, card_line), "",
        sprintf("%d sample(s) analysed, %d left out.", nrow(den), nrow(left)), "",
        "| Sample | Status | Reads analysed | Host reads removed | 16S reads | ARGs detected | ARG copies per 16S copy (all detected) |",
        "|---|---|---:|---:|---:|---:|---:|",
        sprintf("| %s | %s | %s | %s | %s | %s | %s |", per$sample, per$status, per$reads_analysed, per$host_removed,
                per$reads_16s, per$args, per$copies),
        "")
if (nrow(left)) md <- c(md, "## Left out", "", sprintf("- **%s**: %s", left$sample, left$reason), "")
notes <- den$note[den$note != ""]
if (length(notes)) md <- c(md, "## Notes", "", sprintf("- **%s**: %s", den$sample[den$note != ""], notes), "")
md <- c(md, "## How to read these numbers", "",
        "- **reads**: reads mapped to a CARD gene by RGI bwt (each mate of a pair counts once).",
        "- **rpm**: reads per million reads analysed (after QC and host removal).",
        "- **rpkm**: reads per kilobase of the CARD reference gene per million reads analysed.",
        paste("- **copies_per_16s**:", CAVEAT_16S),
        sprintf(paste("- **detected**: at least %g reads, spread along the gene at least %g times as widely as reads landing",
                      "at random would be. Hits that fail are kept in arg_long.tsv with the reason, and left out of the matrices."),
                min_reads, min_ratio),
        "- Only CARD's protein homolog models are searched: genes whose presence alone confers resistance. Resistance by point mutation (e.g. in gyrA) cannot be called from reads mapped this way and is not reported.",
        "- Counts are of reads, not organisms: which organisms carry these genes, and whether on plasmids, is for later versions.")
writeLines(md, "resistome_summary.md")
cat(sprintf("resistome_tables.R: %d samples, %d gene hits (%d detected), %d left out\n",
            nrow(den), nrow(long), sum(long$detected), nrow(left)))
