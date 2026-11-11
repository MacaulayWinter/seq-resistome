#!/usr/bin/env Rscript
#*******************************************************************************
# score_step0.R: protein-mode step 0 (development only; design doc section 4)
#
# Reads DIAMOND blastx hits of the six pure genomes (rounds 3 and 4) against
# CARD 4.0.2's protein homolog proteins, assigns each read to its best CARD
# protein, and keeps a read only if it passes one of three rules, judged read
# by read (as D23 does for DNA):
#   cutoff  CARD's own per-gene BLASTP bitscore cut-off, as a share of a
#           perfect match: read bitscore / bitscore of a perfect match to the
#           same reference stretch >= cut-off / bitscore of a perfect
#           full-length match (design PM2b)
#   id90    read amino-acid identity >= 90%  (fixed threshold, PM2a)
#   id80    read amino-acid identity >= 80%  (fixed threshold, PM2a)
#   f70g90  two stages: reads >= 70% identity are kept (drops paralogs'
#           reads), and the gene is called only if its kept reads' identity,
#           weighted by alignment length, is >= 90% (added after the first
#           three; 90 was chosen on these same data, so it is development)
# A gene is called from its kept reads: >= 2 reads and breadth >= 0.5 of the
# random-landing breadth (D8, on protein coordinates).
# A third argument "mean" applies the rules to the mean over all of a gene's
# reads instead (the first attempt; it failed: paralog reads, e.g. soxS/rob
# on marA at ~50% identity, pull true genes below every rule).
#
# Scored like V1 (score_V1_round4.R), pure genomes only:
#   detection    a truth locus is found if a CARD ARO of its group is called
#   accuracy     summed protein depth of the group's called AROs / summed
#                simulated depth of its loci (ARG counting alone: no 16S)
#   specificity  a called ARO not present in the genome (locate.sh: a CARD
#                reference at >= 80% DNA identity over >= 50% of its length)
#                is unexplained
#
# Usage: Rscript score_step0.R <step0 work dir> <out dir>
#*******************************************************************************
suppressMessages(library(jsonlite))
args <- commandArgs(TRUE); w <- args[1]; out <- args[2]
mean_rule <- length(args) > 2 && args[3] == "mean"   # first attempt: rules on the mean over all reads
dir.create(out, showWarnings = FALSE, recursive = TRUE)
repo <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), "../../.."))
sets <- list(
  r3 = list(genomes = c("GCF_051559745.1", "GCF_051563765.1", "GCF_051618695.1"),
            scratch = "~/seqresistome-scratch/V1r3", outcomes = file.path(repo, "validation/V1/outcomes_round3")),
  r4 = list(genomes = c("GCF_051561185.1", "GCF_051562295.1", "GCF_051617105.1"),
            scratch = "~/seqresistome-scratch/V1r4", outcomes = file.path(repo, "validation/V1/outcomes_round4")))

# CARD proteins, cut-offs and perfect-match bitscores -------------------------------------
fa <- readLines(file.path(w, "card/protein_fasta_protein_homolog_model.fasta"))
hd <- grep("^>", fa)
ids <- sub("^>(\\S+).*", "\\1", fa[hd])
seqs <- vapply(seq_along(hd), function(i) {
  e <- if (i < length(hd)) hd[i + 1] - 1 else length(fa)
  paste(fa[(hd[i] + 1):e], collapse = "") }, "")
names(seqs) <- ids
aro_of <- function(id) sub(".*\\|ARO:([0-9]+)\\|.*", "\\1", id)
name_of <- function(id) sub(".*\\|ARO:[0-9]+\\|", "", id)
blosum_diag <- c(A = 4, R = 5, N = 6, D = 6, C = 9, Q = 5, E = 5, G = 6, H = 8, I = 4, L = 4, K = 5,
                 M = 5, F = 6, P = 7, S = 4, T = 5, W = 11, Y = 7, V = 4)
lambda <- 0.267; K <- 0.041           # BLOSUM62, gaps 11/1 (DIAMOND's default)
cum <- lapply(seqs, function(s) { v <- blosum_diag[strsplit(s, "")[[1]]]; v[is.na(v)] <- 1; c(0, cumsum(v)) })
bits <- function(raw) (lambda * raw - log(K)) / log(2)
perfect_bits <- function(id, a, b) { cs <- cum[[id]]; bits(cs[b + 1] - cs[a]) }

