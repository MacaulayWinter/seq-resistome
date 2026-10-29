#!/usr/bin/env Rscript
#*******************************************************************************
# score_V1_round3.R: score validation V1 round 3, by location
#                    (PREREGISTRATION_round3.md; marks 1-4; mark 5 and E4 are
#                    scored by run_V1.sh and run_E4.sh)
#
# Truth: RGI main Perfect/Strict protein homolog hits findable by reads
# (truth_findable.sh), each a locus (contig, start, stop). Protein-only hits
# are listed, never scored. Where CARD genes lie: locate.sh (BLASTN HSPs of
# >= 80% identity). An ARO lies at a locus if an HSP overlaps it by >= 50% of
# the locus length; it is present in a genome if an HSP covers >= 50% of the
# reference. Loci joined by an ARO that lies at both form one accuracy group.
#
# Usage:  Rscript validation/V1/score_V1_round3.R <pipeline_outdir> <truth_dir> <out_dir>
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
res_dir <- args[1]; truth_dir <- args[2]; out <- args[3]
dir.create(out, showWarnings = FALSE, recursive = TRUE)
rd <- function(f) read.delim(f, comment.char = "#", check.names = FALSE, stringsAsFactors = FALSE, quote = "", na.strings = "NA")

long <- rd(file.path(res_dir, "arg_long.tsv"))
den  <- rd(file.path(res_dir, "denominators.tsv"))
long$aro_accession <- as.character(long$aro_accession)
det  <- long[long$detected, ]
terms <- function(f) unique(trimws(unlist(strsplit(f, ";", fixed = TRUE))))
share_any <- function(f, labels) length(labels) > 0 && any(vapply(labels, function(l) length(intersect(terms(f), terms(l))) > 0, TRUE))

