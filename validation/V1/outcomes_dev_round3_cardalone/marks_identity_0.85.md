# Validation V1 round 3 (by location): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051559745.1 Klebsiella pneumoniae KpnE; GCF_051559745.1 Klebsiella pneumoniae KpnF; GCF_051559745.1 vanG; GCF_051559745.1 rsmA; GCF_051559745.1 ArnT; GCF_051563765.1 vanG; GCF_051563765.1 Klebsiella pneumoniae KpnF; GCF_051563765.1 Klebsiella pneumoniae KpnE; GCF_051563765.1 ArnT; GCF_051563765.1 rsmA; GCF_051618695.1 ArnT; GCF_051618695.1 Klebsiella pneumoniae KpnE; GCF_051618695.1 Klebsiella pneumoniae KpnF; GCF_051618695.1 vanG; GCF_051618695.1 rsmA.

Scored from `dev20c_t0.85`; 136 truth loci in 136 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 543 of 544 truth loci found; exact ARO 532 |
| 2. Specificity | **FAIL** | 1 unexplained of 2126 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 131 of 136 groups within 1.5x; 8x mixtures 227 of 227 within 2x; ratio range 0.52-1.47 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 221 of 272 truth loci found.
- 16S copies estimated / truth on pure genomes: GCF_051559745.1 1.05, GCF_051563765.1 1.09, GCF_051618695.1 1.07.

Missed truth loci (marked depths):

- mix_wastewater_GCF_051563765.1_2x: EC-5 (GCF_051563765.1:NZ_CP196265.1:534491-535624)

Unexplained detected genes:

- mix_wastewater_GCF_051618695.1_8x: OXA-1307 (2 reads, 28.2% covered; OXA-48-like beta-lactamase)

Outside the accuracy limit:

- pure_GCF_051559745.1: CMY-181, observed 0.0894, truth 0.143 (ratio 0.63, limit 1.5x)
- pure_GCF_051559745.1: mdtE, observed 0.0742, truth 0.143 (ratio 0.52, limit 1.5x)
- pure_GCF_051618695.1: gadX, observed 0.0932, truth 0.143 (ratio 0.65, limit 1.5x)
- pure_GCF_051618695.1: AcrS, observed 0.0944, truth 0.143 (ratio 0.66, limit 1.5x)
- pure_GCF_051618695.1: Escherichia coli emrE, observed 0.0813, truth 0.143 (ratio 0.57, limit 1.5x)
