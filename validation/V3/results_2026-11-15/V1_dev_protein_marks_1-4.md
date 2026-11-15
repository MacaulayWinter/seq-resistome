# V3 protein mode, identity band: marks 1-4

Scored as V1 round 4, except PM5 (b): RGI main Perfect/Strict protein hits in the spike genome explain a detection in mark 2.

Explained as RGI main protein hits in the spike genome (PM5 b; tested after the DNA test, before the background): 4 detection(s).

Protein-only RGI hits excluded from the truth (never scored): **18**: GCF_062045445.1 adeF; GCF_062045445.1 qacJ; GCF_062064952.1 norC; GCF_062064952.1 vanT gene in vanG cluster; GCF_062066596.1 rsmA; GCF_062066596.1 ArnT; GCF_062066596.1 qacG; GCF_062066596.1 Klebsiella pneumoniae KpnF; GCF_062066596.1 FosA8; GCF_062066596.1 Klebsiella pneumoniae KpnH; GCF_062074957.1 rsmA; GCF_062074957.1 ArnT; GCF_062074957.1 PmrF; GCF_062074957.1 Klebsiella pneumoniae KpnE; GCF_062074957.1 Klebsiella pneumoniae KpnF; GCF_062074957.1 Escherichia coli mdfA; GCF_062074957.1 vanG; GCF_062074957.1 leuO.

Scored from `results`; 48 truth loci in 44 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **PASS** | 140 of 140 truth loci found; exact ARO 140 |
| 2. Specificity | **FAIL** | 9 unexplained of 1018 detected genes in 31 samples |
| 3. Accuracy, copies per 16S copy | **PASS** | pure genomes 34 of 34 groups within 1.5x; 8x mixtures 59 of 59 within 2x; ratio range 0.85-1.29; 10 group(s) with another gene copy and 17 under 92% identity not marked |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 69 of 96 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 52, of which 38 found: mix_gut_GCF_062064952.1_2x dfrG 0.00x found; mix_gut_GCF_062064952.1_2x mgrA 0.34x missed; mix_gut_GCF_062064952.1_2x mepR 0.85x found; mix_gut_GCF_062064952.1_2x dfrG 0.00x found; mix_gut_GCF_062064952.1_2x ANT(4')-Ia 0.13x missed; mix_gut_GCF_062064952.1_2x tet(45) 1.05x found; mix_gut_GCF_062064952.1_2x sdrM 2.91x found; mix_gut_GCF_062064952.1_2x fexA 0.00x found; mix_gut_GCF_062064952.1_8x dfrG 0.00x found; mix_gut_GCF_062064952.1_8x dfrG 0.00x found; mix_gut_GCF_062064952.1_8x tet(45) 6.99x found; mix_gut_GCF_062064952.1_8x sdrM 9.01x missed; mix_gut_GCF_062064952.1_8x fexA 0.00x found; mix_gut_GCF_062066596.1_2x adeF 1.55x missed; mix_gut_GCF_062066596.1_2x AAC(6')-Ic 0.43x missed; mix_gut_GCF_062066596.1_8x adeF 8.09x missed; mix_gut_GCF_062074957.1_2x APH(6)-Id 0.00x found; mix_gut_GCF_062074957.1_2x APH(3'')-Ib 0.13x found; mix_gut_GCF_062074957.1_2x kdpE 0.61x found; mix_gut_GCF_062074957.1_2x Escherichia coli acrA 2.50x found; mix_gut_GCF_062074957.1_2x adeF 2.33x found; mix_gut_GCF_062074957.1_8x APH(6)-Id 0.00x found; mix_gut_GCF_062074957.1_8x APH(3'')-Ib 0.42x found; mix_gut_GCF_062074957.1_8x kdpE 7.01x missed; mix_gut_GCF_062074957.1_8x Escherichia coli acrA 7.85x found; mix_gut_GCF_062074957.1_8x adeF 9.45x found; mix_wastewater_GCF_062064952.1_2x dfrG 0.00x found; mix_wastewater_GCF_062064952.1_2x mgrA 0.34x missed; mix_wastewater_GCF_062064952.1_2x mepR 0.85x found; mix_wastewater_GCF_062064952.1_2x dfrG 0.00x found; mix_wastewater_GCF_062064952.1_2x ANT(4')-Ia 0.13x missed; mix_wastewater_GCF_062064952.1_2x tet(45) 1.05x found; mix_wastewater_GCF_062064952.1_2x sdrM 2.91x found; mix_wastewater_GCF_062064952.1_2x fexA 0.00x found; mix_wastewater_GCF_062064952.1_8x dfrG 0.00x found; mix_wastewater_GCF_062064952.1_8x dfrG 0.00x found; mix_wastewater_GCF_062064952.1_8x tet(45) 6.99x found; mix_wastewater_GCF_062064952.1_8x sdrM 9.01x missed; mix_wastewater_GCF_062064952.1_8x fexA 0.00x found; mix_wastewater_GCF_062066596.1_2x adeF 1.55x missed; mix_wastewater_GCF_062066596.1_2x AAC(6')-Ic 0.43x missed; mix_wastewater_GCF_062066596.1_8x adeF 8.09x missed; mix_wastewater_GCF_062074957.1_2x APH(6)-Id 0.00x found; mix_wastewater_GCF_062074957.1_2x APH(3'')-Ib 0.13x found; mix_wastewater_GCF_062074957.1_2x kdpE 0.61x found; mix_wastewater_GCF_062074957.1_2x Escherichia coli acrA 2.50x found; mix_wastewater_GCF_062074957.1_2x adeF 2.33x found; mix_wastewater_GCF_062074957.1_8x APH(6)-Id 0.00x found; mix_wastewater_GCF_062074957.1_8x APH(3'')-Ib 0.42x found; mix_wastewater_GCF_062074957.1_8x kdpE 7.01x missed; mix_wastewater_GCF_062074957.1_8x Escherichia coli acrA 7.85x found; mix_wastewater_GCF_062074957.1_8x adeF 9.45x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 38 of 44 within 1.5x; 8x mixtures 70 of 76 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_062045445.1 1.10, GCF_062064952.1 1.03, GCF_062066596.1 0.95, GCF_062074957.1 1.06.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_062045445.1 1.06, GCF_062064952.1 1.01, GCF_062066596.1 1.05, GCF_062074957.1 1.00.

