# Validation V1 round 4 (by location, truth from simulated depth): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051561185.1 adeF; GCF_051561185.1 ArnT; GCF_051561185.1 rsmA; GCF_051561185.1 Klebsiella pneumoniae KpnF; GCF_051561185.1 Klebsiella pneumoniae KpnE; GCF_051561185.1 vanG; GCF_051561185.1 leuO; GCF_051562295.1 vanG; GCF_051562295.1 rsmA; GCF_051562295.1 ArnT; GCF_051562295.1 Klebsiella pneumoniae KpnE; GCF_051562295.1 Klebsiella pneumoniae KpnF; GCF_051617105.1 vanG; GCF_051617105.1 leuO; GCF_051617105.1 rsmA.

Scored from `results`; 136 truth loci in 109 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 461 of 474 truth loci found; exact ARO 402 |
| 2. Specificity | **FAIL** | 3 unexplained of 1582 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 95 of 109 groups within 1.5x; 8x mixtures 185 of 201 within 2x; ratio range 0.00-4.75 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 199 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 70, of which 62 found: mix_gut_GCF_051561185.1_2x emrR 0.93x missed; mix_gut_GCF_051561185.1_2x sul1 0.18x found; mix_gut_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x arr-3 0.02x missed; mix_gut_GCF_051561185.1_2x catB3 0.26x found; mix_gut_GCF_051561185.1_2x SHV-12 0.54x found; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x sul1 0.05x found; mix_gut_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_gut_GCF_051561185.1_8x sul1 0.74x found; mix_gut_GCF_051561185.1_8x sul1 0.35x found; mix_gut_GCF_051561185.1_8x catB3 0.91x found; mix_gut_GCF_051561185.1_8x sul1 0.00x found; mix_gut_GCF_051561185.1_8x sul1 0.33x found; mix_gut_GCF_051562295.1_2x mdtM 0.84x found; mix_gut_GCF_051562295.1_2x gadX 0.90x found; mix_gut_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_gut_GCF_051617105.1_2x CRP 0.93x found; mix_gut_GCF_051617105.1_2x marA 0.61x missed; mix_gut_GCF_051617105.1_2x SHV-12 0.95x found; mix_gut_GCF_051617105.1_2x arr-3 0.66x found; mix_gut_GCF_051617105.1_2x dfrA19 0.62x found; mix_gut_GCF_051617105.1_2x sul1 0.26x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_gut_GCF_051617105.1_2x sul1 0.09x found; mix_gut_GCF_051617105.1_2x OXA-1 0.00x found; mix_gut_GCF_051617105.1_2x aadA2 0.73x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_2x sul1 0.10x found; mix_gut_GCF_051617105.1_8x sul1 0.51x found; mix_gut_GCF_051617105.1_8x sul1 0.16x found; mix_gut_GCF_051617105.1_8x OXA-1 0.00x found; mix_gut_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_8x sul1 0.31x found; mix_wastewater_GCF_051561185.1_2x emrR 0.93x found; mix_wastewater_GCF_051561185.1_2x sul1 0.18x found; mix_wastewater_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x arr-3 0.02x missed; mix_wastewater_GCF_051561185.1_2x catB3 0.26x found; mix_wastewater_GCF_051561185.1_2x SHV-12 0.54x missed; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x sul1 0.05x found; mix_wastewater_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_wastewater_GCF_051561185.1_8x sul1 0.74x found; mix_wastewater_GCF_051561185.1_8x sul1 0.35x found; mix_wastewater_GCF_051561185.1_8x catB3 0.91x found; mix_wastewater_GCF_051561185.1_8x sul1 0.00x found; mix_wastewater_GCF_051561185.1_8x sul1 0.33x found; mix_wastewater_GCF_051562295.1_2x mdtM 0.84x found; mix_wastewater_GCF_051562295.1_2x gadX 0.90x found; mix_wastewater_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_wastewater_GCF_051617105.1_2x CRP 0.93x found; mix_wastewater_GCF_051617105.1_2x marA 0.61x missed; mix_wastewater_GCF_051617105.1_2x SHV-12 0.95x found; mix_wastewater_GCF_051617105.1_2x arr-3 0.66x found; mix_wastewater_GCF_051617105.1_2x dfrA19 0.62x found; mix_wastewater_GCF_051617105.1_2x sul1 0.26x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_wastewater_GCF_051617105.1_2x sul1 0.09x found; mix_wastewater_GCF_051617105.1_2x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_2x aadA2 0.73x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_2x sul1 0.10x found; mix_wastewater_GCF_051617105.1_8x sul1 0.51x found; mix_wastewater_GCF_051617105.1_8x sul1 0.16x found; mix_wastewater_GCF_051617105.1_8x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_8x sul1 0.31x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 92 of 109 within 1.5x; 8x mixtures 184 of 201 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051561185.1 1.03, GCF_051562295.1 1.08, GCF_051617105.1 1.06.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051561185.1 1.06, GCF_051562295.1 1.04, GCF_051617105.1 1.05.

Missed truth loci (marked depths):

