# Validation V3: pre-registration (protein mode, identity band)

**IN FORCE from the commit that contains this sentence (2026-11-14).**
Written 2026-11-14, after V2 failed marks 1, 2 and 3 (`validation/V2/RESULT_2026-11-14.md`)
and before any V3 genome was listed, fetched or simulated. The user decided on
2026-11-14 (relayed by the coordinator session): D32 = C (redefine what protein
mode claims), D33 = B (an identity band), D34 = B (marks 1 and 2 scored on the band,
fixed before V3), D35 = A (checked; section 5).

V2 stays failed. It is not re-scored and its truth table is not edited. V3 is a new
validation of a changed claim, on a fresh draw, and it does not rescue V2.

If any mark fails, V3 fails, and Claude stops and asks the user. Rule 1: no tag or
v0.1.0 unless every pre-registered mark passes.

## 0. What protein mode claims (D32 C)

Protein mode does not claim "this CARD gene is present, yes or no" for genes whose
sequence sits near the identity cut. It reports two classes:

- **detected**: as rule "or", unchanged. 100% of its pass conditions, frozen (V2 section 1).
- **probable homolog**: new. The gene fails "detected" only because its length-weighted
  gene identity is below 0.90, and it has at least 0.85. It is reported, never counted as
  detected, and never counted in copies per 16S.

A gene below 0.85 is not reported as either. Why: in V2 the real *Citrobacter* genes lay at
86-92% identity to CARD, right on the 0.90 cut, and sampling noise decided yes or no
(V2 result, marks 1 and 2).

## 1. Pipeline under test

Pipeline commit: **fixed by Addendum A**, which Claude commits before any V3 data are
touched and which names the commit and its `-profile test` results (both modes). The
rule text is frozen now, so the addendum may name a commit and nothing else.

- **Amendment 1 (see the end):** the "or" route needs at least `--min_protein_core_reads 4`
  reads at 0.90 or more (V2 required 2). Everything else of V2 section 1 is unchanged: rule "or", 0.70, 0.90, 0.95, 0.8, 0.90 (gene),
  allele identity 0.95, `--min_16s_identity 0.90`, `--min_arg_reads 2`, `--min_breadth_ratio 0.5`.
- New: `--min_protein_probable_gene_identity 0.85`, and a new `arg_long.tsv` column `call`
  with values `detected`, `probable_homolog` or empty. A probable homolog has the read
  and breadth conditions of f70g90 (at least `--min_arg_reads` reads at 0.70 or more, breadth
  ratio at least 0.5) and a gene identity from 0.85 up to but not including 0.90, and does not
  pass the "or" route. `detected` is 1:1 with the old `detected = TRUE`. Nothing else changes.
- Unit tests for the new class, and `-profile test` in both modes, must pass before
  Addendum A. The `-profile test` expected results must not change for detected genes.

## 2. Marks (band-scored; fixed now, D34 B)

- **Mark 1, detection:** 100% of truth loci in the 2x and 8x mixtures that were
  simulated at 1x or more **and whose truth protein identity to CARD is 0.92 or more**
  (`truth_loci.tsv`, `protein_identity`) are in class `detected`. Loci under 0.92
  are not marked; they are reported with their class (detected, probable homolog,
  or missed).
- **Mark 2, specificity:** 0 unexplained detected AROs, where a detected ARO is
  explained as in V2 (RGI Perfect/Strict protein hit, reported apart as DNA-found or
  protein-only) **or** RGI `main` calls it a **Loose** protein homolog hit in the
  spike genome at 85% identity or more (*ortholog in the spike genome*; reported apart
  from the other two). Probable homologs are not detected and are not marked in mark 2;
  they are reported with whether an RGI hit lies in the genome.
- **Mark 3, accuracy (as amended, Amendment 1):** copies per 16S copy against the simulated depth, per
  location group: pure within 1.5x, 8x mixtures within 2x, on class `detected` only, and **only for
  groups that mark 1 marks**: every locus of the group has truth identity 0.92 or more and no
  other copy in the genome. Groups with a locus under 0.92 are reported (observed against truth), not marked.
  Original text: a locus is **excluded from mark 3 when the genome holds another copy
  of its gene** (blastn of the locus against the genome: another hit of 95% identity or
  more over at least 500 bp, or at least half the locus length if shorter). V2's
  AAC(6')-Ie-APH(2'')-Ia is the reason (section 5). Excluded loci are listed with their copy
  count, never dropped silently.
- **Mark 4, edge cases E1-E3**, and **E4**, **Mark 5, the CARD cache:** as V2.

Reported, not marked: 95% intervals; results per genus; 0.5x detection; probable homologs
by gene; DNA-found, protein-only and ortholog explanations apart; mark 2 under V2's
rule (Perfect/Strict only), for comparison with V2.

### Checked against V2 before this was fixed (not a pass; the data are seen)

Under these marks V2's data would have given: mark 1 still **fail**, 3 misses of loci at
0.92 or more (mdtB x2 at 92.6%, msbA at 95.2%; rsmA 85.3% and PmrF 88.3% would not be
marked); mark 2 still **fail**, 3 unexplained (KpnG and acrA with no RGI hit, IreK at 59%;
the other 10 were RGI Loose hits at 86.5-91%); mark 3's AAC(6')-Ie case excluded.
The band design fixes the divergent orthologs and the repeat. It does not fix every V2
failure, and V3 may fail again. That is a stated risk, not a hidden one. (Amendment 1 changes
this check: see the end.)

