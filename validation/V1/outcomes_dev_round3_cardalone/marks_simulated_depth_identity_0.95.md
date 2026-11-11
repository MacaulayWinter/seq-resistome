# Validation V1 round 4 (by location, truth from simulated depth): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051559745.1 Klebsiella pneumoniae KpnE; GCF_051559745.1 Klebsiella pneumoniae KpnF; GCF_051559745.1 vanG; GCF_051559745.1 rsmA; GCF_051559745.1 ArnT; GCF_051563765.1 vanG; GCF_051563765.1 Klebsiella pneumoniae KpnF; GCF_051563765.1 Klebsiella pneumoniae KpnE; GCF_051563765.1 ArnT; GCF_051563765.1 rsmA; GCF_051618695.1 ArnT; GCF_051618695.1 Klebsiella pneumoniae KpnE; GCF_051618695.1 Klebsiella pneumoniae KpnF; GCF_051618695.1 vanG; GCF_051618695.1 rsmA.

Scored from `dev20c_t0.95`; 136 truth loci in 136 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 457 of 522 truth loci found; exact ARO 446 |
| 2. Specificity | **FAIL** | 1 unexplained of 1768 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 124 of 136 groups within 1.5x; 8x mixtures 217 of 239 within 2x; ratio range 0.00-1.15 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 170 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 22, of which 15 found: mix_gut_GCF_051559745.1_2x mdtN 0.74x found; mix_gut_GCF_051559745.1_2x sul2 0.95x found; mix_gut_GCF_051563765.1_2x EC-5 0.37x found; mix_gut_GCF_051618695.1_2x PmrF 0.76x found; mix_gut_GCF_051618695.1_2x Escherichia coli emrE 0.88x missed; mix_gut_GCF_051618695.1_2x marA 0.83x found; mix_gut_GCF_051618695.1_2x kdpE 0.40x found; mix_gut_GCF_051618695.1_2x mdtM 0.92x missed; mix_gut_GCF_051618695.1_2x mdtP 0.94x found; mix_gut_GCF_051618695.1_2x cpxA 0.88x found; mix_gut_GCF_051618695.1_2x mdtE 0.75x found; mix_wastewater_GCF_051559745.1_2x mdtN 0.74x found; mix_wastewater_GCF_051559745.1_2x sul2 0.95x found; mix_wastewater_GCF_051563765.1_2x EC-5 0.37x missed; mix_wastewater_GCF_051618695.1_2x PmrF 0.76x missed; mix_wastewater_GCF_051618695.1_2x Escherichia coli emrE 0.88x missed; mix_wastewater_GCF_051618695.1_2x marA 0.83x found; mix_wastewater_GCF_051618695.1_2x kdpE 0.40x missed; mix_wastewater_GCF_051618695.1_2x mdtM 0.92x missed; mix_wastewater_GCF_051618695.1_2x mdtP 0.94x found; mix_wastewater_GCF_051618695.1_2x cpxA 0.88x found; mix_wastewater_GCF_051618695.1_2x mdtE 0.75x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 121 of 136 within 1.5x; 8x mixtures 217 of 239 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051559745.1 1.05, GCF_051563765.1 1.09, GCF_051618695.1 1.07.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051559745.1 1.10, GCF_051563765.1 1.09, GCF_051618695.1 1.14.

Missed truth loci (marked depths):

