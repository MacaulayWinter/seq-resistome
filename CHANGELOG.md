# Changelog

## 0.1.0dev

First version, being validated (V1, pre-registered).

- Read QC (fastp), host removal (hostile; human by default, or your own
  host genome), ARG reads against CARD (RGI bwt, protein homolog models),
  16S reads (SortMeRNA, SILVA bacteria and archaea).
- Tables: raw reads, RPM, RPKM and copies per 16S copy per gene and sample,
  with every denominator; a detection call with its reason for every hit.
- CARD downloaded once into a cache and checksum-checked on every run;
  `--card_version validated|latest`.
- Study metadata carried through; seq-triage results accepted directly
  (`--triage_results`).
