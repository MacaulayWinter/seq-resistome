# Validation V4: pre-registration (protein mode, identity band; V3 repeated after a defect)

**IN FORCE from the commit that contains this sentence (2026-11-15).**
Written 2026-11-15, before any V4 genome was listed, fetched or simulated.
The user decided on 2026-11-15 (relayed by the coordinator session: "go with your
recommendation", option B, a fresh draw).

## 0. Why V4 exists, said plainly

V4 follows a **defect-affected V3**. V3 (`validation/V3/RESULT_2026-11-15.md`, pipeline
commit 93eb4e8) did not test the pre-registered pipeline: the module `resistome_tables`
declared its inputs `core_min_reads, probable_gene_identity` while the workflow passed
`probable_gene_identity, core_min_reads`. The script therefore received probable-homolog
identity 4 (the class never fired) and a core minimum of 0.85 reads (the minimum stayed at 2).
V3 tested the V2 rule plus the loose-ortholog explanation. Its marks: 1, 3, 4, 5 and E4 passed;
**mark 2 failed, 9 unexplained**. V3's failure stays recorded and V3 is not re-scored or rescued.
V3's result is not valid evidence for Amendment 1 of V3, for or against.

Mark 1 and 3 passes in V3 are not evidence about V4 either. V4 is a new validation, on a fresh
draw, of the same rule and marks. Seeing V3's data, the draw is made fresh so that V3's data
cannot tune V4: species, spikes, backgrounds, E3 slice and seed all differ from V3's.

If any mark fails, V4 fails, and Claude stops and asks the user. Rule 1: no tag or
v0.1.0 unless every pre-registered mark passes.

## 1. Rule and marks: V3's, unchanged

V3's `PREREGISTRATION.md` as amended (Amendment 1) is the rule and the marks of V4, unchanged
in every threshold and definition, and is incorporated here by reference at its commit
(the file as of commit 1d9a1fd and the file `validation/V3/PREREGISTRATION.md` in this tree, which are the same):
sections 0 (what protein mode claims: `detected` and `probable_homolog`), 1 (pipeline settings:
rule "or", 0.70 read identity, 0.90 gene identity, `--min_protein_core_reads 4`, core cut 0.95, breadth ratio 0.8,
allele identity 0.95, `--min_16s_identity 0.90`, `--min_arg_reads 2`, `--min_breadth_ratio 0.5`,
`--min_protein_probable_gene_identity 0.85`) and 2 (marks 1 to 5, E4, band scoring at truth identity 0.92,
mark 2 with RGI Loose orthologs, mark 3 only for groups mark 1 marks, reported-not-marked items).
Nothing is added to the marks and nothing is removed.

The one change to the pipeline since 93eb4e8 is the argument order (module inputs now match the
workflow call), with a test that reads the settings back from the pipeline's own output
(`tests/e2e/check_test_profile.R`: the summary must show core minimum reads 4 and probable identity
85%; negative-controlled against V3's output, which it fails). Addendum A names the commit.

## 2. Fresh data, by rules written now (frozen)

- **Spike genomes: four species, none used in V1 (E. coli, Klebsiella, Enterobacter), V2 (Citrobacter,
  Pseudomonas, Acinetobacter, Enterococcus) or V3 (Serratia, Staphylococcus, Stenotrophomonas, Salmonella):**
  *Proteus mirabilis* (584), *Vibrio cholerae* (666), *Streptococcus pneumoniae* (1313),
  *Morganella morganii* (582). The species were chosen by Claude before any V4 data were listed, for
  taxonomic spread (two Enterobacterales, one Vibrionales, one Bacillota) and for being likely to carry
  CARD homolog genes; the choice was not made by looking at any V4 genome.
- RefSeq assemblies at level *Complete Genome*, released on or after **2026-11-15** (else one month
  earlier at a time), from NCBI Datasets, listed after the in-force commit. Order by accession,
  `set.seed(20261116)`, `sample()`, take the first. Save the list and the draw.
- **Backgrounds:** human gut and wastewater; the first fetchable paired-end Illumina run after V3's
  run in `candidates_<type>.tsv` (V3: gut ERR3153732, wastewater SRR15524250), first 1,000,000 pairs.
- **Simulation:** ART seed **20261116**. Depths 0.5x, 2x, 8x; pure genomes 10x. E1, E2 as before.
  E3: HG002 (SRR37356339) pairs 1,200,001-1,400,000. E4 uses V4's first spike genome.
- **Truth:** as V3 (RGI `main` Perfect/Strict, findable, `locate.sh`, `simulated_depth.sh`, `repeats.sh`).
- `run_V4.sh` refuses to start while this file is a draft, while it has uncommitted changes, or before
  Addendum A. Docker: one container at a time, 8 GB, up to 4 cores.

## 3. Scorer

`validation/V4/score_V4.R` is `score_V3.R` with names changed only (checked by diff in Addendum A), and is
committed before any V4 data. A scorer change after that is a mark change.

## 4. Stated risk

On the seen rounds mark 1 missed 3 loci each in V1 rounds 3 and 4 and V2 under these marks (genes of
92-95% identity at low read counts in wastewater); V3 found all 140. V4 may still fail mark 1.
With the 4-read minimum actually in force, mark 2's V3 calls are expected to drop, but this is not
known: V4 may fail mark 2.
