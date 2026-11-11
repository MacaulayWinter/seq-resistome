# Validation V1 round 4 (by location, truth from simulated depth): marks 1-4

Protein-only RGI hits excluded from the truth (never scored): **15**: GCF_051559745.1 Klebsiella pneumoniae KpnE; GCF_051559745.1 Klebsiella pneumoniae KpnF; GCF_051559745.1 vanG; GCF_051559745.1 rsmA; GCF_051559745.1 ArnT; GCF_051563765.1 vanG; GCF_051563765.1 Klebsiella pneumoniae KpnF; GCF_051563765.1 Klebsiella pneumoniae KpnE; GCF_051563765.1 ArnT; GCF_051563765.1 rsmA; GCF_051618695.1 ArnT; GCF_051618695.1 Klebsiella pneumoniae KpnE; GCF_051618695.1 Klebsiella pneumoniae KpnF; GCF_051618695.1 vanG; GCF_051618695.1 rsmA.

Scored from `dev20c_t0.80`; 136 truth loci in 136 accuracy groups.

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **PASS** | 522 of 522 truth loci found; exact ARO 511 |
| 2. Specificity | **FAIL** | 19 unexplained of 2245 detected genes in 24 samples |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 135 of 136 groups within 1.5x; 8x mixtures 224 of 224 within 2x; ratio range 0.64-1.26 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 227 of 272 truth loci found.
- Loci in 2x and 8x mixtures simulated below 1x (not marked): 22, of which 21 found: mix_gut_GCF_051559745.1_2x mdtN 0.74x found; mix_gut_GCF_051559745.1_2x sul2 0.95x found; mix_gut_GCF_051563765.1_2x EC-5 0.37x found; mix_gut_GCF_051618695.1_2x PmrF 0.76x found; mix_gut_GCF_051618695.1_2x Escherichia coli emrE 0.88x found; mix_gut_GCF_051618695.1_2x marA 0.83x found; mix_gut_GCF_051618695.1_2x kdpE 0.40x found; mix_gut_GCF_051618695.1_2x mdtM 0.92x found; mix_gut_GCF_051618695.1_2x mdtP 0.94x found; mix_gut_GCF_051618695.1_2x cpxA 0.88x found; mix_gut_GCF_051618695.1_2x mdtE 0.75x found; mix_wastewater_GCF_051559745.1_2x mdtN 0.74x found; mix_wastewater_GCF_051559745.1_2x sul2 0.95x found; mix_wastewater_GCF_051563765.1_2x EC-5 0.37x missed; mix_wastewater_GCF_051618695.1_2x PmrF 0.76x found; mix_wastewater_GCF_051618695.1_2x Escherichia coli emrE 0.88x found; mix_wastewater_GCF_051618695.1_2x marA 0.83x found; mix_wastewater_GCF_051618695.1_2x kdpE 0.40x found; mix_wastewater_GCF_051618695.1_2x mdtM 0.92x found; mix_wastewater_GCF_051618695.1_2x mdtP 0.94x found; mix_wastewater_GCF_051618695.1_2x cpxA 0.88x found; mix_wastewater_GCF_051618695.1_2x mdtE 0.75x found.
- Mark 3 against the nominal truth (round 3's): pure genomes 131 of 136 within 1.5x; 8x mixtures 224 of 224 within 2x.
- 16S copies estimated / nominal truth on pure genomes: GCF_051559745.1 1.05, GCF_051563765.1 1.09, GCF_051618695.1 1.07.
- 16S copies estimated / simulated depth of the complete 16S copies: GCF_051559745.1 1.10, GCF_051563765.1 1.09, GCF_051618695.1 1.14.

Unexplained detected genes:

- mix_gut_GCF_051559745.1_0.5x: LptD (9 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051559745.1_0.5x: MdtK (2 reads, 20.4% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051559745.1_2x: LptD (10 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051559745.1_2x: MdtK (2 reads, 20.4% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051563765.1_0.5x: LptD (2 reads, 7.7% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051563765.1_2x: LptD (9 reads, 31.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_0.5x: LptD (3 reads, 19.2% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_0.5x: MdtK (2 reads, 17.8% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618695.1_2x: LptD (12 reads, 48.9% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_gut_GCF_051618695.1_2x: MdtK (3 reads, 23.0% covered; multidrug and toxic compound extrusion (MATE) transporter)
- mix_gut_GCF_051618695.1_8x: LptD (59 reads, 58.1% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051559745.1_0.5x: LptD (9 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051559745.1_2x: LptD (10 reads, 34.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051563765.1_0.5x: LptD (2 reads, 7.7% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051563765.1_2x: LptD (9 reads, 31.4% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_0.5x: LptD (3 reads, 19.2% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_2x: LptD (12 reads, 48.9% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- mix_wastewater_GCF_051618695.1_8x: LptD (59 reads, 58.1% covered; ATP-binding cassette (ABC) antibiotic efflux pump)
- pure_GCF_051618695.1: LptD (68 reads, 59.6% covered; ATP-binding cassette (ABC) antibiotic efflux pump)

Outside the accuracy limit:

- pure_GCF_051618695.1: EC-18, observed 0.0988, truth 0.154 (ratio 0.64, limit 1.5x)
