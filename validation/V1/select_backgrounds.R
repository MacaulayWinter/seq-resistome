#!/usr/bin/env Rscript
#*******************************************************************************
# select_backgrounds.R: draw the V1 background metagenomes from ENA by the
#                       pre-registered rule (PREREGISTRATION.md section 1)
#
# For each type (human gut, wastewater): ENA runs that are Illumina paired
# shotgun metagenomes, >= 2,000,000 pairs, 2 x 150 bp (base_count/read_count
# 290-302), first public 2020-2025; one run per study (the first listed);
# ordered by run accession; set.seed(20261028); sample(). The first is the
# background, the next two are backups. Writes the query, every candidate and
# the draw, so the choice can be checked.
#
# Usage:  Rscript validation/V1/select_backgrounds.R <out_dir>
#*******************************************************************************
args <- commandArgs(trailingOnly = TRUE)
options(timeout = 900)   # ENA returns tens of thousands of rows
out <- if (length(args)) args[1] else "validation/V1"
TYPES <- data.frame(type = c("human_gut", "wastewater"), tax_id = c(408170, 527639))
FIELDS <- "run_accession,study_accession,sample_accession,tax_id,scientific_name,instrument_model,read_count,base_count,first_public,fastq_ftp,fastq_md5"
draws <- list()
for (i in seq_len(nrow(TYPES))) {
  q <- sprintf(paste('tax_eq(%d) AND library_strategy="WGS" AND library_source="METAGENOMIC" AND instrument_platform="ILLUMINA"',
                     'AND library_layout="PAIRED" AND read_count>=2000000 AND first_public>=2020-01-01 AND first_public<=2025-12-31'),
               TYPES$tax_id[i])
  url <- sprintf("https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=%s&fields=%s&format=tsv&limit=0",
                 URLencode(q, reserved = TRUE), FIELDS)
  x <- read.delim(url, stringsAsFactors = FALSE, quote = "", colClasses = "character")
  n_all <- nrow(x)
  bp <- as.numeric(x$base_count) / as.numeric(x$read_count)
  x <- x[!is.na(bp) & bp >= 290 & bp <= 302, ]
  x <- x[!duplicated(x$study_accession), ]            # one run per study: the first listed
  x <- x[order(x$run_accession), ]
  set.seed(20261028)
  x$draw <- NA_integer_
  x$draw[sample(nrow(x))] <- seq_len(nrow(x))
  x <- x[order(x$draw), ]
  x$role <- c("background", "backup 1", "backup 2", rep("", max(0, nrow(x) - 3)))[seq_len(nrow(x))]
  write.table(x, file.path(out, sprintf("candidates_%s.tsv", TYPES$type[i])), sep = "\t", quote = FALSE, row.names = FALSE)
  writeLines(c(q, sprintf("%d runs returned; %d after the 2 x 150 bp and one-run-per-study rules", n_all, nrow(x))),
             file.path(out, sprintf("query_%s.txt", TYPES$type[i])))
  draws[[i]] <- cbind(type = TYPES$type[i], x[x$role != "", c("role", "run_accession", "study_accession", "instrument_model", "read_count", "first_public", "fastq_ftp", "fastq_md5")])
  cat(sprintf("%s: %d runs, %d candidates; background %s (%s)\n", TYPES$type[i], n_all, nrow(x), x$run_accession[1], x$study_accession[1]))
}
write.table(do.call(rbind, draws), file.path(out, "backgrounds.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