- mix_gut_GCF_051559745.1_2x: mdtC (GCF_051559745.1:NZ_CP196276.1:129783-132860)
- mix_gut_GCF_051559745.1_2x: mdtB (GCF_051559745.1:NZ_CP196276.1:132861-135983)
- mix_gut_GCF_051559745.1_2x: Escherichia coli emrE (GCF_051559745.1:NZ_CP196276.1:342003-342335)
- mix_gut_GCF_051559745.1_2x: kdpE (GCF_051559745.1:NZ_CP196276.1:1678919-1679596)
- mix_gut_GCF_051559745.1_2x: mdtM (GCF_051559745.1:NZ_CP196276.1:2529638-2530870)
- mix_gut_GCF_051559745.1_2x: eptA (GCF_051559745.1:NZ_CP196276.1:2812826-2814469)
- mix_gut_GCF_051559745.1_2x: gadX (GCF_051559745.1:NZ_CP196276.1:3541803-3542627)
- mix_gut_GCF_051559745.1_2x: AcrF (GCF_051559745.1:NZ_CP196276.1:3786417-3789521)
- mix_gut_GCF_051559745.1_8x: mdtC (GCF_051559745.1:NZ_CP196276.1:129783-132860)
- mix_gut_GCF_051559745.1_8x: Escherichia coli emrE (GCF_051559745.1:NZ_CP196276.1:342003-342335)
- mix_gut_GCF_051559745.1_8x: mdtM (GCF_051559745.1:NZ_CP196276.1:2529638-2530870)
- mix_gut_GCF_051559745.1_8x: eptA (GCF_051559745.1:NZ_CP196276.1:2812826-2814469)
- mix_gut_GCF_051559745.1_8x: gadX (GCF_051559745.1:NZ_CP196276.1:3541803-3542627)
- mix_gut_GCF_051563765.1_2x: mdtN (GCF_051563765.1:NZ_CP196265.1:462324-463355)
- mix_gut_GCF_051563765.1_2x: eptA (GCF_051563765.1:NZ_CP196265.1:492570-494213)
- mix_gut_GCF_051563765.1_2x: H-NS (GCF_051563765.1:NZ_CP196265.1:2301452-2301865)
- mix_gut_GCF_051563765.1_2x: Escherichia coli emrE (GCF_051563765.1:NZ_CP196265.1:3010594-3010926)
- mix_gut_GCF_051563765.1_2x: mdtA (GCF_051563765.1:NZ_CP196265.1:3304285-3305652)
- mix_gut_GCF_051563765.1_2x: mdtC (GCF_051563765.1:NZ_CP196265.1:3308775-3311852)
- mix_gut_GCF_051563765.1_2x: AcrF (GCF_051563765.1:NZ_CP196265.1:4637566-4640670)
- mix_gut_GCF_051563765.1_2x: gadX (GCF_051563765.1:NZ_CP196265.1:4894705-4895529)
- mix_gut_GCF_051563765.1_8x: eptA (GCF_051563765.1:NZ_CP196265.1:492570-494213)
- mix_gut_GCF_051563765.1_8x: H-NS (GCF_051563765.1:NZ_CP196265.1:2301452-2301865)
- mix_gut_GCF_051563765.1_8x: Escherichia coli emrE (GCF_051563765.1:NZ_CP196265.1:3010594-3010926)
- mix_gut_GCF_051563765.1_8x: mdtC (GCF_051563765.1:NZ_CP196265.1:3308775-3311852)
- mix_gut_GCF_051563765.1_8x: gadX (GCF_051563765.1:NZ_CP196265.1:4894705-4895529)
- mix_gut_GCF_051618695.1_2x: mdtC (GCF_051618695.1:NZ_CP196308.1:620092-623169)
- mix_gut_GCF_051618695.1_2x: msbA (GCF_051618695.1:NZ_CP196308.1:1932036-1933784)
- mix_gut_GCF_051618695.1_2x: AcrF (GCF_051618695.1:NZ_CP196308.1:4174024-4177128)
- mix_gut_GCF_051618695.1_8x: Escherichia coli emrE (GCF_051618695.1:NZ_CP196308.1:768724-769056)
- mix_gut_GCF_051618695.1_8x: H-NS (GCF_051618695.1:NZ_CP196308.1:1582246-1582659)
- mix_wastewater_GCF_051559745.1_2x: mdtC (GCF_051559745.1:NZ_CP196276.1:129783-132860)
- mix_wastewater_GCF_051559745.1_2x: mdtB (GCF_051559745.1:NZ_CP196276.1:132861-135983)
- mix_wastewater_GCF_051559745.1_2x: Escherichia coli emrE (GCF_051559745.1:NZ_CP196276.1:342003-342335)
- mix_wastewater_GCF_051559745.1_2x: kdpE (GCF_051559745.1:NZ_CP196276.1:1678919-1679596)
- mix_wastewater_GCF_051559745.1_2x: mdtM (GCF_051559745.1:NZ_CP196276.1:2529638-2530870)
- mix_wastewater_GCF_051559745.1_2x: eptA (GCF_051559745.1:NZ_CP196276.1:2812826-2814469)
- mix_wastewater_GCF_051559745.1_2x: gadX (GCF_051559745.1:NZ_CP196276.1:3541803-3542627)
- mix_wastewater_GCF_051559745.1_2x: AcrF (GCF_051559745.1:NZ_CP196276.1:3786417-3789521)
- mix_wastewater_GCF_051559745.1_2x: PmrF (GCF_051559745.1:NZ_CP196276.1:4951458-4952426)
- mix_wastewater_GCF_051559745.1_8x: mdtC (GCF_051559745.1:NZ_CP196276.1:129783-132860)
- mix_wastewater_GCF_051559745.1_8x: Escherichia coli emrE (GCF_051559745.1:NZ_CP196276.1:342003-342335)
- mix_wastewater_GCF_051559745.1_8x: kdpE (GCF_051559745.1:NZ_CP196276.1:1678919-1679596)
- mix_wastewater_GCF_051559745.1_8x: mdtM (GCF_051559745.1:NZ_CP196276.1:2529638-2530870)
- mix_wastewater_GCF_051559745.1_8x: eptA (GCF_051559745.1:NZ_CP196276.1:2812826-2814469)
- mix_wastewater_GCF_051559745.1_8x: gadX (GCF_051559745.1:NZ_CP196276.1:3541803-3542627)
- mix_wastewater_GCF_051563765.1_2x: mdtN (GCF_051563765.1:NZ_CP196265.1:462324-463355)
- mix_wastewater_GCF_051563765.1_2x: eptA (GCF_051563765.1:NZ_CP196265.1:492570-494213)
- mix_wastewater_GCF_051563765.1_2x: kdpE (GCF_051563765.1:NZ_CP196265.1:1626211-1626888)
- mix_wastewater_GCF_051563765.1_2x: H-NS (GCF_051563765.1:NZ_CP196265.1:2301452-2301865)
- mix_wastewater_GCF_051563765.1_2x: Escherichia coli emrE (GCF_051563765.1:NZ_CP196265.1:3010594-3010926)
- mix_wastewater_GCF_051563765.1_2x: mdtA (GCF_051563765.1:NZ_CP196265.1:3304285-3305652)
- mix_wastewater_GCF_051563765.1_2x: mdtB (GCF_051563765.1:NZ_CP196265.1:3305652-3308774)
- mix_wastewater_GCF_051563765.1_2x: mdtC (GCF_051563765.1:NZ_CP196265.1:3308775-3311852)
- mix_wastewater_GCF_051563765.1_2x: AcrF (GCF_051563765.1:NZ_CP196265.1:4637566-4640670)
- mix_wastewater_GCF_051563765.1_2x: gadX (GCF_051563765.1:NZ_CP196265.1:4894705-4895529)
- mix_wastewater_GCF_051563765.1_8x: eptA (GCF_051563765.1:NZ_CP196265.1:492570-494213)
- mix_wastewater_GCF_051563765.1_8x: H-NS (GCF_051563765.1:NZ_CP196265.1:2301452-2301865)
- mix_wastewater_GCF_051563765.1_8x: Escherichia coli emrE (GCF_051563765.1:NZ_CP196265.1:3010594-3010926)
- mix_wastewater_GCF_051563765.1_8x: gadX (GCF_051563765.1:NZ_CP196265.1:4894705-4895529)
- mix_wastewater_GCF_051618695.1_2x: mdtB (GCF_051618695.1:NZ_CP196308.1:623170-626292)
- mix_wastewater_GCF_051618695.1_2x: msbA (GCF_051618695.1:NZ_CP196308.1:1932036-1933784)
- mix_wastewater_GCF_051618695.1_2x: leuO (GCF_051618695.1:NZ_CP196308.1:2887283-2888227)
- mix_wastewater_GCF_051618695.1_8x: Escherichia coli emrE (GCF_051618695.1:NZ_CP196308.1:768724-769056)
- mix_wastewater_GCF_051618695.1_8x: H-NS (GCF_051618695.1:NZ_CP196308.1:1582246-1582659)

