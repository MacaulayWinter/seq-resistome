# Protein mode, DEVELOPMENT scoring on a seen V1 round (not validation): marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 6 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051561185.1 adeF; GCF_051561185.1 ArnT; GCF_051561185.1 rsmA; GCF_051561185.1 Klebsiella pneumoniae KpnF; GCF_051561185.1 Klebsiella pneumoniae KpnE; GCF_051561185.1 vanG; GCF_051561185.1 leuO; GCF_051562295.1 vanG; GCF_051562295.1 rsmA; GCF_051562295.1 ArnT; GCF_051562295.1 Klebsiella pneumoniae KpnE; GCF_051562295.1 Klebsiella pneumoniae KpnF; GCF_051617105.1 vanG; GCF_051617105.1 leuO; GCF_051617105.1 rsmA.

Scored from `rule_f_r4`; 136 truth loci in 109 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 459 of 474 truth loci found; exact ARO 415 |
| 2. Specificity | **FAIL** | 3 unexplained of 1519 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 107 of 109 groups within 1.5x; 8x mixtures 194 of 200 within 2x; ratio range 0.00-5.34 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 193 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 70, of which 64 found: mix_gut_GCF_051561185.1_2x emrR 0.93x missed; mix_gut_GCF_051561185.1_2x sul1 0.18x found; mix_gut_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x arr-3 0.02x missed; mix_gut_GCF_051561185.1_2x catB3 0.26x found; mix_gut_GCF_051561185.1_2x SHV-12 0.54x found; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x sul1 0.05x found; mix_gut_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_gut_GCF_051561185.1_8x sul1 0.74x found; mix_gut_GCF_051561185.1_8x sul1 0.35x found; mix_gut_GCF_051561185.1_8x catB3 0.91x found; mix_gut_GCF_051561185.1_8x sul1 0.00x found; mix_gut_GCF_051561185.1_8x sul1 0.33x found; mix_gut_GCF_051562295.1_2x mdtM 0.84x found; mix_gut_GCF_051562295.1_2x gadX 0.90x found; mix_gut_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_gut_GCF_051617105.1_2x CRP 0.93x found; mix_gut_GCF_051617105.1_2x marA 0.61x found; mix_gut_GCF_051617105.1_2x SHV-12 0.95x found; mix_gut_GCF_051617105.1_2x arr-3 0.66x found; mix_gut_GCF_051617105.1_2x dfrA19 0.62x found; mix_gut_GCF_051617105.1_2x sul1 0.26x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_gut_GCF_051617105.1_2x sul1 0.09x found; mix_gut_GCF_051617105.1_2x OXA-1 0.00x found; mix_gut_GCF_051617105.1_2x aadA2 0.73x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_2x sul1 0.10x found; mix_gut_GCF_051617105.1_8x sul1 0.51x found; mix_gut_GCF_051617105.1_8x sul1 0.16x found; mix_gut_GCF_051617105.1_8x OXA-1 0.00x found; mix_gut_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_8x sul1 0.31x found; mix_wastewater_GCF_051561185.1_2x emrR 0.93x missed; mix_wastewater_GCF_051561185.1_2x sul1 0.18x found; mix_wastewater_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x arr-3 0.02x missed; mix_wastewater_GCF_051561185.1_2x catB3 0.26x found; mix_wastewater_GCF_051561185.1_2x SHV-12 0.54x found; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x sul1 0.05x found; mix_wastewater_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_wastewater_GCF_051561185.1_8x sul1 0.74x found; mix_wastewater_GCF_051561185.1_8x sul1 0.35x found; mix_wastewater_GCF_051561185.1_8x catB3 0.91x found; mix_wastewater_GCF_051561185.1_8x sul1 0.00x found; mix_wastewater_GCF_051561185.1_8x sul1 0.33x found; mix_wastewater_GCF_051562295.1_2x mdtM 0.84x found; mix_wastewater_GCF_051562295.1_2x gadX 0.90x found; mix_wastewater_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_wastewater_GCF_051617105.1_2x CRP 0.93x found; mix_wastewater_GCF_051617105.1_2x marA 0.61x found; mix_wastewater_GCF_051617105.1_2x SHV-12 0.95x found; mix_wastewater_GCF_051617105.1_2x arr-3 0.66x found; mix_wastewater_GCF_051617105.1_2x dfrA19 0.62x found; mix_wastewater_GCF_051617105.1_2x sul1 0.26x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_wastewater_GCF_051617105.1_2x sul1 0.09x found; mix_wastewater_GCF_051617105.1_2x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_2x aadA2 0.73x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_2x sul1 0.10x found; mix_wastewater_GCF_051617105.1_8x sul1 0.51x found; mix_wastewater_GCF_051617105.1_8x sul1 0.16x found; mix_wastewater_GCF_051617105.1_8x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_8x sul1 0.31x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 100 of 109 within 1.5x; 8x mixtures 190 of 200 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051561185.1 1.03, GCF_051562295.1 1.08, GCF_051617105.1 1.06.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051561185.1 1.06, GCF_051562295.1 1.04, GCF_051617105.1 1.05.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 855 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 6 detection(s): mix_gut_GCF_051561185.1_0.5x adeF (5 reads); mix_gut_GCF_051561185.1_2x adeF (5 reads); mix_gut_GCF_051561185.1_8x adeF (5 reads); mix_gut_GCF_051617105.1_0.5x adeF (5 reads); mix_gut_GCF_051617105.1_2x adeF (5 reads); mix_gut_GCF_051617105.1_8x adeF (5 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 3 unexplained.

Missed truth loci (marked depths):

- mix_gut_GCF_051561185.1_2x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_gut_GCF_051561185.1_8x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_gut_GCF_051562295.1_2x: mdtG (GCF_051562295.1:NZ_CP196259.1:526234-527460)
- mix_gut_GCF_051562295.1_2x: ugd (GCF_051562295.1:NZ_CP196259.1:4532184-4533350)
- mix_gut_GCF_051562295.1_8x: ugd (GCF_051562295.1:NZ_CP196259.1:4532184-4533350)
- mix_gut_GCF_051617105.1_2x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)
- mix_gut_GCF_051617105.1_2x: AAC(3)-IId (GCF_051617105.1:NZ_CP196295.1:266063-266923)
- mix_gut_GCF_051617105.1_8x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)
- mix_wastewater_GCF_051561185.1_2x: msbA (GCF_051561185.1:NZ_CP196253.1:3746863-3748611)
- mix_wastewater_GCF_051562295.1_2x: msbA (GCF_051562295.1:NZ_CP196259.1:690658-692406)
- mix_wastewater_GCF_051562295.1_2x: ugd (GCF_051562295.1:NZ_CP196259.1:4532184-4533350)
- mix_wastewater_GCF_051562295.1_8x: ugd (GCF_051562295.1:NZ_CP196259.1:4532184-4533350)
- mix_wastewater_GCF_051617105.1_2x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)
- mix_wastewater_GCF_051617105.1_2x: msbA (GCF_051617105.1:NZ_CP196294.1:4848162-4849910)
- mix_wastewater_GCF_051617105.1_8x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)

