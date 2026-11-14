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
#                               that match its CARD reference at
#                               min_read_identity or more, judged read by
#                               read (D23); reads_below_identity, the rest
#               rpm             reads per million reads analysed (after QC
#                               and host removal)
#               rpkm            reads per kilobase of the CARD reference gene
#                               per million reads analysed
#               copies_per_16s  ARG copies per 16S rRNA gene copy:
#                               (ARG aligned bases / gene length) /
#                               (16S aligned bases / 16S length), counting
#                               only the bases reads actually cover on each
#                               reference (16S: D13; ARGs: D19).
#                               Missing (NA), never infinite, when a sample
#                               has no 16S reads.
#
# DETECTED      reads >= min_arg_reads, and the gene covered at least
#               min_breadth_ratio of the breadth reads landing at random would
#               cover: 1 - exp(-reads x read length / gene length). Reads piled
#               on one shared domain of a gene that is not there cover far
#               less than that (D8). Reads and breadth count only reads
#               matching the CARD reference at min_read_identity or more,
#               each read on its own (D19, D23): reads from a different gene
#               that only shares a stretch with a CARD gene match it less
#               well, and a few such reads no longer drag a real gene's
#               average below the line. Every hit is kept in
#               arg_long.tsv with its call and reason; the matrices hold
#               detected genes only.
#
# ALLELES       (D22) A gene's reads can split between near-identical CARD
#               references (alleles): kma gives each read to the best one,
#               and reads that match several equally well scatter. The minor
#               alleles then fail the call on their own and their reads are
#               lost. When min_allele_identity > 0, an undetected gene that
#               failed only on read count or breadth (its reads match it well)
#               has its reads counted under the most similar detected gene of
#               the same sample, if their CARD references are at least
#               min_allele_identity identical over >= 90% of the longer one
#               (allele table from RGI_DB). Detection calls never change;
#               reads, rpm and rpkm stay each gene's own; copies and the
#               interval of the detected gene include the merged reads, and
#               merged_reads / merged_from say what was added.
#
# ENGINES       (D27) count_mode "dna": RGI bwt's gene tables
#               (<sample>.gene_mapping_data.txt). count_mode "protein":
#               DIAMOND's (<sample>.protein_genes.tsv, from
#               bin/protein_read_stats.sh). Both come with <sample>.read_stats.tsv
#               in the same columns (protein coordinates as nucleotide
#               equivalents), so every measure and rule below is computed the
#               same way. In protein mode identity is amino-acid identity:
#               reads below read_filter_identity were already left out one by
#               one, and min_read_identity is the identity the gene's kept
#               reads must reach together (rule f70g90; D26).
#
# Usage:  resistome_tables.R <arg_dir> <rrna_dir> <read_flow.tsv>
#             <samples_left_out.tsv> <samplesheet.csv> <card_version>
#             <card_validated true|false> <length_16s> <min_arg_reads>
#             <min_breadth_ratio> [pipeline_version] [min_read_identity]
#             [allele_table|none] [min_allele_identity] [min_identity_share]
#             [count_mode dna|protein] [read_filter_identity]
#             [core_dir|none] [core_read_identity] [core_gene_identity] [core_breadth_ratio]
#*******************************************************************************

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 10) stop("Usage: resistome_tables.R <rgi_dir> <rrna_dir> <read_flow.tsv> <samples_left_out.tsv> <samplesheet.csv> <card_version> <card_validated> <length_16s> <min_arg_reads> <min_breadth_ratio> [pipeline_version] [min_read_identity]")
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
min_identity <- if (length(args) >= 12) as.numeric(args[12]) else 0
allele_file  <- if (length(args) >= 13) args[13] else "none"
min_allele   <- if (length(args) >= 14) as.numeric(args[14]) else 0
min_share    <- if (length(args) >= 15) as.numeric(args[15]) else 0   # D24; 0 = off
count_mode   <- if (length(args) >= 16) args[16] else "dna"               # D27
read_filter  <- if (length(args) >= 17) as.numeric(args[17]) else min_identity
# Protein mode's second way to detect a gene (D31, "or" rule): the gene's reads at
# core_read_identity or more, counted on their own (core_dir holds their read
# statistics, made by protein_read_stats.sh at that identity), are enough when there
# are min_arg_reads of them, they average core_gene_identity or more, and they spread
# along the gene at least core_breadth_ratio times as widely as random reads would.
# core_gene_identity 0 switches it off. Background organisms' homologs (70-89%) pull a
# real gene's pooled identity below the f70g90 line in mixtures; they cannot pull this one.
core_dir     <- if (length(args) >= 18) args[18] else "none"
core_read    <- if (length(args) >= 19) as.numeric(args[19]) else 0
core_gene    <- if (length(args) >= 20) as.numeric(args[20]) else 0
core_ratio   <- if (length(args) >= 21) as.numeric(args[21]) else 0
# V3 (D33): protein mode reports, apart from "detected", a "probable_homolog": a gene that fails
# only on gene identity, at probable_gene or more (below min_identity), with the read and breadth
# conditions met. Never counted as detected. probable_gene 0 = off.
probable_gene <- if (length(args) >= 22) as.numeric(args[22]) else 0
if (!count_mode %in% c("dna", "protein")) stop("count_mode must be dna or protein, not '", count_mode, "'; nothing was written.")
core_on      <- count_mode == "protein" && core_gene > 0 && core_dir != "none"
gene_suffix  <- if (count_mode == "dna") "\\.gene_mapping_data\\.txt$" else "\\.protein_genes\\.tsv$"
engine_name  <- if (count_mode == "dna") "RGI" else "DIAMOND"
if (min_allele > 0 && (allele_file == "none" || !file.exists(allele_file)))
  stop("min_allele_identity is ", min_allele, " but no allele table was given; nothing was written.")

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
  data.frame(sample = character(0), reads_16s = character(0), bases_16s = character(0), copies_16s = character(0),
             short_16s = character(0), low_identity_16s = character(0), reads_seen = character(0))
