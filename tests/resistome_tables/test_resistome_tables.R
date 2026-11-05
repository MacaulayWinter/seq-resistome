#!/usr/bin/env Rscript
#*******************************************************************************
# test_resistome_tables.R: unit tests for bin/resistome_tables.R (D7, D8)
#
# Builds small inputs by hand, whose right answers are worked out here, runs
# the script on them and checks every table. Run from the repository root:
#   Rscript tests/resistome_tables/test_resistome_tables.R
#*******************************************************************************
script <- normalizePath("bin/resistome_tables.R")
n_pass <- 0; fails <- character(0)
ok <- function(cond, msg) { if (isTRUE(all(cond))) n_pass <<- n_pass + 1 else fails <<- c(fails, msg) }
near <- function(a, b) isTRUE(all(abs(a - b) < 1e-6 * pmax(1, abs(b))))

RGI_HEADER <- c("ARO Term", "ARO Accession", "Reference Model Type", "Reference DB", "Completely Mapped Reads",
                "Mapped Reads with Flanking Sequence", "All Mapped Reads", "Average Percent Coverage",
                "Average Length Coverage (bp)", "Average MAPQ (Completely Mapped Reads)", "Reference Length",
                "AMR Gene Family", "Drug Class", "Resistance Mechanism")
gene <- function(term, acc, reads, cov, len, fam = "fam", cls = "cls")
  c(term, acc, "protein homolog model", "CARD", reads, 0, reads, cov, round(len * cov / 100), 60, len, fam, cls, "mech")