cj <- fromJSON(file.path(w, "card/card.json"), simplifyVector = FALSE)
cut <- do.call(rbind, lapply(cj, function(m) {
  if (!is.list(m) || !identical(m$model_type, "protein homolog model")) return(NULL)
  data.frame(aro = as.character(m$ARO_accession), cutoff = as.numeric(m$model_param$blastp_bit_score$param_value),
             family = paste(vapply(Filter(function(x) identical(x$category_aro_class_name, "AMR Gene Family"),
                                          m$ARO_category), function(x) x$category_aro_name, ""), collapse = "; "),
             stringsAsFactors = FALSE)
}))
cut <- cut[!duplicated(cut$aro), ]
full_bits <- setNames(vapply(ids, function(id) perfect_bits(id, 1, nchar(seqs[[id]])), 0), aro_of(ids))
cut$cutoff_share <- cut$cutoff / full_bits[cut$aro]

# Per sample: assign reads, call genes ------------------------------------------------------
cols <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send",
          "evalue", "bitscore", "slen")
genes_of <- function(sample) {
  h <- do.call(rbind, lapply(1:2, function(m) {
    f <- file.path(w, "hits", sprintf("%s_%d.tsv", sample, m))
    x <- read.delim(f, header = FALSE, col.names = cols, stringsAsFactors = FALSE)
    x$read <- paste0(x$qseqid, "/", m); x }))
  h <- h[h$bitscore == ave(h$bitscore, h$read, FUN = max), ]
  h$aro <- aro_of(h$sseqid)
  # ties: the tied ARO with the most reads of its own (allele merging, D22)
  n_tied <- table(h$read)
  own <- table(h$aro[h$read %in% names(n_tied)[n_tied == 1]])
  h$own <- as.numeric(own[h$aro]); h$own[is.na(h$own)] <- 0
  h <- h[order(h$read, -h$own, h$aro), ]
  h <- h[!duplicated(h$read), ]
  a <- pmin(h$sstart, h$send); b <- pmax(h$sstart, h$send)
  h$share <- h$bitscore / mapply(perfect_bits, h$sseqid, a, b)
  h$cutoff_share <- cut$cutoff_share[match(h$aro, cut$aro)]
  pass <- list(cutoff = h$share >= h$cutoff_share, id90 = h$pident >= 90, id80 = h$pident >= 80,
               f70g90 = h$pident >= 70)
  if (mean_rule) pass <- lapply(pass, function(p) rep(TRUE, nrow(h)))
  do.call(rbind, lapply(names(pass), function(ru) {
    hh <- h[pass[[ru]] %in% TRUE, ]
    if (!nrow(hh)) return(NULL)
    n_all <- table(h$aro)
    g <- do.call(rbind, lapply(split(seq_len(nrow(hh)), hh$aro), function(i) {
      x <- hh[i, ]; L <- x$slen[1]
      cov <- integer(L); for (j in seq_len(nrow(x))) { s <- min(x$sstart[j], x$send[j]); e <- max(x$sstart[j], x$send[j]); cov[s:e] <- 1L }
      breadth <- mean(cov); expect <- 1 - exp(-nrow(x) * mean(x$length) / L)
      data.frame(sample = sample, rule = ru, aro = x$aro[1], name = name_of(x$sseqid[1]), reads = nrow(x),
                 reads_all = as.integer(n_all[[x$aro[1]]]), depth = sum(x$length) / L, breadth = breadth,
                 breadth_ratio = breadth / expect, mean_identity = mean(x$pident),
                 gene_identity = sum(x$pident * x$length) / sum(x$length), mean_share = mean(x$share),
                 stringsAsFactors = FALSE)
    }))
    g <- merge(g, cut, by = "aro", all.x = TRUE)
    g$call <- g$reads >= 2 & g$breadth_ratio >= 0.5
    if (ru == "f70g90") g$call <- g$call & g$gene_identity >= 90
    if (mean_rule) g$call <- g$call & switch(ru, cutoff = g$mean_share >= g$cutoff_share,
                                              id90 = g$mean_identity >= 90, id80 = g$mean_identity >= 80, f70g90 = TRUE)
    g
  }))
}