miss16 <- setdiff(c("reads_16s", "bases_16s", "copies_16s", "short_16s", "low_identity_16s", "reads_seen"), names(rrna))
if (length(miss16)) stop("16S counts lack column(s) ", paste(miss16, collapse = ", "), "; nothing was written.")
rrna$reads_16s  <- num(rrna$reads_16s)
rrna$bases_16s  <- num(rrna$bases_16s)
rrna$copies_16s <- num(rrna$copies_16s)
rrna$short_16s  <- num(rrna$short_16s)
rrna$low_identity_16s <- num(rrna$low_identity_16s)
rrna$reads_seen <- num(rrna$reads_seen)

# 3. Gene tables (RGI's, or DIAMOND's in the same columns under our names) ------
RGI_COLS <- c(aro_term = "ARO Term", aro_accession = "ARO Accession", model_type = "Reference Model Type",
              reads = "All Mapped Reads", completely_mapped_reads = "Completely Mapped Reads",
              average_percent_coverage = "Average Percent Coverage", average_mapq = "Average MAPQ (Completely Mapped Reads)",
              reference_length_bp = "Reference Length", amr_gene_family = "AMR Gene Family",
              drug_class = "Drug Class", resistance_mechanism = "Resistance Mechanism")
rgi_files <- list.files(rgi_dir, pattern = gene_suffix, full.names = TRUE)
other <- list.files(rgi_dir, pattern = if (count_mode == "dna") "\\.protein_genes\\.tsv$" else "\\.gene_mapping_data\\.txt$")
if (length(other)) stop("count_mode is ", count_mode, " but the other engine's gene tables are here too (", paste(other, collapse = ", "),
                        "); nothing was written.")
want_cols <- if (count_mode == "dna") RGI_COLS else setNames(names(RGI_COLS), names(RGI_COLS))
hits <- do.call(rbind, c(list(as.data.frame(setNames(replicate(length(RGI_COLS) + 1, character(0), simplify = FALSE),
                                                     c("sample", names(RGI_COLS))))),
  lapply(rgi_files, function(f) {
    g <- read_tsv(f)
    miss <- setdiff(want_cols, names(g))
    if (length(miss)) stop(basename(f), ": ", engine_name, " gene table lacks column(s) ", paste(miss, collapse = ", "),
                           ". Its format may have changed; nothing was written.")
    out <- g[, want_cols, drop = FALSE]
    names(out) <- names(RGI_COLS)
    cbind(sample = rep(sub(gene_suffix, "", basename(f)), nrow(out)), out, stringsAsFactors = FALSE)
  })))
