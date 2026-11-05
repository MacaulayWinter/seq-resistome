#!/usr/bin/env Rscript
#*******************************************************************************
# variant_bands.R: where reads land when CARD's variants collection is used
#                  (development only; the evidence for dropping it, D20)
#
# For pure-genome samples run with --card_variants: reads, and their identity
# to the reference they mapped to, by kind of reference (CARD's own or a
# variant), by the reference's length relative to the gene's CARD reference,
# and by the variant's protein identity to CARD (from CARD's variant index).
# Then, gene by gene, the same samples with CARD alone and with variants.
#
# Usage:  Rscript variant_bands.R <localDB with index-for-model-sequences.txt>
#             <results with variants> <results with CARD alone> <out dir>
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
db <- args[1]; rv <- args[2]; rc <- args[3]; out <- args[4]
dir.create(out, showWarnings = FALSE, recursive = TRUE)
ix <- read.delim(pipe(paste("cut -f1,10", shQuote(file.path(db, "index-for-model-sequences.txt")))), stringsAsFactors = FALSE, quote = "")
ix <- ix[!duplicated(ix$prevalence_sequence_id), ]
files <- list.files(file.path(rv, "rgi"), pattern = "^pure_.*\\.read_stats\\.tsv$", full.names = TRUE)
st <- do.call(rbind, lapply(files, function(f) {
  x <- read.delim(f, stringsAsFactors = FALSE, quote = "")
  x$sample <- sub("\\.read_stats\\.tsv$", "", basename(f)); x
}))
isv <- grepl("^Prevalence", st$reference)
st$psid <- NA_integer_
st$psid[isv] <- suppressWarnings(as.integer(sub("^Prevalence_Sequence_ID:([0-9]+)[|].*", "\\1", st$reference[isv])))
st$protein_identity <- ifelse(isv, ix$percent_identity[match(st$psid, ix$prevalence_sequence_id)], 100)
st$kind <- ifelse(isv, "variant", "CARD reference")
st$length_vs_card <- as.character(cut(st$reference_length / st$canonical_length, c(0, 0.9, 1.1, Inf),
                                      labels = c("under 0.9x", "0.9-1.1x", "over 1.1x")))
st$protein_identity_band <- as.character(cut(st$protein_identity, c(0, 90, 95, 98, 101), right = FALSE,
                                             labels = c("under 90%", "90-95%", "95-98%", "98-100%")))
band <- function(by) {
  a <- aggregate(st[, c("reads", "aligned_bases", "mismatches")], st[by], sum)
  a$read_identity <- round(1 - a$mismatches / a$aligned_bases, 3)
  a$share_of_reads <- round(a$reads / sum(a$reads), 3)
  a[, c(by, "reads", "share_of_reads", "read_identity")]
}
w <- function(d, f) write.table(d, file.path(out, f), sep = "\t", quote = FALSE, row.names = FALSE)
w(band(c("kind", "length_vs_card")), "reads_by_reference_kind_and_length.tsv")
st2 <- st[isv & st$length_vs_card == "0.9-1.1x", ]; st_all <- st; st <- st2
w(band("protein_identity_band"), "reads_on_full_length_variants_by_protein_identity.tsv")
st <- st_all
rd <- function(d) read.delim(file.path(d, "arg_long.tsv"), comment.char = "#", stringsAsFactors = FALSE, quote = "")
a <- rd(rc); b <- rd(rv)
a <- a[grepl("^pure_", a$sample), ]; b <- b[grepl("^pure_", b$sample), ]
k <- c("sample", "aro_accession", "aro_term")
m <- merge(a[, c(k, "reads", "read_identity", "detected", "copies_per_16s")],
           b[, c(k, "reads", "read_identity", "detected", "copies_per_16s", "n_references")],
           by = k, all = TRUE, suffixes = c("_card_alone", "_with_variants"))
m <- m[order(m$sample, -pmax(m$reads_card_alone, m$reads_with_variants, na.rm = TRUE)), ]
w(m, "genes_pure_genomes_card_alone_vs_variants.tsv")
cat("written to", out, "\n")
