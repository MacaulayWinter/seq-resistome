# Changelog

## Unreleased (branch `read-identity`; development, not validated)

- Per-gene read identity to CARD (`read_identity`) and a detection
  threshold, `--min_read_identity`, default 0.85 (D19, D21).
- Reads split between near-identical alleles are counted under the detected
  allele (`--min_allele_identity`, default 0.95; `merged_reads`,
  `merged_aligned_bases`, `merged_from`; D22). RGI_DB also writes the
  allele table, `card_alleles.tsv`.
- ARG copies from reference bases covered, not reads x read length (D19).
- 16S: alignments covering under 50 bases are dropped (`--min_16s_bases`,
  `short_16s`); each counts against its own SILVA reference's length (D20).
- 16S alignments matching their SILVA reference below 90% identity are
  dropped (`--min_16s_identity`, `low_identity_16s`; D23): reads from 23S
  genes, gene flanks and short local hits had inflated the 16S count.
- Read identity is judged read by read: reads below `--min_read_identity`
  are left out of every count (`reads_below_identity`), instead of the
  gene's mean deciding its call (D23). A gene counts only if at least half
  its reads pass (`--min_identity_share`, default 0.5; D24).
- 95% interval per gene for copies per 16S copy (D20).
- RGI's CARD database and index are built once per run, not per sample;
  RGI's temporary files are deleted after each sample (D20).
- CARD's variants collection was built in and then removed: in development
  it made every validation mark worse (D20; evidence in
  `validation/V1/outcomes_dev_round3_variants/`).

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
