# Validation V1 round 3 (by location): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051559745.1 Klebsiella pneumoniae KpnE; GCF_051559745.1 Klebsiella pneumoniae KpnF; GCF_051559745.1 vanG; GCF_051559745.1 rsmA; GCF_051559745.1 ArnT; GCF_051563765.1 vanG; GCF_051563765.1 Klebsiella pneumoniae KpnF; GCF_051563765.1 Klebsiella pneumoniae KpnE; GCF_051563765.1 ArnT; GCF_051563765.1 rsmA; GCF_051618695.1 ArnT; GCF_051618695.1 Klebsiella pneumoniae KpnE; GCF_051618695.1 Klebsiella pneumoniae KpnF; GCF_051618695.1 vanG; GCF_051618695.1 rsmA.

Scored from `results`; 136 truth loci in 136 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 543 of 544 truth loci found; exact ARO 532 |
| 2. Specificity | **FAIL** | 22 unexplained of 2337 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 132 of 136 groups within 1.5x; 8x mixtures 222 of 222 within 2x; ratio range 0.53-1.66 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 227 of 272 truth loci found.
- 16S copies estimated / truth on pure genomes: GCF_051559745.1 1.05, GCF_051563765.1 1.10, GCF_051618695.1 1.07.

Missed truth loci (marked depths):

- mix_wastewater_GCF_051563765.1_2x: EC-5 (GCF_051563765.1:NZ_CP196265.1:534491-535624)

Unexplained detected genes:

- mix_gut_GCF_051559745.1_0.5x: LptD (9 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051559745.1_0.5x: MdtK (2 reads, 20.4% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051559745.1_2x: LptD (10 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051559745.1_2x: MdtK (2 reads, 20.4% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051563765.1_0.5x: LptD (2 reads, 7.7% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051563765.1_2x: eptB (10 reads, 31.5% covered; pmr phosphoethanolamine transferase)
- mix_gut_GCF_051563765.1_2x: LptD (9 reads, 31.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_0.5x: LptD (3 reads, 19.1% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_0.5x: MdtK (2 reads, 17.8% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618695.1_2x: LptD (12 reads, 48.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_2x: eptB (4 reads, 24.8% covered; pmr phosphoethanolamine transferase)
- mix_gut_GCF_051618695.1_2x: MdtK (3 reads, 23.0% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618695.1_8x: LptD (59 reads, 57.9% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_8x: eptB (7 reads, 27.1% covered; pmr phosphoethanolamine transferase)
- mix_wastewater_GCF_051559745.1_0.5x: LptD (9 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051559745.1_2x: LptD (10 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051563765.1_0.5x: LptD (2 reads, 7.7% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051563765.1_2x: LptD (9 reads, 31.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_0.5x: LptD (3 reads, 19.1% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_2x: LptD (12 reads, 48.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_8x: LptD (59 reads, 57.9% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- pure_GCF_051618695.1: LptD (68 reads, 59.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)

Outside the accuracy limit:

- pure_GCF_051559745.1: H-NS, observed 0.23, truth 0.143 (ratio 1.61, limit 1.5x)
- pure_GCF_051559745.1: CMY-181, observed 0.0945, truth 0.143 (ratio 0.66, limit 1.5x)
- pure_GCF_051559745.1: mdtE, observed 0.0768, truth 0.143 (ratio 0.54, limit 1.5x)
- pure_GCF_051618695.1: QnrS1, observed 0.215, truth 0.143 (ratio 1.51, limit 1.5x)