rules <- c("cutoff", "id90", "id80", "f70g90")
det_rows <- list(); acc_rows <- list(); spec_rows <- list(); gene_rows <- list()
for (r in names(sets)) for (gn in sets[[r]]$genomes) {
  s <- paste0("pure_", gn); oc <- sets[[r]]$outcomes; sc <- path.expand(sets[[r]]$scratch)
  g <- genes_of(s); gene_rows[[s]] <- g
  loci <- read.delim(file.path(oc, "truth_loci.tsv"), colClasses = c(aro_accession = "character"))
  loci <- loci[loci$genome == gn, ]
  grp <- read.delim(file.path(oc, "truth_groups.tsv"), colClasses = "character")
  grp <- grp[grp$genome == gn, ]
  sd <- read.delim(file.path(sc, "simulated_depth", paste0(s, ".tsv")))
  sd <- sd[sd$type == "locus", ]
  loci$sim <- sd$mean_depth[match(paste(loci$contig, loci$start, loci$stop), paste(sd$contig, sd$start, sd$end))]
  loc <- read.delim(file.path(sc, "truth", paste0(gn, ".locate.tsv")), colClasses = c(aro_accession = "character"))
  present <- unique(loc$aro_accession[loc$aln_length >= 0.5 * loc$ref_length])
  loose <- read.delim(file.path(sc, "truth", paste0(gn, ".loose.txt")), check.names = FALSE, quote = "")
  loose_id <- tapply(loose$Best_Identities, as.character(loose$ARO), max)
  for (k in seq_len(nrow(grp))) {
    aros <- strsplit(grp$aros[k], ";")[[1]]
    gl <- loci[loci$aro_accession %in% aros, ]
    for (ru in rules) {
      called <- g[g$rule == ru & g$call & g$aro %in% aros, ]
      obs <- sum(called$depth); tru <- sum(gl$sim)
      acc_rows[[length(acc_rows) + 1]] <- data.frame(round = r, sample = s, rule = ru, group = grp$group[k],
        genes = grp$genes[k], simulated_depth = round(tru, 2), protein_depth = round(obs, 2),
        ratio = round(obs / tru, 3), within = obs / tru <= 1.5 & obs / tru >= 1 / 1.5,
        called = paste(called$name, collapse = ";"), stringsAsFactors = FALSE)
      det_rows[[length(det_rows) + 1]] <- data.frame(round = r, sample = s, rule = ru, group = grp$group[k],
        genes = grp$genes[k], found = nrow(called) > 0, stringsAsFactors = FALSE)
    }
  }
  for (ru in rules) {
    called <- g[g$rule == ru & g$call, ]
    u <- called[!called$aro %in% present, ]
    if (nrow(u)) spec_rows[[length(spec_rows) + 1]] <- data.frame(round = r, sample = s, rule = ru, aro = u$aro,
      name = u$name, reads = u$reads, breadth = round(u$breadth, 3), breadth_ratio = round(u$breadth_ratio, 2),
      mean_identity = round(u$mean_identity, 1), mean_share = round(u$mean_share, 3),
      cutoff_share = round(u$cutoff_share, 3), rgi_loose_identity = unname(loose_id[u$aro]),
      family = u$family, stringsAsFactors = FALSE)
  }
}
genes <- do.call(rbind, gene_rows); det <- do.call(rbind, det_rows); acc <- do.call(rbind, acc_rows)
spec <- if (length(spec_rows)) do.call(rbind, spec_rows) else data.frame()
num <- vapply(genes, is.numeric, TRUE); genes[num] <- lapply(genes[num], round, 3)
write.table(genes, file.path(out, "genes_all_rules.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(det, file.path(out, "detection.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(acc, file.path(out, "accuracy.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(spec, file.path(out, "unexplained.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# Summary -------------------------------------------------------------------------------------
md <- c("# Protein-mode step 0 (development; pure genomes of rounds 3 and 4)", "",
        "| Round | Rule | Groups found | Groups within 1.5x | Unexplained calls |", "|---|---|---|---|---|")
for (r in names(sets)) for (ru in rules) {
  d <- det[det$round == r & det$rule == ru, ]; a <- acc[acc$round == r & acc$rule == ru, ]
  nu <- if (nrow(spec)) sum(spec$round == r & spec$rule == ru) else 0
  md <- c(md, sprintf("| %s | %s | %d / %d | %d / %d | %d |", r, ru, sum(d$found), nrow(d),
                      sum(a$within, na.rm = TRUE), nrow(a), nu))
}
md <- c(md, "", "Accuracy here is protein depth over simulated depth (ARG counting alone, no 16S), not mark 3's copies per 16S.")
writeLines(md, file.path(out, "step0_summary.md")); cat(md, sep = "\n")