for (k in c("reads", "completely_mapped_reads", "average_percent_coverage", "average_mapq", "reference_length_bp"))
  hits[[k]] <- suppressWarnings(num(hits[[k]]))   # a list when RGI maps reads to several references of a gene (D20)

# Read statistics per CARD reference (bin/rgi_read_stats.sh), summed per ARO:
# aligned bases (for copies) and mismatches (for read identity; D19).
stat_files <- list.files(rgi_dir, pattern = "\\.read_stats\\.tsv$", full.names = TRUE)
# Per ARO (D20), from the read statistics, not RGI's table: breadth is
# judged on each reference in its own coordinates, against what its own
# reads landing at random would cover, and averaged over the ARO's
# references weighted by reads; the gene's length is its CARD reference's
# (canonical_length). CARD 4.0.2 has one reference per ARO, so this equals
# the per-gene rule of D8; it stays right if a reference set ever gives a
# gene several (as CARD's variants collection did in development, D20).
stats_from <- function(stat_files) do.call(rbind, c(list(data.frame(sample = character(0), aro_accession = character(0), stat_reads = numeric(0),
                                          canonical_length = numeric(0), aligned_bases = numeric(0), mismatches = numeric(0),
                                          pct_covered = numeric(0), pct_expected = numeric(0), ratio = numeric(0),
                                          n_references = numeric(0), dispersion = numeric(0), reads_below_identity = numeric(0))),
  lapply(stat_files, function(f) {
    x <- read_tsv(f)
    if (!nrow(x)) return(NULL)
    need <- c("reference_length", "canonical_length", "covered_bases", "window_var", "reads_low_identity")
    if (length(setdiff(need, names(x)))) stop(basename(f), ": read statistics lack ", paste(setdiff(need, names(x)), collapse = ", "),
                                              "; nothing was written.")
    smp <- sub("\\.read_stats\\.tsv$", "", basename(f))
    rl  <- flow$mean_read_length[flow$sample == smp]; if (!length(rl)) rl <- NA_real_
    for (k in c("reads", "aligned_bases", "mismatches", "reference_length", "canonical_length", "covered_bases", "reads_low_identity"))
      x[[k]] <- num(x[[k]])
    # Window counts are "NA" for genes too short for three windows (D20).
    for (k in c("window_mean", "window_var")) x[[k]] <- num(ifelse(x[[k]] == "NA", NA, x[[k]]))
    cov <- 100 * x$covered_bases / x$reference_length
    expd <- 100 * (1 - exp(-x$reads * rl / x$reference_length))
    phi <- x$window_var / x$window_mean
    phi[!is.finite(phi)] <- NA
    a <- do.call(rbind, lapply(split(seq_len(nrow(x)), x$aro_accession), function(i) {
      # Weighted by the reads kept (D23); a gene whose reads all fell below
      # the identity threshold has none: covered 0, ratio 0.
      w <- x$reads[i]; ok <- !is.na(phi[i]) & w > 0; W <- sum(w)
      wavg <- function(v) if (W > 0) sum((w * v)[w > 0]) / W else 0
      data.frame(aro_accession = x$aro_accession[i[1]], stat_reads = W,
                 canonical_length = suppressWarnings(max(x$canonical_length[i], na.rm = TRUE)),
                 aligned_bases = sum(x$aligned_bases[i]), mismatches = sum(x$mismatches[i]),
                 pct_covered = wavg(cov[i]), pct_expected = wavg(expd[i]),
                 ratio = wavg(cov[i] / expd[i]), n_references = length(i),
                 dispersion = if (any(ok)) sum(phi[i][ok] * w[ok]) / sum(w[ok]) else NA_real_,
                 reads_below_identity = sum(x$reads_low_identity[i]), stringsAsFactors = FALSE)
    }))
    a$canonical_length[!is.finite(a$canonical_length)] <- NA
    cbind(sample = rep(smp, nrow(a)), a, stringsAsFactors = FALSE)
  })))
