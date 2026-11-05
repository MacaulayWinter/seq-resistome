# Validation V1 round 2: marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15** (listed in protein_only_hits.tsv): GCF_051563005.1 vanG; GCF_051563005.1 Klebsiella pneumoniae KpnF; GCF_051563005.1 Klebsiella pneumoniae KpnE; GCF_051563005.1 ArnT; GCF_051563005.1 rsmA; GCF_051617875.1 Klebsiella pneumoniae KpnF; GCF_051617875.1 Klebsiella pneumoniae KpnE; GCF_051617875.1 vanG; GCF_051617875.1 leuO; GCF_051617875.1 ArnT; GCF_051617875.1 rsmA; GCF_051619525.1 leuO; GCF_051619525.1 qacG; GCF_051619525.1 rsmA; GCF_051619525.1 vanG.

Scored from `results` (pipeline results) and `truth` (truth).

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 348 of 352 truth genes found (same ARO or same AMR gene family); exact ARO 297 of 352 |
| 2. Specificity | **FAIL** | 9 unexplained families in 24 samples scored |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 37 of 51 families within 1.5x; 8x mixtures 33 of 38 within 2x; ratio range 0.00-20.68 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 166 of 176 truth genes found.
- 16S copies estimated / truth on pure genomes: GCF_051563005.1 1.15, GCF_051617875.1 1.14, GCF_051619525.1 1.13.

Missed truth genes (marked depths):

- mix_gut_GCF_051563005.1_2x: CMY-181 (CMY beta-lactamase)
- mix_gut_GCF_051563005.1_8x: CMY-181 (CMY beta-lactamase)
- mix_wastewater_GCF_051563005.1_2x: CMY-181 (CMY beta-lactamase)
- mix_wastewater_GCF_051563005.1_8x: CMY-181 (CMY beta-lactamase)

Unexplained families:

- mix_gut_GCF_051617875.1_0.5x: aminoglycoside bifunctional resistance protein (AAC(3)-Ib/AAC(6')-Ib3 bifunctional protein)
- mix_gut_GCF_051619525.1_0.5x: aminoglycoside bifunctional resistance protein (ANT(3'')-II-AAC(6')-IId bifunctional protein)
- mix_gut_GCF_051619525.1_2x: aminoglycoside bifunctional resistance protein (AAC(3)-Ib/AAC(6')-Ib3 bifunctional protein)
- mix_wastewater_GCF_051563005.1_0.5x: EC beta-lactamase (EC-5)
- mix_wastewater_GCF_051563005.1_2x: EC beta-lactamase (EC-5)
- mix_wastewater_GCF_051563005.1_8x: EC beta-lactamase (EC-5)
- pure_GCF_051563005.1: EC beta-lactamase (EC-5)
- pure_GCF_051563005.1: rifamycin-resistant beta-subunit of RNA polymerase (rpoB) (Bifidobacterium adolescentis rpoB mutants conferring resistance to rifampicin)
- pure_GCF_051619525.1: rifamycin-resistant beta-subunit of RNA polymerase (rpoB) (Bifidobacterium adolescentis rpoB mutants conferring resistance to rifampicin)

Outside the accuracy limit:

- pure_GCF_051563005.1: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump, observed 2.95, truth 0.143 (ratio 20.68, limit 1.5x)
- pure_GCF_051563005.1: CMY beta-lactamase, observed 0, truth 0.143 (ratio 0.00, limit 1.5x)
- pure_GCF_051563005.1: major facilitator superfamily (MFS) antibiotic efflux pump, observed 0, truth 1.57 (ratio 0.00, limit 1.5x)
- pure_GCF_051563005.1: major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 1.06, truth 0.286 (ratio 3.70, limit 1.5x)
- pure_GCF_051563005.1: resistance-nodulation-cell division (RND) antibiotic efflux pump, observed 0, truth 1.43 (ratio 0.00, limit 1.5x)
- pure_GCF_051563005.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0, truth 0.571 (ratio 0.00, limit 1.5x)
- pure_GCF_051617875.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0465, truth 0.125 (ratio 0.37, limit 1.5x)
- pure_GCF_051617875.1: chloramphenicol acetyltransferase (CAT), observed 0.207, truth 0.125 (ratio 1.66, limit 1.5x)
- pure_GCF_051617875.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0643, truth 0.125 (ratio 0.51, limit 1.5x)
- pure_GCF_051617875.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0.234, truth 0.125 (ratio 1.87, limit 1.5x)
- pure_GCF_051619525.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.117, truth 0.25 (ratio 0.47, limit 1.5x)
- pure_GCF_051619525.1: General Bacterial Porin with reduced permeability to beta-lactams, observed 0.2, truth 0.125 (ratio 1.60, limit 1.5x)
- pure_GCF_051619525.1: resistance-nodulation-cell division (RND) antibiotic efflux pump, observed 0.468, truth 0.25 (ratio 1.87, limit 1.5x)
- pure_GCF_051619525.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051563005.1_8x: CMY beta-lactamase, observed 0, truth 0.0115 (ratio 0.00, limit 2x)
- mix_gut_GCF_051617875.1_8x: chloramphenicol acetyltransferase (CAT), observed 0.0259, truth 0.0113 (ratio 2.29, limit 2x)
- mix_gut_GCF_051619525.1_8x: General Bacterial Porin with reduced permeability to beta-lactams, observed 0.0241, truth 0.0113 (ratio 2.12, limit 2x)
- mix_wastewater_GCF_051563005.1_8x: CMY beta-lactamase, observed 0, truth 0.0298 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051617875.1_8x: chloramphenicol acetyltransferase (CAT), observed 0.0652, truth 0.0289 (ratio 2.26, limit 2x)
