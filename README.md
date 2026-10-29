# seq-resistome

Antibiotic resistance genes (ARGs) in shotgun metagenomes: reads are
cleaned, host reads removed, and reads from ARGs counted against
[CARD](https://card.mcmaster.ca); each gene is then reported four ways (raw
reads, RPM, RPKM, copies per 16S rRNA gene copy) with every denominator
shown.

**Status:** v0.1 under construction. Validation V1 has run three
pre-registered rounds and **not passed** (see Validation below). The plan and every decision are in
[CLAUDE.md](CLAUDE.md).

It is the first domain pipeline after
[seq-triage](https://github.com/MacaulayWinter/seq-triage), and can take
seq-triage's results directly: only the samples seq-triage passed as
short-read metagenomes are analysed.

## Quick start

```bash
conda env create -f environment.yml && conda activate seq-resistome-dev
nextflow run MacaulayWinter/seq-resistome -profile test,docker --outdir results
```

Then open `results/resistome_summary.md`. On Apple Silicon use
`-profile test,docker,arm64`.

The first run downloads CARD (4 MB) into `~/.seq-resistome/card/`; with the
default human host removal it also downloads hostile's human index (about
4 GB) into `~/.seq-resistome/hostile/`. Both are reused by every later run.

## Usage

```bash
nextflow run MacaulayWinter/seq-resistome -profile docker \
    --input samplesheet.csv --outdir results
```

**Samplesheet** (CSV): `sample, fastq_1, fastq_2` (leave `fastq_2` empty for
single-end reads), then any columns of your own. Your columns (site, day,
treatment ...) are study metadata: carried through to the tables untouched,
never interpreted by v0.1. Several rows with the same sample name are one
sample in several files (lanes), joined in order.

```csv
sample,fastq_1,fastq_2,site,day
S1,S1_R1.fastq.gz,S1_R2.fastq.gz,river,1
S2,S2_R1.fastq.gz,S2_R2.fastq.gz,river,7
```

The pipeline stops, naming the problem, rather than guess: a column header
that looks like a pipeline column (`fastq2`, `R1`, `Sample`), a sample name
with spaces, lanes of one sample whose metadata disagree, or a metadata
column named like an output column.

**From seq-triage:** give seq-triage's results folder and the samplesheet
seq-triage was run with:

```bash
nextflow run MacaulayWinter/seq-resistome -profile docker \
    --input samplesheet.csv --triage_results seq_triage_results/ --outdir results
```

Samples seq-triage did not pass (verdict FAIL or UNCERTAIN), that are not
metagenomes, or are not short reads given as FASTQ are listed in
`samples_left_out.tsv` with the reason.

| Parameter | Default | What it does |
|---|---|---|
| `--card_version` | `validated` | `validated`: CARD 4.0.2, the release this version was validated with. `latest`: the newest CARD release; every output then says it is not validated by the pipeline authors |
| `--card_cache` | `~/.seq-resistome/card` | Where CARD is kept between runs |
| `--host_index` | `human-t2t-hla` | hostile's human index (T2T-CHM13 plus HLA alleles) |
| `--host_fasta` | | Your own host genome instead (FASTA) |
| `--skip_host_removal` | `false` | For samples with no host (water, soil) |
| `--min_arg_reads`, `--min_breadth_ratio` | `2`, `0.5` | When a gene counts as detected (below) |

`nextflow run MacaulayWinter/seq-resistome --help` lists every parameter.

## Outputs

| File (in `--outdir`) | What it is |
|---|---|
| `resistome_summary.md` | **Start here.** Per sample: reads analysed, host share, 16S reads, ARGs detected; samples left out and why; how to read the numbers |
| `arg_long.tsv` | One row per sample and CARD gene with any mapped read: every measure, the detection call with its reason, the denominators and your metadata (the table later versions build on) |
| `arg_reads.tsv`, `arg_rpm.tsv`, `arg_rpkm.tsv`, `arg_copies_per_16s.tsv` | Gene x sample matrices of detected genes (a sample with none is a column of zeros) |
| `denominators.tsv` | Per sample: raw reads, reads after QC, host reads removed, reads analysed, mean read length, 16S reads, 16S bases and 16S copies |
| `samples_left_out.tsv` | Samples not analysed, and why |
| `fastp/`, `host_removal/`, `rgi/`, `16s/` | Each tool's own reports (no reads are ever published) |
| `pipeline_info/` | Tool versions actually used (including the CARD release), run timeline and resource report |

Every table starts with two `#` lines naming the CARD release and the 16S
caveat below (`read.delim(..., comment.char = "#")` in R, `comment="#"` in
pandas).

## How the numbers are made

