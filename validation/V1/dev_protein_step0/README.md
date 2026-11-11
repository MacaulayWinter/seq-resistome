# Protein-mode step 0 (development, 2026-11-11)

This is the check run before building protein-level counting. The design is
`~/Documents/Bioinformatics_pipelines/seq_resistome_protein_mode_design.md`,
section 4, approved by the user: "Approve, run step 0".

**These are development results, not validation.** Every number here comes
from rounds 3 and 4, which have already been seen. The rule that worked
(f70g90) was found on these same data, so only a fresh, pre-registered
validation (V2) can test it.

## What was run

- **DIAMOND 2.2.8** blastx, `--sensitive --top 0` (each read's best-scoring
  hits only), against CARD 4.0.2's 6,059 protein homolog proteins.
- **Reads:** the six pure genomes at 10x.
  - Round 4: *E. hormaechei* GCF_051561185.1, *E. coli* GCF_051562295.1,
    *K. pneumoniae* GCF_051617105.1. These are the round-4 reads.
  - Round 3: three *E. coli*. Their reads were remade with ART, seed 20261030,
    exactly as round 3 made them.
- **Speed:** 15-21 seconds per mate file of about 170,000 reads, in one
  amd64 container under Rosetta.
- **Disk:** 60 MB in total.
- **Scripts:** `run_step0.sh`, then `score_step0.R`. `explore_floor70.R` is
  the exploration that led to rule f70g90.

**Scoring** is pure genomes only. Mixtures and backgrounds were not tested.

- **Detection:** a truth group is found when one of its CARD AROs is called.
- **Accuracy:** protein depth / simulated depth (D21), within 1.5x. This
  measures ARG counting alone, with no 16S.
- **Unexplained:** a called ARO not present in the genome by `locate.sh`'s
  DNA rule, as in mark 2.

## Results

The first attempt applied each rule to the mean over all of a gene's reads
(`mean_rule/`). It failed:

- Round 3: 99-126 of 136 groups found.
- Even *E. coli* marA, which is 100% identical to CARD, was missed.

The reason is that reads from paralogs land on the closest CARD protein. For
example, soxS and rob reads land on marA at about 50% identity and pull the
mean down.

Rules judged read by read (`per_read_rules/`):

| Rule | Round 3 found | Round 3 within 1.5x | Round 3 unexplained | Round 4 found | Round 4 within 1.5x | Round 4 unexplained |
|---|---|---|---|---|---|---|
| cutoff: CARD per-gene bitscore cut-off, per read (design PM2b) | 136/136 | 121/136 | 57 | 108/109 | 96/109 | 78 |
| id90: read identity >= 90% | 136/136 | 136/136 | 23 | 109/109 | 105/109 | 49 |
| id80: read identity >= 80% | 136/136 | 136/136 | 38 | 109/109 | 106/109 | 69 |
| **f70g90**: reads >= 70%, then gene identity >= 90% | **136/136** | **135/136** | **1** | **108/109** | **104/109** | **1** |

- **Round 4's DNA-mode misses are recovered** under f70g90, at 0.82-0.98x of
  simulated depth:
  - *Enterobacter*: emrB, emrR, marA, msbA, CRP.
  - *Klebsiella*: emrR, marA, msbA, CRP.
- **The look-alikes stay out.** *E. coli* LptD, MdtK and eptB are not called
  under f70g90. They were round 3's unexplained DNA calls (D17).
- **Most calls outside the truth under the single-read rules are real
  orthologs.** Their whole protein is 75-90% identical to CARD's, and RGI
  `main` rates them only "Loose" (for example YojI, mdfA, MdtK, TolC and AcrF
  in *Enterobacter* and *Klebsiella*). Conserved stretches give single reads
  of 90% or more. The gene-level identity separates them, whereas single
  reads do not. Gene-level identity against the threshold:

  | Gene-level identity ≥ | Truth genes kept (of 275) | Non-truth genes kept (of 160) |
  |---|---|---|
  | 88% | 274 | 13 |
  | 90% | 274 | 2 |
  | 92% | 268 | 1 |

- **CARD's per-gene cut-off (design PM2b) does not work on short reads.** It
  calls the most genes that aren't in the truth. Some cut-offs are very low,
  for example the van ligases at about 0.5 of a perfect match, and one read
  of about 50 amino acids is too short to judge against them.

## Still wrong under f70g90 (all development data)

- **Klebsiella OmpK37 missed.** The gene identity is 83.7%, although RGI
  gives 94% for the whole protein. Porin reads from hypervariable loops and
  from other porins pull the gene identity down.
- **AAC(6')-Ib10: 3.97x in Enterobacter and 1.55x in Klebsiella.** DNA mode
  was 3.6-4.75x. The same overcount under both engines points to the truth,
  probably extra copies of the gene missing from the truth loci, not to the
  counting. Still to check.
- **SHV-12: 0.59x in Enterobacter.** Reads split between near-identical SHV
  alleles. The pipeline's allele merging (D22) is meant for exactly this;
  step 0 doesn't merge.
- **ugd: 1.50-1.56x in E. coli.**
- **Unexplained calls:**
  - **rsmA** in round 3. It's a protein-only hit: RGI `main` calls it Strict
    at 85% protein identity, so it really is in the genome. It counts as
    unexplained only because the marks' "present" test is DNA-based.
  - **ANT3II_ANT6II**, 2 reads covering 11% of the protein, in round 4. It's
    a fused protein whose AAC(6')-Ib part draws reads from the real
    AAC(6')-Ib gene.

The raw DIAMOND hits (2.5 MB, over the repo's 1 MB file limit) are kept
outside the repo at `~/seqresistome-scratch/step0_diamond_hits.tar.gz`, so the
scores can be redone with `score_step0.R` without rerunning DIAMOND.
