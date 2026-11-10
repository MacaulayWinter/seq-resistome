# Share of a gene's reads that must pass the identity (D24), chosen on round 3 (development)

Round 3 run on 2026-11-09 with every fix (D20-D23): CARD alone, `--min_read_identity 0.85` judged read by read, alleles merged
at 0.95, 16S identity floor 0.90. The tables were re-run offline from that run's own inputs with each
`min_identity_share`, then scored by `score_V1_round4.R` (simulated-depth truth).

| min_identity_share | Detected calls (all samples) | 1. Loci found | 2. Unexplained | 3. Pure / 8x mixtures | Wastewater background calls OXA-1307 |
|---|---|---|---|---|---|
| 0 (off) | 2,384 | 522/522 | 10 (LptD 8, eptB 2) | 136/136, 227/227 | yes |
| 0.3 | 2,347 | 522/522 | 6 | 136/136, 227/227 | yes |
| 0.4 | 2,313 | 522/522 | 2 (LptD, 4 of 10 reads pass) | 136/136, 227/227 | yes |
| **0.5** | **2,306** | **522/522** | **0** | **136/136, 227/227** | **yes (2 of 4 reads pass)** |
| 0.6 | 2,243 | 522/522 | 1 (OXA-1307 in an 8x mixture) | 136/136, 233/233 | no |
| 0.7 | 2,179 | 522/522 | 1 | 136/136, 233/233 | no |

The mean-identity rule (before D23) gave 2,269 detected calls on the same reads.

**The window is narrow and rests on few reads.** Only values above LptD's 0.40 (4 of 10 reads) and at or below
OXA-1307's 0.50 (2 of 4) pass mark 2. 0.5 ("at least half") is the natural value inside it, but the development data cannot
show it is robust. Round 4, on fresh data, tests it.

**Known cost:** OmpA (a porin present in the genomes, 80-90% DNA identity to CARD, not a truth locus) is not called in 4
samples, because most of its reads fall below 0.85. Genes this divergent from CARD's reference stay a limitation (README).
