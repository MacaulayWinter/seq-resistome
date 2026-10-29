#!/usr/bin/env Rscript
#*******************************************************************************
# select_genomes_round3.R: draw round 3's spike genomes by the pre-registered
#                          rule (PREREGISTRATION_round3.md section 3)
#
# RefSeq assemblies at level Complete Genome in BioProject PRJNA1287288 that
# are not seq-triage layer D isolates; ordered by accession;
# set.seed(20261030); sample(); the first three are the spikes.
#
# Usage:  Rscript validation/V1/select_genomes_round3.R <ncbi_dataset_report.json> <out.tsv>
#         the JSON from https://api.ncbi.nlm.nih.gov/datasets/v2/genome/bioproject/PRJNA1287288/dataset_report?page_size=1000
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
LAYER_D <- c("ECE107", "KPE111", "ECE170", "KPE072", "CPO025", "ECE228", "ALF22C020", "AH21H052", "KPE040", "CPO413")
txt <- paste(readLines(args[1], warn = FALSE), collapse = "")
# One record per assembly: accession, level, isolate/strain names, organism.
recs <- regmatches(txt, gregexpr('\\{"accession":"GC[AF]_[0-9.]+".*?"type":"GENOME_REPORT"|\\{"accession":"GC[AF]_[0-9.]+"', txt, perl = TRUE))[[1]]
starts <- gregexpr('"accession":"GC[AF]_[0-9.]+"', txt)[[1]]
ends <- c(starts[-1] - 1, nchar(txt))
rows <- lapply(seq_along(starts), function(i) {
  r <- substr(txt, starts[i], ends[i])
  get <- function(k) { m <- regmatches(r, regexpr(sprintf('"%s":"[^"]*"', k), r)); if (length(m)) sub(sprintf('"%s":"([^"]*)"', k), "\\1", m) else NA }
  names_in <- unique(sub('.*:"([^"]*)"', "\\1", regmatches(r, gregexpr('"(isolate|strain)":"[^"]*"', r))[[1]]))
  data.frame(accession = get("accession"), level = get("assembly_level"), organism = get("organism_name"),
             isolate = paste(names_in, collapse = ";"), stringsAsFactors = FALSE)
})
x <- do.call(rbind, rows)
x <- x[grepl("^GCF_", x$accession) & x$level %in% "Complete Genome", ]
x$layer_D <- vapply(x$isolate, function(n) any(strsplit(n, ";")[[1]] %in% LAYER_D), TRUE)
x <- x[!x$layer_D, ]
x <- x[order(x$accession), ]
set.seed(20261030)
x$draw <- NA_integer_
x$draw[sample(nrow(x))] <- seq_len(nrow(x))
x <- x[order(x$draw), ]
x$role <- ifelse(x$draw <= 3, sprintf("spike %d", x$draw), "")
write.table(x, args[2], sep = "\t", quote = FALSE, row.names = FALSE)
cat(sprintf("%d candidates; spikes: %s\n", nrow(x), paste(sprintf("%s (%s %s)", x$accession[1:3], x$organism[1:3], x$isolate[1:3]), collapse = ", ")))
