# Changelog

## 0.1.0dev (unvalidated)

First version. Validation V1 did not pass in three pre-registered rounds
(README: Validation), so there is no 0.1.0 release.

- Read QC (fastp), host removal (hostile; human by default, or your own
  host genome), ARG reads against CARD (RGI bwt, protein homolog models),
  16S reads (SortMeRNA, SILVA bacteria and archaea).
- Tables: raw reads, RPM, RPKM and copies per 16S copy per gene and sample,
  with every denominator; a detection call with its reason for every hit.
- CARD downloaded once into a cache and checksum-checked on every run;
  `--card_version validated|latest`.
- Study metadata carried through; seq-triage results accepted directly
  (`--triage_results`).
- 16S copies counted from aligned bases, not reads (V1 round 1 found a
  1.25-1.34x overestimate).
- RGI's leftover alignment files are deleted after each task (about 1 GB
  per sample).