Unexplained detected genes:

- mix_wastewater_GCF_051618695.1_8x: OXA-1307 (2 reads, 28.2% covered; OXA-48-like beta-lactamase)

Outside the accuracy limit:

- pure_GCF_051559745.1: mdtC, observed 0, truth 0.146 (ratio 0.00, limit 1.5x)
- pure_GCF_051559745.1: mdtM, observed 0, truth 0.136 (ratio 0.00, limit 1.5x)
- pure_GCF_051559745.1: eptA, observed 0, truth 0.175 (ratio 0.00, limit 1.5x)
- pure_GCF_051559745.1: Escherichia coli emrE, observed 0, truth 0.174 (ratio 0.00, limit 1.5x)
- pure_GCF_051559745.1: gadX, observed 0, truth 0.129 (ratio 0.00, limit 1.5x)
- pure_GCF_051563765.1: H-NS, observed 0, truth 0.0988 (ratio 0.00, limit 1.5x)
- pure_GCF_051563765.1: Escherichia coli emrE, observed 0, truth 0.154 (ratio 0.00, limit 1.5x)
- pure_GCF_051563765.1: gadX, observed 0, truth 0.132 (ratio 0.00, limit 1.5x)
- pure_GCF_051563765.1: eptA, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051618695.1: H-NS, observed 0, truth 0.0999 (ratio 0.00, limit 1.5x)
- pure_GCF_051618695.1: EC-18, observed 0.0988, truth 0.154 (ratio 0.64, limit 1.5x)
- pure_GCF_051618695.1: Escherichia coli emrE, observed 0, truth 0.0948 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051559745.1_8x: mdtC, observed 0, truth 0.019 (ratio 0.00, limit 2x)
- mix_gut_GCF_051559745.1_8x: mdtM, observed 0, truth 0.0201 (ratio 0.00, limit 2x)
- mix_gut_GCF_051559745.1_8x: eptA, observed 0, truth 0.0257 (ratio 0.00, limit 2x)
- mix_gut_GCF_051559745.1_8x: Escherichia coli emrE, observed 0, truth 0.0232 (ratio 0.00, limit 2x)
- mix_gut_GCF_051559745.1_8x: gadX, observed 0, truth 0.02 (ratio 0.00, limit 2x)
- mix_gut_GCF_051563765.1_8x: H-NS, observed 0, truth 0.0159 (ratio 0.00, limit 2x)
- mix_gut_GCF_051563765.1_8x: Escherichia coli emrE, observed 0, truth 0.0222 (ratio 0.00, limit 2x)
- mix_gut_GCF_051563765.1_8x: mdtC, observed 0, truth 0.0222 (ratio 0.00, limit 2x)
- mix_gut_GCF_051563765.1_8x: gadX, observed 0, truth 0.0191 (ratio 0.00, limit 2x)
- mix_gut_GCF_051563765.1_8x: eptA, observed 0, truth 0.0166 (ratio 0.00, limit 2x)
- mix_gut_GCF_051618695.1_8x: H-NS, observed 0, truth 0.0134 (ratio 0.00, limit 2x)
- mix_gut_GCF_051618695.1_8x: Escherichia coli emrE, observed 0, truth 0.0152 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051559745.1_8x: mdtC, observed 0, truth 0.00683 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051559745.1_8x: kdpE, observed 0, truth 0.00705 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051559745.1_8x: mdtM, observed 0, truth 0.00723 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051559745.1_8x: Escherichia coli emrE, observed 0, truth 0.00833 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051559745.1_8x: gadX, observed 0, truth 0.00719 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051563765.1_8x: H-NS, observed 0, truth 0.00572 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051563765.1_8x: Escherichia coli emrE, observed 0, truth 0.008 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051563765.1_8x: gadX, observed 0, truth 0.0069 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051618695.1_8x: H-NS, observed 0, truth 0.00484 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051618695.1_8x: Escherichia coli emrE, observed 0, truth 0.00548 (ratio 0.00, limit 2x)
