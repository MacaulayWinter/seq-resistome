for (r in 3:4) {
  task <- Sys.glob(if (r==3) path.expand("~/Projects/seqcompendium-work/resistome-dev/r3work/aa/a3efc3*") else path.expand("~/seqresistome-scratch/V1r4/work/26/263486*"))
  rd <- function(f) read.delim(f, comment.char="#", colClasses=c(aro_accession="character"), check.names=FALSE, quote="")
  a <- rd(file.path(task,"arg_long.tsv")); b <- rd(sprintf("r%d_id0.70/arg_long.tsv", r))
  ka <- paste(a$sample,a$aro_accession)[a$detected]; kb <- paste(b$sample,b$aro_accession)[b$detected]
  cat("round",r,": original detected",length(ka),"rebuilt",length(kb),"only-orig",length(setdiff(ka,kb)),"only-new",length(setdiff(kb,ka)),"\n")
  m <- merge(a,b,by=c("sample","aro_accession")); cat("  copies_per_16s max abs diff:", max(abs(m$copies_per_16s.x-m$copies_per_16s.y),na.rm=TRUE),"\n")
}
