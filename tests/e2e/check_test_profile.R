#!/usr/bin/env Rscript
#*******************************************************************************
# check_test_profile.R: check a -profile test run's results (CLAUDE.md D10)
#
# Every sample is in every table, with the status and the genes expected
# (tests/e2e/expected.tsv); copies per 16S copy are never infinite and are
# missing exactly where there is no 16S denominator; the measures agree with
# their definitions; every table states the CARD release and the 16S caveat;
# no reads are published; every tool's version is recorded.
#
# Usage:  Rscript tests/e2e/check_test_profile.R <outdir> [expected.tsv]
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
out  <- if (length(args) >= 1) args[1] else "results"
expf <- if (length(args) >= 2) args[2] else "tests/e2e/expected.tsv"
fails <- character(0)
check <- function(ok, msg) if (!isTRUE(all(ok))) fails <<- c(fails, msg)
rd <- function(f) read.delim(file.path(out, f), comment.char = "#", check.names = FALSE, stringsAsFactors = FALSE,
                             na.strings = "NA", quote = "")

exp  <- read.delim(expf, stringsAsFactors = FALSE, na.strings = "NA", colClasses = "character", quote = "")
den  <- rd("denominators.tsv")
long <- rd("arg_long.tsv")
left <- rd("samples_left_out.tsv")

# Every expected sample analysed or left out, nothing else.
check(setequal(c(den$sample, left$sample), exp$sample), sprintf("samples in results (%s) differ from expected (%s)",
      paste(sort(c(den$sample, left$sample)), collapse = ","), paste(sort(exp$sample), collapse = ",")))
for (i in seq_len(nrow(exp))) {
  e <- exp[i, ]; s <- e$sample
  if (e$status == "left out") {
    check(s %in% left$sample && nzchar(left$reason[left$sample == s]), paste(s, "should be left out, with a reason"))
    # For a left-out sample, must_detect holds text its reason must contain.
    if (nzchar(e$must_detect) && s %in% left$sample)
      check(grepl(e$must_detect, left$reason[left$sample == s], fixed = TRUE), sprintf("%s: reason '%s' lacks '%s'", s, left$reason[left$sample == s], e$must_detect))
    next
  }
  d <- den[den$sample == s, ]
  check(nrow(d) == 1 && d$status == e$status, sprintf("%s: status '%s', expected '%s'", s, d$status, e$status))
  if (!is.na(e$has_16s)) check((d$reads_16s > 0) == as.logical(e$has_16s), sprintf("%s: 16S reads %s", s, d$reads_16s))
  det <- long$aro_term[long$sample == s & long$detected]
  check(length(det) >= as.numeric(e$min_detected), sprintf("%s: %d genes detected, expected at least %s", s, length(det), e$min_detected))
  if (as.numeric(e$min_detected) == 0) check(length(det) == 0, sprintf("%s: %d genes detected, expected none", s, length(det)))
  for (g in strsplit(e$must_detect, ";")[[1]]) check(g %in% det, sprintf("%s: %s not detected", s, g))
  for (g in strsplit(e$must_not_detect, ";")[[1]]) check(!(g %in% det), sprintf("%s: %s detected but should not be", s, g))
}

# Copies per 16S copy: never infinite; missing exactly where 16S is 0 or missing.
for (f in c("arg_long.tsv", "arg_copies_per_16s.tsv")) {
  x <- rd(f); v <- unlist(x[, setdiff(names(x), c("sample", "aro_accession", "aro_term", "amr_gene_family", "drug_class", "resistance_mechanism", "model_type", "detection_note", "card_version", "status", "note", "layout", "host_removal")), drop = FALSE])
  check(!any(is.infinite(suppressWarnings(as.numeric(v)))), paste(f, "holds an infinite value"))
}
no16 <- den$sample[is.na(den$reads_16s) | den$reads_16s == 0]
cp <- rd("arg_copies_per_16s.tsv")
for (s in den$sample) {
  check(s %in% names(cp), paste("arg_copies_per_16s.tsv has no column for", s))
  if (s %in% no16 && nrow(cp)) check(all(is.na(cp[[s]])), paste(s, "has no 16S reads but has copies per 16S copy"))
  if (!(s %in% no16) && nrow(cp)) check(!any(is.na(cp[[s]])), paste(s, "has 16S reads but missing copies per 16S copy"))
}
check(all(is.na(long$copies_per_16s[long$sample %in% no16])), "arg_long.tsv: copies_per_16s present where there is no 16S denominator")

# The measures agree with their definitions (recomputed here).
near <- function(a, b) all(abs(a - b) <= 1e-4 * pmax(1, abs(b)), na.rm = TRUE)
check(near(long$rpm, long$reads / long$reads_analysed * 1e6), "rpm does not match reads / reads analysed x 1e6")
check(near(long$rpkm, long$reads / (long$reference_length_bp / 1e3) / (long$reads_analysed / 1e6)), "rpkm does not match its definition")
check(near(long$copies_per_16s, (long$reads / long$reference_length_bp) / (long$reads_16s / 1542)), "copies_per_16s does not match its definition")
check(near(den$reads_analysed, den$reads_after_qc - den$host_reads_removed), "reads analysed != reads after QC - host reads removed")
for (m in c("reads", "rpm", "rpkm")) {
  x <- rd(sprintf("arg_%s.tsv", m))
  check(setequal(intersect(names(x), den$sample), den$sample), sprintf("arg_%s.tsv lacks a column for some sample", m))
  check(nrow(x) == length(unique(long$aro_accession[long$detected])), sprintf("arg_%s.tsv rows != detected genes", m))
}
check(all(c("site", "day") %in% names(long)) && all(c("site", "day") %in% names(den)), "study metadata columns not carried through")

# Every table states the CARD release and the 16S caveat in its header.
for (f in c("arg_long.tsv", "arg_reads.tsv", "arg_rpm.tsv", "arg_rpkm.tsv", "arg_copies_per_16s.tsv", "denominators.tsv", "samples_left_out.tsv")) {
  h <- readLines(file.path(out, f), n = 2)
  check(grepl("CARD [0-9.]+", h[1]), paste(f, "does not state the CARD release"))
  check(grepl("16S", h[2]) && grepl("not ARGs per cell", h[2]), paste(f, "does not state the 16S copy-number caveat"))
}
check(any(grepl("CARD [0-9.]+", readLines(file.path(out, "resistome_summary.md")))), "summary does not state the CARD release")

# No reads published, by any step.
all_files <- list.files(out, recursive = TRUE)
reads_like <- grep("\\.(fastq|fq|bam|sam|cram)(\\.gz)?$", all_files, value = TRUE)
check(length(reads_like) == 0, paste("reads published:", paste(reads_like, collapse = ", ")))

# Every tool's version recorded, and the CARD release RGI used.
v <- read.delim(file.path(out, "pipeline_info", "software_versions.tsv"), stringsAsFactors = FALSE)
for (t in c("fastp", "hostile", "rgi", "kma", "sortmerna", "R", "rgi-database"))
  check(t %in% v$tool, paste("no version recorded for", t))
check(all(v$version[v$tool == "rgi-database"] == den$card_version[1]), "RGI's database version differs from the CARD release reported")

if (length(fails)) {
  cat("FAILED:\n", paste0("  - ", fails, collapse = "\n"), "\n", sep = "")
  quit(status = 1)
}
cat(sprintf("check_test_profile.R: all checks passed (%d samples analysed, %d left out, %d detected gene calls)\n",
            nrow(den), nrow(left), sum(long$detected)))