Detected genes present in the spike genome, DNA-found and protein-only reported apart (PM5 condition):

- DNA-found (a CARD DNA reference lies in the genome, `locate.sh`): 432 detection(s).
- Protein-only (RGI main Perfect/Strict protein hit, no CARD DNA reference there): 4 detection(s): mix_gut_GCF_062066596.1_2x rsmA (5 reads); mix_gut_GCF_062066596.1_2x FosA8 (2 reads); mix_wastewater_GCF_062074957.1_2x PmrF (6 reads); pure_GCF_062066596.1 rsmA (18 reads).
- Mark 2 under V1 round 4's DNA-only test (reported, not marked): FAIL, 16 unexplained.

Unexplained detected genes:

- mix_gut_GCF_062066596.1_8x: QnrB32 (2 reads, 23.4% covered; quinolone resistance protein (qnr))
- mix_wastewater_GCF_062066596.1_0.5x: MdtK (2 reads, 20.5% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_062066596.1_2x: emrB (4 reads, 30.7% covered; major facilitator superfamily (MFS) antibiotic efflux pump)
- mix_wastewater_GCF_062066596.1_2x: MdtK (3 reads, 28.9% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_wastewater_GCF_062066596.1_8x: QnrB32 (2 reads, 23.4% covered; quinolone resistance protein (qnr))
- mix_wastewater_GCF_062074957.1_2x: Klebsiella pneumoniae OmpK37 (3 reads, 26.5% covered; General Bacterial Porin with reduced permeability to beta-lactams)
- pure_GCF_062066596.1: QnrB32 (2 reads, 23.4% covered; quinolone resistance protein (qnr))
- pure_GCF_062074957.1: Klebsiella pneumoniae acrA (7 reads, 29.1% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)
- pure_GCF_062074957.1: mdtF (2 reads, 5.3% covered; resistance-nodulation-cell division (RND) antibiotic efflux pump)

V3 reports (not marked):

- Loci below 92% truth identity in 2x and 8x mixtures (not marked): 22; detected 14, probable homolog 0, missed 8.
- Detected genes explained as orthologs in the spike genome (RGI Loose, 85% or more), apart from DNA-found and protein-only: 14: mix_gut_GCF_062074957.1_0.5x AcrF (17 reads); mix_gut_GCF_062074957.1_0.5x AcrE (5 reads); mix_gut_GCF_062074957.1_2x AcrF (40 reads); mix_gut_GCF_062074957.1_2x mdtH (17 reads); mix_gut_GCF_062074957.1_8x AcrF (139 reads); mix_gut_GCF_062074957.1_8x mdtH (58 reads); mix_wastewater_GCF_062074957.1_0.5x AcrE (3 reads); mix_wastewater_GCF_062074957.1_0.5x mdtG (2 reads); mix_wastewater_GCF_062074957.1_2x AcrF (25 reads); mix_wastewater_GCF_062074957.1_2x mdtH (8 reads); mix_wastewater_GCF_062074957.1_8x AcrF (124 reads); mix_wastewater_GCF_062074957.1_8x mdtH (49 reads); pure_GCF_062074957.1 AcrF (159 reads); pure_GCF_062074957.1 mdtH (80 reads).
- Mark 2 under V2's rule (Perfect/Strict only; for comparison): 23 unexplained.
- Probable homologs: 0 call(s) in 0 sample(s).
- Groups under 92% truth identity, left out of mark 3 (4a): 17; observed copies pure_GCF_062064952.1 tet(45) 0.139/0.143; pure_GCF_062064952.1 sdrM 0/0.157; pure_GCF_062066596.1 adeF 0/0.16; pure_GCF_062074957.1 kdpE 0.104/0.109; pure_GCF_062074957.1 Escherichia coli acrA 0.121/0.142; pure_GCF_062074957.1 adeF 0.151/0.157; mix_gut_GCF_062064952.1_8x tet(45) 0.0167/0.017; mix_gut_GCF_062064952.1_8x sdrM 0/0.0219; mix_gut_GCF_062066596.1_8x adeF 0/0.0196; mix_gut_GCF_062074957.1_8x kdpE 0/0.0168; mix_gut_GCF_062074957.1_8x adeF 0.0218/0.0226; mix_wastewater_GCF_062064952.1_8x tet(45) 0.0572/0.0583; mix_wastewater_GCF_062064952.1_8x sdrM 0/0.0751; mix_wastewater_GCF_062066596.1_8x adeF 0/0.0665; mix_wastewater_GCF_062074957.1_8x kdpE 0/0.0551; mix_wastewater_GCF_062074957.1_8x Escherichia coli acrA 0.0573/0.0617; mix_wastewater_GCF_062074957.1_8x adeF 0.0722/0.0744.
- Groups left out of mark 3 because a locus has another copy in its genome: 10: pure_GCF_062064952.1 fexA (1 other copies); pure_GCF_062064952.1 dfrG (2 other copies); pure_GCF_062074957.1 APH(6)-Id (1 other copies); pure_GCF_062074957.1 APH(3'')-Ib (1 other copies); mix_gut_GCF_062064952.1_8x fexA (1 other copies); mix_gut_GCF_062064952.1_8x dfrG (2 other copies); mix_wastewater_GCF_062064952.1_8x fexA (1 other copies); mix_wastewater_GCF_062064952.1_8x dfrG (2 other copies); mix_wastewater_GCF_062074957.1_8x APH(6)-Id (1 other copies); mix_wastewater_GCF_062074957.1_8x APH(3'')-Ib (1 other copies).