stats <- stats_from(stat_files)
core_files <- if (core_on) list.files(core_dir, pattern = "\\.read_stats\\.tsv$", full.names = TRUE) else character(0)
cstats <- stats_from(core_files)

# 4. Bookkeeping checks: every analysed sample has its outputs, and nothing
#    else does; SortMeRNA saw exactly the reads the read flow says. A broken
#    join would otherwise give wrong numbers silently.
analysed <- flow$sample[flow$reads_analysed > 0]
rgi_samples <- sub(gene_suffix, "", basename(rgi_files))
stat_samples <- sub("\\.read_stats\\.tsv$", "", basename(stat_files))
problems <- c(
  if (length(setdiff(rgi_samples, stat_samples))) paste("no", engine_name, "read statistics for", paste(setdiff(rgi_samples, stat_samples), collapse = ", ")),
  if (core_on && length(setdiff(stat_samples, sub("\\.read_stats\\.tsv$", "", basename(core_files))))) paste("no high-identity read statistics for", paste(setdiff(stat_samples, sub("\\.read_stats\\.tsv$", "", basename(core_files))), collapse = ", ")),
  if (length(setdiff(analysed, rgi_samples))) paste("no", engine_name, "output for", paste(setdiff(analysed, rgi_samples), collapse = ", ")),
  if (length(setdiff(rgi_samples, analysed))) paste(engine_name, "output for samples with no reads analysed:", paste(setdiff(rgi_samples, analysed), collapse = ", ")),
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
                 "model_type", "reference_length_bp", "n_references", "reads", "reads_below_identity", "merged_reads", "merged_from", "completely_mapped_reads", "average_percent_coverage", "rgi_percent_coverage",
                 "expected_percent_coverage", "breadth_ratio", "average_mapq", "aligned_bases", "merged_aligned_bases", "read_identity", "detected", "detected_by", "call", "detection_note", "rpm",
                 "rpkm", "arg_copies", "copies_per_16s", "copies_per_16s_low95", "copies_per_16s_high95", "dispersion", "reads_analysed", "mean_read_length", "reads_16s",
                 "bases_16s", "copies_16s", "card_version", "card_validated", "count_mode", "layout", "n_files", "reads_raw", "reads_after_qc",
                 "host_removal", "host_reads_removed", "status", "note")
clash <- intersect(meta_cols, OUTPUT_COLS)
if (length(clash)) stop("Samplesheet column(s) ", paste(clash, collapse = ", "), " have the same name as an output column. ",
                        "Rename them in the samplesheet; nothing has been renamed for you.")
meta <- unique(sheet[, c("sample", meta_cols), drop = FALSE])
dup <- unique(meta$sample[duplicated(meta$sample)])
if (length(dup)) stop("Samplesheet rows of the same sample disagree on study metadata: ", paste(dup, collapse = ", "),
                      ". Each sample has one value per column; nothing has been assumed.")

# 6. Denominators, per sample ------------------------------------------------------
# 16S copies: each alignment's covered bases over its own SILVA reference's
# length, summed (COUNT_16S; D20). length_16s is no longer used for this.
den <- merge(flow, rrna[, c("sample", "reads_16s", "bases_16s", "copies_16s", "short_16s", "low_identity_16s")], by = "sample", all.x = TRUE)
den$status <- ifelse(den$reads_after_qc == 0, "no reads left after QC",
              ifelse(den$reads_analysed == 0, "no reads left after host removal", "analysed"))
den$note <- ifelse(den$status != "analysed", "Zero ARGs (no reads to look in); copies per 16S copy missing (NA).",
            ifelse(den$reads_16s == 0, "No 16S reads: copies per 16S copy are missing (NA), not zero or infinite.", ""))
den$card_version   <- card_version
den$card_validated <- card_ok
den$count_mode     <- count_mode

