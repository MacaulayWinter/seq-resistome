# Offline sweep of the core cut (D34), 2026-11-14

`sweep_core_cut.tsv`: `resistome_tables.R` on the saved inputs of V1 rounds 3, 4 and V2, with the
high-identity route's gene identity (`core_gene`) at 0.95 (current), 0.94, 0.93, 0.92, 0.90 and its
breadth ratio (`core_ratio`) at 0.8 (current) and 0.7; scored by `score_dev_protein.R` (the old marks).
Offline, no Docker, no V3 data. All three rounds are seen, so this is development. Row r3 0.95/0.8
reproduces the earlier 519/522 and 0 unexplained.

Old-mark results (found/total; unexplained):

| core_gene / ratio | round 3 | round 4 | V2 |
|---|---|---|---|
| 0.95 / 0.8 (current) | 519/522; 0 | 469/474; 5 | 379/388; 14 |
| 0.94 / 0.8 | 520; 2 | 470; 9 | 382; 18 |
| 0.94 / 0.7 | 522; 3 | 473; 16 | 385; 20 |
| 0.93 / 0.7 | 522; 9 | 473; 24 | 386; 29 |
| 0.90 / 0.7 | 522; 16 | 473; 39 | 387; 27 |

Under V3's marks (`score_V3.R`, V2 data only): 0.95/0.8 gives mark 1 373/376, mark 2 4 unexplained;
0.94/0.8: 375/376, 4; **0.94/0.7: mark 1 PASS 376/376, mark 2 5 unexplained**; 0.93/0.7: 376/376, 6;
0.92/0.7: 376/376, 12. Mark 3 still fails in every row because rsmA/PmrF/mdtB (not marked in mark 1)
count as 0 copies; that is the mark 3 coherence point.

Reading: lowering the cut buys a few loci and costs far more unexplained detections. On round 4,
0.94/0.7 finds 4 more loci for 11 more unexplained; no setting gives 0 unexplained on a
development round except the current one on round 3. No value passes mark 2 on all three rounds.
The V2 misses of genes at 92-95% identity are a real limit of a 95% core cut, but the cost
of removing it is specificity (the old scorer does not count RGI Loose orthologs as explained, so
part of that cost may be orthologs; not yet checked on rounds 3-4).

## Follow-up (option D): are the extra unexplained calls RGI Loose orthologs? (2026-11-14)

Offline, from the RGI Loose tables in the round 3, round 4 and V2 truth directories. A detected gene
is counted as explained under V3's mark 2 when RGI main lists it as a Loose protein homolog hit of 85%
identity or more in the spike genome. Unexplained detections under that rule:

| Core cut / ratio | Round 3 | Round 4 | V2 |
|---|---|---|---|
| 0.95 / 0.8 (current) | 0 (old rule 0) | 1 (old rule 5) | 4 (old rule 14) |
| 0.94 / 0.8 | 2 (2) | 5 (9) | 4 |
| 0.94 / 0.7 | 3 (3) | 7 (16) | 5 |

The calls that lowering the cut adds (beyond the current setting) split like this at 0.94 / 0.7:
round 3: 3 added, 0 are Loose orthologs of 85% or more (all MdtK, 2 reads each, Loose under 85%);
round 4: 12 added, 6 are Loose orthologs of 85% or more (bacA x3, YojI x2, PmrF x1) and 6 are not
(ugd x2, LptD, MdtK, PmrF x2, all under 85%).

Reading: about half the extra cost on round 4 and none on round 3 is real orthologs. Under V3's
own mark 2, 0.94 / 0.7 still adds 3 (round 3), 6 (round 4) and 1 (V2) unexplained calls, each a
gene present at under 85% identity to CARD that is called from a few reads, for 3 to 4 more loci found
per round. Even the current setting does not reach 0 unexplained under V3's mark 2 on round 4 (1) or V2 (4).
Genes under 85% identity detected from 2-17 reads at 90% or more are the weak spot of the core route.