# One case: a folder with the script's inputs. flow: data frame of the read
# flow; rgi: named list sample -> list of gene rows (NULL = no file);
# rrna: named vector sample -> 16S reads (and reads_seen = reads_analysed
# unless seen is given); sheet: lines of the samplesheet.
run_case <- function(flow, rgi, rrna, sheet, left = character(0), seen = NULL, card_ok = "true", expect_fail = FALSE,
                     rgi_header = RGI_HEADER, bases = NULL, identity = NULL, min_identity = 0, stats = TRUE,
                     dispersion = NULL, copies16 = NULL, old16 = FALSE) {
  d <- tempfile("case"); dir.create(d); dir.create(file.path(d, "rgi")); dir.create(file.path(d, "rrna"))
  write.table(flow, file.path(d, "read_flow.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
  writeLines(c("sample\treason", left), file.path(d, "left.tsv"))
  writeLines(sheet, file.path(d, "sheet.csv"))
  for (s in names(rgi)) {
    rows <- vapply(rgi[[s]], paste, "", collapse = "\t")
    writeLines(c(paste(rgi_header, collapse = "\t"), rows), file.path(d, "rgi", paste0(s, ".gene_mapping_data.txt")))
    # Read statistics (D19): every read aligned over its whole 100 bp unless
    # a test says otherwise; mismatches from the identity given per ARO.
    if (stats) {
      st <- vapply(rgi[[s]], function(g) {
        b <- 100 * as.numeric(g[5]); id <- if (!is.null(identity) && g[2] %in% names(identity)) identity[[g[2]]] else 1
        # Window counts (D20): mean 1 and variance = dispersion given per
        # ARO; NA (no interval widening) unless a test gives one.
        ph <- if (!is.null(dispersion) && g[2] %in% names(dispersion)) dispersion[[g[2]]] else NA
        win <- if (is.na(ph)) "NA\tNA\tNA" else sprintf("10\t1\t%s", ph)
        sprintf("ARO:%s|ID:1|Name:%s\t%s\t%s\t%s\t%s\t%s", g[2], g[1], g[2], g[5], b, round(b * (1 - id)), win)
      }, "")
      writeLines(c("reference\taro_accession\treads\taligned_bases\tmismatches\twindows\twindow_mean\twindow_var", st), file.path(d, "rgi", paste0(s, ".read_stats.tsv")))
    }
  }
  for (s in names(rrna)) {
    sn <- if (!is.null(seen) && s %in% names(seen)) seen[[s]] else flow$reads_analysed[flow$sample == s]
    # 16S aligned bases: every 16S read aligned over its whole 100 bp; 16S
    # copies (D20: summed per SILVA reference length) = bases / 1,542 unless
    # a test gives them, so the hand-worked copies below are reads x 100 / 1,542.
    b16 <- if (!is.null(bases)) as.numeric(bases[[s]]) else 100 * as.numeric(rrna[[s]])
    c16 <- if (!is.null(copies16)) copies16[[s]] else b16 / 1542
    if (old16) writeLines(c("sample\treads_16s\tbases_16s\treads_seen", sprintf("%s\t%s\t%s\t%s", s, rrna[[s]], b16, sn)),
                          file.path(d, "rrna", paste0(s, ".16s.tsv")))
    else writeLines(c("sample\treads_16s\tbases_16s\tcopies_16s\tshort_16s\treads_seen",
                      sprintf("%s\t%s\t%s\t%s\t0\t%s", s, rrna[[s]], b16, c16, sn)), file.path(d, "rrna", paste0(s, ".16s.tsv")))
  }
  old <- setwd(d); on.exit(setwd(old))
  res <- suppressWarnings(system2("Rscript", c(script, "rgi", "rrna", "read_flow.tsv", "left.tsv", "sheet.csv", "4.0.2", card_ok, "1542", "2", "0.5", "test", min_identity),
                                  stdout = TRUE, stderr = TRUE))
  status <- attr(res, "status"); if (is.null(status)) status <- 0
  if (expect_fail) return(list(status = status, msg = paste(res, collapse = "\n")))
  if (status != 0) stop("script failed unexpectedly: ", paste(res, collapse = "\n"))
  rd <- function(f) read.delim(file.path(d, f), comment.char = "#", check.names = FALSE, stringsAsFactors = FALSE, quote = "")
  list(status = status, dir = d, long = rd("arg_long.tsv"), den = rd("denominators.tsv"), cp = rd("arg_copies_per_16s.tsv"),
       reads = rd("arg_reads.tsv"), rpm = rd("arg_rpm.tsv"), left = rd("samples_left_out.tsv"),
       header = readLines(file.path(d, "arg_long.tsv"), n = 2), md = readLines(file.path(d, "resistome_summary.md")))
}
flow_row <- function(s, analysed, qc = analysed, removed = qc - analysed, len = 100, layout = "paired")
  data.frame(sample = s, layout = layout, n_files = 1, reads_raw = qc + 10, reads_after_qc = qc, mean_read_length = len,
             host_removal = "own genome (test)", host_reads_removed = removed, reads_analysed = analysed)

# --- Case 1: the measures, worked by hand ------------------------------------
# A: 1,000,000 reads of 100 bp; 1,542 16S reads aligned over 154,200 bases -> 100 16S copies.
#   X: 1,000 bp, 50 reads, 99% covered -> rpm 50, rpkm 50, 5 copies, 0.05 per 16S copy;
#      random breadth 100(1 - e^-5) = 99.33% -> ratio 0.997 -> detected.
#   Y: 2,000 bp, 10 reads, 5% covered -> random breadth 39.3% -> ratio 0.127 -> not detected.
#   Z: 500 bp, 1 read -> fewer than 2 reads -> not detected.
# B: 500,000 reads, no 16S reads; X 20 reads -> detected, copies per 16S missing.
# C: reads, 16S, but no ARG hit at all (RGI file with a header only).
# D: every read was host: no RGI or 16S output.
flow <- rbind(flow_row("A", 1e6), flow_row("B", 5e5), flow_row("C", 1000), flow_row("D", 0, qc = 300))
rgi <- list(A = list(gene("X", "3000001", 50, 99, 1000), gene("Y", "3000002", 10, 5, 2000), gene("Z", "3000003", 1, 20, 500)),
            B = list(gene("X", "3000001", 20, 86.47, 1000)), C = list())
sheet <- c("sample,fastq_1,fastq_2,site,day", "A,a1.fq.gz,a2.fq.gz,gut,1", "B,b1.fq.gz,b2.fq.gz,gut,2",
           "C,c1.fq.gz,c2.fq.gz,soil,1", "D,d1.fq.gz,d2.fq.gz,host,1")
r <- run_case(flow, rgi, c(A = 1542, B = 0, C = 3), sheet)
L <- r$long; x <- L[L$sample == "A" & L$aro_term == "X", ]
ok(near(x$rpm, 50) && near(x$rpkm, 50), "case 1: rpm/rpkm of A:X")
ok(near(x$arg_copies, 5) && near(x$copies_per_16s, 0.05), "case 1: copies of A:X")
ok(near(x$expected_percent_coverage, 100 * (1 - exp(-5))) && x$detected, "case 1: A:X detected, expected breadth")
y <- L[L$sample == "A" & L$aro_term == "Y", ]
ok(!y$detected && grepl("shared domain", y$detection_note), "case 1: A:Y (piled-up reads) not detected, with the reason")
z <- L[L$sample == "A" & L$aro_term == "Z", ]
ok(!z$detected && grepl("fewer than 2 reads", z$detection_note), "case 1: A:Z (1 read) not detected, with the reason")
ok(is.na(L$copies_per_16s[L$sample == "B"]) && !any(is.infinite(L$copies_per_16s)), "case 1: B (no 16S) copies per 16S missing, not infinite")
ok(all(is.na(r$cp$B)) && near(r$cp$A[r$cp$aro_term == "X"], 0.05), "case 1: copies matrix: B all missing, A:X 0.05")
ok(all(c("A", "B", "C", "D") %in% names(r$reads)) && r$reads$D == 0 && r$reads$C == 0, "case 1: matrices have a zero column for C and D")
ok(identical(sort(r$reads$aro_term), "X"), "case 1: matrices hold detected genes only")
ok(is.na(r$cp$D) && is.na(r$cp$C) == FALSE, "case 1: D (no reads) missing in the copies matrix; C (16S, no ARG) zero")
dD <- r$den[r$den$sample == "D", ]
ok(dD$status == "no reads left after host removal" && is.na(dD$reads_16s) && is.na(dD$copies_16s), "case 1: D status and missing 16S")
ok(near(r$den$copies_16s[r$den$sample == "A"], 100), "case 1: A has 100 16S copies")
ok(all(c("site", "day") %in% names(L)) && L$site[L$sample == "A"][1] == "gut" && r$den$day[r$den$sample == "B"] == 2, "case 1: metadata carried through")
ok(grepl("CARD 4.0.2 \\(the release this pipeline version was validated with\\)", r$header[1]) && grepl("not ARGs per cell", r$header[2]),
   "case 1: header states CARD release and 16S caveat")
ok(any(grepl("\\| D \\| no reads left after host removal \\| 0 \\|", r$md)), "case 1: summary row for D")

# --- Case 2: CARD not validated ----------------------------------------------
r2 <- run_case(flow, rgi, c(A = 1542, B = 0, C = 3), sheet, card_ok = "false")
ok(grepl("CARD 4.0.2: not validated by the pipeline authors", r2$header[1]) && any(grepl("not validated by the pipeline authors", r2$md)),
   "case 2: unvalidated CARD stated in tables and summary")

# --- Case 3: no hits anywhere; a left-out sample -----------------------------
r3 <- run_case(rbind(flow_row("A", 1000), flow_row("C", 1000)), list(A = list(), C = list()), c(A = 5, C = 0),
               c("sample,fastq_1", "A,a.fq.gz", "C,c.fq.gz", "E,e.fq.gz"), left = "E\tseq-triage verdict FAIL: too few reads")
ok(nrow(r3$long) == 0 && nrow(r3$reads) == 0 && all(c("A", "C") %in% names(r3$reads)), "case 3: no hits: empty tables with every sample column")
ok(r3$left$sample == "E" && grepl("FAIL", r3$left$reason), "case 3: left-out sample carried with its reason")

# --- Case 4: lanes of one sample (two samplesheet rows) agreeing -------------
r4 <- run_case(flow_row("A", 1000), list(A = list(gene("X", "3000001", 5, 40, 1000))), c(A = 10),
               c("sample,fastq_1,fastq_2,site", "A,l1_1.fq.gz,l1_2.fq.gz,gut", "A,l2_1.fq.gz,l2_2.fq.gz,gut"))
ok(nrow(r4$den) == 1 && r4$den$site == "gut", "case 4: two rows of one sample give one row of metadata")

# --- Case 5: stops, each naming its problem ------------------------------------
f <- run_case(flow_row("A", 1000), list(), c(A = 10), c("sample,fastq_1", "A,a.fq.gz"), expect_fail = TRUE)
ok(f$status != 0 && grepl("no RGI output for A", f$msg), "case 5a: a missing RGI output stops the run")
f <- run_case(flow_row("A", 1000), list(A = list()), c(A = 10), c("sample,fastq_1", "A,a.fq.gz"), seen = c(A = 999), expect_fail = TRUE)
ok(f$status != 0 && grepl("SortMeRNA read a different number", f$msg), "case 5b: SortMeRNA read count mismatch stops the run")
f <- run_case(flow_row("A", 1000), list(A = list()), c(A = 10), c("sample,fastq_1,reads", "A,a.fq.gz,7"), expect_fail = TRUE)
ok(f$status != 0 && grepl("same name as an output column", f$msg) && grepl("reads", f$msg), "case 5c: a metadata column named like an output column stops")
f <- run_case(flow_row("A", 1000), list(A = list()), c(A = 10), c("sample,fastq_1,site", "A,a.fq.gz,gut", "A,b.fq.gz,soil"), expect_fail = TRUE)
ok(f$status != 0 && grepl("disagree on study metadata: A", f$msg), "case 5d: lanes disagreeing on metadata stop")
f <- run_case(flow_row("A", 1000), list(A = list(gene("X", "3000001", 5, 40, 1000)[-11])), c(A = 10), c("sample,fastq_1", "A,a.fq.gz"),
              rgi_header = RGI_HEADER[-11], expect_fail = TRUE)
ok(f$status != 0 && grepl("lacks column\\(s\\) Reference Length", f$msg), "case 5e: an RGI table with a missing column stops, naming it")
f <- run_case(flow_row("A", 0, qc = 10), list(A = list()), c(A = 0), c("sample,fastq_1", "A,a.fq.gz"), expect_fail = TRUE)
ok(f$status != 0 && grepl("RGI output for samples with no reads analysed", f$msg), "case 5f: outputs for an emptied sample stop the run")

# --- Case 6: 16S copies come from aligned bases, not reads (D13) ------------
# 1,542 16S reads of 100 bp, but aligned over only 77,100 bases (half each):
# 50 16S copies, not 100, so A:X is 0.1 copies per 16S copy, not 0.05.
r6 <- run_case(flow_row("A", 1e6), list(A = list(gene("X", "3000001", 50, 99, 1000))), c(A = 1542),
               c("sample,fastq_1", "A,a.fq.gz"), bases = c(A = 77100))
ok(near(r6$den$copies_16s, 50) && near(r6$long$copies_per_16s, 0.1) && r6$den$bases_16s == 77100,
   "case 6: partial 16S alignments count only their aligned bases")

# --- Case 7: read identity (D19) ---------------------------------------------
# X: 50 reads at 99% identity, detected; Y: 50 reads, 95% covered (looks like
# a real gene by breadth) but only 82% identity: not detected at 0.9, with
# the reason; at 0 (off) both are detected.
g7 <- list(A = list(gene("X", "3000001", 50, 99, 1000), gene("Y", "3000002", 50, 99, 1000)))
r7 <- run_case(flow_row("A", 1e6), g7, c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"), identity = c("3000001" = 0.99, "3000002" = 0.82), min_identity = 0.9)
ok(r7$long$detected[r7$long$aro_term == "X"] && !r7$long$detected[r7$long$aro_term == "Y"] &&
   grepl("82.0% identity", r7$long$detection_note[r7$long$aro_term == "Y"]), "case 7: low read identity is not detected, with the reason")
ok(near(r7$long$read_identity[r7$long$aro_term == "X"], 0.99), "case 7: read identity reported")
r7b <- run_case(flow_row("A", 1e6), g7, c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"), identity = c("3000001" = 0.99, "3000002" = 0.82), min_identity = 0)
ok(all(r7b$long$detected), "case 7: identity check off when min_read_identity is 0")

# --- Case 8: ARG copies from aligned bases (D19) -------------------------------
# 50 reads but only 2,500 aligned bases (half each) on a 1,000 bp gene: 2.5
# copies, not 5; per 16S copy (100 copies) 0.025.
d8 <- run_case(flow_row("A", 1e6), list(A = list(gene("X", "3000001", 50, 99, 1000))), c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"))
st <- file.path(d8$dir, "rgi", "A.read_stats.tsv"); x <- readLines(st); x[2] <- sub("\t5000\t", "\t2500\t", x[2]); writeLines(x, st)
old <- setwd(d8$dir); invisible(system2("Rscript", c(script, "rgi", "rrna", "read_flow.tsv", "left.tsv", "sheet.csv", "4.0.2", "true", "1542", "2", "0.5", "test", "0"), stdout = TRUE, stderr = TRUE)); setwd(old)
l8 <- read.delim(file.path(d8$dir, "arg_long.tsv"), comment.char = "#", stringsAsFactors = FALSE)
ok(near(l8$arg_copies, 2.5) && near(l8$copies_per_16s, 0.025), "case 8: ARG copies follow aligned bases")

# --- Case 9: a sample with RGI output but no read statistics stops ---------------
f <- run_case(flow_row("A", 1000), list(A = list()), c(A = 10), c("sample,fastq_1", "A,a.fq.gz"), stats = FALSE, expect_fail = TRUE)
ok(f$status != 0 && grepl("no RGI read statistics for A", f$msg), "case 9: missing read statistics stop the run")

# --- Case 10: per-gene 95% interval (D20) ---------------------------------------
# X: 50 reads, 0.05 copies per 16S copy. Window counts as Poisson (NA: no
# widening): limits 0.05 x qgamma(0.025, 50)/50 and 0.05 x qgamma(0.975, 51)/50.
# Read starts clumped at dispersion 2: effective reads 25. Dispersion below 1
# never narrows the interval.
g10 <- list(A = list(gene("X", "3000001", 50, 99, 1000), gene("Y", "3000002", 50, 99, 1000), gene("Z", "3000003", 50, 99, 1000)))
r10 <- run_case(flow_row("A", 1e6), g10, c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"), dispersion = c("3000002" = 2, "3000003" = 0.5))
lx <- r10$long[r10$long$aro_term == "X", ]; ly <- r10$long[r10$long$aro_term == "Y", ]; lz <- r10$long[r10$long$aro_term == "Z", ]
ok(near(lx$copies_per_16s_low95, 0.05 * qgamma(0.025, 50) / 50) && near(lx$copies_per_16s_high95, 0.05 * qgamma(0.975, 51) / 50),
   "case 10: Poisson interval")
ok(near(ly$dispersion, 2) && near(ly$copies_per_16s_low95, 0.05 * qgamma(0.025, 25) / 25) &&
   near(ly$copies_per_16s_high95, 0.05 * qgamma(0.975, 26) / 25), "case 10: interval widened by clumping")
ok(near(lz$copies_per_16s_low95, lx$copies_per_16s_low95), "case 10: dispersion below 1 does not narrow it")
r10b <- run_case(flow_row("A", 1e6), list(A = list(gene("X", "3000001", 50, 99, 1000))), c(A = 0), c("sample,fastq_1", "A,a.fq.gz"))
ok(is.na(r10b$long$copies_per_16s_low95) && is.na(r10b$long$copies_per_16s_high95), "case 10: no 16S reads, interval missing")

# --- Case 11: 16S copies come from COUNT_16S's per-reference sum (D20) -----------
# 1,542 16S reads (154,200 bases) but copies_16s given as 80 (references
# longer than 1,542 bp): X's 5 copies -> 0.0625 per 16S copy, not 0.05.
r11 <- run_case(flow_row("A", 1e6), list(A = list(gene("X", "3000001", 50, 99, 1000))), c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"),
                copies16 = c(A = 80))
ok(near(r11$den$copies_16s, 80) && near(r11$long$copies_per_16s, 0.0625) && r11$den$short_16s == 0, "case 11: 16S copies as counted")
f <- run_case(flow_row("A", 1e6), list(A = list(gene("X", "3000001", 50, 99, 1000))), c(A = 1542), c("sample,fastq_1", "A,a.fq.gz"),
              old16 = TRUE, expect_fail = TRUE)
ok(f$status != 0 && grepl("16S counts lack column", f$msg), "case 11: 16S counts without copies_16s stop the run")

if (length(fails)) {
  cat(sprintf("test_resistome_tables.R: %d passed, %d FAILED\n", n_pass, length(fails)), paste0("  - ", fails, collapse = "\n"), "\n", sep = "")
  quit(status = 1)
}
cat(sprintf("test_resistome_tables.R: all %d checks passed\n", n_pass))