# 7. Measures and the detection call, per hit --------------------------------------
long <- merge(hits, den[, c("sample", "reads_analysed", "mean_read_length", "reads_16s", "bases_16s", "copies_16s")], by = "sample")
long <- merge(long, stats, by = c("sample", "aro_accession"), all.x = TRUE)
# RGI's own per-gene coverage is kept for reference (rgi_percent_coverage);
# detection uses the read statistics (D20). Gene length: the ARO's CARD
# reference; RGI's if that is missing.
long$rgi_percent_coverage <- long$average_percent_coverage
has <- !is.na(long$stat_reads)
# reads = the reads kept, those matching the CARD reference at or above
# min_read_identity one by one (D23); RGI's own count includes the others,
# reported as reads_below_identity.
long$reads <- ifelse(has, long$stat_reads, long$reads)
long$reads_below_identity <- ifelse(has, long$reads_below_identity, 0)
long$reference_length_bp <- ifelse(has & !is.na(long$canonical_length), long$canonical_length, long$reference_length_bp)
long$average_percent_coverage  <- ifelse(has, long$pct_covered, long$average_percent_coverage)
L <- long$reference_length_bp
long$read_identity <- ifelse(!is.na(long$aligned_bases) & long$aligned_bases > 0, 1 - long$mismatches / long$aligned_bases, NA)
long$expected_percent_coverage <- ifelse(has, long$pct_expected, 100 * (1 - exp(-long$reads * long$mean_read_length / L)))
long$breadth_ratio <- ifelse(has, long$ratio, long$average_percent_coverage / long$expected_percent_coverage)
id_ok <- min_identity <= 0 | (!is.na(long$read_identity) & long$read_identity >= min_identity)
# Share of a gene's reads that pass the identity (D24): at least
# min_identity_share. Reads from a look-alike gene that happen to match well
# in a shared stretch are a minority of its reads (LptD, eptB: 7-40%); a real
# gene's reads mostly match, even if a few junk reads land on it.
share <- ifelse(long$reads + long$reads_below_identity > 0, long$reads / (long$reads + long$reads_below_identity), 0)
share_ok <- min_identity <= 0 | min_share <= 0 | share >= min_share
id_ok <- id_ok & share_ok    # also keeps look-alikes out of allele merging (D22)
long$detected <- long$reads >= min_reads & long$breadth_ratio >= min_ratio & id_ok
long$detection_note <- ifelse(long$detected, "",
  ifelse(long$reads < min_reads & long$reads_below_identity > 0,
         sprintf("fewer than %g reads match the CARD reference at %.0f%% identity or more (%g did; %g below): likely a related gene that only resembles it",
                 min_reads, 100 * read_filter, long$reads, long$reads_below_identity),
  ifelse(long$reads < min_reads, sprintf("fewer than %g reads", min_reads),
  ifelse(!share_ok,
         sprintf("only %g of %g reads (%.0f%%; < %.0f%%) match the CARD reference at %.0f%% identity or more: likely a related gene that only resembles it",
                 long$reads, long$reads + long$reads_below_identity, 100 * share, 100 * min_share, 100 * min_identity),
  ifelse(long$breadth_ratio < min_ratio,
         sprintf("reads cover %.0f%% of the gene; reads landing at random would cover %.0f%% (ratio %.2f < %g): likely a shared domain of another gene",
                 long$average_percent_coverage, long$expected_percent_coverage, long$breadth_ratio, min_ratio),
         sprintf("reads match the CARD reference at %.1f%% identity (< %.1f%%): likely a related gene that only resembles it",
                 100 * long$read_identity, 100 * min_identity))))))