## 3. Fresh data, by rules written now (frozen)

- **Spike genomes: four species, none used in V1 (E. coli, Klebsiella, Enterobacter) or V2
  (Citrobacter, Pseudomonas, Acinetobacter, Enterococcus):**
  *Serratia marcescens* (Enterobacterales), *Staphylococcus aureus* (Bacillota),
  *Stenotrophomonas maltophilia* (Xanthomonadales), *Salmonella enterica* (Enterobacterales).
  Three genera outside Enterobacterales are not available among four; two are.
- RefSeq assemblies at level *Complete Genome* released on or after **2026-11-14**, from NCBI
  Datasets, listed after the in-force commit. Order by accession, `set.seed(20261115)`,
  `sample()`, take the first. A species with none takes the previous release window, one
  month at a time. Save the list and the draw.
- **Backgrounds:** human gut and wastewater; the first fetchable paired-end Illumina run after V2's
  run in `candidates_<type>.tsv` (`SRR` of V2 in `backgrounds_V2.tsv`), first 1,000,000 pairs.
- **Simulation:** ART seed **20261115**. Depths 0.5x, 2x, 8x; pure genomes 10x. E1, E2 as before.
  E3: HG002 pairs 1,000,001-1,200,000. E4 uses V3's first spike genome.
- **Truth:** as V2 (RGI `main` Perfect/Strict, findable, `locate.sh`, `simulated_depth.sh`), plus
  the repeat table of section 2.
- A `run_V3.sh`, written from `run_V2.sh`, refuses to start while this file is a draft,
  while it has uncommitted changes, or before Addendum A.
- Docker: one container at a time, 8 GB, up to 4 cores, as V2.

## 4. Scorer

`validation/V3/score_V3.R` is written from `score_V2.R` with only the changes of section 2, and
committed in Addendum A, before any V3 data. A scorer change after that is a mark change.

## 5. D35: the *Enterococcus* AAC(6')-Ie-APH(2'')-Ia overcount in V2 (checked 2026-11-14)

A blastn of the 1,440 bp locus (NZ_JCAWFM010000002.1:199029-200468) against its own genome
finds **a second copy**: NZ_JCAWFM010000002.1:156456-157558, 100% identical over 1,103 bp
(the first 77% of the gene). RGI lists only the full-length copy. `simulated_depth.sh` maps
reads with kma, which splits reads between identical copies, so its depth for this locus
(2.9) is far below the chromosome's (about 11.6); the genome's six identical 16S copies
show the same effect (depths 0.2 to 25). Against the nominal depth the observed value is
1.53x (pure) and 2.19x (8x mixture), inside the limit once the second copy
(about 1.77 gene copies) is counted; a repeated locus therefore has an unreliable truth
depth, not a pipeline overcount. V2's truth table is **not edited** and V2's mark 3 stays failed;
V3 excludes such loci and lists them (section 2).

## Amendment 1 (2026-11-14, before any V3 data were listed, fetched or simulated)

Two changes, both decided by the user on 2026-11-14 (relayed by the coordinator session:
"go with your recommendations, D2 and 4a"). The text above is edited in place; the version
committed as 04f9b40 stays in git history.

1. **D2: the "or" route needs 4 reads.** `--min_protein_core_reads 4` (code in 93eb4e8). Core cut stays
   0.95 and breadth ratio 0.8. Why: V2's noise calls IreK and acrA came from 2-3 reads at 90% or more.
   An offline sweep on V1 rounds 3-4 and V2, scored with `score_V3.R` (`SWEEP_CORE_CUT.md`,
   `sweep_min_reads.tsv`): 2 reads (V2's rule), 3, 4, 5, and a minimum coverage of 15% or 25%.

   | Round | min 2 | min 3 | min 4 | min 5 | cov 15% | cov 25% |
   |---|---|---|---|---|---|---|
   | 3: found / unexplained | 515/518; 0 | 515; 0 | 515; 0 | 515; 0 | 515; 0 | 515; 0 |
   | 4: found / unexplained | 443/446; 1 | 443; 1 | 443; 1 | 443; 1 | 443; 1 | 443; 1 |
   | V2: found / unexplained | 373/376; 4 | 373; 3 | 373; 1 | 373; 1 | 373; 2 | 373; 1 |

   No setting loses a found locus; 4 is the smallest read count that removes 3 of V2's 4
   unexplained calls (IreK twice, acrA), and it is simpler than a coverage rule.
2. **4a: mark 3 scores only what mark 1 marks** (as written in section 2 above).

**Stated risk, not hidden:** on the seen rounds, under these marks, mark 1 still misses 3 loci in each of
round 3 (515 of 518), round 4 (443 of 446) and V2 (373 of 376): genes of 92-95% identity at low read
counts in wastewater (V2: mdtB x2, msbA). The amendment does not fix them. V3 may fail mark 1 again.
Mark 2 on V2 would leave 1 unexplained (KpnG, probably an RGI naming issue); mark 3 on V2 would have
1 group outside the limit, mdtB, which is the same missed locus.
