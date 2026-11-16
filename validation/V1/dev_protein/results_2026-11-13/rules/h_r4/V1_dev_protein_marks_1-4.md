# Protein mode, DEVELOPMENT scoring on a seen V1 round (not validation): marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 6 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051561185.1 adeF; GCF_051561185.1 ArnT; GCF_051561185.1 rsmA; GCF_051561185.1 Klebsiella pneumoniae KpnF; GCF_051561185.1 Klebsiella pneumoniae KpnE; GCF_051561185.1 vanG; GCF_051561185.1 leuO; GCF_051562295.1 vanG; GCF_051562295.1 rsmA; GCF_051562295.1 ArnT; GCF_051562295.1 Klebsiella pneumoniae KpnE; GCF_051562295.1 Klebsiella pneumoniae KpnF; GCF_051617105.1 vanG; GCF_051617105.1 leuO; GCF_051617105.1 rsmA.

Scored from `rule_h_r4`; 136 truth loci in 109 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 455 of 474 truth loci found; exact ARO 416 |
| 2. Specificity | **FAIL** | 3 unexplained of 1296 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 100 of 109 groups within 1.5x; 8x mixtures 194 of 204 within 2x; ratio range 0.00-4.28 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 189 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 70, of which 59 found: mix_gut_GCF_051561185.1_2x emrR 0.93x found; mix_gut_GCF_051561185.1_2x sul1 0.18x found; mix_gut_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x arr-3 0.02x missed; mix_gut_GCF_051561185.1_2x catB3 0.26x found; mix_gut_GCF_051561185.1_2x SHV-12 0.54x missed; mix_gut_GCF_051561185.1_2x sul1 0.00x found; mix_gut_GCF_051561185.1_2x sul1 0.05x found; mix_gut_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_gut_GCF_051561185.1_8x sul1 0.74x found; mix_gut_GCF_051561185.1_8x sul1 0.35x found; mix_gut_GCF_051561185.1_8x catB3 0.91x found; mix_gut_GCF_051561185.1_8x sul1 0.00x found; mix_gut_GCF_051561185.1_8x sul1 0.33x found; mix_gut_GCF_051562295.1_2x mdtM 0.84x found; mix_gut_GCF_051562295.1_2x gadX 0.90x missed; mix_gut_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_gut_GCF_051617105.1_2x CRP 0.93x found; mix_gut_GCF_051617105.1_2x marA 0.61x missed; mix_gut_GCF_051617105.1_2x SHV-12 0.95x missed; mix_gut_GCF_051617105.1_2x arr-3 0.66x found; mix_gut_GCF_051617105.1_2x dfrA19 0.62x found; mix_gut_GCF_051617105.1_2x sul1 0.26x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_gut_GCF_051617105.1_2x sul1 0.09x found; mix_gut_GCF_051617105.1_2x OXA-1 0.00x found; mix_gut_GCF_051617105.1_2x aadA2 0.73x found; mix_gut_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_2x sul1 0.10x found; mix_gut_GCF_051617105.1_8x sul1 0.51x found; mix_gut_GCF_051617105.1_8x sul1 0.16x found; mix_gut_GCF_051617105.1_8x OXA-1 0.00x found; mix_gut_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_gut_GCF_051617105.1_8x sul1 0.31x found; mix_wastewater_GCF_051561185.1_2x emrR 0.93x found; mix_wastewater_GCF_051561185.1_2x sul1 0.18x found; mix_wastewater_GCF_051561185.1_2x qacEdelta1 0.47x found; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x arr-3 0.02x missed; mix_wastewater_GCF_051561185.1_2x catB3 0.26x found; mix_wastewater_GCF_051561185.1_2x SHV-12 0.54x missed; mix_wastewater_GCF_051561185.1_2x sul1 0.00x found; mix_wastewater_GCF_051561185.1_2x sul1 0.05x found; mix_wastewater_GCF_051561185.1_2x AAC(3)-IId 0.44x found; mix_wastewater_GCF_051561185.1_8x sul1 0.74x found; mix_wastewater_GCF_051561185.1_8x sul1 0.35x found; mix_wastewater_GCF_051561185.1_8x catB3 0.91x found; mix_wastewater_GCF_051561185.1_8x sul1 0.00x found; mix_wastewater_GCF_051561185.1_8x sul1 0.33x found; mix_wastewater_GCF_051562295.1_2x mdtM 0.84x found; mix_wastewater_GCF_051562295.1_2x gadX 0.90x missed; mix_wastewater_GCF_051562295.1_2x Escherichia coli emrE 0.03x missed; mix_wastewater_GCF_051617105.1_2x CRP 0.93x found; mix_wastewater_GCF_051617105.1_2x marA 0.61x missed; mix_wastewater_GCF_051617105.1_2x SHV-12 0.95x found; mix_wastewater_GCF_051617105.1_2x arr-3 0.66x found; mix_wastewater_GCF_051617105.1_2x dfrA19 0.62x found; mix_wastewater_GCF_051617105.1_2x sul1 0.26x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.22x found; mix_wastewater_GCF_051617105.1_2x sul1 0.09x found; mix_wastewater_GCF_051617105.1_2x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_2x aadA2 0.73x found; mix_wastewater_GCF_051617105.1_2x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_2x sul1 0.10x found; mix_wastewater_GCF_051617105.1_8x sul1 0.51x found; mix_wastewater_GCF_051617105.1_8x sul1 0.16x found; mix_wastewater_GCF_051617105.1_8x OXA-1 0.00x found; mix_wastewater_GCF_051617105.1_8x qacEdelta1 0.00x found; mix_wastewater_GCF_051617105.1_8x sul1 0.31x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 92 of 109 within 1.5x; 8x mixtures 187 of 204 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051561185.1 1.03, GCF_051562295.1 1.08, GCF_051617105.1 1.06.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051561185.1 1.06, GCF_051562295.1 1.04, GCF_051617105.1 1.05.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 734 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 6 detection(s): mix_gut_GCF_051561185.1_0.5x adeF (4 reads); mix_gut_GCF_051561185.1_2x adeF (4 reads); mix_gut_GCF_051561185.1_8x adeF (4 reads); mix_gut_GCF_051617105.1_0.5x adeF (4 reads); mix_gut_GCF_051617105.1_2x adeF (4 reads); mix_gut_GCF_051617105.1_8x adeF (4 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 3 unexplained.

Missed truth loci (marked depths):

- mix_gut_GCF_051561185.1_2x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_gut_GCF_051561185.1_2x: Shigella flexneri acrA (GCF_051561185.1:NZ_CP196253.1:4252688-4253881)
- mix_gut_GCF_051561185.1_2x: FosA2 (GCF_051561185.1:NZ_CP196253.1:4770800-4771225)
- mix_gut_GCF_051561185.1_2x: CTX-M-9 (GCF_051561185.1:NZ_CP196254.1:230081-230956)
- mix_gut_GCF_051561185.1_8x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_gut_GCF_051561185.1_8x: Shigella flexneri acrA (GCF_051561185.1:NZ_CP196253.1:4252688-4253881)
- mix_gut_GCF_051562295.1_8x: CMY-181 (GCF_051562295.1:NZ_CP196259.1:1979508-1980512)
- mix_gut_GCF_051617105.1_2x: SHV-1 (GCF_051617105.1:NZ_CP196294.1:4233508-4234368)
- mix_gut_GCF_051617105.1_2x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)
- mix_gut_GCF_051617105.1_2x: AAC(3)-IId (GCF_051617105.1:NZ_CP196295.1:266063-266923)
- mix_wastewater_GCF_051561185.1_2x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_wastewater_GCF_051561185.1_2x: Shigella flexneri acrA (GCF_051561185.1:NZ_CP196253.1:4252688-4253881)
- mix_wastewater_GCF_051561185.1_2x: FosA2 (GCF_051561185.1:NZ_CP196253.1:4770800-4771225)
- mix_wastewater_GCF_051561185.1_2x: CTX-M-9 (GCF_051561185.1:NZ_CP196254.1:230081-230956)
- mix_wastewater_GCF_051561185.1_8x: ACT-17 (GCF_051561185.1:NZ_CP196253.1:153570-154817)
- mix_wastewater_GCF_051561185.1_8x: oqxA (GCF_051561185.1:NZ_CP196253.1:2074387-2075562)
- mix_wastewater_GCF_051561185.1_8x: Shigella flexneri acrA (GCF_051561185.1:NZ_CP196253.1:4252688-4253881)
- mix_wastewater_GCF_051562295.1_8x: CMY-181 (GCF_051562295.1:NZ_CP196259.1:1979508-1980512)
- mix_wastewater_GCF_051617105.1_2x: Klebsiella pneumoniae OmpK37 (GCF_051617105.1:NZ_CP196294.1:4402951-4404105)