long$detected_by <- ifelse(long$detected, if (count_mode == "protein") "f70g90" else "dna", "")
if (core_on && nrow(cstats)) {
  ci  <- match(paste(long$sample, long$aro_accession), paste(cstats$sample, cstats$aro_accession))
  cid <- 1 - cstats$mismatches[ci] / cstats$aligned_bases[ci]
  take <- which(!long$detected & !is.na(ci) & cstats$stat_reads[ci] >= min_reads & is.finite(cid) & cid >= core_gene &
                cstats$ratio[ci] >= core_ratio)
  for (k in take) {
    j <- ci[k]
    matched <- long$reads[k] + long$reads_below_identity[k]
    long$reads[k]                    <- cstats$stat_reads[j]
    long$reads_below_identity[k]     <- matched - cstats$stat_reads[j]
    long$aligned_bases[k]            <- cstats$aligned_bases[j]
    long$mismatches[k]               <- cstats$mismatches[j]
    long$average_percent_coverage[k] <- cstats$pct_covered[j]
    long$expected_percent_coverage[k] <- cstats$pct_expected[j]
    long$breadth_ratio[k]            <- cstats$ratio[j]
    long$dispersion[k]               <- cstats$dispersion[j]
    long$read_identity[k]            <- cid[k]
    long$detected[k]                 <- TRUE
    long$detection_note[k]           <- ""
    long$detected_by[k]              <- "high_identity"
  }
}
long$call <- ifelse(long$detected, "detected", "")
if (count_mode == "protein" && probable_gene > 0) {
  prob <- !long$detected & has & long$reads >= min_reads & long$breadth_ratio >= min_ratio &
          !is.na(long$read_identity) & long$read_identity >= probable_gene & long$read_identity < min_identity
  long$call[prob] <- "probable_homolog"
}
long$rpm  <- long$reads / long$reads_analysed * 1e6
long$rpkm <- long$reads / (L / 1e3) / (long$reads_analysed / 1e6)

# Alleles (D22): reads of an undetected near-identical allele counted under
# the detected gene. Only genes that failed on read count or breadth: one
# whose reads match it poorly (identity rule) is a different gene.
long$merged_reads <- rep(0, nrow(long)); long$merged_aligned_bases <- rep(0, nrow(long)); long$merged_from <- rep("", nrow(long))
if (min_allele > 0) {
  al <- read_tsv(allele_file)
  if (length(setdiff(c("aro_a", "aro_b", "identity"), names(al))))
    stop(basename(allele_file), ": allele table lacks aro_a, aro_b or identity; nothing was written.")
  al$identity <- num(al$identity)
  al <- al[al$identity >= min_allele & al$aro_a != al$aro_b, ]
  long$own_aligned <- ifelse(is.na(long$aligned_bases), long$reads * long$mean_read_length, long$aligned_bases)
  for (s in unique(long$sample)) {
    rows <- which(long$sample == s)
    dets <- rows[long$detected[rows]]
    cand <- rows[!long$detected[rows] & long$reads[rows] > 0 & id_ok[rows]]
    for (u in cand) {
      p <- al[al$aro_a == long$aro_accession[u], ]
      d <- dets[long$aro_accession[dets] %in% p$aro_b]
      if (!length(d)) next
      idn <- p$identity[match(long$aro_accession[d], p$aro_b)]
      d <- d[order(-idn, -long$reads[d])][1]
      long$merged_reads[d] <- long$merged_reads[d] + long$reads[u]
      long$merged_aligned_bases[d] <- long$merged_aligned_bases[d] + long$own_aligned[u]
      long$merged_from[d] <- paste(c(if (nzchar(long$merged_from[d])) long$merged_from[d], long$aro_term[u]), collapse = ";")
      long$detection_note[u] <- sprintf("%s; its reads are counted under %s (an allele: CARD references %.1f%% identical)",
                                        long$detection_note[u], long$aro_term[d], 100 * max(idn))
    }
  }
  long$own_aligned <- NULL
}

# Copies from the reference bases reads cover, as for 16S (D13): a read
# hanging over a gene end covers only part of it (D19). Read-based if the
# statistics are missing for a hit (never expected; the bookkeeping checks
# that every sample has them). Merged alleles' bases count over this gene's
# length (D22).
long$arg_copies <- (ifelse(is.na(long$aligned_bases), long$reads * long$mean_read_length, long$aligned_bases) +
                    long$merged_aligned_bases) / L
