# CLAUDE.md: seq-resistome

> **What this file is:** the public development log of seq-resistome, kept
> as it is built with Claude Code (an AI coding assistant). Claude reads it at
> the start of every session; people can read it to see why each design
> choice was made. The **plan** (D1) comes first, as agreed; then the
> **decisions log** (every decision, with its reason) and the **CI fix log**
> (every CI failure and how it was fixed). It names the HPC cluster the
> validation runs on by name only: no accounts, usernames or paths.

## Project

A Nextflow DSL2 pipeline for antibiotic resistance genes (ARGs) in shotgun
metagenomes, the first domain pipeline after
[seq-triage](https://github.com/MacaulayWinter/seq-triage) (whose conventions
it copies). A portfolio piece: every design choice must be defensible in
interview.

**Working agreement** (user, 2026-10-28: "I accept your suggestions as
written"): Claude builds milestone by milestone without checking in, posting
a short summary at the end of each milestone. Claude decides and logs code,
tests, CI, versions (two-week rule), test data, bug and CI fixes (each
explained in plain language below), pass marks written before data is
chosen, and merging its own PRs once CI is green, a full `-profile test` run
has passed and the final diff is reviewed. Claude stops and asks only for the
list in D1 section 5. Auto-merge is never enabled. Nothing is ever run on the
HPC by Claude: HPC work is queued as scripts the user submits (with their
`sbatchm` alias; no email or account in this repository).

## Hard rules

- No research data in the repository, ever: public test data only, referenced
  by URL and pinned by commit. Validation reads are built outside it.
- CARD is never in the repository: it is downloaded from card.mcmaster.ca
  into a cache (D5). The repository guard blocks CARD files (D3).
- Reuse nf-core modules for every standard tool; our own code is the read
  bookkeeping, the 16S count and the tables.
- Pin every container and tool version, at least two weeks old (D2).
- Negative results are always reported. A failed pass mark blocks: fix,
  regression-check, confirm on fresh data (D1 section 5).
- Never pool timepoints; models write tables that figures only read (X0124's
  working rules, for v0.2).
- Keep this file current at the end of each session.

## D1. The plan (agreed 2026-10-28; the first entry, as written)

The plan below was accepted by the user on 2026-10-28 (sections 1-6 as
first drafted, with the revisions listed at its top). It is the
specification. Section 5 is the list of things Claude stops and asks about;
section 6 the validation outline that `validation/V1/PREREGISTRATION.md`
turns into fixed numbers (D11).

### seq-resistome: roadmap, v0.1 build plan and working agreement

Drafted 2026-10-28; revised the same day with Macaulay's changes:

- keep CARD downloaded between runs;
- a validated-or-latest CARD switch;
- no ISCA work until 2026-10-29;
- the end product is a curated set of statistics, tables and figures, chosen
  automatically to fit the study's design: a general exploratory survey that
  helps the user choose what to probe, not a replica of X0124.

Sections 1–6 were accepted as written; this revision adds to them. Once
approved, this becomes the first entry in the repository's `CLAUDE.md`, and
Claude works from it, checking in only where section 5 says to stop.

#### 1. The end product, and what to call it

The aim is one folder per study: a general, exploratory survey of the
resistome, not answers to one study's questions. It shows:

- what is there;
- how it varies between samples, groups and times;
- which differences look strong enough to follow up.

You then decide what to probe further. X0124's specialised analyses (for
example temperature x treatment risk, or the five-genus volcano) are examples
of follow-ups a user might choose. They are not things the pipeline tries to
reproduce. X0124 supplies working rules (never pool timepoints; models write
tables that figures only read), not figure designs.

**It ends with a ranked "leads" table:** every signal the survey found, with
its effect size, uncertainty, the test used and its caveats (small groups,
p-value floor, leave-one-out instability). It is a list of things worth a
closer look, not a list of findings.

**The design comes from the samplesheet's metadata:**

- a single timepoint gives a **snapshot**;
- the same subjects sampled at several times gives **change over time**.

**The statistical method is chosen by an inbuilt design triage** (section 3),
like the R_Bible's.

**Name for the folder.** Options:

- **compendium** (a curated, complete collection);
- **dossier**;
- **atlas**;
- **results book**.

