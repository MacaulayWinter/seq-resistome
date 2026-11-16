#!/usr/bin/env Rscript
#*******************************************************************************
# apply_identity.R: re-call detection at a candidate --min_read_identity on a
#                   finished run's tables (development only, D19)
#
# Reads <in_dir>/arg_long.tsv and denominators.tsv from a run made with the
# identity check off, adds the identity condition to `detected`, and writes
# arg_long.tsv, denominators.tsv and arg_copies_per_16s.tsv to <out_dir>, so
# score_V1_round3.R can score the candidate without re-running the pipeline.
# Copies are not changed by the threshold, only which genes are detected.
#
# Usage:  Rscript validation/V1/apply_identity.R <in_dir> <min_identity> <out_dir>
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
in_dir <- args[1]; t <- as.numeric(args[2]); out <- args[3]
dir.create(out, showWarnings = FALSE, recursive = TRUE)
rd <- function(f) read.delim(file.path(in_dir, f), comment.char = "#", check.names = FALSE, stringsAsFactors = FALSE, quote = "")
long <- rd("arg_long.tsv"); den <- rd("denominators.tsv")
long$detected <- long$detected & !is.na(long$read_identity) & long$read_identity >= t
genes <- unique(long[long$detected, c("aro_accession", "aro_term")])
mat <- genes
for (s in den$sample) {
  v <- long[long$detected & long$sample == s, ]
  no16 <- is.na(den$reads_16s[den$sample == s]) || den$reads_16s[den$sample == s] == 0
  x <- v$copies_per_16s[match(genes$aro_accession, v$aro_accession)]
  mat[[s]] <- if (no16) rep(NA_real_, nrow(genes)) else ifelse(is.na(x), 0, x)
}
w <- function(d, f) write.table(d, file.path(out, f), sep = "\t", quote = FALSE, row.names = FALSE, na = "NA")
w(long, "arg_long.tsv"); w(den, "denominators.tsv"); w(mat, "arg_copies_per_16s.tsv")
cat(sprintf("min_read_identity %.2f: %d of %d hits detected\n", t, sum(long$detected), nrow(long)))