- mix_gut_GCF_051561185.1_8x: emrB (GCF_051561185.1:NZ_CP196253.1:1896596-1898143)
- mix_gut_GCF_051617105.1_2x: emrR (GCF_051617105.1:NZ_CP196294.1:2623652-2624182)
- mix_gut_GCF_051617105.1_2x: msbA (GCF_051617105.1:NZ_CP196294.1:4848162-4849910)
- mix_gut_GCF_051617105.1_2x: AAC(3)-IId (GCF_051617105.1:NZ_CP196295.1:266063-266923)
- mix_gut_GCF_051617105.1_8x: emrR (GCF_051617105.1:NZ_CP196294.1:2623652-2624182)
- mix_gut_GCF_051617105.1_8x: marA (GCF_051617105.1:NZ_CP196294.1:4213031-4213405)
- mix_gut_GCF_051617105.1_8x: msbA (GCF_051617105.1:NZ_CP196294.1:4848162-4849910)
- mix_wastewater_GCF_051561185.1_8x: emrB (GCF_051561185.1:NZ_CP196253.1:1896596-1898143)
- mix_wastewater_GCF_051617105.1_2x: emrR (GCF_051617105.1:NZ_CP196294.1:2623652-2624182)
- mix_wastewater_GCF_051617105.1_2x: msbA (GCF_051617105.1:NZ_CP196294.1:4848162-4849910)
- mix_wastewater_GCF_051617105.1_8x: emrR (GCF_051617105.1:NZ_CP196294.1:2623652-2624182)
- mix_wastewater_GCF_051617105.1_8x: marA (GCF_051617105.1:NZ_CP196294.1:4213031-4213405)
- mix_wastewater_GCF_051617105.1_8x: msbA (GCF_051617105.1:NZ_CP196294.1:4848162-4849910)

Unexplained detected genes:

- mix_wastewater_GCF_051561185.1_2x: eptB (3 reads, 17.4% covered; pmr phosphoethanolamine transferase)
- mix_wastewater_GCF_051562295.1_2x: LptD (2 reads, 8.0% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- pure_GCF_051617105.1: ANT(3'')-II-AAC(6')-IId bifunctional protein (18 reads, 43.2% covered; aminoglycoside bifunctional resistance protein)

Outside the accuracy limit:

- pure_GCF_051561185.1: CRP, observed 0.0637, truth 0.146 (ratio 0.44, limit 1.5x)
- pure_GCF_051561185.1: emrB, observed 0, truth 0.156 (ratio 0.00, limit 1.5x)
- pure_GCF_051561185.1: emrR, observed 0.0452, truth 0.135 (ratio 0.33, limit 1.5x)
- pure_GCF_051561185.1: oqxA, observed 0.0843, truth 0.128 (ratio 0.66, limit 1.5x)
- pure_GCF_051561185.1: adeF, observed 0.0928, truth 0.145 (ratio 0.64, limit 1.5x)
- pure_GCF_051561185.1: marA, observed 0.0633, truth 0.118 (ratio 0.53, limit 1.5x)
- pure_GCF_051561185.1: msbA, observed 0, truth 0.135 (ratio 0.00, limit 1.5x)
- pure_GCF_051561185.1: Shigella flexneri acrA, observed 0.066, truth 0.106 (ratio 0.62, limit 1.5x)
- pure_GCF_051561185.1: AAC(6')-Ib10, observed 0.295, truth 0.0823 (ratio 3.59, limit 1.5x)
- pure_GCF_051617105.1: CRP, observed 0.0542, truth 0.102 (ratio 0.53, limit 1.5x)
- pure_GCF_051617105.1: Klebsiella pneumoniae KpnH, observed 0, truth 0.107 (ratio 0.00, limit 1.5x)
- pure_GCF_051617105.1: emrR, observed 0.00558, truth 0.0839 (ratio 0.07, limit 1.5x)
- pure_GCF_051617105.1: marA, observed 0, truth 0.164 (ratio 0.00, limit 1.5x)
- pure_GCF_051617105.1: msbA, observed 0, truth 0.115 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051561185.1_8x: emrB, observed 0, truth 0.00931 (ratio 0.00, limit 2x)
- mix_gut_GCF_051561185.1_8x: emrR, observed 0.00305, truth 0.00845 (ratio 0.36, limit 2x)
- mix_gut_GCF_051561185.1_8x: msbA, observed 0.00179, truth 0.00908 (ratio 0.20, limit 2x)
- mix_gut_GCF_051561185.1_8x: AAC(6')-Ib10, observed 0.0185, truth 0.00389 (ratio 4.75, limit 2x)
- mix_gut_GCF_051617105.1_8x: Klebsiella pneumoniae KpnH, observed 0.00146, truth 0.00737 (ratio 0.20, limit 2x)
- mix_gut_GCF_051617105.1_8x: emrR, observed 0, truth 0.00463 (ratio 0.00, limit 2x)
- mix_gut_GCF_051617105.1_8x: marA, observed 0, truth 0.00945 (ratio 0.00, limit 2x)
- mix_gut_GCF_051617105.1_8x: msbA, observed 0, truth 0.00841 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: CRP, observed 0.011, truth 0.0233 (ratio 0.47, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: emrB, observed 0, truth 0.0241 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: emrR, observed 0.00785, truth 0.0219 (ratio 0.36, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: msbA, observed 0.00461, truth 0.0235 (ratio 0.20, limit 2x)
- mix_wastewater_GCF_051617105.1_8x: Klebsiella pneumoniae KpnH, observed 0.00373, truth 0.0189 (ratio 0.20, limit 2x)
- mix_wastewater_GCF_051617105.1_8x: emrR, observed 0, truth 0.0119 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051617105.1_8x: marA, observed 0, truth 0.0243 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051617105.1_8x: msbA, observed 0, truth 0.0216 (ratio 0.00, limit 2x)
