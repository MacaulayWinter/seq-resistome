# Validation V1 round 3 (by location): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **17**: GCF_051560495.1 vanG; GCF_051560495.1 leuO; GCF_051560495.1 rsmA; GCF_051560505.1 ArnT; GCF_051560505.1 rsmA; GCF_051560505.1 Klebsiella pneumoniae KpnF; GCF_051560505.1 Klebsiella pneumoniae KpnE; GCF_051560505.1 vanG; GCF_051560505.1 leuO; GCF_051618705.1 ArnT; GCF_051618705.1 rsmA; GCF_051618705.1 vanG; GCF_051618705.1 Klebsiella pneumoniae KpnF; GCF_051618705.1 Klebsiella pneumoniae KpnE; GCF_051620725.1 rsmA; GCF_051620725.1 leuO; GCF_051620725.1 vanG.

Scored from `results_fix`; 125 truth loci in 118 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 486 of 500 truth loci found; exact ARO 429 |
| 2. Specificity | **FAIL** | 27 unexplained of 2738 detected genes in 31 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 101 of 118 groups within 1.5x; 8x mixtures 182 of 195 within 2x; ratio range 0.00-2.00 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 198 of 250 truth loci found.
- 16S copies estimated / truth on pure genomes: GCF_051560495.1 1.11, GCF_051560505.1 1.07, GCF_051618705.1 1.15, GCF_051620725.1 1.09.

Missed truth loci (marked depths):

- mix_gut_GCF_051560495.1_2x: msbA (GCF_051560495.1:NZ_CP196279.1:683759-685507)
- mix_gut_GCF_051560495.1_2x: marA (GCF_051560495.1:NZ_CP196279.1:5222013-5222387)
- mix_gut_GCF_051560495.1_8x: Klebsiella pneumoniae KpnH (GCF_051560495.1:NZ_CP196279.1:3708486-3710024)
- mix_gut_GCF_051560495.1_8x: marA (GCF_051560495.1:NZ_CP196279.1:5222013-5222387)
- mix_gut_GCF_051620725.1_2x: marA (GCF_051620725.1:NZ_CP196330.1:656638-657012)
- mix_gut_GCF_051620725.1_2x: FosA6 (GCF_051620725.1:NZ_CP196330.1:4014317-4014736)
- mix_gut_GCF_051620725.1_8x: marA (GCF_051620725.1:NZ_CP196330.1:656638-657012)
- mix_gut_GCF_051620725.1_8x: Klebsiella pneumoniae KpnH (GCF_051620725.1:NZ_CP196330.1:2150935-2152473)
- mix_gut_GCF_051620725.1_8x: msbA (GCF_051620725.1:NZ_CP196330.1:5159505-5161253)
- mix_wastewater_GCF_051560495.1_2x: marA (GCF_051560495.1:NZ_CP196279.1:5222013-5222387)
- mix_wastewater_GCF_051560495.1_8x: marA (GCF_051560495.1:NZ_CP196279.1:5222013-5222387)
- mix_wastewater_GCF_051620725.1_2x: marA (GCF_051620725.1:NZ_CP196330.1:656638-657012)
- mix_wastewater_GCF_051620725.1_2x: FosA6 (GCF_051620725.1:NZ_CP196330.1:4014317-4014736)
- mix_wastewater_GCF_051620725.1_8x: marA (GCF_051620725.1:NZ_CP196330.1:656638-657012)

Unexplained detected genes:

- mix_gut_GCF_051560495.1_0.5x: YojI (2 reads, 18.2% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051560495.1_2x: YojI (6 reads, 26.3% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051560505.1_2x: Klebsiella pneumoniae OmpK37 (18 reads, 61.8% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- mix_gut_GCF_051560505.1_2x: LptD (7 reads, 24.7% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051560505.1_2x: YojI (6 reads, 29.0% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051560505.1_2x: Klebsiella pneumoniae KpnE (3 reads, 51.8% covered; small multidrug resistance (SMR) antibiotic efflux pump)
- mix_gut_GCF_051560505.1_8x: Klebsiella pneumoniae OmpK37 (60 reads, 63.9% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- mix_gut_GCF_051560505.1_8x: Klebsiella pneumoniae KpnE (6 reads, 51.8% covered; small multidrug resistance (SMR) antibiotic efflux pump)
- mix_gut_GCF_051560505.1_8x: MdtK (3 reads, 14.6% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618705.1_2x: LptD (11 reads, 40.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618705.1_2x: MdtK (3 reads, 14.5% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618705.1_8x: LptD (39 reads, 56.8% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051620725.1_2x: AAC(6')-Ib7 (3 reads, 28.5% covered; AAC(6'))
- mix_wastewater_GCF_051560505.1_2x: Klebsiella pneumoniae OmpK37 (18 reads, 61.8% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- mix_wastewater_GCF_051560505.1_2x: Klebsiella pneumoniae KpnE (4 reads, 51.8% covered; small multidrug resistance (SMR) antibiotic efflux pump)
- mix_wastewater_GCF_051560505.1_8x: Klebsiella pneumoniae OmpK37 (60 reads, 63.9% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- mix_wastewater_GCF_051560505.1_8x: Klebsiella pneumoniae KpnE (7 reads, 51.8% covered; small multidrug resistance (SMR) antibiotic efflux pump)
- mix_wastewater_GCF_051560505.1_8x: MdtK (3 reads, 14.6% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_051618705.1_2x: MdtK (3 reads, 14.5% covered; multidrug and toxic compound extrusion (MATE) transporter)
- pure_GCF_051560495.1: arnA (31 reads, 49.4% covered; pmr phosphoethanolamine transferase)
- pure_GCF_051560495.1: mdtG (7 reads, 30.1% covered; major facilitator superfamily (MFS) antibiotic efflux pump)
- pure_GCF_051560505.1: Klebsiella pneumoniae OmpK37 (68 reads, 63.9% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- pure_GCF_051560505.1: ANT(3'')-II-AAC(6')-IId bifunctional protein (66 reads, 50.1% covered; aminoglycoside bifunctional resistance protein)
- pure_GCF_051560505.1: kdpE (10 reads, 58.1% covered; kdpDE; antibiotic efflux regulatory protein)
- pure_GCF_051560505.1: Klebsiella pneumoniae KpnE (9 reads, 51.8% covered; small multidrug resistance (SMR) antibiotic efflux pump)
- pure_GCF_051560505.1: Klebsiella pneumoniae acrA (3 reads, 18.1% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- pure_GCF_051618705.1: LptD (50 reads, 57.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)

Outside the accuracy limit:

- pure_GCF_051560495.1: Klebsiella pneumoniae OmpK37, observed 0.21, truth 0.125 (ratio 1.68, limit 1.5x)
- pure_GCF_051560495.1: Klebsiella pneumoniae KpnH, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560495.1: emrR, observed 0.041, truth 0.125 (ratio 0.33, limit 1.5x)
- pure_GCF_051560495.1: marA, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560495.1: msbA, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: emrB, observed 0.06, truth 0.125 (ratio 0.48, limit 1.5x)
- pure_GCF_051560505.1: adeF, observed 0.079, truth 0.125 (ratio 0.63, limit 1.5x)
- pure_GCF_051560505.1: CRP, observed 0.0661, truth 0.125 (ratio 0.53, limit 1.5x)
- pure_GCF_051560505.1: msbA, observed 0.0369, truth 0.125 (ratio 0.29, limit 1.5x)
- pure_GCF_051560505.1: Shigella flexneri acrA, observed 0.0817, truth 0.125 (ratio 0.65, limit 1.5x)
- pure_GCF_051560505.1: FosA2, observed 0.0736, truth 0.125 (ratio 0.59, limit 1.5x)
- pure_GCF_051618705.1: emrR, observed 0.0942, truth 0.143 (ratio 0.66, limit 1.5x)
- pure_GCF_051620725.1: emrR, observed 0.0355, truth 0.125 (ratio 0.28, limit 1.5x)
- pure_GCF_051620725.1: Klebsiella pneumoniae KpnH, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051620725.1: Klebsiella pneumoniae OmpK37, observed 0.225, truth 0.125 (ratio 1.80, limit 1.5x)
- pure_GCF_051620725.1: msbA, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051620725.1: marA, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051560495.1_8x: Klebsiella pneumoniae KpnH, observed 0, truth 0.0148 (ratio 0.00, limit 2x)
- mix_gut_GCF_051560495.1_8x: emrR, observed 0.00669, truth 0.0148 (ratio 0.45, limit 2x)
- mix_gut_GCF_051560495.1_8x: marA, observed 0, truth 0.0148 (ratio 0.00, limit 2x)
- mix_gut_GCF_051560495.1_8x: msbA, observed 0.000782, truth 0.0148 (ratio 0.05, limit 2x)
- mix_gut_GCF_051560505.1_8x: msbA, observed 0.00531, truth 0.0148 (ratio 0.36, limit 2x)
- mix_gut_GCF_051620725.1_8x: emrR, observed 0.00411, truth 0.0148 (ratio 0.28, limit 2x)
- mix_gut_GCF_051620725.1_8x: Klebsiella pneumoniae KpnH, observed 0, truth 0.0148 (ratio 0.00, limit 2x)
- mix_gut_GCF_051620725.1_8x: msbA, observed 0, truth 0.0148 (ratio 0.00, limit 2x)
- mix_gut_GCF_051620725.1_8x: marA, observed 0, truth 0.0148 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051560495.1_8x: emrR, observed 0.0128, truth 0.0289 (ratio 0.44, limit 2x)
- mix_wastewater_GCF_051560495.1_8x: marA, observed 0, truth 0.0289 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051620725.1_8x: emrR, observed 0.00784, truth 0.0289 (ratio 0.27, limit 2x)
- mix_wastewater_GCF_051620725.1_8x: marA, observed 0, truth 0.0289 (ratio 0.00, limit 2x)