# 1. Truth loci, protein-only hits, locations --------------------------------------
rgi_main <- function(g) {
  x <- read.delim(file.path(truth_dir, sprintf("%s.strict.txt", g)), check.names = FALSE, stringsAsFactors = FALSE, quote = "")
  x <- x[x$Model_type == "protein homolog model" & x$Cut_Off %in% c("Perfect", "Strict"), , drop = FALSE]
  fz <- read.delim(file.path(truth_dir, sprintf("%s.findable.tsv", g)), stringsAsFactors = FALSE)
  x$orf <- sub(" .*", "", x$ORF_ID)
  x$findable <- fz$findable[match(x$orf, fz$orf_id)] %in% TRUE
  x$best_dna_identity <- fz$best_identity[match(x$orf, fz$orf_id)]
  data.frame(genome = rep(g, nrow(x)), orf = x$orf, aro_accession = as.character(x$ARO), aro_term = x$Best_Hit_ARO,
             family = x$`AMR Gene Family`, contig = sub("_[0-9]+$", "", x$Contig), start = pmin(x$Start, x$Stop),
             stop = pmax(x$Start, x$Stop), findable = x$findable, protein_identity = x$Best_Identities,
             best_dna_identity = x$best_dna_identity, stringsAsFactors = FALSE)
}
locate <- function(g) {
  x <- read.delim(file.path(truth_dir, sprintf("%s.locate.tsv", g)), stringsAsFactors = FALSE, colClasses = c(aro_accession = "character"))
  x
}
genomes <- unique(den$spike[den$kind %in% c("pure", "mixture")])
edge_genomes <- unique(den$spike[den$kind %in% c("edge_no_arg", "edge_no_16s")])
hits <- do.call(rbind, lapply(genomes, rgi_main))
loci <- hits[hits$findable, ]
loci$locus <- sprintf("%s:%s:%d-%d", loci$genome, loci$contig, loci$start, loci$stop)
prot_only <- hits[!hits$findable, ]
write.table(loci, file.path(out, "truth_loci.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(prot_only, file.path(out, "protein_only_hits.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
locs <- setNames(lapply(c(genomes, edge_genomes), locate), c(genomes, edge_genomes))
n16_of <- function(g) { gff <- readLines(file.path(truth_dir, sprintf("%s.barrnap.gff", g))); sum(grepl("Name=16S_rRNA", gff) & !grepl("partial", gff)) }
n16 <- setNames(vapply(genomes, n16_of, 0), genomes)
glen <- function(g) sum(nchar(grep("^>", readLines(file.path(dirname(truth_dir), "genomes", paste0(g, ".fna"))), value = TRUE, invert = TRUE)))
genome_len <- setNames(vapply(genomes, glen, 0), genomes)

# AROs lying at each locus (any CARD ARO, not only detected ones), and the
# AROs present anywhere in each genome.
lies_at <- lapply(seq_len(nrow(loci)), function(i) {
  l <- loci[i, ]; h <- locs[[l$genome]]
  h <- h[h$contig == l$contig, ]
  ov <- pmin(h$end, l$stop) - pmax(h$start, l$start) + 1
  unique(c(l$aro_accession, h$aro_accession[ov >= 0.5 * (l$stop - l$start + 1)]))
})
names(lies_at) <- loci$locus
present <- lapply(locs, function(h) unique(h$aro_accession[h$aln_length >= 0.5 * h$ref_length]))

# Accuracy groups: union-find over the loci of each genome, joined by AROs.
parent <- setNames(loci$locus, loci$locus)
find <- function(x) { while (parent[[x]] != x) x <- parent[[x]]; x }
for (g in genomes) {
  ls <- loci$locus[loci$genome == g]
  for (a in unique(unlist(lies_at[ls]))) {
    at <- ls[vapply(lies_at[ls], function(v) a %in% v, TRUE)]
    if (length(at) > 1) for (k in at[-1]) { r1 <- find(at[1]); r2 <- find(k); if (r1 != r2) parent[[r2]] <- r1 }
  }
}
loci$group <- vapply(loci$locus, find, "")
groups <- do.call(rbind, lapply(split(loci, loci$group), function(x)
  data.frame(genome = x$genome[1], group = x$group[1], n_loci = nrow(x), genes = paste(sort(unique(x$aro_term)), collapse = ";"),
             aros = paste(sort(unique(unlist(lies_at[x$locus]))), collapse = ";"), stringsAsFactors = FALSE)))
write.table(groups, file.path(out, "truth_groups.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

bg_det <- function(bg) det[det$sample == paste0("bg_", bg), ]

# 2. Mark 1: detection by location (mixtures at 2x and 8x) ------------------------------
mix <- den[den$kind == "mixture", ]
d_rows <- do.call(rbind, lapply(seq_len(nrow(mix)), function(i) {
  s <- mix$sample[i]; g <- mix$spike[i]; l <- loci[loci$genome == g, ]
  d <- det$aro_accession[det$sample == s]
  data.frame(sample = s, background = mix$background[i], genome = g, depth = mix$spike_depth[i], locus = l$locus,
             aro_term = l$aro_term, exact_aro = l$aro_accession %in% d,
             found = vapply(l$locus, function(k) any(lies_at[[k]] %in% d), TRUE),
             marked = mix$spike_depth[i] >= 1, stringsAsFactors = FALSE)
}))
write.table(d_rows, file.path(out, "mark1_detection.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
m1 <- d_rows[d_rows$marked, ]
mark1 <- all(m1$found)

# 3. Mark 2: specificity by location ---------------------------------------------------
scored <- den[den$kind %in% c("mixture", "pure", "edge_no_arg", "edge_no_16s", "edge_host_only"), ]
s_rows <- do.call(rbind, lapply(seq_len(nrow(scored)), function(i) {
  s <- scored$sample[i]; g <- scored$spike[i]; bg <- scored$background[i]
  d <- det[det$sample == s, ]
  if (!nrow(d)) return(NULL)
  b <- if (bg %in% c("gut", "wastewater")) bg_det(bg) else det[0, ]
  why <- vapply(seq_len(nrow(d)), function(j) {
    a <- d$aro_accession[j]
    if (g %in% names(present) && a %in% present[[g]]) "present in the spike genome"
    else if (a %in% b$aro_accession) "detected in the background alone"
    else if (share_any(d$amr_gene_family[j], b$amr_gene_family)) "shares a family term with the background alone"
    else "UNEXPLAINED"
  }, "")
  data.frame(sample = s, aro_accession = d$aro_accession, aro_term = d$aro_term, reads = d$reads,
             average_percent_coverage = d$average_percent_coverage, family = d$amr_gene_family, explained_by = why,
             stringsAsFactors = FALSE)
}))
if (is.null(s_rows)) s_rows <- data.frame(sample = character(0), explained_by = character(0))
write.table(s_rows, file.path(out, "mark2_specificity.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
mark2 <- !any(s_rows$explained_by == "UNEXPLAINED")

# 4. Mark 3: accuracy by group -------------------------------------------------------------
obs_group <- function(s, aros) sum(det$copies_per_16s[det$sample == s & det$aro_accession %in% aros])
a_rows <- list()
for (i in which(den$kind == "pure")) {
  s <- den$sample[i]; g <- den$spike[i]
  for (k in which(groups$genome == g)) {
    aros <- strsplit(groups$aros[k], ";")[[1]]
    a_rows[[length(a_rows) + 1]] <- data.frame(sample = s, kind = "pure", genome = g, depth = den$spike_depth[i],
      group = groups$group[k], genes = groups$genes[k], truth = groups$n_loci[k] / n16[[g]], observed = obs_group(s, aros), limit = 1.5)
  }
}
for (i in which(den$kind == "mixture" & den$spike_depth == 8)) {
  s <- den$sample[i]; g <- den$spike[i]; bg <- den$background[i]
  D <- (den$reads_raw[i] - den$reads_raw[den$sample == paste0("bg_", bg)]) * 150 / genome_len[[g]]
  bg16 <- den$copies_16s[den$sample == paste0("bg_", bg)]
  for (k in which(groups$genome == g)) {
    aros <- strsplit(groups$aros[k], ";")[[1]]
    if (any(aros %in% bg_det(bg)$aro_accession)) next
    a_rows[[length(a_rows) + 1]] <- data.frame(sample = s, kind = "mixture", genome = g, depth = D, group = groups$group[k],
      genes = groups$genes[k], truth = groups$n_loci[k] * D / (n16[[g]] * D + bg16), observed = obs_group(s, aros), limit = 2)
  }
}
acc <- do.call(rbind, a_rows)
acc$ratio <- acc$observed / acc$truth
acc$within <- acc$ratio >= 1 / acc$limit & acc$ratio <= acc$limit
write.table(acc, file.path(out, "mark3_accuracy.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
mark3 <- all(acc$within)

# 5. Mark 4: edge cases E1-E3 (as rounds 1 and 2) -------------------------------------------
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

# 6. Reported, not marked -------------------------------------------------------------------
pure16 <- den[den$kind == "pure", ]
pure16$ratio_16s <- pure16$copies_16s / (n16[pure16$spike] * pure16$reads_raw * 150 / genome_len[pure16$spike])
write.table(pure16[, c("sample", "spike", "reads_16s", "bases_16s", "copies_16s", "ratio_16s")],
            file.path(out, "reported_16s_pure.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

pf <- function(x) if (x) "PASS" else "FAIL"
lowd <- d_rows[!d_rows$marked, ]
md <- c("# Validation V1 round 3 (by location): marks 1-4", "",
        sprintf("Protein-only RGI hits excluded from the truth (never scored): **%d**: %s.", nrow(prot_only),
                paste(sprintf("%s %s", prot_only$genome, prot_only$aro_term), collapse = "; ")), "",
        sprintf("Scored from `%s`; %d truth loci in %d accuracy groups.", basename(normalizePath(res_dir)), nrow(loci), nrow(groups)), "",
        "| Mark | Result | Detail |", "|---|---|---|",
        sprintf("| 1. Detection (2x and 8x mixtures) | **%s** | %d of %d truth loci found; exact ARO %d |", pf(mark1), sum(m1$found), nrow(m1), sum(m1$exact_aro)),
        sprintf("| 2. Specificity | **%s** | %d unexplained of %d detected genes in %d samples |", pf(mark2),
                sum(s_rows$explained_by == "UNEXPLAINED"), nrow(s_rows), nrow(scored)),
        sprintf("| 3. Accuracy, copies per 16S copy | **%s** | pure genomes %d of %d groups within 1.5x; 8x mixtures %d of %d within 2x; ratio range %.2f-%.2f |",
                pf(mark3), sum(acc$within[acc$kind == "pure"]), sum(acc$kind == "pure"), sum(acc$within[acc$kind == "mixture"]),
                sum(acc$kind == "mixture"), min(acc$ratio), max(acc$ratio)),
        sprintf("| 4. Edge cases E1-E3 | **%s** | %s |", pf(mark4), paste(sprintf("%s: %s", e_rows$case, ifelse(e_rows$passed, "pass", "FAIL")), collapse = "; ")),
        "", "Reported, not marked:", "",
        sprintf("- Detection at 0.5x: %d of %d truth loci found.", sum(lowd$found), nrow(lowd)),
        sprintf("- 16S copies estimated / truth on pure genomes: %s.", paste(sprintf("%s %.2f", pure16$spike, pure16$ratio_16s), collapse = ", ")))
if (!mark1) md <- c(md, "", "Missed truth loci (marked depths):", "", sprintf("- %s: %s (%s)", m1$sample[!m1$found], m1$aro_term[!m1$found], m1$locus[!m1$found]))
if (!mark2) { u <- s_rows[s_rows$explained_by == "UNEXPLAINED", ]
  md <- c(md, "", "Unexplained detected genes:", "", sprintf("- %s: %s (%s reads, %.1f%% covered; %s)", u$sample, u$aro_term, u$reads, u$average_percent_coverage, u$family)) }
if (!mark3) { b <- acc[!acc$within, ]
  md <- c(md, "", "Outside the accuracy limit:", "", sprintf("- %s: %s, observed %.3g, truth %.3g (ratio %.2f, limit %gx)", b$sample, b$genes, b$observed, b$truth, b$ratio, b$limit)) }
writeLines(md, file.path(out, "V1_round3_marks_1-4.md"))
cat(md, sep = "\n")