1. **fastp** trims adapters and low-quality bases (its defaults).
2. **hostile** removes host reads (human by default).
3. **RGI bwt** (with kma) maps reads to CARD's *protein homolog models*:
   genes whose presence alone confers resistance. Resistance by point
   mutation (e.g. in *gyrA*) cannot be called from reads this way and is not
   reported.
4. **SortMeRNA** counts reads from 16S rRNA genes (SILVA bacteria and
   archaea).
5. The tables:
   - **reads**: reads mapped to the gene (each mate of a pair counts once);
   - **RPM**: reads per million reads analysed (after QC and host removal);
   - **RPKM**: reads per kilobase of the CARD reference gene per million
     reads analysed;
   - **copies per 16S copy**: (gene reads x read length / gene length) /
     (16S bases covered by reads / 1,542 bp). Bacteria carry 1 to about 15
     copies of the 16S gene, so this is **not ARGs per cell or per genome**,
     and communities whose members carry more 16S copies look poorer in ARGs.
     A sample with no 16S reads gets NA, never zero or infinity.
   - **detected**: at least 2 reads, spread along the gene at least half as
     widely as reads landing at random would be. Reads piled on one stretch a
     gene shares with an unrelated gene do not count. Every hit is kept in
     `arg_long.tsv` with the reason it was or was not called.

## Validation

V1 tests detection, specificity and accuracy of copies per 16S copy on reads
simulated from complete *E. coli*, *Klebsiella* and *Enterobacter* genomes
mixed into real human gut and wastewater metagenomes, plus edge cases and the
CARD cache. Every round's marks were committed before its data was chosen
([round 1](validation/V1/PREREGISTRATION.md),
[round 2](validation/V1/PREREGISTRATION_round2.md),
[round 3](validation/V1/PREREGISTRATION_round3.md)). **V1 has not passed.**

| Round | Detection (100% needed) | Specificity (0 unexplained) | Accuracy (all within 1.5x / 2x) | Edge cases | CARD cache |
|---|---|---|---|---|---|
| 1 | FAIL 526/544 | FAIL 23 families | FAIL 120/166 | PASS | PASS |
| 2 (16S fix) | FAIL 348/352 | FAIL 9 families | FAIL 70/89 | PASS | PASS |
| 3 (scored by location) | FAIL 543/544 | FAIL 22 of 2,337 genes | FAIL 354/358 | PASS | PASS |

Rounds 1 and 2 failed mostly because CARD names one gene in different ways
(CLAUDE.md D12, D15). Round 3's misses are real: reads from a bacterium's
own genes that only partly resemble a CARD gene (*E. coli* LptD, MdtK,
eptB) are called detected (D17).

## Known limitations (v0.1)

- Short reads only (Illumina, DNBSEQ, Element), as FASTQ.
- Counts are of reads, not organisms: which organisms carry the genes, and
  whether on plasmids, chromosomes or phages, is for later versions (roadmap
  in [CLAUDE.md](CLAUDE.md), D1 section 2).
- Close alleles (TEM-1 vs TEM-116) cannot be told apart reliably from reads;
  judge at the level of CARD's AMR gene family.
- Found in validation (V1 rounds 1 and 2, CLAUDE.md D12, D15), stated before
  round 3: a gene can be called from 2 reads on a long CARD reference that
  only resembles a resistance gene (for example *E. coli* reads on a
  *Bifidobacterium* rpoB); ABC transporter genes are undercounted (about
  0.4x); chloramphenicol acetyltransferases and porins are overcounted (up
  to about 2x). About 1 in 8 genes RGI finds by protein similarity has DNA
  too far from CARD's reference for any read to map (vanG, rsmA, leuO in
  Enterobacterales, for example): read-based counting cannot see them.
- No statistics yet: v0.1 counts and normalises. Comparisons between groups
  and times come in v0.2.

## Licences

The pipeline code is MIT-licensed. **CARD is not part of this repository**:
it is downloaded from card.mcmaster.ca on your machine. CARD is free for
non-commercial research use; use by a commercial organisation, even for
research, needs written permission from McMaster University
([CARD terms](https://card.mcmaster.ca/about)). The 16S references are
SILVA-derived databases distributed with SortMeRNA.

## Reproducibility

Every tool runs in a container (or conda environment) pinned to an exact
version; the launch environment is pinned in `environment.yml` with exact
lockfiles in `envs/`; nf-core modules are pinned by commit in
`modules.json`; CARD is pinned by version and checksum in
`assets/card_versions.csv`. `pipeline_info/software_versions.tsv` records
what actually ran.

## How this was built

With Claude Code (an AI coding assistant), working from a plan the author
agreed in advance. [CLAUDE.md](CLAUDE.md) is the public log: every decision,
its reason, and every CI fix.

## Citations

See [CITATIONS.md](CITATIONS.md).
