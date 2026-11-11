# Round 3, CARD alone with the D19/D20 fixes: why marks 1 and 3 still fail

These are development results (rounds 1-3 only), from 2026-11-09. Round 3's
27 samples were run with CARD 4.0.2 alone and all kept fixes: read identity,
the 16S short-hit filter and copy count, per-reference breadth, and the 95%
interval. The run was then scored by location (`score_V1_round3.R`) at five
read-identity thresholds (`apply_identity.R`).

## Marks

| Identity | 1. Truth loci found (need 544/544) | 2. Unexplained genes (need 0) | 3. Pure-genome groups within 1.5x (need 136/136) |
|---|---|---|---|
| 0 | 543 | 22 | 131 |
| 0.80 | 543 | 19 | 131 |
| 0.85 | 543 | 1 | 131 |
| 0.90 | 543 | 1 | 131 |
| 0.95 | 472 | 1 | 121 |

Edge cases E1-E3 pass at every threshold. Full reports are in `marks_identity_*.md`.

## Finding: the misses are in the simulated reads, not the pipeline

The misses on marks 1 and 3 are at loci where the read simulator (ART)
produced far fewer reads than the genome's nominal depth. The pipeline
counted the reads that were there.

To show this, each sample's simulated reads were mapped (kma, `-1t1`) to the
genome's own sequence at each truth locus. That gives the depth actually
simulated there (`simulated_depth_*.tsv`).

| Sample | Gene | Ratio reported / truth | Simulated depth (nominal 10x) | Reads the pipeline counted | Reads simulated at the locus (about) |
|---|---|---|---|---|---|
| pure GCF_051559745.1 | mdtE | 0.52 | 5.5x | 44 | 43 |
| pure GCF_051559745.1 | CMY-181 (reported as EC-5) | 0.63 | 7.8x | 53 | 52 |
| pure GCF_051618695.1 | E. coli emrE | 0.57 | 6.2x | 16 | 14 |
| pure GCF_051618695.1 | gadX | 0.65 | 7.0x | 45 | 38 |
| pure GCF_051618695.1 | AcrS | 0.66 | 7.0x | 35 | 31 |

These five are the lowest-depth loci in their genomes, or among the lowest.
The same genes pass in the other genome, where their simulated depth is
normal (mdtE 8.6x there, gadX 8.6x, AcrS 10.9x, emrE 11.7x).

Mark 1's one miss works the same way. In `mix_wastewater_GCF_051563765.1_2x`,
EC-5 was simulated at 0.4x (about 3 reads) against a nominal 2x. That is
below what any read-based method can detect at the 2-read minimum.

The simulated depth varies far more than chance would give. Reads landing
at random (Poisson) would put about 0.5 of the 134 pure-genome groups
outside 1.5x; 5 are outside.

## Why protein-level mapping was not pursued

The user approved trying protein-level mapping (2026-11-09) on the
hypothesis that these genes are too divergent from CARD's references. Its
first check refuted that:

- The five genes are 97.8-99.5% identical in DNA to CARD's reference, not 80-90%.
- Error-free 150 bp reads tiled across each locus (both strands) all map, by
  kma, to the gene's own CARD reference (`tiled_reads_kma_assignment.tsv`).
  The one exception is CMY-181: 322 of its 344 tiles land on EC-5, another
  E. coli AmpC. Scoring by location counts that as the right locus.

So no reads are lost in mapping, and protein mapping has nothing to recover.

## Remaining genuine miss

Mark 2 at identity 0.85 or more: OXA-1307 in
`mix_wastewater_GCF_051618695.1_8x`. It has 2 reads covering 28% of the
gene, and is detected because it just meets the 2-read rule.

## Decision (user, 2026-11-09): truth from the depth actually simulated

Marks 1 and 3 compared against a truth that assumed every locus was
simulated at the genome's nominal depth. The user chose to base the truth on
the depth actually simulated at each locus, with the mark wording unchanged
(CLAUDE.md D21):

- `simulated_depth.sh` measures that depth.
- `score_V1_round4.R` scores against it.

Rescored at each identity threshold (`marks_simulated_depth_identity_*.md`):

| Identity | 1. Loci found | 2. Unexplained | 3. Pure groups within 1.5x | 3. 8x mixtures within 2x |
|---|---|---|---|---|
| 0 | 522 / 522 PASS | 22 | 135 / 136 | 222 / 222 |
| 0.80 | 522 / 522 PASS | 19 | 135 / 136 | 224 / 224 |
| 0.85 | 522 / 522 PASS | 1 | 135 / 136 | 227 / 227 |
| 0.90 | 522 / 522 PASS | 1 | 135 / 136 | 236 / 236 |
| 0.95 | 457 / 522 | 1 | 124 / 136 | 217 / 239 |

Mark 1 no longer marks 22 loci, because they were simulated below 1x. Of
those 22, 21 were detected anyway. The one missed is EC-5 at 0.37x.

What is left are genuine pipeline issues:

1. **16S overcount, 1.09-1.14x** of the depth simulated at the complete 16S
   copies. It pulls every ratio down: the pure-genome median is 0.90. The
   simulated 16S depth itself is 0.93-1.0x of the genome's depth, so the
   truth side is sound. The cause is still open.
2. **Reads split between near-identical alleles.** EC-18 (pure
   GCF_051618695.1, ratio 0.64) had its reads go 60 / 10 / 10 to EC-18, EC-15
   and EC-8. The two minor alleles fail the breadth rule alone, so their
   reads are not counted.
3. **OXA-1307**: 2 reads covering 28% of the gene, in one 8x mixture.
