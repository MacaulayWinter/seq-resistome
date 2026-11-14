#!/usr/bin/env Rscript
#*******************************************************************************
# features.R: per-gene read features from DIAMOND blastx hits, labelled from a
# genome's truth (development; DIAGNOSIS.md, 2026-11-13)
#
# Reads are assigned as bin/protein_read_stats.sh assigns them: the best
# bitscore; ties go to the ARO with most reads of its own, then the lowest
# accession; each mate is its own read. Reads below 70% are dropped
# (f70g90's first stage). For each ARO with 2 or more kept reads:
#   mean_id    length-weighted identity of all kept reads (f70g90's gene identity)
#   ratio      breadth / breadth expected from random landing (D8)
#   q50, q75   median and upper-quartile read identity
#   nH, ratioH, meanH   the same for reads at 90% or more only
#   posmax     mean over covered positions of the best read's identity
# Label (spike genome only; background reads have no truth):
#   present  truth locus (RGI main Perfect/Strict, protein homolog model)
#   strict_protein_only   Perfect/Strict hit, not findable by DNA reads
#   loose    RGI main Loose hit only: a real ortholog, not counted as present
#   none     no RGI hit
#
# Usage: Rscript features.R <out.tsv> <annotation.tsv> <outcomes dir>,<truth dir> or NA <genome or NA> <sample> <hits_1[.gz]> [hits_2[.gz]]
#*******************************************************************************
a <- commandArgs(TRUE)
out <- a[1]; truth_dir <- a[3]; genome <- a[4]; sample <- a[5]; files <- a[-(1:5)]
cols <- c("q", "s", "pident", "len", "mm", "gap", "qs", "qe", "ss", "se", "ev", "bits", "slen")
h <- do.call(rbind, lapply(seq_along(files), function(i) {
  x <- read.delim(files[i], header = FALSE, col.names = cols, stringsAsFactors = FALSE, quote = "")
  if (nrow(x) > 0) x$q <- paste0(i, ":", x$q); x }))
h$aro <- sub(".*ARO:([0-9]+).*", "\\1", h$s)
top <- ave(h$bits, h$q, FUN = max); h <- h[h$bits == top, ]
h <- h[!duplicated(h[, c("q", "aro")]), ]
nt <- table(h$q); h$nt <- as.integer(nt[h$q])
own <- table(h$aro[h$nt == 1]); h$own <- ifelse(h$aro %in% names(own), as.integer(own[h$aro]), 0L)
h <- h[order(h$q, -h$own, as.numeric(h$aro)), ]; h <- h[!duplicated(h$q), ]
h <- h[h$pident >= 70, ]
h$lo <- pmin(h$ss, h$se); h$hi <- pmax(h$ss, h$se)
feat <- function(x, L) {
  if (nrow(x) < 1) return(c(n = 0, mean_id = NA, ratio = NA))
  cov <- logical(L); for (i in seq_len(nrow(x))) cov[x$lo[i]:x$hi[i]] <- TRUE
  expect <- 1 - exp(-nrow(x) * mean(x$len) / L)
  c(n = nrow(x), mean_id = sum(x$pident * x$len) / sum(x$len) / 100, ratio = mean(cov) / expect)
}
g <- do.call(rbind, lapply(split(h, h$aro), function(x) {
  L <- x$slen[1]
  if (nrow(x) < 2) return(NULL)
  f <- feat(x, L); fH <- feat(x[x$pident >= 90, ], L)
  pm <- rep(NA_real_, L); for (i in seq_len(nrow(x))) { r <- x$lo[i]:x$hi[i]; pm[r] <- pmax(pm[r], x$pident[i], na.rm = TRUE) }
  data.frame(sample = sample, aro = x$aro[1], name = sub(".*ARO:[0-9]+\\|", "", x$s[1]), L = L,
             n = f[["n"]], mean_id = f[["mean_id"]], ratio = f[["ratio"]],
             q50 = median(x$pident) / 100, q75 = unname(quantile(x$pident, 0.75)) / 100,
             nH = fH[["n"]], meanH = fH[["mean_id"]], ratioH = fH[["ratio"]],
             posmax = mean(pm, na.rm = TRUE) / 100, stringsAsFactors = FALSE)
}))
if (is.null(g)) g <- data.frame()
if (nrow(g) && !is.na(genome) && genome != "NA") {
  od <- strsplit(truth_dir, ",")[[1]]   # <outcomes dir>,<truth dir>
  tl <- read.delim(file.path(od[1], "truth_loci.tsv"), stringsAsFactors = FALSE, colClasses = c(aro_accession = "character"))
  findable <- unique(tl$aro_accession[tl$genome == genome & tl$findable])
  po <- read.delim(file.path(od[1], "protein_only_hits.tsv"), stringsAsFactors = FALSE, colClasses = c(aro_accession = "character"))
  strict <- unique(po$aro_accession[po$genome == genome])
  loose <- character(0)
  if (length(od) > 1 && od[2] != "NA") {
    lf <- file.path(od[2], sprintf("%s.loose.txt", genome))
    if (file.exists(lf)) {
      lx <- read.delim(lf, check.names = FALSE, stringsAsFactors = FALSE, quote = "")
      loose <- unique(as.character(lx$ARO[lx$Model_type == "protein homolog model" & lx$Cut_Off == "Loose"]))
    }
  }
  g$label <- ifelse(g$aro %in% findable, "present", ifelse(g$aro %in% strict, "strict_protein_only",
                    ifelse(g$aro %in% loose, "loose", "none")))
} else if (nrow(g)) g$label <- NA
write.table(g, out, sep = "\t", quote = FALSE, row.names = FALSE)
