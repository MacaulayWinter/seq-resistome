# V4 Addendum B: a missing simulated depth at a spike depth below 1x

Written 2026-11-15, after the pipeline run of V4 finished and `score_V4.R` stopped, and **before any V4 mark was computed or seen**.
Decided by the user on 2026-11-15 (relayed by the coordinator: "go with your recommendation", option A).

## What happened

The scorer stopped with "mix_gut_GCF_062058145.1_0.5x has no simulated depth for ...". `simulated_depth.sh` maps each spike's reads with
`kma -1t1`. For *Vibrio cholerae* GCF_062058145.1 (two chromosomes) at 0.5x (6,883 spike pairs), kma chose the small chromosome 2 as its
sole template and aligned no read (every SAM record unaligned, position 0). The depth file is header-only. Two samples are affected:
**mix_gut_GCF_062058145.1_0.5x and mix_wastewater_GCF_062058145.1_0.5x: no simulated depth, reported as NA.** The other 26 depth files are complete.

## The change (3 lines in `score_V4.R`, in `locus_depth`)

For a sample whose spike depth is below 1x and whose depth file holds no locus rows, `locus_depth` returns NA instead of stopping. Any other
missing depth (at 1x or more, or a partial file) still stops. Marks 1-5, E4 and all truth values are unchanged; no new simulation.

## Why it cannot change a marked quantity

- Marks use only samples at spike depth 1x or more. `locus_depth` returns NA only below 1x, so no marked sample's depth changes.
- Mark 1's `marked` flag is `spike_depth >= 1 & sd >= 1 & identity >= 92`; with spike depth below 1x it is FALSE whether `sd` is a number or NA (FALSE & NA is FALSE).
  The reported 0.5x detection counts rows by `depth < 1` and never reads `sd`. The below-1x list and the identity-band report filter on `depth >= 1`, so they exclude these rows as before.
- Mark 3 calls `locus_depth` only for pure (10x) and 8x samples.
- **Check on V3's saved run:** `score_V4.R` run on V3's results, truth and simulated depths writes `mark1_detection.tsv`, `mark2_specificity.tsv`, `mark3_accuracy.tsv`,
  `mark4_edge_cases.tsv`, `probable_homologs.tsv`, `protein_only_hits.tsv`, `reported_16s_pure.tsv`, `truth_groups.tsv`, `truth_loci.tsv` byte-identical to V3's
  scored outcomes (the commit-927ea4f result: mark 1 140/140, mark 2 9 unexplained, mark 3 pass, mark 4 pass), and the marks report identical apart from the label V4 for V3.
