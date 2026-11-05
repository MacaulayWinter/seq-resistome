#!/usr/bin/env Rscript
#*******************************************************************************
# score_V1.R: score validation V1 against its pre-registered marks
#             (PREREGISTRATION.md section 3, marks 1-4; mark 5 and E4 are
#             scored from their run logs by run_V1.sh)
#
# Truth comes from the assemblies (truth.sh): RGI main Perfect/Strict
# protein homolog hits (copies per genome = number of hits), Loose hits with
# Best Identities >= 80% as explainable, barrnap full-length 16S genes.
#
# A gene "family" is CARD's AMR Gene Family string exactly as CARD gives it
# (the same string in RGI main and RGI bwt for the same gene). Detection
# accepts the truth ARO itself or any detected ARO with the same family.
#
# Usage:  Rscript validation/V1/score_V1.R <pipeline_outdir> <truth_dir> <out_dir>
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
res_dir <- args[1]; truth_dir <- args[2]; out <- args[3]
dir.create(out, showWarnings = FALSE, recursive = TRUE)
rd <- function(f) read.delim(f, comment.char = "#", check.names = FALSE, stringsAsFactors = FALSE, quote = "", na.strings = "NA")

long <- rd(file.path(res_dir, "arg_long.tsv"))
den  <- rd(file.path(res_dir, "denominators.tsv"))
det  <- long[long$detected, ]

