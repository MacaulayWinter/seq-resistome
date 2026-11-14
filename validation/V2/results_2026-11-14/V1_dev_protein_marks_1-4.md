# Protein mode, DEVELOPMENT scoring on a seen V1 round (not validation): marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 7 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **12**: GCF_052055575.2 vanY gene in vanB cluster; GCF_062052425.1 vanW gene in vanG cluster; GCF_062052425.1 ArnT; GCF_062052425.1 qacJ; GCF_062075917.1 ArnT; GCF_062075917.1 Klebsiella pneumoniae KpnF; GCF_062075917.1 Klebsiella pneumoniae KpnE; GCF_062075917.1 mdtG; GCF_062075917.1 Escherichia coli mdfA; GCF_062075917.1 kdpE; GCF_062075917.1 vanG; GCF_062075917.1 leuO.

Scored from `results`; 101 truth loci in 98 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 379 of 388 truth loci found; exact ARO 363 |
| 2. Specificity | **FAIL** | 14 unexplained of 1339 detected genes in 31 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 96 of 98 groups within 1.5x; 8x mixtures 179 of 185 within 2x; ratio range 0.00-5.93 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 159 of 202 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 16, of which 14 found: mix_gut_GCF_052055575.2_2x vanX gene in vanB cluster 0.74x found; mix_gut_GCF_052055575.2_2x AAC(6')-Ie-APH(2'')-Ia bifunctional protein 0.76x found; mix_gut_GCF_062052425.1_2x MexJ 0.84x found; mix_gut_GCF_062052425.1_2x OprN 0.63x found; mix_gut_GCF_062052425.1_2x MexE 0.80x found; mix_gut_GCF_062075456.1_2x ANT(3'')-IIa 0.73x found; mix_gut_GCF_062075456.1_2x AAC(3)-IIe 0.60x found; mix_gut_GCF_062075456.1_2x abeS 0.03x missed; mix_wastewater_GCF_052055575.2_2x vanX gene in vanB cluster 0.74x found; mix_wastewater_GCF_052055575.2_2x AAC(6')-Ie-APH(2'')-Ia bifunctional protein 0.76x found; mix_wastewater_GCF_062052425.1_2x MexJ 0.84x found; mix_wastewater_GCF_062052425.1_2x OprN 0.63x found; mix_wastewater_GCF_062052425.1_2x MexE 0.80x found; mix_wastewater_GCF_062075456.1_2x ANT(3'')-IIa 0.73x found; mix_wastewater_GCF_062075456.1_2x AAC(3)-IIe 0.60x found; mix_wastewater_GCF_062075456.1_2x abeS 0.03x missed.
- Mark 3 against the nominal truth (round 3's): pure genomes 94 of 98 within 1.5x; 8x mixtures 179 of 185 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_052055575.2 1.05, GCF_062052425.1 0.96, GCF_062075456.1 1.10, GCF_062075917.1 1.13.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_052055575.2 1.05, GCF_062052425.1 1.02, GCF_062075456.1 1.00, GCF_062075917.1 1.04.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 798 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 7 detection(s): mix_gut_GCF_062075917.1_0.5x kdpE (6 reads); mix_gut_GCF_062075917.1_2x kdpE (10 reads); mix_gut_GCF_062075917.1_8x kdpE (28 reads); mix_wastewater_GCF_062075917.1_0.5x kdpE (6 reads); mix_wastewater_GCF_062075917.1_2x kdpE (10 reads); mix_wastewater_GCF_062075917.1_8x kdpE (28 reads); pure_GCF_062075917.1 kdpE (42 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 21 unexplained.

Missed truth loci (marked depths):

- mix_gut_GCF_062075917.1_2x: rsmA (GCF_062075917.1:NZ_CM206596.1:1031120-1031305)
- mix_gut_GCF_062075917.1_8x: rsmA (GCF_062075917.1:NZ_CM206596.1:1031120-1031305)
- mix_wastewater_GCF_062075917.1_2x: rsmA (GCF_062075917.1:NZ_CM206596.1:1031120-1031305)
- mix_wastewater_GCF_062075917.1_2x: PmrF (GCF_062075917.1:NZ_CM206596.1:1561127-1562110)
- mix_wastewater_GCF_062075917.1_2x: mdtB (GCF_062075917.1:NZ_CM206596.1:1760627-1763749)
- mix_wastewater_GCF_062075917.1_2x: msbA (GCF_062075917.1:NZ_CM206596.1:3054027-3055775)
- mix_wastewater_GCF_062075917.1_8x: rsmA (GCF_062075917.1:NZ_CM206596.1:1031120-1031305)
- mix_wastewater_GCF_062075917.1_8x: PmrF (GCF_062075917.1:NZ_CM206596.1:1561127-1562110)
- mix_wastewater_GCF_062075917.1_8x: mdtB (GCF_062075917.1:NZ_CM206596.1:1760627-1763749)

Unexplained detected genes:

- mix_gut_GCF_052055575.2_0.5x: IreK (3 reads, 9.3% covered; Serine/threonine kinases)
- mix_gut_GCF_052055575.2_2x: IreK (3 reads, 9.3% covered; Serine/threonine kinases)
- mix_gut_GCF_062075917.1_2x: MdtK (8 reads, 51.7% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_062075917.1_0.5x: MdtK (10 reads, 77.6% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_062075917.1_0.5x: mdtA (3 reads, 35.2% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- mix_wastewater_GCF_062075917.1_2x: mdtA (13 reads, 68.9% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- mix_wastewater_GCF_062075917.1_2x: MdtK (8 reads, 51.7% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_062075917.1_2x: ramA (8 reads, 94.4% covered; General Bacterial Porin with reduced permeability to beta-lactams;antibiotic efflux regulatory protein;resistance-nodulation-cell division (RND) antibiotic efflux pump)
- mix_wastewater_GCF_062075917.1_2x: AcrE (3 reads, 28.1% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- mix_wastewater_GCF_062075917.1_2x: Klebsiella pneumoniae acrA (2 reads, 21.4% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- pure_GCF_062075917.1: AcrF (152 reads, 85.8% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- pure_GCF_062075917.1: mdtH (77 reads, 100.0% covered; major facilitator superfamily (MFS) antibiotic efflux pump)
- pure_GCF_062075917.1: mdtA (58 reads, 94.5% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- pure_GCF_062075917.1: Klebsiella pneumoniae KpnG (36 reads, 64.4% covered; major facilitator superfamily (MFS) antibiotic efflux pump)

Outside the accuracy limit:

- pure_GCF_052055575.2: AAC(6')-Ie-APH(2'')-Ia bifunctional protein, observed 0.255, truth 0.0453 (ratio 5.62, limit 1.5x)
- pure_GCF_062075917.1: rsmA, observed 0, truth 0.076 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_052055575.2_8x: AAC(6')-Ie-APH(2'')-Ia bifunctional protein, observed 0.083, truth 0.014 (ratio 5.93, limit 2x)
- mix_gut_GCF_062075917.1_8x: rsmA, observed 0, truth 0.0274 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_052055575.2_8x: AAC(6')-Ie-APH(2'')-Ia bifunctional protein, observed 0.115, truth 0.0194 (ratio 5.91, limit 2x)
- mix_wastewater_GCF_062075917.1_8x: rsmA, observed 0, truth 0.0367 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_062075917.1_8x: PmrF, observed 0, truth 0.0402 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_062075917.1_8x: mdtB, observed 0, truth 0.041 (ratio 0.00, limit 2x)