Recommended: **compendium** (`compendium/` in the output; "the resistome
compendium" in prose). This is a placeholder until you choose; changing it
later is a rename.

#### 2. Roadmap

Each version is released only after its own pre-registered validation passes.

| Version | Adds | Figures it makes possible |
|---|---|---|
| **v0.1** | Read-based ARG counts (RGI bwt / CARD), host removal, 16S denominator, the normalisation ladder | Per-sample ARG tables; distributions of abundance per sample |
| **v0.2** | The compendium: design triage, descriptive statistics, ARG diversity (richness, Shannon), drug-class composition and shifts, ordination with PERMANOVA, DESeq2 gene contrasts, gene-set enrichment (fgsea) over drug classes and mechanisms, snapshot or longitudinal layout, the ranked leads table | A general overview: composition, diversity, class shifts, ordination, differential ARGs, enriched classes, change over time where sampled |
| **v0.3** | Contigs and compartments: MEGAHIT, two ARG callers, geNomad + MOB-suite, evidence per call | Chromosome / plasmid / virus share of each ARG and drug class |
| **v0.4** | ARGs linked to organisms (contig taxonomy; MAGs if justified), long-read confirmation via `group` | Which organisms carry which ARGs |

v0.1 stays as approved: counting and normalising. The statistics come in
v0.2, built on v0.1's tables, so each piece is validated on its own.

#### 3. The design triage (v0.2), stated now so v0.1's outputs fit it

**Metadata it reads** (optional samplesheet columns):

- `condition`: the groups compared;
- `subject`: the unit sampled repeatedly (animal, patient, reactor);
- `timepoint`;
- `stratum`: for example temperature; effects are estimated within each
  stratum and then compared, never pooled away;
- `batch`.

**What it decides, and writes down with the reason for each choice:**

1. **Design**
   - Snapshot or longitudinal: repeated `subject` across `timepoint`.
   - Paired or independent.
   - Number of groups.
   - Replicates per cell.
2. **Response type**
   - Counts: negative binomial / DESeq2, with the 16S or RPM denominator as
     an offset (R_Bible Part 21 rung c).
   - Diversity indices: linear model on the index.
   - Proportions: drug-class shares.
   - Composition: PERMANOVA, with its dispersion check.
3. **Assumptions**, checked on model **residuals**, not raw data (R_Bible
   Part 02). Failing a check moves to the robust or nonparametric alternative
   (Parts 03–04, 12), and the report says so.
4. **Repeated measures:** mixed model, or GEE when the question is marginal
   (Parts 06, 21). Timepoints are never pooled (X0124 rule).
5. **Honesty checks**
   - The exact-test p-value floor: for example, 5 pairs cannot give
     p < 0.05 in a paired Wilcoxon.
   - Multiplicity correction within each question family.
   - Effect sizes with confidence intervals, alongside p-values.
   - Leave-one-out sensitivity on headline results (Part 23).

Every model writes its result table first; figures only read those tables.
Nothing is recomputed in a figure (X0124 rule).

**Validated by simulation before release** (R_Bible 12.11), with marks
committed first:

- the design triage classifies simulated designs correctly;
- under no true effect, the false-positive rate stays at the nominal level;
- known effects are recovered with stated power;
- results match the R_Bible's own worked examples.

v0.1 already writes its tables in the long format that v0.2 reads, with the
metadata columns carried through.

#### 4. v0.1 in detail (sections 1–6 of the accepted draft, with the changes)

**Steps**

1. fastp.
2. hostile (human by default).
3. RGI bwt against CARD.
4. SortMeRNA 16S counts.
5. Local R: count matrix, then raw counts, RPM, RPKM (CARD reference gene
   length) and ARG copies per 16S copy, each named, with the 16S copy-number
   bias stated in every output. The denominators are written as columns.

**Input**

- seq-triage's results: metagenomes with PASS or WARN only, plus a list of
  samples left out and why; or
- a plain samplesheet.

**CARD: kept between runs, from the official source only**

- **Downloaded once** from card.mcmaster.ca into a cache folder (default
  `~/.seq-resistome/card/`, or `--card_cache <dir>`), and reused on every
  later run.
- **Checked at use:** before each run its checksum is compared with the
  pinned one; a mismatch is reported and the cache refetched, never used
  silently. The repository never contains CARD.
- **`--card_version validated`** (default): the CARD release this pipeline
  version was validated with.
- **`--card_version latest`:** the newest CARD release, fetched and cached
  alongside the validated one. Every output and the report then state "CARD
  <version>: not validated by the pipeline authors".
- **Licence:** non-commercial research use, stated in the README. Our use
  (non-profit, MIT-licensed code that points to the official source) fits it.

**Milestones**

1. Repository.
2. Walking skeleton.
3. ARG counts and the CARD cache.
4. Denominators and normalisation.
5. seq-triage handoff.
6. Validation V1.
7. v0.1.0 release.

"Done" means the same as in the accepted draft. Milestone 3 also needs the
cache to work: a second run must use it without downloading, and a corrupted
cache must be detected and refetched.

#### 5. Who decides what (as accepted, plus ISCA timing)

**I decide and log, without asking:**

- code, tests, CI;
- versions within the two-week rule;
- test data;
- bug and CI fixes, each explained in plain language;
- merging my own PRs once CI is green and a full `-profile test` run passed;
- writing pass marks before choosing data;
- validation data chosen by a rule written down first;
- fixing and re-confirming a failed mark once, on fresh data.

**I stop and ask about:**

1. Design changes, including choosing the compendium's final name.
2. A pass mark changed after it was committed, or one still failing after one
   fix-and-reconfirm cycle.
3. Publishing beyond the repository and the v0.x.0 release tags.
4. Data or licence doubts.
5. Changes to seq-triage's existing verdicts or recommendations.
6. Money or credentials.
7. Disk or Docker problems I can't fix.

**ISCA:** nothing today. Work needing ISCA is queued, and I'll give you every
batch together on 2026-10-29. They can run concurrently.

#### 6. Validation V1 (v0.1), pre-registered before data is chosen

**Truth from complete genomes**

- Layer D isolates with complete public assemblies, e.g. KPE111
  (GCF_051620725.1) and AH21H052 (GCF_051563005.1).
- RGI on each assembly gives the true ARG list and copies per genome.
- Each assembly gives its 16S copy number.

**Test samples**

- Simulated reads from those genomes, mixed at set proportions into real
  background metagenomes.
- Each background is also run on its own, so the ARGs it already carries are
  known.

**Pass marks**

Fixed numbers are committed before any mixture is made:

- **detection:** every spiked ARG found above a stated abundance;
- **specificity:** no ARG reported that is in neither the spike nor the
  background;
- **accuracy:** copies per 16S copy within a stated factor of the truth;
- **edge cases:** zero-ARG samples; no 16S reads (reported as missing, never
  infinite); samples left out by seq-triage;
- **the CARD cache:** reused, and refetched when corrupted.

**Where it runs:** on the Mac where small enough; larger mixtures are queued
for ISCA on 2026-10-29.

#### 7. How you'll hear from me

- **At the end of each milestone:** what was built, what was checked, and the
  PR. No reply needed.
- **Only for the section 5 list:** a question, with one recommendation.
- **When you ask "status?":** where things are.

## Architecture (v0.1)

```
samplesheet (+ seq-triage results) ─► main.nf: header check (D4), which samples,
     │                                 why any are left out (D9); CARD cache (D5)
     ▼
[meta, reads] ─► CAT_FASTQ (lanes) ─► FASTP ─► HOSTILE_CLEAN (D6) ─┬─ reads left?
                                                                    │   no ──► zero ARGs, 16S missing
                                                                    ▼   yes
                         UNTAR(CARD) ─► RGI_CARDANNOTATION ─► RGI_BWT (D8)
                         SORTMERNA_INDEX ──────────────────► COUNT_16S (D7)
                                                                    ▼
   read flow (fastp + hostile JSON) + left-out list + samplesheet ─► RESISTOME_TABLES
                                                                    ▼
      arg_long.tsv, arg_{reads,rpm,rpkm,copies_per_16s}.tsv, denominators.tsv,
      samples_left_out.tsv, resistome_summary.md
```

- `[meta, reads]` tuples throughout; per-sample numbers travel as a keyed
  join on `meta.id` with `failOnMismatch`, so a sample cannot silently drop
  out of a join.
- A sample with no reads after QC or host removal is routed around RGI and
  SortMeRNA (they fail on empty input) and still gets a row in every table.
- One RESISTOME_TABLES task sees every sample, so it can check the
  bookkeeping: every analysed sample has its RGI and 16S outputs, nothing
  else does, and SortMeRNA saw exactly the reads the read flow says.
- Resource labels and retry policy are seq-triage's (its D17).

## Decisions log

| # | Decision | Why |
|---|----------|-----|
| D1 | **The plan above is the specification** (2026-10-28). | User: it becomes the first entry of this file. |
| D2 | **Set up like seq-triage.** Same layout (main.nf for input, `workflows/seq_resistome.nf` for logic, `modules/local`, `conf/`, `bin/`), same launch environment pins (OpenJDK 17.0.18, Nextflow 26.10.2, nf-core tools 4.1.0, nf-test 0.9.5; seq-triage's three lockfiles, renamed), same nf-schema 2.8.0, same resource labels, same pinned R image (rocker/r-ver 4.5.2 by digest; base R only, so `-profile conda` needs only r-base). nf-core modules are pinned to **nf-core/modules commit `7f44b7c` (2026-10-13)**, the last before 2026-10-14: the two-week rule applied to module code as well as tool versions (the newest commit was a day old). Tools: fastp 1.3.6, hostile 2.0.2, RGI 6.0.8 with kma 1.6.11, SortMeRNA 4.3.7 (all released 2025-01 to 2026-07). `.nf-core.yml` switches off the nf-core-organisation lint checks, each with its reason, as in seq-triage. | One way of working across the user's pipelines; every choice already defended there. |
| D3 | **Repository guard, merging.** `.githooks/check_repo.sh` (seq-triage D52) refuses sequencing data by extension and content, files over 1 MB, HPC account patterns and the user's private strings (git-ignored `private_patterns.txt`), a non-noreply author email (files under `validation/V*/outcomes*/`, published validation tables, may be up to 10 MB, as in seq-triage), and now **CARD files** by name (`card.json`, CARD's FASTA and index tables, `broadstreet-*` archives). CI runs it over every tracked file. Merging: only after CI is green, a full `-profile test` run has passed, and the final diff is reviewed; `.githooks/merge_when_green.sh <PR>` waits for the checks; **auto-merge is never enabled**. Branch protection on `main` requires the CI checks. | CARD's licence: non-commercial research use, never redistributed. User rules (seq-triage D10, D52; no auto-merge). |
| D4 | **Samplesheet and study metadata.** Columns `sample, fastq_1, fastq_2`; every other column is study metadata, carried through to `arg_long.tsv` and `denominators.tsv` untouched and **never interpreted in v0.1** (v0.1 models nothing; v0.2's design triage will read it only through seq-triage's column guide, seq-triage D95, merged into seq-triage's main on 2026-10-28 as PR #62, after v0.1's input code was written; v0.2 reuses it). seq-triage's own columns (`bam`, `platform`, `sample_type` ...) are recognised, so seq-triage's samplesheet works unchanged. From seq-triage D95: a header that looks like a pipeline column (same letters ignoring case and punctuation, one keystroke away, or a synonym such as R1, read1) **stops the run** naming it; nothing is assumed. Several rows with one sample name are lanes, concatenated (nf-core CAT_FASTQ); if their study metadata disagree, or a metadata column has the name of an output column, the run stops. Sample names: letters, digits, `.`, `_`, `-`. | A typo read as metadata would silently turn paired reads single-end; a renamed user column would mislead every later analysis. |
| D5 | **CARD cache** (`utils/card_cache.nf`; moved from `subworkflows/local/` by CI fix 2). Runs inside Nextflow before any task, so the download happens once on the launching machine (an HPC login node has internet; compute nodes may not). Archive `broadstreet-v<version>.tar.bz2` in `--card_cache` (default `~/.seq-resistome/card`). **Every run checks its SHA-256**: against `assets/card_versions.csv` for the validated release, or against the checksum recorded at first download for any other. A mismatch is warned about and the archive fetched again; a fresh download that fails the pinned checksum stops the run. Downloads go to a temporary name and are renamed into place, so an interrupted or concurrent run never leaves a half-written archive. `--card_version validated` (default) = **CARD 4.0.2** (released 2026-08-11, the newest on 2026-10-28; SHA-256 `94b8...c065`, identical to CARD's `latest/data` that day); `latest` = the newest release named on CARD's download page, cached alongside, and every table and the summary then say "CARD <version>: not validated by the pipeline authors". The extracted database is never cached (4 MB archive, seconds to unpack). **Licence** (read in CARD-Download-README.txt, 2026-10-28): free for non-commercial research; any use by a commercial organisation needs McMaster's written permission. Our use (MIT code that downloads from the official source) fits; the README says so. | Plan section 4. Checked by `tests/card_cache/test_card_cache.sh` (14 checks, offline: CARD's site replaced by local files) and by the e2e run (second run must log "reused from the cache"). |
| D6 | **Host removal: hostile 2.0.2.** Default `--host_index human-t2t-hla`, fetched once (bowtie2 index only) by our HOST_FETCH into `--host_cache` (default `~/.seq-resistome/hostile/<index>`) via Nextflow `storeDir`, so later runs skip the fetch. **Found by the first run with the default human index (V1 timing test, 2026-10-28):** nf-core's HOSTILE_FETCH cannot be cached this way, because Nextflow allows `storeDir` only on plain file outputs and that module also reports its version through an `eval` output; the run stopped before any work. HOST_FETCH is the same command without that output (hostile's version is still recorded by HOSTILE_CLEAN). The test profile cannot cover this path (it would fetch 4 GB in CI); V1 runs it. `--host_fasta` for any other host (bowtie2 index built by HOST_INDEX in hostile's own image); `--skip_host_removal` for samples with no host. **Always `--aligner bowtie2`**: found while building, hostile treats single-end input as long reads (minimap2) unless told otherwise, and then cannot use a bowtie2 index. | Plan section 4 (human by default). hostile's T2T+HLA index removes human reads with very few bacterial false positives (hostile's own benchmark). |
| D7 | **16S denominator.** SortMeRNA 4.3.7 against SILVA 16S as shipped in SortMeRNA's repository at tag v4.3.7 (`silva-bac-16s-id90.fasta`, `silva-arc-16s-id95.fasta`; 12,798 + 3,193 sequences), indexed once per run. Our own COUNT_16S, not nf-core's SORTMERNA: that module always passes `--paired_in` for paired reads, which counts both mates when only one matches 16S and inflates the denominator. Here each read is judged alone (as RGI counts ARG reads) and counted from the SAM output (`--num_alignments 1`); the SAM is deleted. **Copies:** ARG copies = reads x mean read length / CARD reference length; 16S copies = 16S aligned bases / 1,542 bp (E. coli rrsB; until D13 it was 16S reads x mean read length / 1,542, which overestimated 1.25-1.34x); copies per 16S copy = their ratio. **Every table states** that bacteria carry 1 to ~15 16S copies, so this is not ARGs per cell. A sample with no 16S reads gets NA (with a note), never 0 or infinity. | Plan section 4. Standard ARGs-OAP-style normalisation; the read-length term cancels, but both copy numbers are written so each denominator can be checked. |
| D8 | **ARG counting and the detection call.** RGI 6.0.8 `bwt` with kma (named explicitly), CARD **protein homolog models only** (RGI's default): genes whose presence alone confers resistance. Variant models (resistance by point mutation, e.g. gyrA) cannot be called from reads mapped this way and are not reported. Measures per gene: reads (each mate counted), RPM (per million reads analysed after QC and host removal), RPKM (per kb of CARD reference), copies per 16S copy. **Detected** = at least `--min_arg_reads` 2 reads **and** coverage at least `--min_breadth_ratio` 0.5 of the breadth the same reads would cover landing at random (100(1 - e^(-reads x read length / gene length))). Reads piled on one domain a gene shares with a non-resistance gene cover far less: in the test data, 4 E. coli reads on rmtH covered 7% where random reads would cover 48% (ratio 0.14), and are rightly not called; genuine genes sit near 1. Every hit stays in `arg_long.tsv` with its call and the reason; the gene x sample matrices hold detected genes only. Both numbers were set on the test data (development data), before validation; V1 tests them. | A threshold on coverage alone would miss real genes at low depth; one on reads alone would keep shared-domain hits. |
| D9 | **seq-triage handoff** (milestone 5). `--triage_results <seq-triage outdir>` with `--input` = the samplesheet seq-triage was run with (seq-triage's summary has no file paths). Analysed: verdict PASS or WARN, detected type metagenome, platform Illumina, DNBSEQ or Element, given as FASTQ. Everything else goes to `samples_left_out.tsv` with the reason, quoting seq-triage's verdict reason or type reason (also printed as a warning). The two must list the same samples, or the run stops naming the difference. seq-triage itself is not changed. | Plan section 4 (input). |
| D10 | **Test profile and CI.** Four public samples (nf-core test-datasets, pinned by commit), each testing one path: `minigut` (B. fragilis + E. coli K-12: ARGs, 16S, the rmtH shared-domain hit not called), `mock_community` (eight genomes, mostly A. baumannii, though nf-core's folder says B. fragilis: the read names say so; 61 detected calls across the samples), `host_only` (human mitochondrial reads: all removed, zero ARGs, 16S missing), `virus_only` (SARS-CoV-2: reads left, no ARGs, no 16S). Host removal in the test uses the human mitochondrial genome as the host (`--host_fasta`), so CI does not fetch hostile's 4 GB index. `tests/e2e/check_test_profile.R` checks: every sample present with its expected status and genes; copies per 16S copy never infinite and NA exactly where there is no 16S; RPM, RPKM and copies recomputed from their definitions; metadata carried; CARD release and 16S caveat in every table header; no reads published; every tool version recorded. CI runs it on a plain run and on the seq-triage handoff (four more samples left out, each reason checked), plus the CARD cache tests, the samplesheet tests (15 bad and good sheets, `-preview`), R unit tests (25 checks on hand-worked inputs), nf-core lint, `--help`, a lockfile rebuild, and the same e2e under conda. Whole test profile: about 3 minutes on the Mac. | Walking skeleton first; nothing reaches main untested (seq-triage D28). Writing the unit tests found a real bug: with no ARG hit in any sample the tables step crashed (fixed before the first commit). |
| D11 | **Validation V1 pre-registered** (`validation/V1/PREREGISTRATION.md`, committed 2026-10-28 20:29 before any data was chosen). Data rules applied afterwards: spike genomes = first four layer D isolates with a RefSeq Complete Genome: **KPE111** (K. pneumoniae, GCF_051620725.1), **CPO025** (E. hormaechei, GCF_051560505.1), **ECE228** (E. coli, GCF_051618705.1), **ALF22C020** (K. pneumoniae, GCF_051560495.1); reserves AH21H052, KPE040, CPO413 (`validation/V1/spike_genomes.tsv`; ECE170 has a GenBank assembly only). Backgrounds by the seeded ENA draw: **human gut SRR26745743** (PRJNA1030952), **wastewater DRR804577** (PRJDB38115). One correction before any download: the first version of `select_backgrounds.R` also required exactly two FASTQ files per run, a filter the pre-registration does not have; it was removed and the draw re-run, so the draw follows the rule as written (the superseded draw had picked SRR27322254 and DRR804571; no reads of either were fetched). | Marks fixed before data, as the plan requires. |
| D12 | **Validation V1, round 1: FAILED as pre-registered** (run 2026-10-28/29 on the Mac; tables in `validation/V1/outcomes/`). Mark 1 detection **FAIL** (526 of 544 truth genes at 2x/8x; misses: marA, vanG, FosA6 at 2x); mark 2 specificity **FAIL** (23 "unexplained" families in 31 samples); mark 3 accuracy **FAIL** (pure genomes 54 of 79 families within 1.5x; 8x mixtures 66 of 87 within 2x); mark 4 edge cases E1-E3 **PASS**, E4 **PASS** (a real seq-triage run, commit fbf74dd, Standard-8 Kraken2: it passed none of the three samples, and all three were left out with its reasons and appear in no table; the path where seq-triage passes a sample is covered only by the CI fixtures, because seq-triage FAILs the gut mixture on 'off target fraction 67.3%', a limit that may not suit a metagenome with no declared target: a question for seq-triage, not changed here, D1 section 5 item 5; a first E4 run without a declared platform passed none for that reason, and the 10 GB Kraken2 request needed `validation/V1/e4.config`); mark 5 CARD cache **PASS** (second run downloaded nothing; appended bytes detected, archive fetched again, pinned checksum restored). **Diagnosis** (pure KPE111 gene by gene, then all four genomes): (1) **24 of 136 truth genes (18%) receive no read at all**: RGI `main` calls them from *protein* similarity (marA, vanG, rsmA, Shigella acrA in Klebsiella/Enterobacter), but their DNA is too far from CARD's reference for any read mapper; the pre-registered truth includes genes read mapping cannot see. (2) **The family test was stricter than its intent:** `score_V1.R` compared CARD's AMR Gene Family label as exact text, but close relatives carry differently worded labels (AAC(6')-Ib7 "AAC(6')" vs AAC(6')-Ib-cr5 "AAC(6'); AAC(6')-Ib-cr"; TolC; OmpK37), so allele-level spill-over was scored as unexplained or missed, and 16 accuracy rows had observed 0. (3) **A real pipeline bias: 16S copies overestimated 1.25-1.34x** on every pure genome. Cause found: 27% of SortMeRNA's 16S reads align over only part of their length (gene ends, short local hits) yet counted as full 150 bp reads. Counting aligned bases instead gives 1.09x on KPE111. For the genes reads can find, accuracy is otherwise close: exact-gene median 0.81 of truth (IQR 0.72-0.94), 1.04 once the 16S bias is removed. **Decision needed from the user** (D1 section 5, item 2: marks 1 and 2 cannot pass without changing how the committed marks define truth and gene family): see Status. | Negative results are reported as they are. |
| D13 | **V1 round 2 re-registered** (user, 2026-10-29: option A; `validation/V1/PREREGISTRATION_round2.md`, committed before any round-2 data was fetched, simulated or looked at). Truth = RGI `main` Perfect/Strict homolog hits **findable by reads** (predicted gene DNA has a BLASTN hit >= 80% identity over >= 80% of its length to a CARD 4.0.2 homolog reference); the others are **protein-only hits**, listed in full with their count in the outputs and here, never scored. Same family = at least one CARD family term in common. Mark numbers unchanged. One fix cycle: **16S counted by aligned bases** (D7 changes). Fresh data: reserve genomes AH21H052, KPE040, CPO413; backup backgrounds gut SRR28158871, wastewater SRR11809751; ART seed 20261029; HG002's next 200,000 pairs. Disclosed: the reserves' assemblies and their RGI/barrnap outputs were made on 2026-10-28 (one summary line each seen) and moved aside unread; truth is recomputed. Any round-2 mark failing: stop and ask. | User's conditions with option A. |
| D14 | **Two resource fixes found while running V1 on the laptop; neither changes any result.** (1) RGI_BWT leaves its read alignments (SAM/BAM, about 1 GB per 2-million-read sample, not outputs) in the work folder; with 33 samples they filled the disk twice (2026-10-29, Docker Desktop wedged and had to be force-restarted), so `afterScript` now deletes them when the task ends. (2) Nextflow's local executor schedules by *requested* memory; tasks asking 8 GB but using under 1 GB (SORTMERNA_INDEX, RGI_CARDANNOTATION) were never scheduled while smaller tasks kept the memory busy, holding up every 16S or RGI task. Sized in `validation/V1/local.config`; a pipeline-wide fix (smaller labels for these one-off tasks) is a follow-up. Also learnt: `-resume` resumes the last run launched in a folder, so V1's CARD-cache test now runs from its own folder (it once made a resume redo every task). **Regression check of the 16S fix** (round-1 samples, scored by the round-2 rules; development results, not validation; `validation/V1/outcomes_round1_samples_fixed/`): 16S estimates 1.07-1.15x of truth (were 1.25-1.34x); edge cases E1-E3 still pass; marks 1-3 would still fail on these samples (2 misses: FosA6 at 2x; 3 unexplained families; 57 of 73 pure-genome families within 1.5x, ratios up to 5.8x). 17 protein-only hits excluded across the four genomes, listed in full in `protein_only_hits.tsv`. | Disk and scheduling problems fixed in place; results reported as they are. |
| D15 | **V1 round 2 (fresh data, after the 16S fix): FAILED as re-registered; stopped for the user** (2026-10-29; `validation/V1/outcomes_round2/`). Mark 1 detection **FAIL** (348 of 352; all 4 misses are CMY-181 in AH21H052); mark 2 specificity **FAIL** (9 unexplained families in 24 samples); mark 3 accuracy **FAIL** (pure genomes 37 of 51 units within 1.5x; 8x mixtures 33 of 38 within 2x); mark 4 edge cases E1-E4 **PASS**; mark 5 CARD cache **PASS**. 16S estimates 1.13-1.15x of truth (round 1: 1.25-1.34x). **Protein-only hits excluded, 15** (listed in full in `protein_only_hits.tsv`): AH21H052 vanG, KpnF, KpnE, ArnT, rsmA; CPO413 KpnF, KpnE, vanG, leuO, ArnT, rsmA; KPE040 leuO, qacG, rsmA, vanG. (Round-1 genomes, development: 17.) **Diagnosis:** (1) Most failures are still CARD labels, not counts. AH21H052's chromosomal ampC is labelled CMY-181 by RGI `main` (76% protein identity, Strict) while reads map, correctly, to EC-5 (E. coli's own ampC, 98.7% covered): one gene gives the 4 "misses", 4 "unexplained" EC families and an accuracy 0. Aminoglycoside bifunctional proteins (AAC(3)-Ib/AAC(6')-Ib3) carry a family label sharing no term with AAC(6'). Efflux pumps and porins carry overlapping multi-term labels, and assigning each detected gene to one label splits one true total between neighbours: E. coli 20.7x on one label and 0 on its neighbours (round-1 genomes: summed over the three labels, observed 2.49 vs truth 2.43). (2) **Genuine pipeline weaknesses:** a 2-read call on a long housekeeping homolog (Bifidobacterium rpoB, 2 reads covering 5% of 3.5 kb) passes the detection rule; ABC transporters are undercounted (0.37-0.47x); CAT and porins overcounted (1.6-2.3x). No further fix was made (the user's condition: one fix cycle). | Negative results reported as they are; the next step is the user's. |
| D16 | **V1 round 3 re-registered, scored by location** (user, 2026-10-29: "Round 3 by location"; `validation/V1/PREREGISTRATION_round3.md`, committed before any round-3 data was chosen, fetched or looked at). A detected gene is matched to a truth gene by where its CARD reference DNA lies in the assembly (>= 80% identity overlapping >= 50% of the locus), not by CARD's label wording; loci linked by a shared gene are scored as one group, so one true total is never split between neighbours. Specificity: a detected gene is explained if its reference is present in the spike genome (>= 80% over >= 50% of the reference) or it is detected in the background alone. Pipeline unchanged; its weak spots are written into the README's limitations first. Fresh data: three RefSeq complete genomes of PRJNA1287288 outside layer D (seeded draw, `set.seed(20261030)`), backgrounds' backup 2 (gut SRR26421003, wastewater SRR31394446), ART seed 20261030, HG002 pairs 400,001-600,000. Mark numbers unchanged. Any mark failing: stop and ask. | The round-1/2 failures were mostly CARD label disagreements; location tests what reads actually measure. |
| D17 | **V1 round 3 (by location, fresh E. coli genomes AH21C062, ECE218, ECAMP047; backgrounds SRR26421003, SRR31394446): marks 1-3 FAIL narrowly, 4-5 PASS; stopped for the user** (2026-10-29; `validation/V1/outcomes_round3/`). Mark 1: 543 of 544 truth loci (miss: EC-5 at 2x in wastewater). Mark 2: 22 unexplained of 2,337 detected genes (0.9%): LptD (17), MdtK (3), eptB (2), all in E. coli mixtures; E. coli's own copies of these genes are only partly similar to CARD's references (none present at >= 80% over >= 50% of the reference), and reads covering 8-59% of the reference pass the detection rule. Mark 3: pure genomes 132 of 136 groups within 1.5x (outside: H-NS 1.61, QnrS1 1.51, CMY-181 0.66, mdtE 0.54); 8x mixtures 222 of 222 within 2x. Mark 4 (E1-E4) and mark 5 PASS. 16S 1.05-1.10x of truth. 15 protein-only hits excluded, listed in full (KpnE, KpnF, vanG, rsmA, ArnT in each genome; `protein_only_hits.tsv`). **No threshold fixes mark 2**: the unexplained calls' breadth ratios (0.55-1.16) overlap the genuine calls' (5% below 0.58); a 0.8 cut would keep 11 of the 22 and lose 491 genuine calls. Development rescoring of round 1 by location (not validation): detection 486/500, 27 unexplained, accuracy 101/118 pure and 182/195 mixtures. | The pass marks are applied as written; the next step is the user's. |
| D18 | **v0.1 recorded as unvalidated; no v0.1.0 tag** (user, 2026-10-29: "Record unvalidated"). V1 failed marks 1-3 in all three pre-registered rounds (D12, D15, D17), and the user's rule stands: a failed mark blocks a release. The counts are kept usable and the weakness documented: the README shows every round's result, and its limitations name the partial-homolog calls (E. coli LptD, MdtK, eptB), the protein-only genes reads cannot see, and the per-family biases. Work moves to v0.2, which builds on v0.1's tables; a later validation (a V2 with a different design, e.g. a caller that reports read identity) can still earn a tag. | User's choice of option B; the failed-mark rule is kept intact. |

## Status

**2026-10-29 (evening).** v0.1 is built (milestones 1-5) and **recorded as
unvalidated, no tag** (D18): V1 failed marks 1-3 in three pre-registered
rounds (D12, D15, D17); edge cases and the CARD cache always passed. All
work is local on branch `v0.1-build`.

**Next:**
1. The user creates the empty public repository `MacaulayWinter/seq-resistome`
   on GitHub (Claude Code's permission check refuses `gh repo create`).
   Then: push, protect `main`, PRs (milestones 1-5, then V1 records), CI,
   merge when green after review. No tag.
2. v0.2, the compendium, on the compendium engine (its design approved
   2026-10-29); its final name is still the user's choice.
3. Follow-ups: smaller resource labels for one-off tasks (SORTMERNA_INDEX,
   RGI_CARDANNOTATION; D14); a pipeline-level way to flag partial-homolog
   calls (D17), tested by a future V2.

## Open questions

- The compendium's final name (D1 section 1; placeholder "compendium").

## Environment (recorded 2026-10-28)

- Mac: Apple M1 Pro (arm64), macOS 26; Docker Desktop 29.9.1 (11.7 GB
  memory, 8 CPUs); about 47 GB disk free at the start.
- Launch environment: seq-triage's `seq-triage-dev` env (identical pins to
  `environment.yml` here).

**How to run things (notes for future sessions):**
- Claude's shell: `PATH=~/.conda/envs/seq-triage-dev/bin:$PATH JAVA_HOME=~/.conda/envs/seq-triage-dev/lib/jvm nextflow ...`
- Test profile on the Mac: `nextflow run main.nf -profile test,docker,arm64 -work-dir ~/seqresistome-scratch/work --outdir ~/seqresistome-scratch/<name>`.
- R tests: `docker run --rm -v "$PWD":/w -w /w <R_IMAGE> Rscript tests/resistome_tables/test_resistome_tables.R`.
- Bulky files (work dirs, validation reads) go in `~/seqresistome-scratch/`,
  never in `~/Documents` (synced to iCloud) or the repository.
- `nf-core pipelines lint` cannot reach schemastore.org from Python in
  Claude's sandbox (curl can); lint runs in CI.

## CI fix log

Every CI fix is recorded here in plain language: what failed, why, what
changed, how it was verified. Fixes are never applied silently.

**1. 2026-10-29, PR #1, job "End-to-end, conda".**
- *What failed:* SortMeRNA crashed while building its 16S index:
  `Illegal instruction (core dumped)`, exit status 132.
- *Why:* the conda recipe asked only for `sortmerna=4.3.7`, so conda picked
  the newest rebuild of that version. That rebuild was compiled for
  processor features the GitHub runner's CPU does not have. The Docker
  image of the same version works because it holds an older build of it
  (conda-forge `py313h71a826f_1`, read from the image's own records).
- *What changed:* SORTMERNA_INDEX's and COUNT_16S's conda recipes now pin
  that build (`sortmerna=4.3.7=py313*_1` with `python=3.13`), so conda and
  Docker run the same program. Written as a pattern rather than the full
  build name, so other platforms can still find their own copy of build 1.
- *How verified:* a dry-run solve for Linux picks exactly
  `sortmerna-4.3.7-py313h71a826f_1`; the conda end-to-end job re-runs on
  this push.

**2. 2026-10-29, PR #1, job "Lockfile rebuild (linux-64), lint, --help".**
- *What failed:* `nf-core pipelines lint` crashed (`IndexError: list index
  out of range`) before reporting anything.
- *Why:* the CARD-cache code was in `subworkflows/local/card_cache.nf`.
  nf-core's linter treats every file there as a subworkflow and reads the
  name from its `workflow` line; that file holds only functions (it runs
  before any task, D5), so there was no such line to read.
- *What changed:* the file moved to `utils/card_cache.nf`, which the linter
  does not inspect; `main.nf` and the cache test include it from there. No
  code inside it changed.
- *How verified:* the CARD cache tests (14) and the test profile pass
  locally after the move; the lint job re-runs on this push (it cannot run
  on the Mac, D2). Any lint findings it then reports get their own entry.

**3. 2026-10-29, PR #1, job "End-to-end (-profile test), CARD cache, input
checks"** (first run, commit e81d97f).
- *What failed:* the samplesheet tests: the three sheets that should be
  accepted (study metadata columns, seq-triage's own columns, a UTF-8
  byte-order mark) did exit cleanly, yet were reported as failures.
- *Why:* the test looked for the word "SUCCESS" in Nextflow's console
  output. In quiet mode (`-q`) Nextflow prints that line on the Mac but not
  on GitHub's runner, so the test was checking a display detail, not the
  pipeline.
- *What changed:* `tests/input/test_input.sh` now also reads the run's log
  file and, for a sheet that should pass, looks for the pipeline's own
  "CARD 4.0.2 (" line, written only after every input check has passed.
- *How verified:* 15 of 15 locally; the job re-runs on this push. The
  end-to-end runs themselves (plain and seq-triage handoff) had passed in
  the failing job.
