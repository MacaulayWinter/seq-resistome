# Validation V1 (v0.1): pre-registration

Written and committed on 2026-10-28, **before any validation data was
chosen, fetched or made** (the commit that adds this file is the proof).
The plan (CLAUDE.md D1, section 6) set the outline; this file fixes every
number. Nothing here changes after data is chosen without asking the user
(CLAUDE.md D1, section 5, item 2).

The pipeline under test is fixed at the commit that adds this file, with its
defaults: CARD 4.0.2 (`--card_version validated`), hostile `human-t2t-hla`,
SortMeRNA 16S (SILVA bacteria and archaea, SortMeRNA 4.3.7), detection rule
`--min_arg_reads 2 --min_breadth_ratio 0.5`.

## 1. Data, chosen by rules written now

**Spike genomes (truth).** The layer D isolates of seq-triage's validation
(rounds 1 and 2, `seq-triage/validation/layer_D/sources.tsv` and
`round2/sources.tsv`: ten isolates from PRJNA1287288) whose assembly in NCBI
is a RefSeq assembly at level *Complete Genome*, looked up once after this
file is committed. If more than four qualify, the first four in the order of
those two files (round 1, then round 2). If fewer than two qualify, stop and
ask (a data doubt).

**Truth per genome**, from the assembly itself, never from reads:

- ARGs: RGI 6.0.8 `main` on the assembly (contigs, DIAMOND, CARD 4.0.2,
  defaults), protein homolog models, hits of class Perfect or Strict. Copies of an ARO per genome = the number of
  such hits.
- Loose homologs: the same run with `--include_loose`; Loose hits with Best
  Identities >= 80% are recorded as *explainable* (reads of such a gene can
  map to CARD), not as truth.
- 16S copies per genome: barrnap 0.9 (`--kingdom bac`), full-length 16S
  hits.

**Backgrounds.** Two real shotgun metagenomes from ENA, one per type:
*human gut metagenome* (NCBI taxon 408170; it brings real human reads, so it
also tests host removal) and *wastewater metagenome* (527639). For each type,
ENA's portal API (`result=read_run`) is searched once for runs with
library_strategy WGS, library_source METAGENOMIC, instrument_platform
ILLUMINA, library_layout PAIRED, read_count >= 2,000,000, base_count /
read_count between 290 and 302 (2 x 150 bp), first_public 2020-01-01 to
2025-12-31. One run per study is kept (the first listed), the list is
ordered by run accession and shuffled with R's `set.seed(20261028)`;
`sample()`; the first run is the background, the next two are backups used
only if a download fails. The query, the full candidate list and the draw
are saved in `validation/V1/`. The first 1,000,000 read pairs of each run are
used.

**Edge-case samples**, chosen now:

- E1, no ARGs but 16S: reads simulated from *Mycoplasmoides genitalium* G37
  (NC_000908.2), 10x depth. If RGI `main` finds any Perfect or Strict hit in
  it, E1 is scored against that truth instead.
- E2, no 16S and no ARGs: reads simulated from phage lambda (NC_001416.1),
  10x depth.
- E3, only host: the first 200,000 read pairs of HG002 (SRR37356339; human,
  openly consented, used by seq-triage layer D).
- E4, left out by seq-triage: seq-triage (its `main` on 2026-10-28) is run on
  three samples (mixture M1 below at 8x, the first spike genome's pure
  reads, and a 50-pair subsample of that genome's reads); seq-resistome then
  runs with `--triage_results`.

## 2. Test samples

Reads are simulated with ART (`art_illumina`, HiSeq 2500 profile `HS25`,
2 x 150 bp, fragments 350 +/- 50 bp, seed 20261028), every replicon of an
assembly at the same depth (plasmid copy number is not simulated, so a
plasmid gene's true copies per genome is its count in the assembly).

- **Pure genomes:** each spike genome alone at 10x depth.
- **Mixtures:** each spike genome x each background x three depths,
  **0.5x, 2x and 8x** (reads simulated to that depth over the whole
  assembly, added to the background's 1,000,000 pairs).
- **Backgrounds alone:** each background's same 1,000,000 pairs.
- **Edge cases:** E1-E4.

## 3. Pass marks (fixed numbers)

The unit is the CARD gene (ARO). Reads cannot reliably tell close alleles
apart (TEM-1 from TEM-116), so a call of a different ARO in the **same CARD
AMR gene family** counts as finding the gene; how often the exact ARO is
found is reported, not marked.

1. **Detection.** In every mixture at 2x and 8x, every truth ARO of the
   spike genome is detected (`detected = TRUE`) as itself or as an ARO of
   its AMR gene family. Mark: **100%** of truth AROs, in every such mixture.
   (0.5x is reported, not marked: about 3 reads per kilobase.)
2. **Specificity.** In every mixture, pure-genome and edge sample, every
   detected ARO's AMR gene family is in the spike genome's truth, its
   explainable Loose homologs, or the families detected in the same
   background run alone. Mark: **0** unexplained families in every sample.
3. **Accuracy (copies per 16S copy).** Truth for a pure genome: an AMR gene
   family's copies per genome / the genome's 16S copies. Truth in a mixture,
   for a spiked family not detected in the background alone: (family copies
   x spike depth) / (spike 16S copies x spike depth + the background's 16S
   copies as measured on the background alone). Observed: the sum of
   `copies_per_16s` over the family's detected AROs. Marks: **pure genomes,
   every family within a factor of 1.5** of truth; **mixtures at 8x, every
   spiked family within a factor of 2**. (The mixture truth relies on the
   pipeline's own background 16S estimate; the pure genomes do not, which is
   why their mark is tighter.)
4. **Edge cases.** E1: present in every table, 0 detected ARGs (or exactly
   its truth), copies per 16S copy 0 (not missing). E2: present, 0 detected,
   copies per 16S copy missing (NA) everywhere, never infinite, with the
   note saying why. E3: present with status "no reads left after host
   removal" (or, if hostile keeps some human reads, 0 detected and the host
   share >= 99%). E4: every sample seq-triage did not pass as a short-read
   metagenome is in `samples_left_out.tsv` with seq-triage's reason and in no
   other table; every sample it passed is analysed.
5. **The CARD cache.** With the real cache and card.mcmaster.ca: a second
   run downloads nothing (the log says "reused from the cache"); a cache
   archive with bytes appended is detected, reported and fetched again, and
   the run completes with CARD 4.0.2's pinned checksum.

**Reported, not marked:** exact-ARO recovery; detection at 0.5x; 16S copies
estimated vs truth on pure genomes; RPM and RPKM (no independent truth).

## 4. Where it runs

On the Mac if one 2-million-read mixture completes in under 20 minutes
there; otherwise the mixtures are queued for ISCA (batch given to the user
from 2026-10-29) and only truth, edge cases and the CARD cache test run on
the Mac.

## 5. If a mark fails

Reported as failed, with the samples and genes. One fix, a regression check
on the samples that passed, and confirmation on fresh data chosen by the
same rules (the next spike genomes or backups, never the failing samples
again). Still failing after that: stop and ask (CLAUDE.md D1, section 5).
