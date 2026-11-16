# Protein mode, DEVELOPMENT scoring on a seen V1 round (not validation): marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 11 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051559745.1 Klebsiella pneumoniae KpnE; GCF_051559745.1 Klebsiella pneumoniae KpnF; GCF_051559745.1 vanG; GCF_051559745.1 rsmA; GCF_051559745.1 ArnT; GCF_051563765.1 vanG; GCF_051563765.1 Klebsiella pneumoniae KpnF; GCF_051563765.1 Klebsiella pneumoniae KpnE; GCF_051563765.1 ArnT; GCF_051563765.1 rsmA; GCF_051618695.1 ArnT; GCF_051618695.1 Klebsiella pneumoniae KpnE; GCF_051618695.1 Klebsiella pneumoniae KpnF; GCF_051618695.1 vanG; GCF_051618695.1 rsmA.

Scored from `rule_or_r3`; 136 truth loci in 136 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 519 of 522 truth loci found; exact ARO 510 |
| 2. Specificity | **PASS** | 0 unexplained of 1986 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **PASS** | pure genomes 136 of 136 groups within 1.5x; 8x mixtures 225 of 225 within 2x; ratio range 0.75-1.60 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 222 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 22, of which 22 found: mix_gut_GCF_051559745.1_2x mdtN 0.74x found; mix_gut_GCF_051559745.1_2x sul2 0.95x found; mix_gut_GCF_051563765.1_2x EC-5 0.37x found; mix_gut_GCF_051618695.1_2x PmrF 0.76x found; mix_gut_GCF_051618695.1_2x Escherichia coli emrE 0.88x found; mix_gut_GCF_051618695.1_2x marA 0.83x found; mix_gut_GCF_051618695.1_2x kdpE 0.40x found; mix_gut_GCF_051618695.1_2x mdtM 0.92x found; mix_gut_GCF_051618695.1_2x mdtP 0.94x found; mix_gut_GCF_051618695.1_2x cpxA 0.88x found; mix_gut_GCF_051618695.1_2x mdtE 0.75x found; mix_wastewater_GCF_051559745.1_2x mdtN 0.74x found; mix_wastewater_GCF_051559745.1_2x sul2 0.95x found; mix_wastewater_GCF_051563765.1_2x EC-5 0.37x found; mix_wastewater_GCF_051618695.1_2x PmrF 0.76x found; mix_wastewater_GCF_051618695.1_2x Escherichia coli emrE 0.88x found; mix_wastewater_GCF_051618695.1_2x marA 0.83x found; mix_wastewater_GCF_051618695.1_2x kdpE 0.40x found; mix_wastewater_GCF_051618695.1_2x mdtM 0.92x found; mix_wastewater_GCF_051618695.1_2x mdtP 0.94x found; mix_wastewater_GCF_051618695.1_2x cpxA 0.88x found; mix_wastewater_GCF_051618695.1_2x mdtE 0.75x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 132 of 136 within 1.5x; 8x mixtures 223 of 225 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051559745.1 1.00, GCF_051563765.1 1.04, GCF_051618695.1 0.98.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051559745.1 1.05, GCF_051563765.1 1.04, GCF_051618695.1 1.05.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 979 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 11 detection(s): mix_gut_GCF_051559745.1_0.5x ArnT (2 reads); mix_gut_GCF_051559745.1_8x rsmA (8 reads); mix_wastewater_GCF_051559745.1_0.5x rsmA (7 reads); mix_wastewater_GCF_051559745.1_2x rsmA (8 reads); mix_wastewater_GCF_051559745.1_8x rsmA (15 reads); mix_wastewater_GCF_051563765.1_0.5x rsmA (7 reads); mix_wastewater_GCF_051563765.1_2x rsmA (9 reads); mix_wastewater_GCF_051563765.1_8x rsmA (15 reads); mix_wastewater_GCF_051618695.1_0.5x rsmA (8 reads); mix_wastewater_GCF_051618695.1_2x rsmA (5 reads); pure_GCF_051559745.1 rsmA (9 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 2 unexplained.

Missed truth loci (marked depths):

- mix_wastewater_GCF_051559745.1_2x: ugd (GCF_051559745.1:NZ_CP196276.1:190326-191492)
- mix_wastewater_GCF_051563765.1_2x: H-NS (GCF_051563765.1:NZ_CP196265.1:2301452-2301865)
- mix_wastewater_GCF_051618695.1_2x: QnrS1 (GCF_051618695.1:NZ_CP196310.1:5801-6457)