# 1. Truth -------------------------------------------------------------------------
rgi_main <- function(g, which) {
  f <- file.path(truth_dir, sprintf("%s.%s.txt", g, which))
  x <- read.delim(f, check.names = FALSE, stringsAsFactors = FALSE, quote = "")
  x[x$Model_type == "protein homolog model", , drop = FALSE]
}
truth_of <- function(g) {
  x <- rgi_main(g, "strict"); x <- x[x$Cut_Off %in% c("Perfect", "Strict"), ]
  if (!nrow(x)) return(data.frame(genome = character(0), aro_accession = character(0), aro_term = character(0), family = character(0), copies = numeric(0)))
  a <- aggregate(list(copies = rep(1, nrow(x))), by = list(aro_accession = as.character(x$ARO), aro_term = x$Best_Hit_ARO, family = x$`AMR Gene Family`), FUN = sum)
  cbind(genome = g, a, stringsAsFactors = FALSE)
}
explainable_of <- function(g) {
  x <- rgi_main(g, "loose")
  unique(x$`AMR Gene Family`[x$Cut_Off %in% c("Perfect", "Strict") | (x$Cut_Off == "Loose" & x$Best_Identities >= 80)])
}
n16_of <- function(g) {
  gff <- readLines(file.path(truth_dir, sprintf("%s.barrnap.gff", g)))
  sum(grepl("Name=16S_rRNA", gff) & !grepl("partial", gff))
}
genomes <- unique(den$spike[den$kind %in% c("pure", "mixture")])
truth <- do.call(rbind, lapply(genomes, truth_of))
n16 <- setNames(vapply(genomes, n16_of, 0), genomes)
write.table(truth, file.path(out, "truth_args.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(data.frame(genome = names(n16), copies_16s = n16), file.path(out, "truth_16s.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
glen <- function(g) sum(nchar(grep("^>", readLines(file.path(dirname(truth_dir), "genomes", paste0(g, ".fna"))), value = TRUE, invert = TRUE)))
genome_len <- setNames(vapply(genomes, glen, 0), genomes)

bg_families <- function(bg) unique(det$amr_gene_family[det$sample == paste0("bg_", bg)])
families_in <- function(s) unique(det$amr_gene_family[det$sample == s])

# 2. Mark 1: detection (mixtures at 2x and 8x) ---------------------------------------
mix <- den[den$kind == "mixture", ]
d_rows <- do.call(rbind, lapply(seq_len(nrow(mix)), function(i) {
  s <- mix$sample[i]; g <- mix$spike[i]; t <- truth[truth$genome == g, ]
  if (!nrow(t)) return(NULL)
  d <- det[det$sample == s, ]
  data.frame(sample = s, background = mix$background[i], genome = g, depth = mix$spike_depth[i],
             aro_accession = t$aro_accession, aro_term = t$aro_term, family = t$family,
             exact_aro = t$aro_accession %in% as.character(d$aro_accession),
             found = t$aro_accession %in% as.character(d$aro_accession) | t$family %in% d$amr_gene_family,
             marked = mix$spike_depth[i] >= 1, stringsAsFactors = FALSE)
}))
write.table(d_rows, file.path(out, "mark1_detection.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
m1 <- d_rows[d_rows$marked, ]
mark1 <- all(m1$found)

# 3. Mark 2: specificity (every mixture, pure and edge sample) -------------------
scored <- den[den$kind %in% c("mixture", "pure", "edge_no_arg", "edge_no_16s", "edge_host_only"), ]
s_rows <- do.call(rbind, lapply(seq_len(nrow(scored)), function(i) {
  s <- scored$sample[i]; g <- scored$spike[i]; bg <- scored$background[i]
  fams <- families_in(s)
  if (!length(fams)) return(NULL)
  ok_truth <- if (g %in% genomes) unique(truth$family[truth$genome == g]) else character(0)
  ok_loose <- if (g %in% genomes) explainable_of(g) else if (g %in% c("NC_000908.2", "NC_001416.1")) explainable_of(g) else character(0)
  ok_bg    <- if (bg %in% c("gut", "wastewater")) bg_families(bg) else character(0)
  data.frame(sample = s, family = fams,
             explained_by = ifelse(fams %in% ok_truth, "spike truth", ifelse(fams %in% ok_loose, "spike Loose homolog (>= 80%)",
                            ifelse(fams %in% ok_bg, "background alone", "UNEXPLAINED"))),
             aros = vapply(fams, function(f) paste(unique(det$aro_term[det$sample == s & det$amr_gene_family == f]), collapse = ";"), ""),
             stringsAsFactors = FALSE)
}))
if (is.null(s_rows)) s_rows <- data.frame(sample = character(0), family = character(0), explained_by = character(0), aros = character(0))
write.table(s_rows, file.path(out, "mark2_specificity.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
mark2 <- !any(s_rows$explained_by == "UNEXPLAINED")

# 4. Mark 3: accuracy of copies per 16S copy -------------------------------------------
obs_family <- function(s, f) sum(det$copies_per_16s[det$sample == s & det$amr_gene_family == f])
fam_truth <- aggregate(copies ~ genome + family, data = truth, FUN = sum)
a_rows <- list()
for (i in which(den$kind == "pure")) {
  s <- den$sample[i]; g <- den$spike[i]
  for (f in fam_truth$family[fam_truth$genome == g]) {
    tv <- fam_truth$copies[fam_truth$genome == g & fam_truth$family == f] / n16[[g]]
    a_rows[[length(a_rows) + 1]] <- data.frame(sample = s, kind = "pure", genome = g, depth = den$spike_depth[i], family = f,
                                               truth = tv, observed = obs_family(s, f), limit = 1.5)
  }
}
for (i in which(den$kind == "mixture" & den$spike_depth == 8)) {
  s <- den$sample[i]; g <- den$spike[i]; bg <- paste0("bg_", den$background[i])
  spike_reads <- den$reads_raw[i] - den$reads_raw[den$sample == bg]
  D <- spike_reads * 150 / genome_len[[g]]          # actual depth simulated over the genome
  bg16 <- den$copies_16s[den$sample == bg]
  for (f in setdiff(fam_truth$family[fam_truth$genome == g], bg_families(den$background[i]))) {
    tv <- fam_truth$copies[fam_truth$genome == g & fam_truth$family == f] * D / (n16[[g]] * D + bg16)
    a_rows[[length(a_rows) + 1]] <- data.frame(sample = s, kind = "mixture", genome = g, depth = D, family = f,
                                               truth = tv, observed = obs_family(s, f), limit = 2)
  }
}
acc <- do.call(rbind, a_rows)
acc$ratio <- acc$observed / acc$truth
acc$within <- acc$ratio >= 1 / acc$limit & acc$ratio <= acc$limit
write.table(acc, file.path(out, "mark3_accuracy.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
mark3 <- all(acc$within)

# 5. Mark 4: edge cases E1-E3 ----------------------------------------------------------
edge <- function(s) den[den$sample == s, ]
e1 <- edge("E1_mgenitalium"); e2 <- edge("E2_lambda"); e3 <- edge("E3_host")
cp <- rd(file.path(res_dir, "arg_copies_per_16s.tsv"))
e_rows <- data.frame(
  case = c("E1 no ARGs, has 16S", "E2 no 16S, no ARGs", "E3 only host"),
  passed = c(
    nrow(e1) == 1 && sum(det$sample == "E1_mgenitalium") == 0 && e1$reads_16s > 0 && (!nrow(cp) || all(cp$E1_mgenitalium == 0)),
    nrow(e2) == 1 && sum(det$sample == "E2_lambda") == 0 && e2$reads_16s == 0 && grepl("missing \\(NA\\)", e2$note) &&
      (!nrow(cp) || all(is.na(cp$E2_lambda))) && all(is.na(long$copies_per_16s[long$sample == "E2_lambda"])),
    nrow(e3) == 1 && (e3$status == "no reads left after host removal" ||
                      (sum(det$sample == "E3_host") == 0 && e3$host_reads_removed / e3$reads_after_qc >= 0.99))),
  detail = c(sprintf("detected %d, 16S reads %s", sum(det$sample == "E1_mgenitalium"), e1$reads_16s),
             sprintf("detected %d, 16S reads %s, note: %s", sum(det$sample == "E2_lambda"), e2$reads_16s, e2$note),
             sprintf("status %s; host removed %s of %s reads", e3$status, e3$host_reads_removed, e3$reads_after_qc)),
  stringsAsFactors = FALSE)
write.table(e_rows, file.path(out, "mark4_edge_cases.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
mark4 <- all(e_rows$passed)

# 6. Reported, not marked ---------------------------------------------------------------
pure16 <- den[den$kind == "pure", ]
pure16$depth_actual <- (pure16$reads_raw) * 150 / genome_len[pure16$spike]
pure16$truth_16s_copies <- n16[pure16$spike] * pure16$depth_actual
pure16$ratio_16s <- pure16$copies_16s / pure16$truth_16s_copies
write.table(pure16[, c("sample", "spike", "depth_actual", "reads_16s", "copies_16s", "truth_16s_copies", "ratio_16s")],
            file.path(out, "reported_16s_pure.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# 7. Summary ----------------------------------------------------------------------------
pf <- function(x) if (x) "PASS" else "FAIL"
lowd <- d_rows[!d_rows$marked, ]
md <- c("# Validation V1: marks 1-4", "",
        sprintf("Scored from `%s` (pipeline results) and `%s` (truth).", basename(normalizePath(res_dir)), basename(normalizePath(truth_dir))), "",
        "| Mark | Result | Detail |", "|---|---|---|",
        sprintf("| 1. Detection (2x and 8x mixtures) | **%s** | %d of %d truth genes found (same ARO or same AMR gene family); exact ARO %d of %d |",
                pf(mark1), sum(m1$found), nrow(m1), sum(m1$exact_aro), nrow(m1)),
        sprintf("| 2. Specificity | **%s** | %d unexplained families in %d samples scored |", pf(mark2), sum(s_rows$explained_by == "UNEXPLAINED"), nrow(scored)),
        sprintf("| 3. Accuracy, copies per 16S copy | **%s** | pure genomes %d of %d families within 1.5x; 8x mixtures %d of %d within 2x; ratio range %.2f-%.2f |",
                pf(mark3), sum(acc$within[acc$kind == "pure"]), sum(acc$kind == "pure"), sum(acc$within[acc$kind == "mixture"]),
                sum(acc$kind == "mixture"), min(acc$ratio), max(acc$ratio)),
        sprintf("| 4. Edge cases E1-E3 | **%s** | %s |", pf(mark4), paste(sprintf("%s: %s", e_rows$case, ifelse(e_rows$passed, "pass", "FAIL")), collapse = "; ")),
        "", "Reported, not marked:", "",
        sprintf("- Detection at 0.5x: %d of %d truth genes found.", sum(lowd$found), nrow(lowd)),
        sprintf("- 16S copies estimated / truth on pure genomes: %s.", paste(sprintf("%s %.2f", pure16$spike, pure16$ratio_16s), collapse = ", ")))
if (!mark1) md <- c(md, "", "Missed truth genes (marked depths):", "", sprintf("- %s: %s (%s)", m1$sample[!m1$found], m1$aro_term[!m1$found], m1$family[!m1$found]))
if (!mark2) { u <- s_rows[s_rows$explained_by == "UNEXPLAINED", ]; md <- c(md, "", "Unexplained families:", "", sprintf("- %s: %s (%s)", u$sample, u$family, u$aros)) }
if (!mark3) { b <- acc[!acc$within, ]; md <- c(md, "", "Outside the accuracy limit:", "", sprintf("- %s: %s, observed %.3g, truth %.3g (ratio %.2f, limit %gx)", b$sample, b$family, b$observed, b$truth, b$ratio, b$limit)) }
writeLines(md, file.path(out, "V1_marks_1-4.md"))
cat(md, sep = "\n")
