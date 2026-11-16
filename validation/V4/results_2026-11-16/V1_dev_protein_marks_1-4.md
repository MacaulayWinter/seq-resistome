# V4 protein mode, identity band: marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 3 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **14**: GCF_062052633.1 qacJ; GCF_062052633.1 Klebsiella pneumoniae KpnH; GCF_062052633.1 rsmA; GCF_062052633.1 qacJ; GCF_062052633.1 ArnT; GCF_062052633.1 Klebsiella pneumoniae KpnF; GCF_062052633.1 vanG; GCF_062075038.1 vanY gene in vanM cluster; GCF_062083255.1 dfrA17; GCF_062083255.1 ArnT; GCF_062083255.1 ArnT; GCF_062083255.1 qacG; GCF_062083255.1 FosA8; GCF_062083255.1 Klebsiella pneumoniae KpnH.

Scored from `results`; 24 truth loci in 23 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **PASS** | 90 of 90 truth loci found; exact ARO 88 |
| 2. Specificity | **PASS** | 0 unexplained of 777 detected genes in 31 samples |
| 3. Accuracy, copies per 16S copy | **PASS** | pure genomes 22 of 22 groups within 1.5x; 8x mixtures 38 of 38 within 2x; ratio range 0.87-1.17; 0 group(s) with another gene copy and 3 under 92% identity not marked |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 29 of 48 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 6, of which 2 found: mix_gut_GCF_062083255.1_2x AAC(6')-Ib10 0.89x found; mix_gut_GCF_062083255.1_2x rsmA 1.33x missed; mix_gut_GCF_062083255.1_8x rsmA 6.29x missed; mix_wastewater_GCF_062083255.1_2x AAC(6')-Ib10 0.89x found; mix_wastewater_GCF_062083255.1_2x rsmA 1.33x missed; mix_wastewater_GCF_062083255.1_8x rsmA 6.29x missed.
- Mark 3 against the nominal truth (round 3's): pure genomes 21 of 23 within 1.5x; 8x mixtures 38 of 40 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_062052633.1 1.08, GCF_062058145.1 0.93, GCF_062075038.1 1.13, GCF_062083255.1 0.99.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_062052633.1 1.03, GCF_062058145.1 0.97, GCF_062075038.1 1.07, GCF_062083255.1 1.04.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 175 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 3 detection(s): mix_gut_GCF_062052633.1_8x rsmA (11 reads); mix_gut_GCF_062052633.1_8x Klebsiella pneumoniae KpnH (4 reads); pure_GCF_062052633.1 rsmA (13 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 2 unexplained.

V4 reports (not marked):

- Loci below 92% truth identity in 2x and 8x mixtures (not marked): 4; detected 0, probable homolog 1, missed 3.
- Detected genes explained as orthologs in the spike genome (RGI Loose, 85% or more), apart from DNA-found and protein-only: 1: pure_GCF_062058145.1 rsmA (16 reads).
- Mark 2 under V2's rule (Perfect/Strict only; for comparison): 1 unexplained.
- Probable homologs: 127 call(s) in 28 sample(s).
- Groups under 92% truth identity, left out of mark 3 (4a): 3; observed copies pure_GCF_062083255.1 rsmA 0/0.127; mix_gut_GCF_062083255.1_8x rsmA 0/0.0112; mix_wastewater_GCF_062083255.1_8x rsmA 0/0.0679.
- Groups left out of mark 3 because a locus has another copy in its genome: 0.