Unexplained detected genes:

- mix_gut_GCF_051617105.1_2x: bacA (8 reads, 62.3% covered; undecaprenyl pyrophosphate related proteins)
- mix_wastewater_GCF_051617105.1_0.5x: AcrF (2 reads, 9.7% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- mix_wastewater_GCF_051617105.1_2x: bacA (8 reads, 62.3% covered; undecaprenyl pyrophosphate related proteins)

Outside the accuracy limit:

- pure_GCF_051561185.1: ACT-17, observed 0, truth 0.163 (ratio 0.00, limit 1.5x)
- pure_GCF_051561185.1: emrR, observed 0.0872, truth 0.135 (ratio 0.65, limit 1.5x)
- pure_GCF_051561185.1: oqxA, observed 0, truth 0.128 (ratio 0.00, limit 1.5x)
- pure_GCF_051561185.1: marA, observed 0.0771, truth 0.118 (ratio 0.65, limit 1.5x)
- pure_GCF_051561185.1: Shigella flexneri acrA, observed 0, truth 0.106 (ratio 0.00, limit 1.5x)
- pure_GCF_051561185.1: AAC(6')-Ib10, observed 0.295, truth 0.0823 (ratio 3.59, limit 1.5x)
- pure_GCF_051561185.1: SHV-12, observed 0.0503, truth 0.123 (ratio 0.41, limit 1.5x)
- pure_GCF_051562295.1: CMY-181, observed 0.0772, truth 0.12 (ratio 0.65, limit 1.5x)
- pure_GCF_051617105.1: Klebsiella pneumoniae KpnH, observed 0.0573, truth 0.107 (ratio 0.53, limit 1.5x)
- mix_gut_GCF_051561185.1_8x: oqxA, observed 0, truth 0.00774 (ratio 0.00, limit 2x)
- mix_gut_GCF_051561185.1_8x: Shigella flexneri acrA, observed 0, truth 0.00744 (ratio 0.00, limit 2x)
- mix_gut_GCF_051561185.1_8x: CTX-M-9, observed 0.00216, truth 0.00661 (ratio 0.33, limit 2x)
- mix_gut_GCF_051561185.1_8x: AAC(6')-Ib10, observed 0.0166, truth 0.00389 (ratio 4.28, limit 2x)
- mix_gut_GCF_051562295.1_8x: CMY-181, observed 0, truth 0.00778 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: ACT-17, observed 0, truth 0.0282 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: oqxA, observed 0, truth 0.02 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: Shigella flexneri acrA, observed 0, truth 0.0192 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051561185.1_8x: CTX-M-9, observed 0.00556, truth 0.0171 (ratio 0.32, limit 2x)
- mix_wastewater_GCF_051562295.1_8x: CMY-181, observed 0, truth 0.0201 (ratio 0.00, limit 2x)
