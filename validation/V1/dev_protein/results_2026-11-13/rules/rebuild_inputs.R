a <- commandArgs(TRUE); r <- a[1]; alle <- a[2]
res <- path.expand(sprintf("~/seqresistome-scratch/V1r%s/results_protein", r)); dir <- sprintf("pipe_or_r%s", r)
unlink(file.path(dir, c("input","rrna")), recursive=TRUE); dir.create(file.path(dir,"input")); dir.create(file.path(dir,"rrna"))
file.copy(Sys.glob(file.path(res,"16s","*.16s.tsv")), file.path(dir,"rrna"))
d <- read.delim(file.path(res,"denominators.tsv"), comment.char="#", check.names=FALSE, quote="", colClasses="character", na.strings=character(0))
rs <- do.call(rbind, lapply(Sys.glob(file.path(dir,"rrna","*.16s.tsv")), function(f) read.delim(f, colClasses="character")))
d$reads_analysed[match(rs$sample, d$sample)] <- rs$reads_seen
d$host_reads_removed[match(rs$sample, d$sample)] <- as.character(as.numeric(d$reads_after_qc[match(rs$sample, d$sample)]) - as.numeric(rs$reads_seen))
fl <- c("sample","layout","n_files","reads_raw","reads_after_qc","mean_read_length","host_removal","host_reads_removed","reads_analysed")
write.table(d[,fl], file.path(dir,"input","read_flow.tsv"), sep="\t", quote=FALSE, row.names=FALSE)
meta <- setdiff(names(d), c(fl,"reads_16s","bases_16s","copies_16s","short_16s","low_identity_16s","status","note","card_version","card_validated","count_mode"))
sh <- d[, c("sample", meta), drop=FALSE]; sh$fastq_1 <- paste0(sh$sample, ".fq.gz"); sh <- sh[, c("sample","fastq_1", setdiff(meta,"sample"))]
write.csv(sh, file.path(dir,"input","samplesheet.csv"), row.names=FALSE, quote=TRUE)
file.copy(file.path(res,"samples_left_out.tsv"), file.path(dir,"input","samples_left_out.tsv"))
file.copy(alle, file.path(dir,"input","card_alleles.tsv"))
cat(r, nrow(d), "samples; meta:", paste(setdiff(meta,"sample"), collapse=","), "\n")
