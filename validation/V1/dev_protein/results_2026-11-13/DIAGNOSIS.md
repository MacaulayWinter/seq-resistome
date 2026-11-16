# Protein-mode development run: why the mixtures miss genes (2026-11-13)

These are development data (V1 rounds 3 and 4, both seen before). The run
was pipeline commit a853ceb plus uncommitted changes, protein mode, rule
f70g90. Marks are in `round3/` and `round4/`, in
`outcomes_protein/V1_dev_protein_marks_1-4.md`.

## Result

| | Round 3 | Round 4 |
|---|---|---|
| Truth loci missed in 2x/8x mixtures (mark 1) | 32 of 522 | 15 of 474 |
| ... of which: gene identity below 90% | 31 | 14 |
| ... of which: other causes | 1 | 1 |

## Main cause: the gene identity averages over every organism in the sample

Rule f70g90 keeps reads with 70% or more amino-acid identity to their best
CARD protein. It then calls the gene only if those reads, weighted by
alignment length, average 90% or more.

In a pure genome the reads come from one organism. The missed genes pass
there: on round 3's pure genomes, msbA is 98-99%, ugd 92-94% and kdpE 98-99%.

In a mixture, the background organisms carry their own homologs of the same
genes, at 70-89% identity to CARD's protein. Those reads pass the 70% read
filter and join the average, so the real gene's identity is pulled below 90%.
For example, in mix_gut_GCF_051559745.1_2x:

| Gene | Kept reads | Gene identity | Breadth ratio | Same gene, pure genome |
|---|---|---|---|---|
| ugd | 151 | 78.4% | 0.90 | 92.8% |
| msbA | 70 | 85.4% | 0.90 | 99.1% |
| kdpE | 17 | 88.1% | 0.96 | 99.1% |

It happens at 8x too, where the spike dominates the gene: mix_gut 8x msbA is
89.9%. So mark 3's ratio-0 rows (round 3: ugd and msbA in 8x mixtures) are
these same genes, not counted.

Step 0 couldn't see this, because it tested pure genomes only. This is a
flaw in rule f70g90 itself, not in its two values. A real metagenome holds
many related organisms, so the effect will be at least as strong there.

## Other misses

- **Round 4, pure genomes too:** *Klebsiella* OmpK37 (77-84%), ugd (87%) and
  mdtG (87%) in *Enterobacter* and *Klebsiella*. These are divergent orthologs
  that RGI `main` calls Strict, and they sit below 90% even alone. That was
  known for OmpK37 (step 0).
- **Round 4, AAC(3)-IId in a 2x mixture:** 8 reads with breadth ratio 0.47,
  just below 0.5. That's chance at low depth, as in DNA mode (D21).
- **Round 3, QnrS1 in a wastewater 2x mixture:** no row. Not yet traced.
- **Round 4, AAC(6')-Ib10:** 3.7x in the pure *Enterobacter*, 5.3x in a gut
  8x mixture. The same overcount as DNA mode, so probably the truth (D26).

## Why this needs the user

D28 froze rule f70g90 at 0.70/0.90. A fix must change how the gene identity
is computed. One example: judge only the reads of the best-matching group,
not every read on the protein. That is a design change, so Claude stops and
asks (D28; D1 section 5).

What was tried before: step 0's per-read rule id90 (reads at 90% or more,
plus the reads and breadth rules) avoids this averaging, but it called 23-49
orthologs on the pure genomes. So no existing rule passes both tests.

A new rule needs the per-read DIAMOND hits of the mixtures. The pipeline
deletes them at task end (D14), so they would have to be made again.