long$copies_per_16s <- ifelse(long$reads_16s > 0, long$arg_copies / long$copies_16s, NA)
# 95% interval for copies_per_16s (D20): the read count treated as Poisson
# (exact gamma limits), widened by the gene's clumping of read starts when
# above 1 (effective reads = reads / dispersion). It covers counting noise
# only, not bias from CARD's reference choice; 16S counts are in the
# thousands, so their own noise is left out. Merged reads count (D22).
infl <- pmax(1, ifelse(is.na(long$dispersion), 1, long$dispersion))
neff <- (long$reads + long$merged_reads) / infl
long$copies_per_16s_low95  <- ifelse(is.na(long$copies_per_16s) | neff <= 0, NA,
                                     long$copies_per_16s * qgamma(0.025, neff) / neff)
long$copies_per_16s_high95 <- ifelse(is.na(long$copies_per_16s) | neff <= 0, NA,
                                     long$copies_per_16s * qgamma(0.975, neff + 1) / neff)
long$card_version   <- rep(card_version, nrow(long))
long$card_validated <- rep(card_ok, nrow(long))
long$count_mode     <- rep(count_mode, nrow(long))
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
                  "host_reads_removed", "reads_analysed", "mean_read_length", "reads_16s", "bases_16s", "short_16s", "low_identity_16s", "copies_16s",
                  "card_version", "card_validated", "count_mode", meta_cols)],
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
        sprintf("seq-resistome %s. %s. ARG reads counted by %s (count_mode %s).", pipe_version, card_line,
                if (count_mode == "dna") "RGI bwt" else "DIAMOND blastx", count_mode), "",
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
        if (count_mode == "dna") "- **reads**: reads mapped to a CARD gene by RGI bwt (each mate of a pair counts once)." else
          sprintf("- **reads**: reads whose translated sequence matches a CARD protein best, at %.0f%% amino-acid identity or more, found by DIAMOND blastx (each mate of a pair counts once).", 100 * read_filter),
        "- **rpm**: reads per million reads analysed (after QC and host removal).",
        "- **rpkm**: reads per kilobase of the CARD reference gene per million reads analysed.",
        paste("- **copies_per_16s**:", CAVEAT_16S),
        sprintf(paste("- **detected**: at least %g reads, spread along the gene at least %g times as widely as reads landing",
                      "at random would be%s. Hits that fail are kept in arg_long.tsv with the reason, and left out of the matrices."),
                min_reads, min_ratio, if (min_identity > 0) sprintf(", matching the CARD reference at %.0f%% %sidentity or more on average", 100 * min_identity,
                                                                       if (count_mode == "protein") "amino-acid " else "") else ""),
        if (core_on) sprintf(paste("- **detected_by**: f70g90 = the gene's kept reads average %.0f%% or more together; high_identity = they do not, but its reads at %.0f%% identity or more alone (at least %g, averaging %.0f%% or more, spread %g times as widely as random reads) are enough, as when other organisms' related genes dilute a real gene in a mixture. Such a gene's reads, copies and identity count only those reads."),
                             100 * min_identity, 100 * core_read, min_reads, 100 * core_gene, core_ratio),
        if (count_mode == "protein" && probable_gene > 0) sprintf("- **call**: detected, or probable_homolog = the gene fails detection only because its reads average %.0f%% to under %.0f%% amino-acid identity to the CARD protein (with at least %g reads, spread %g times as widely as random reads). A probable homolog is a related gene that may be the real one with a distant sequence; it is reported, never counted as detected, and has no copies per 16S copy.", 100 * probable_gene, 100 * min_identity, min_reads, min_ratio),
        "- Only CARD's protein homolog models are searched: genes whose presence alone confers resistance. Resistance by point mutation (e.g. in gyrA) cannot be called from reads mapped this way and is not reported.",
        if (count_mode == "protein") "- Gene lengths, aligned bases and coverage are protein lengths times 3 (the coding sequence), so rpkm and copies are on the same scale as in DNA mode. rgi_percent_coverage, completely_mapped_reads and average_mapq are RGI's and are missing (NA) in protein mode.",
        "- Counts are of reads, not organisms: which organisms carry these genes, and whether on plasmids, is for later versions.")
writeLines(md, "resistome_summary.md")
cat(sprintf("resistome_tables.R: %d samples, %d gene hits (%d detected), %d left out\n",
            nrow(den), nrow(long), sum(long$detected), nrow(left)))
