# Validation V1, round 2: pre-registration

Written and committed on 2026-10-29, **before any round-2 data is fetched,
simulated or looked at** (the commit adding this file is the proof). Round 1
(`PREREGISTRATION.md`) failed marks 1-3 (CLAUDE.md D12). The user chose
option A on 2026-10-29: re-register with a truth that read mapping can be
held to, a family match on a shared CARD family term, the marks' numbers
unchanged, the 16S fix as the one fix cycle, and confirmation on fresh data.
If any mark fails in round 2, Claude stops and asks (no further fix cycle).

Everything not changed here stays as in `PREREGISTRATION.md`.

## 1. What changes, and why

| | Round 1 | Round 2 | Why |
|---|---|---|---|
| Truth genes | RGI `main` Perfect/Strict protein homolog hits on the assembly | The same hits, **kept only if findable by reads** (below). The rest are **protein-only hits**: listed in full, with their count, in the outputs and in CLAUDE.md, never scored | 24 of 136 round-1 truth genes got no read at all: RGI `main` finds them by protein similarity, but their DNA is too far from CARD's reference for any read mapper |
| Same gene family | CARD's AMR Gene Family label, exact text | **At least one family term in common**, a label being split at "; " into its terms | Close alleles carry differently worded labels (AAC(6')-Ib7 "AAC(6')" vs AAC(6')-Ib-cr5 "AAC(6'); AAC(6')-Ib-cr") |
| 16S copies | 16S reads x mean read length / 1,542 | **16S aligned bases / 1,542** | 27% of 16S reads align over only part of their length; counted as whole reads they inflated 16S copies 1.25-1.34x |
| Mark numbers | | **unchanged**: 100%, 0, 1.5x, 2x, edge cases, cache | |

**Findable by reads**, fixed now: a truth hit is findable if its predicted
gene DNA (RGI `main`'s `Predicted_DNA`) has a BLASTN hit (BLAST 2.17.0,
`blastn -task blastn`, not megablast) against CARD
4.0.2's `nucleotide_fasta_protein_homolog_model.fasta` with **>= 80%
nucleotide identity over >= 80% of the gene's length** (one HSP). 80% is
a common working limit for mapping short reads to a divergent reference;
it is set here, before any round-2
result exists, and is not tuned.

**Explained families** (mark 2) now also include the terms of the genome's
protein-only hits (real genes that are there, whether or not reads find
them), as well as the spike truth, Loose hits >= 80% and the background run
alone, all matched by shared term.

**Accuracy units** (mark 3): each truth family label of a genome is one
unit; its truth copies are the copies of its findable truth genes. Each
detected ARO in a sample is assigned to the one truth label it shares the
most terms with (ties: alphabetical first), so no read is counted twice;
detected AROs sharing no term with any truth label are left to mark 2.
Mixture accuracy is scored only for labels none of whose terms were
detected in the background alone.

## 2. Fresh data, by the same rules

- **Spike genomes:** the three reserves of `spike_genomes.tsv`, in order:
  **AH21H052** (E. coli, GCF_051563005.1), **KPE040** (K. variicola,
  GCF_051619525.1), **CPO413** (E. hormaechei, GCF_051617875.1). Three, not
  four: no other layer D isolate qualifies.
  *Disclosure:* these three assemblies were downloaded, and RGI `main` and
  barrnap run on them, on 2026-10-28 before round 1 (`truth.sh` ran over
  every genome). Only one summary line per genome was printed (RGI hit
  counts 55, 37, 37; 16S genes 7, 8, 8); the files were moved aside unread
  on 2026-10-29 and the truth is recomputed from scratch after this commit.
- **Backgrounds:** each type's **backup 1** from the round-1 draw
  (`backgrounds.tsv`, never fetched): human gut **SRR28158871**
  (PRJNA1081952), wastewater **SRR11809751** (PRJNA620830); first 1,000,000
  pairs. If one fails to download, backup 2.
- **Simulation:** as round 1 but ART seed **20261029**; depths 0.5x, 2x, 8x;
  pure genomes 10x.
- **Edge cases:** E1 and E2 as round 1 with the new seed; E3 the **next**
  200,000 pairs of HG002 (pairs 200,001-400,000); E4 as round 1 (platform
  declared), on round 2's first mixture (AH21H052 in gut at 8x) and genome.
- **Mark 5:** repeated with the real cache.

## 3. Regression check (not a mark)

Before round 2, the round-1 samples are re-run with the 16S fix and scored
with the round-2 scorer, to show the fix changes what it should and
nothing else (edge cases E1-E3 must still pass). These samples were used to
find the problems, so their scores are reported as development results,
never as validation.

## 4. Pass marks, round 2

1. **Detection:** 100% of findable truth genes found (same ARO or a shared
   family term) in every mixture at 2x and 8x.
2. **Specificity:** 0 unexplained families in every scored sample.
3. **Accuracy:** pure genomes every unit within 1.5x; 8x mixtures every
   unit within 2x.
4. **Edge cases** E1-E4 as round 1.
5. **CARD cache** as round 1.

Reported, not marked: every protein-only hit; exact-ARO recovery; 0.5x
detection; 16S copies vs truth.
