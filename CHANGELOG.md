# Changelog

## Unreleased (branch `protein-mode`; development, not validated)

- **Protein mode, the new default** (`--count_mode protein`; D26, D27):
  reads are translated and searched against CARD's protein homolog
  proteins with DIAMOND 2.2.8 blastx. Rule f70g90: a read counts at 70%
  amino-acid identity or more (`--min_protein_read_identity`), and a gene is
  called when its kept reads together reach 90%
  (`--min_protein_gene_identity`), plus the read-count and breadth rules.
  Allele merging at protein identity (`--min_protein_allele_identity`).
  The settings come from development on V1 rounds 3-4; V2 tests them.
- **Protein mode, high-identity detection** (the "or" rule; V2 decision 1,
  user 2026-11-14; to be recorded as D31): a gene that fails f70g90 is also
  detected when its reads at 90% or more identity alone number at least
  `--min_arg_reads`, average 95% or more, and spread at least 0.8 times as
  widely as random reads (`--min_protein_core_read_identity 0.90`,
  `--min_protein_core_gene_identity 0.95`,
  `--min_protein_core_breadth_ratio 0.8`; `--min_protein_core_gene_identity 0`
  switches it off). Why: in mixtures other organisms' related genes
  (70-89%) pull a real gene's pooled identity below 90%
  (`validation/V1/dev_protein/results_2026-11-13/DIAGNOSIS.md`). On
  development data (V1 rounds 3-4) it found 519 of 522 and 469 of 474 truth
  loci, against 490 and 459 for f70g90 alone. The three values were chosen on
  those rounds; V2 tests them. DIAMOND_BLASTX makes the read statistics a
  second time over the reads at 90% or more (`core/`), and RESISTOME_TABLES
  applies the rule.
- **Protein mode, probable homologs** (V3 design, D32-D34, user
  2026-11-14): V2 failed marks 1-3 because real genes of a genus far from
  CARD's references lay at 86-92% identity, on the 0.90 cut. A gene that
  fails detection only on gene identity, at 85% or more
  (`--min_protein_probable_gene_identity 0.85`; 0 = off), with the read and
  breadth rules met, is now reported with `call = probable_homolog`. It is
  never counted as detected and has no copies per 16S copy. New `arg_long.tsv`
  column `call`: `detected`, `probable_homolog`, or empty. Detection itself is
  unchanged. Validated by V3 (`validation/V3/PREREGISTRATION.md`), not yet run.
- **Protein mode, minimum reads for the high-identity route** (V3 design, D2,
  user 2026-11-14): the "or" rule now needs at least `--min_protein_core_reads`
  (default 4) reads at 90% or more, never fewer than `--min_arg_reads`; 0
  keeps `--min_arg_reads` only. V2's unexplained calls IreK and acrA came from
  2-3 such reads. An offline sweep on V1 rounds 3-4 and V2
  (`validation/V3/SWEEP_CORE_CUT.md`) found no loci lost and 3 of V2's 4
  unexplained calls removed.
- New column `detected_by` in `arg_long.tsv`: `f70g90`, `high_identity`
  or `dna` for a detected gene, empty otherwise.
- DNA mode (RGI bwt) stays as `--count_mode dna`, unchanged.
- New column `count_mode` in `arg_long.tsv` and `denominators.tsv`; the
  summary names the engine. Protein mode publishes `diamond/` instead of
  `rgi/`; RGI's own columns (`rgi_percent_coverage`,
  `completely_mapped_reads`, `average_mapq`) are NA there.

## Branch `read-identity` (PR #3; development, not validated)

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
