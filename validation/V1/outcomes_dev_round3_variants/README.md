# Why seq-resistome does not use CARD's variants collection (D20)

These are development results, not validation: settings and design were
chosen on rounds 1-3 only. They are the evidence for removing CARD's
variants collection (WildCARD "prevalence", release 4.0.2) from the
pipeline on 2026-11-05, after it had been built in.

## Why it was added

V1 round 3 failed narrowly. One cause: 31 of 349 true genes are only 80-90%
identical, as DNA, to the one CARD reference sequence of their gene, so
their reads map partly and they are undercounted or look like partial
homologs (CLAUDE.md D19). CARD's variants collection holds each gene as it
occurs in sequenced pathogen genomes. The hope was that such reads would
map to a closer variant.

## What was run

Round 3's 27 samples (`PREREGISTRATION_round3.md` data) were run twice:

- with CARD 4.0.2 alone (the D19 development run);
- with CARD 4.0.2 plus its variants collection (`rgi bwt --include_wildcard`).

Both runs were scored by location exactly as round 3 was
(`score_V1_round3.R`), and both at read-identity thresholds 0 and 0.85
(`apply_identity.R`).

The variants run also had the new 16S count (D20); the CARD-alone run did
not. The 16S change moves 16S copies by about 1%, which is far too little to
explain the differences below.

## Results

| Mark (round 3, identity 0) | CARD alone | CARD + variants |
|---|---|---|
| Detection, truth loci found | 543 / 544 | 512 / 544 |
| Specificity, unexplained detected genes | 22 | 101 |
| Accuracy, pure-genome groups within 1.5x | 131 / 136 | 99 / 136 |

Raising the read-identity threshold does not rescue variants. At 0.85,
CARD + variants gives 473 / 544, 53 unexplained, and 98 / 136. CARD alone at
0.85 gives 543 / 544, 1 unexplained, and 131 / 136. Full reports are in
`marks_*.md`.

## Why it is worse

From `variant_bands.R` on the three pure-genome samples:

- **Almost every read leaves CARD's own references.** 99% of reads map to
  variant sequences (`reads_by_reference_kind_and_length.tsv`).
- **A quarter of reads land on "variants" more than 10% longer than the
  gene's CARD reference.** These sequences are whole reading frames taken
  from assemblies, so they carry neighbouring sequence and draw reads from
  adjacent genes. Read identity on them is 0.89, and 0.71 on the short
  ones.
- **Even full-length variants match no better.** Their read identity is
  0.94, the same as CARD's own references (0.95). By protein identity to
  CARD, the band at 90-95% is the worst, at 0.79
  (`reads_on_full_length_variants_by_protein_identity.tsv`).
- **Genes gain reads that are not theirs.** Gene by gene
  (`genes_pure_genomes_card_alone_vs_variants.tsv`):
  - kdpE goes from 52 reads to 347, at 0.73 read identity;
  - APH(6)-Id from 57 to 190;
  - aadA5 from 73 to 152.

  Copies per genome copy rise from 0.95-1.02 to 1.09 (median, pure genomes).
- **Cost.** Each sample's RGI task needs about 4 GB of memory instead of
  2.5 GB, there is a 1.8 GB download, and the database step uses 2.6 GB of
  disk per run.

So the collection does not fix the genes it was meant to fix, and it adds
errors that every user would meet.

## What would change this decision

A future attempt would need two things:

- a variants set restricted to full-length sequences close to CARD's
  reference (for example 0.9-1.1x its length, 98% or more protein identity);
- or reads realigned to CARD's own reference after variant assignment.

Either attempt would have to beat CARD alone on every development mark
before any validation.
