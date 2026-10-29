# Validation V1, round 3: pre-registration (scored by location)

Written and committed on 2026-10-29, **before any round-3 data is chosen,
fetched, simulated or looked at** (the commit adding this file is the
proof). Rounds 1 and 2 failed marks 1-3 (CLAUDE.md D12, D15), mostly
because CARD's family labels, not the counts, decided the score. The user
chose round 3 scored by location on 2026-10-29: the pipeline is unchanged;
its known weak spots are stated as limitations; if any mark fails, Claude
stops and asks.

Everything not changed here stays as in rounds 1 and 2.

## 1. Pipeline under test

The commit that adds this file, unchanged (16S by aligned bases, D13; RGI
alignment clean-up, D14). Known weak spots, stated in the README before
round 3 is run: a call made from 2 reads on a long gene that only resembles
a resistance gene (e.g. a Bifidobacterium rpoB reference hit by E. coli
reads); ABC transporters undercounted (about 0.4x); chloramphenicol
acetyltransferases and porins overcounted (up to about 2x). These are not
excused by the marks: if they make a mark fail, round 3 fails.

## 2. Scoring by location

Truth stays as in round 2: RGI `main` Perfect/Strict protein homolog hits
on the assembly that are findable by reads (`truth_findable.sh`); the rest
are protein-only hits, listed in full with their count, never scored. Each
truth hit is a **locus**: its contig, start and stop in the assembly.

**Where a CARD gene lies in a genome** (`locate.sh`): every CARD 4.0.2
protein homolog reference (`nucleotide_fasta_protein_homolog_model.fasta`,
6,059 sequences) is searched against the assembly with BLASTN 2.17.0
(`-task blastn`, e-value 1e-10). An ARO **lies at** a locus if one of its
references has an HSP of >= 80% identity that overlaps the locus by >= 50%
of the locus length. An ARO **is present** in a genome if one of its
references has an HSP of >= 80% identity over >= 50% of the reference's
length anywhere in it.

1. **Detection:** a truth locus is found in a sample if a detected ARO is
   the locus's own ARO or lies at the locus. Mark: **100%** of truth loci,
   in every mixture at 2x and 8x.
2. **Specificity:** a detected ARO is explained if it is present in the
   spike genome (any locus, truth or not), or the same ARO is detected in
   the same background run alone, or it shares a CARD family term with an
   ARO detected there (backgrounds have no assembly, so the round-2 family
   rule stays for them). Mark: **0** unexplained detected AROs in every
   mixture, pure-genome and edge sample.
3. **Accuracy (copies per 16S copy):** truth loci and the detected AROs
   lying at them are joined into groups (two loci are in one group when an
   ARO lies at both, so one true total is never split between neighbours,
   the round-2 problem). Each group is one unit. Truth: the group's loci /
   the genome's 16S copies (pure); in a mixture, (loci x spike depth) /
   (spike 16S copies x spike depth + the background's 16S copies measured
   alone), only for groups none of whose AROs is detected in the background
   alone. Observed: the sum of `copies_per_16s` over the group's detected
   AROs. Marks: **pure genomes, every group within 1.5x; 8x mixtures, every
   group within 2x**.
4. **Edge cases** E1-E4, as round 1.
5. **CARD cache**, as round 1.

Reported, not marked: exact-ARO recovery, detection at 0.5x, 16S copies vs
truth, the protein-only hits, and the round-1 and round-2 data rescored
this way (development results, never validation).

## 3. Fresh data, by rules written now

- **Spike genomes:** RefSeq assemblies at level *Complete Genome* from
  BioProject PRJNA1287288 that are **not** layer D isolates of seq-triage
  (rounds 1 and 2), listed once from NCBI Datasets after this commit,
  ordered by accession, shuffled with R's `set.seed(20261030)`;
  `sample()`; the first **three**. The list and the draw are saved.
- **Backgrounds:** each type's **backup 2** from the round-1 draw
  (`backgrounds.tsv`, never fetched): human gut **SRR26421003**
  (PRJNA800070), wastewater **SRR31394446** (PRJNA1187900); first 1,000,000
  pairs. If one cannot be fetched, the next run in that type's candidate
  list (`candidates_<type>.tsv`, draw order).
- **Simulation:** ART seed **20261030**; depths 0.5x, 2x, 8x; pure genomes
  10x. E1 and E2 as before with the new seed; E3 HG002 pairs
  400,001-600,000; E4 on round 3's first spike genome (mixture in gut at 8x,
  its pure reads, a 50-pair subsample), platform declared.
- Mark 5 repeated with the real cache.
