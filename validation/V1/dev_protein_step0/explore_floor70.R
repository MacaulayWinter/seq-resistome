# explore_floor70.R: the exploration that led to rule f70g90 (step 0, development). Run: Rscript explore_floor70.R <step0 work dir> <out dir>

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
repo <- path.expand("~/Projects/seq-resistome")
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
  pass <- list(cutoff = h$share >= h$cutoff_share, id90 = h$pident >= 90, id80 = h$pident >= 80)
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
                 breadth_ratio = breadth / expect, mean_identity = mean(x$pident), mean_share = mean(x$share),
                 stringsAsFactors = FALSE)
    }))
    g <- merge(g, cut, by = "aro", all.x = TRUE)
    g$call <- g$reads >= 2 & g$breadth_ratio >= 0.5
    if (mean_rule) g$call <- g$call & switch(ru, cutoff = g$mean_share >= g$cutoff_share,
                                              id90 = g$mean_identity >= 90, id80 = g$mean_identity >= 80)
    g
  }))
}

# Exploration: per read floor 70% (drops paralogs), then gene-level statistics; label truth vs not
res <- list()
for (r in names(sets)) for (gn in sets[[r]]$genomes) {
  s <- paste0("pure_", gn); oc <- sets[[r]]$outcomes; sc <- path.expand(sets[[r]]$scratch)
  h <- do.call(rbind, lapply(1:2, function(m) { x <- read.delim(file.path(w, "hits", sprintf("%s_%d.tsv", s, m)), header = FALSE, col.names = cols); x$read <- paste0(x$qseqid, "/", m); x }))
  h <- h[h$bitscore == ave(h$bitscore, h$read, FUN = max), ]; h <- h[!duplicated(h$read), ]
  h$aro <- aro_of(h$sseqid); h <- h[h$pident >= 70, ]
  a <- pmin(h$sstart, h$send); b <- pmax(h$sstart, h$send); h$share <- h$bitscore / mapply(perfect_bits, h$sseqid, a, b)
  grp <- read.delim(file.path(oc, "truth_groups.tsv"), colClasses = "character"); grp <- grp[grp$genome == gn, ]
  truth_aros <- unique(unlist(strsplit(grp$aros, ";")))
  loci <- read.delim(file.path(oc, "truth_loci.tsv"), colClasses = c(aro_accession = "character")); loci <- loci[loci$genome == gn, ]
  po <- read.delim(file.path(oc, "protein_only_hits.tsv"), colClasses = c(aro_accession = "character")); po <- po[po$genome == gn, ]
  loose <- read.delim(file.path(sc, "truth", paste0(gn, ".loose.txt")), check.names = FALSE, quote = "")
  loose_id <- tapply(loose$Best_Identities, as.character(loose$ARO), max)
  g <- do.call(rbind, lapply(split(seq_len(nrow(h)), h$aro), function(i) { x <- h[i, ]; L <- x$slen[1]
    cov <- integer(L); for (j in seq_len(nrow(x))) cov[min(x$sstart[j], x$send[j]):max(x$sstart[j], x$send[j])] <- 1L
    data.frame(round = r, sample = s, aro = x$aro[1], name = name_of(x$sseqid[1]), reads = nrow(x),
               breadth_ratio = mean(cov) / (1 - exp(-nrow(x) * mean(x$length) / L)),
               mean_id = mean(x$pident), wmean_id = sum(x$pident * x$length) / sum(x$length), mean_share = mean(x$share)) }))
  g$cutoff_share <- cut$cutoff_share[match(g$aro, cut$aro)]
  g$truth <- ifelse(g$aro %in% loci$aro_accession, "truth_exact", ifelse(g$aro %in% truth_aros, "truth_group", ifelse(g$aro %in% po$aro_accession, "protein_only", "other")))
  g$rgi_loose <- unname(loose_id[g$aro]); res[[s]] <- g
}
g <- do.call(rbind, res); g <- g[g$reads >= 2 & g$breadth_ratio >= 0.5, ]
write.table(g, file.path(out, "explore_floor70.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
for (lab in c("truth_exact", "truth_group", "protein_only", "other")) { x <- g[g$truth == lab, ]
  cat(sprintf("%-13s n=%3d  wmean_id quantiles: %s\n", lab, nrow(x), paste(round(quantile(x$wmean_id, c(0, .05, .25, .5, .75, 1)), 1), collapse = " "))) }
cat("\ntruth_exact below 93:\n"); print(g[g$truth == "truth_exact" & g$wmean_id < 93, c("sample","name","reads","wmean_id","rgi_loose")])
cat("\nother above 88:\n"); print(g[g$truth == "other" & g$wmean_id >= 88, c("sample","name","reads","wmean_id","rgi_loose")])
