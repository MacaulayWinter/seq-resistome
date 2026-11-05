# Validation V1 round 2: marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **17** (listed in protein_only_hits.tsv): GCF_051560495.1 vanG; GCF_051560495.1 leuO; GCF_051560495.1 rsmA; GCF_051560505.1 ArnT; GCF_051560505.1 rsmA; GCF_051560505.1 Klebsiella pneumoniae KpnF; GCF_051560505.1 Klebsiella pneumoniae KpnE; GCF_051560505.1 vanG; GCF_051560505.1 leuO; GCF_051618705.1 ArnT; GCF_051618705.1 rsmA; GCF_051618705.1 vanG; GCF_051618705.1 Klebsiella pneumoniae KpnF; GCF_051618705.1 Klebsiella pneumoniae KpnE; GCF_051620725.1 rsmA; GCF_051620725.1 leuO; GCF_051620725.1 vanG.

Scored from `results_fix` (pipeline results) and `truth` (truth).

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 474 of 476 truth genes found (same ARO or same AMR gene family); exact ARO 413 of 476 |
| 2. Specificity | **FAIL** | 3 unexplained families in 31 samples scored |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 57 of 73 families within 1.5x; 8x mixtures 60 of 63 within 2x; ratio range 0.00-5.82 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 216 of 238 truth genes found.
- 16S copies estimated / truth on pure genomes: GCF_051560495.1 1.11, GCF_051560505.1 1.07, GCF_051618705.1 1.15, GCF_051620725.1 1.09.

Missed truth genes (marked depths):

- mix_gut_GCF_051620725.1_2x: FosA6 (fosfomycin thiol transferase)
- mix_wastewater_GCF_051620725.1_2x: FosA6 (fosfomycin thiol transferase)

Unexplained families:

- mix_gut_GCF_051620725.1_2x: AAC(6') (AAC(6')-Ib7)
- mix_wastewater_GCF_051618705.1_8x: ampC-type beta-lactamase (Escherichia coli ampC beta-lactamase)
- pure_GCF_051560505.1: aminoglycoside bifunctional resistance protein (ANT(3'')-II-AAC(6')-IId bifunctional protein)

Outside the accuracy limit:

- pure_GCF_051560495.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.105, truth 0.25 (ratio 0.42, limit 1.5x)
- pure_GCF_051560495.1: General Bacterial Porin with reduced permeability to beta-lactams, observed 0.21, truth 0.125 (ratio 1.68, limit 1.5x)
- pure_GCF_051560495.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: AAC(6'), observed 0.0785, truth 0.125 (ratio 0.63, limit 1.5x)
- pure_GCF_051560505.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0369, truth 0.125 (ratio 0.29, limit 1.5x)
- pure_GCF_051560505.1: chloramphenicol acetyltransferase (CAT), observed 0.379, truth 0.25 (ratio 1.51, limit 1.5x)
- pure_GCF_051560505.1: fosfomycin thiol transferase, observed 0.0736, truth 0.125 (ratio 0.59, limit 1.5x)
- pure_GCF_051560505.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0661, truth 0.125 (ratio 0.53, limit 1.5x)
- pure_GCF_051560505.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0.256, truth 0.125 (ratio 2.05, limit 1.5x)
- pure_GCF_051618705.1: major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 2.49, truth 0.429 (ratio 5.82, limit 1.5x)
- pure_GCF_051618705.1: resistance-nodulation-cell division (RND) antibiotic efflux pump, observed 0, truth 1.43 (ratio 0.00, limit 1.5x)
- pure_GCF_051618705.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0, truth 0.571 (ratio 0.00, limit 1.5x)
- pure_GCF_051620725.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0969, truth 0.25 (ratio 0.39, limit 1.5x)
- pure_GCF_051620725.1: General Bacterial Porin with reduced permeability to beta-lactams, observed 0.225, truth 0.125 (ratio 1.80, limit 1.5x)
- pure_GCF_051620725.1: major facilitator superfamily (MFS) antibiotic efflux pump, observed 0.124, truth 0.25 (ratio 0.50, limit 1.5x)
- pure_GCF_051620725.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051560495.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0135, truth 0.0296 (ratio 0.46, limit 2x)
- mix_gut_GCF_051560505.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.00531, truth 0.0148 (ratio 0.36, limit 2x)
- mix_gut_GCF_051620725.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0131, truth 0.0296 (ratio 0.44, limit 2x)
