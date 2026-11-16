# Validation V2: pre-registration (protein mode)

**IN FORCE from the commit that contains this sentence (2026-11-14).**
Written 2026-11-11 to 2026-11-14 during the protein-mode build (CLAUDE.md
D27; design PM4). The user approved its choices on 2026-11-14 (the "or"
rule, four species, backgrounds, genome draw, allele identity, mark 5 and E4
at 8 GB). Before this commit: the development run on V1 rounds 3 and 4, a
passing `-profile test` run in protein and DNA mode on the pipeline commit
section 1 names, and the DNA-mode end-to-end CI step (added in that
commit; it runs on GitHub when the commit is pushed).

Nothing in section 3 was listed, fetched, simulated or looked at before
this commit.

**The marks are V1 round 4's, word for word**, with the one scoring change
the user approved (PM5 b, 2026-11-11; section 2). If any mark fails, V2
fails, and Claude stops and asks the user. A miss that falls inside the
gene's own 95% interval is still a miss.

## 1. Pipeline under test

Pipeline commit **f20ef13** (branch `protein-mode`), with its defaults:

- `--count_mode protein` (DIAMOND 2.2.8 blastx against CARD 4.0.2's protein
  homolog proteins).
- **Detection rule: "or". Frozen.** It replaces D28's f70g90 alone (the user,
  2026-11-14). It is the two-stage rule f70g90 with one more way in:
  - `--min_protein_read_identity 0.70` and `--min_protein_gene_identity 0.90`:
    f70g90, as D28. Reads at 70% or more amino-acid identity to their best
    CARD protein are kept. The gene passes if its kept reads, weighted by
    alignment length, average 90% or more, and it passes the read-count and
    breadth rules below.
  - **or** the gene's reads at 90% or more identity alone number at least 2,
    average 95% or more (length-weighted), and cover at least 0.8 of the
    breadth that reads landing at random would (`--min_protein_core_read_identity
    0.90`, `--min_protein_core_gene_identity 0.95`,
    `--min_protein_core_breadth_ratio 0.8`). Its
    copies then count only those reads.
  - Why: in mixtures, other organisms' homologs at 70-89% pull a real gene's
    pooled identity below 90% (DIAGNOSIS.md, 2026-11-13). Rule "or" found 519
    of 522 round-3 and 469 of 474 round-4 truth loci (current rule: 490 and
    459), with 0 and 5 unexplained detections (current: 0 and 3).
    Development data only; the three values 0.90, 0.95, 0.8 were chosen on
    rounds 3 and 4. These three values and 0.70/0.90 may not be changed by
    the V2 run; if V2 shows they fail, Claude stops and asks.
- `--min_protein_allele_identity 0.95` (the pipeline default; not changed in
  the development run).
- `--min_16s_identity 0.90`, `--min_16s_bases 50`.
- `--min_arg_reads 2`, `--min_breadth_ratio 0.5`.

It is run as `validation/V1/run_V1.sh` runs it, with a V2 scorer that is
`validation/V1/dev_protein/score_dev_protein.R` copied to
`validation/V2/score_V2.R` (unchanged apart from its title comment) and
committed with this file.

## 2. Scoring

As V1 round 4 (`PREREGISTRATION_round4.md` section 2, `score_V1_round4.R`):

- **Mark 1, detection:** 100% of truth loci in the 2x and 8x mixtures whose
  locus was simulated at 1x or more.
- **Mark 2, specificity:** 0 unexplained detected AROs.
- **Mark 3, accuracy:** copies per 16S copy against the simulated depth, per
  location group: pure genomes within 1.5x, 8x mixtures within 2x.
- **Mark 4, edge cases E1-E4.**
- **Mark 5, the CARD cache.**

**One change (PM5 b):** in mark 2 only, a detected ARO that RGI `main`
calls Perfect or Strict (protein homolog model) in the spike genome counts
as "present in the spike genome", even when no CARD DNA reference lies
there. Marks 1 and 3 still exclude protein-only hits, so detection and
accuracy are no easier to pass. **Frozen.** The user approved it on
2026-11-11 and confirmed it on 2026-11-12, with one condition.

**Condition (user, 2026-11-12): DNA-found and protein-only genes are always
reported apart.** The marks file lists:
- the detections explained by a CARD DNA reference in the spike genome;
- the detections explained only by an RGI `main` protein hit, by name;
- mark 2's result under V1 round 4's DNA-only test, reported but not
  marked.

`mark2_specificity.tsv` has both columns, `explained_by` and
`explained_by_dna_only`.

**Mark 5 and E4** run with a configuration that allows 8 GB per task, the
test profile's request. In V1 round 4 they were not run because of a 6 GB
cap: a setup error, not a pipeline result.

Reported, not marked:

- each unit's 95% interval, and whether the truth lies inside it;
- results per genus;
- every round-4 report.

## 3. Fresh data, by rules written now

**Frozen with this file (user, 2026-11-14).**

- **Spike genomes: four species, each from a different genus.** At least
  three genera, with at least one outside Enterobacterales (PM4). None of
  these genera has been used for development:
  - *Citrobacter freundii* (Enterobacterales, a genus not seen before);
  - *Pseudomonas aeruginosa* (Pseudomonadales);
  - *Acinetobacter baumannii* (Moraxellales);
  - *Enterococcus faecium* (Gram-positive, Lactobacillales).

  For each species, list the RefSeq assemblies at level *Complete Genome*
  released on or after **2026-11-14**, from NCBI Datasets, after
  the in-force commit. Order them by accession, shuffle with R's
  `set.seed(20261111)` and `sample()`, and take the first. Save the list and
  the draw. A species with no such assembly takes the next release window
  back, one month at a time.
  - The test profile's `mock_community` holds reads of other *P.
    aeruginosa* and *A. baumannii* genomes. These are test data, not
    development data: no setting was chosen on them.
- **Backgrounds:** the same two types (human gut, wastewater). For each, the
  first run after the one V1 round 4 used in its candidate list
  (`validation/V1/candidates_<type>.tsv`, draw order) that is paired-end
  Illumina and can be fetched. Take its first 1,000,000 pairs.
- **Simulation:** ART seed **20261111**. Depths are 0.5x, 2x and 8x; pure
  genomes are at 10x. E1 and E2 are as before, with the new seed. E3 uses
  HG002 pairs 800,001-1,000,000. E4 uses V2's first spike genome.
- **Truth:** as V1 round 4. RGI `main` Perfect/Strict protein homolog hits
  that are findable by reads (`truth_findable.sh`), placed by `locate.sh`,
  with depths from `simulated_depth.sh`.
- All of this is done by a `run_V2.sh`, written from `run_round4.sh`, which
  refuses to start while this file is a draft.
