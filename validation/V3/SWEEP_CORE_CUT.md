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
