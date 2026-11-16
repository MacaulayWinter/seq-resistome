# Allele-merge threshold (D22), chosen on round 3 (development)

Round 3 with CARD alone, `--min_read_identity 0.85`, scored by `score_V1_round4.R` (simulated-depth truth).
The tables were re-run offline from the run's RGI and 16S outputs with each `min_allele_identity`. The allele
table is CARD 4.0.2's references, BLASTN megablast all against all (>= 80% identity over >= 90% of the longer).

| min_allele_identity | Gene rows receiving merged reads | 1. Loci found | 2. Unexplained | 3. Pure within 1.5x | 3. 8x mixtures within 2x | Pure median ratio | Pure min | 8x max | EC-18 ratio |
|---|---|---|---|---|---|---|---|---|---|
| 0 (off) | 0 | 522/522 | 1 | 135/136 | 227/227 | 0.897 | 0.64 | 1.26 | 0.64 |
| 0.90 | 82 | 522/522 | 1 | 136/136 | 227/227 | 0.899 | 0.69 | 1.26 | 0.85 |
| 0.95 | 72 | 522/522 | 1 | 136/136 | 227/227 | 0.899 | 0.69 | 1.26 | 0.85 |
| 0.97 | 42 | 522/522 | 1 | 136/136 | 227/227 | 0.899 | 0.69 | 1.26 | 0.74 |
| 0.98 | 32 | 522/522 | 1 | 136/136 | 227/227 | 0.899 | 0.69 | 1.26 | 0.74 |

0.95 is the pipeline's default: the strictest value tested that still merges both of EC-18's minor alleles (EC-15 99.1%, EC-8 96.9%).
Below it, 10 more merges fix nothing. No ratio rises at any threshold.