Unexplained detected genes:

- mix_gut_GCF_051617105.1_0.5x: bacA (4 reads, 37.7% covered; undecaprenyl pyrophosphate related proteins)
- mix_gut_GCF_051617105.1_2x: bacA (15 reads, 100.0% covered; undecaprenyl pyrophosphate related proteins)
- pure_GCF_051561185.1: ANT(3'')-II-AAC(6')-IId bifunctional protein (2 reads, 10.6% covered; aminoglycoside bifunctional resistance protein)

Outside the accuracy limit:

- pure_GCF_051561185.1: AAC(6')-Ib10, observed 0.308, truth 0.0823 (ratio 3.74, limit 1.5x)
- pure_GCF_051617105.1: Klebsiella pneumoniae OmpK37, observed 0, truth 0.132 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051561185.1_8x: oqxA, observed 0, truth 0.00774 (ratio 0.00, limit 2x)
- mix_gut_GCF_051561185.1_8x: AAC(6')-Ib10, observed 0.0208, truth 0.00389 (ratio 5.34, limit 2x)
- mix_gut_GCF_051562295.1_8x: ugd, observed 0, truth 0.00831 (ratio 0.00, limit 2x)
- mix_gut_GCF_051617105.1_8x: Klebsiella pneumoniae OmpK37, observed 0, truth 0.00861 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051562295.1_8x: ugd, observed 0, truth 0.0215 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051617105.1_8x: Klebsiella pneumoniae OmpK37, observed 0, truth 0.0221 (ratio 0.00, limit 2x)
