rd <- function(f) read.delim(f, comment.char="#", colClasses=c(aro_accession="character"), check.names=FALSE, quote="", na.strings="NA")
for (r in 3:4) {
  A <- rd(sprintf("r%d_id0.70/arg_long.tsv", r)); B <- rd(sprintf("r%d_id0.90/arg_long.tsv", r))
  key <- function(x) paste(x$sample, x$aro_accession)
  B$h <- !is.na(B$reads) & B$reads >= 2 & !is.na(B$read_identity) & B$read_identity >= 0.95 & !is.na(B$breadth_ratio) & B$breadth_ratio >= 0.8
  hk <- key(B)[B$h]; ak <- key(A)
  # 'or': f70g90 detections kept; extra genes taken from the 90% run
  orR <- A; add <- B[B$h & !(key(B) %in% ak[A$detected]), ]
  idx <- match(key(add), ak)
  for (i in seq_len(nrow(add))) { j <- idx[i]; if (!is.na(j)) { keep <- orR[j, c("sample","aro_accession")]; orR[j, ] <- add[i, names(orR)]; orR$detected[j] <- TRUE } }
  # high-identity only
  hR <- A; hR$detected <- FALSE
  for (i in which(B$h)) { j <- match(key(B)[i], ak); if (!is.na(j)) { hR[j, ] <- B[i, names(hR)]; hR$detected[j] <- TRUE } }
  for (nm in c("f","or","h")) { d <- sprintf("rule_%s_r%d", nm, r); dir.create(d, showWarnings=FALSE)
    x <- switch(nm, f=A, or=orR, h=hR)
    hdr <- readLines(sprintf("r%d_id0.70/arg_long.tsv", r), 2)
    writeLines(hdr, file.path(d,"arg_long.tsv")); write.table(x, file.path(d,"arg_long.tsv"), sep="\t", quote=FALSE, row.names=FALSE, na="NA", append=TRUE)
    file.copy(sprintf("r%d_id0.70/denominators.tsv", r), d, overwrite=TRUE); file.copy(sprintf("r%d_id0.70/arg_copies_per_16s.tsv", r), d, overwrite=TRUE)
    cat(sprintf("round %d rule %-2s detected %d\n", r, nm, sum(x$detected))) }
}
