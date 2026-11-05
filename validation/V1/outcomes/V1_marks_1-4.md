# Validation V1: marks 1-4

Scored from `results` (pipeline results) and `truth` (truth).

| Mark | Result | Detail |
|---|---|---|
| 1. Detection (2x and 8x mixtures) | **FAIL** | 526 of 544 truth genes found (same ARO or same AMR gene family); exact ARO 421 of 544 |
| 2. Specificity | **FAIL** | 23 unexplained families in 31 samples scored |
| 3. Accuracy, copies per 16S copy | **FAIL** | pure genomes 54 of 79 families within 1.5x; 8x mixtures 66 of 87 within 2x; ratio range 0.00-1.97 |
| 4. Edge cases E1-E3 | **PASS** | E1 no ARGs, has 16S: pass; E2 no 16S, no ARGs: pass; E3 only host: pass |

Reported, not marked:

- Detection at 0.5x: 224 of 272 truth genes found.
- 16S copies estimated / truth on pure genomes: GCF_051560495.1 1.26, GCF_051560505.1 1.25, GCF_051618705.1 1.34, GCF_051620725.1 1.26.

Missed truth genes (marked depths):

- mix_gut_GCF_051560495.1_2x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_gut_GCF_051560495.1_8x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_gut_GCF_051620725.1_2x: FosA6 (fosfomycin thiol transferase)
- mix_gut_GCF_051620725.1_2x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_gut_GCF_051620725.1_8x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_wastewater_GCF_051560495.1_2x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051560495.1_2x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_wastewater_GCF_051560495.1_8x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051560495.1_8x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_wastewater_GCF_051560505.1_2x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051560505.1_8x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051618705.1_2x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051618705.1_8x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051620725.1_2x: FosA6 (fosfomycin thiol transferase)
- mix_wastewater_GCF_051620725.1_2x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051620725.1_2x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)
- mix_wastewater_GCF_051620725.1_8x: vanG (glycopeptide resistance gene cluster; Van ligase)
- mix_wastewater_GCF_051620725.1_8x: marA (resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein)

Unexplained families:

- mix_gut_GCF_051560505.1_0.5x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- mix_gut_GCF_051560505.1_2x: General Bacterial Porin with reduced permeability to beta-lactams (Klebsiella pneumoniae OmpK37)
- mix_gut_GCF_051560505.1_2x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- mix_gut_GCF_051560505.1_8x: General Bacterial Porin with reduced permeability to beta-lactams (Klebsiella pneumoniae OmpK37)
- mix_gut_GCF_051560505.1_8x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- mix_gut_GCF_051618705.1_0.5x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_gut_GCF_051618705.1_2x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_gut_GCF_051618705.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_gut_GCF_051620725.1_2x: AAC(6') (AAC(6')-Ib7)
- mix_wastewater_GCF_051560505.1_0.5x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- mix_wastewater_GCF_051560505.1_2x: General Bacterial Porin with reduced permeability to beta-lactams (Klebsiella pneumoniae OmpK37)
- mix_wastewater_GCF_051560505.1_2x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr9)
- mix_wastewater_GCF_051560505.1_8x: General Bacterial Porin with reduced permeability to beta-lactams (Klebsiella pneumoniae OmpK37)
- mix_wastewater_GCF_051560505.1_8x: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- mix_wastewater_GCF_051560505.1_8x: pmr phosphoethanolamine transferase; antibiotic efflux regulatory protein (cprS)
- mix_wastewater_GCF_051618705.1_0.5x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_wastewater_GCF_051618705.1_2x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_wastewater_GCF_051618705.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)
- mix_wastewater_GCF_051618705.1_8x: ampC-type beta-lactamase (Escherichia coli ampC beta-lactamase)
- pure_GCF_051560505.1: General Bacterial Porin with reduced permeability to beta-lactams (Klebsiella pneumoniae OmpK37)
- pure_GCF_051560505.1: aminoglycoside bifunctional resistance protein (ANT(3'')-II-AAC(6')-IId bifunctional protein)
- pure_GCF_051560505.1: AAC(6'); AAC(6')-Ib-cr (AAC(6')-Ib-cr5)
- pure_GCF_051618705.1: ATP-binding cassette (ABC) antibiotic efflux pump; major facilitator superfamily (MFS) antibiotic efflux pump; resistance-nodulation-cell division (RND) antibiotic efflux pump (TolC)

Outside the accuracy limit:

- pure_GCF_051560495.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0923, truth 0.25 (ratio 0.37, limit 1.5x)
- pure_GCF_051560495.1: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560495.1: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0361, truth 0.25 (ratio 0.14, limit 1.5x)
- pure_GCF_051560495.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0745, truth 0.25 (ratio 0.30, limit 1.5x)
- pure_GCF_051560495.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: AAC(6'), observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0316, truth 0.125 (ratio 0.25, limit 1.5x)
- pure_GCF_051560505.1: fosfomycin thiol transferase, observed 0.0632, truth 0.125 (ratio 0.51, limit 1.5x)
- pure_GCF_051560505.1: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: IMP beta-lactamase, observed 0.0807, truth 0.125 (ratio 0.65, limit 1.5x)
- pure_GCF_051560505.1: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0901, truth 0.25 (ratio 0.36, limit 1.5x)
- pure_GCF_051560505.1: pmr phosphoethanolamine transferase, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051560505.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0567, truth 0.25 (ratio 0.23, limit 1.5x)
- pure_GCF_051560505.1: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.0371, truth 0.25 (ratio 0.15, limit 1.5x)
- pure_GCF_051618705.1: EC beta-lactamase, observed 0.0941, truth 0.143 (ratio 0.66, limit 1.5x)
- pure_GCF_051618705.1: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.143 (ratio 0.00, limit 1.5x)
- pure_GCF_051618705.1: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.179, truth 0.286 (ratio 0.63, limit 1.5x)
- pure_GCF_051618705.1: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.124, truth 0.429 (ratio 0.29, limit 1.5x)
- pure_GCF_051620725.1: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0837, truth 0.25 (ratio 0.33, limit 1.5x)
- pure_GCF_051620725.1: General Bacterial Porin with reduced permeability to beta-lactams, observed 0.194, truth 0.125 (ratio 1.56, limit 1.5x)
- pure_GCF_051620725.1: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- pure_GCF_051620725.1: major facilitator superfamily (MFS) antibiotic efflux pump, observed 0.107, truth 0.25 (ratio 0.43, limit 1.5x)
- pure_GCF_051620725.1: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0306, truth 0.25 (ratio 0.12, limit 1.5x)
- pure_GCF_051620725.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0995, truth 0.25 (ratio 0.40, limit 1.5x)
- pure_GCF_051620725.1: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.125 (ratio 0.00, limit 1.5x)
- mix_gut_GCF_051560495.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0116, truth 0.0259 (ratio 0.45, limit 2x)
- mix_gut_GCF_051560495.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.00579, truth 0.0259 (ratio 0.22, limit 2x)
- mix_gut_GCF_051560495.1_8x: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.0129 (ratio 0.00, limit 2x)
- mix_gut_GCF_051560505.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.00458, truth 0.0129 (ratio 0.35, limit 2x)
- mix_gut_GCF_051560505.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0129, truth 0.0259 (ratio 0.50, limit 2x)
- mix_gut_GCF_051560505.1_8x: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.00389, truth 0.0259 (ratio 0.15, limit 2x)
- mix_gut_GCF_051618705.1_8x: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.0114, truth 0.0394 (ratio 0.29, limit 2x)
- mix_gut_GCF_051620725.1_8x: ATP-binding cassette (ABC) antibiotic efflux pump, observed 0.0113, truth 0.0259 (ratio 0.44, limit 2x)
- mix_gut_GCF_051620725.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.00454, truth 0.0259 (ratio 0.18, limit 2x)
- mix_gut_GCF_051620725.1_8x: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.0129 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051560495.1_8x: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.0236 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051560495.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0103, truth 0.0471 (ratio 0.22, limit 2x)
- mix_wastewater_GCF_051560495.1_8x: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.0236 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051560505.1_8x: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.0236 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051560505.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.0227, truth 0.0471 (ratio 0.48, limit 2x)
- mix_wastewater_GCF_051560505.1_8x: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.00802, truth 0.0471 (ratio 0.17, limit 2x)
- mix_wastewater_GCF_051618705.1_8x: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.0241 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051618705.1_8x: small multidrug resistance (SMR) antibiotic efflux pump, observed 0.0202, truth 0.0724 (ratio 0.28, limit 2x)
- mix_wastewater_GCF_051620725.1_8x: glycopeptide resistance gene cluster; Van ligase, observed 0, truth 0.0236 (ratio 0.00, limit 2x)
- mix_wastewater_GCF_051620725.1_8x: major facilitator superfamily (MFS) antibiotic efflux pump; antibiotic efflux regulatory protein, observed 0.00802, truth 0.0471 (ratio 0.17, limit 2x)
- mix_wastewater_GCF_051620725.1_8x: resistance-nodulation-cell division (RND) antibiotic efflux pump; General Bacterial Porin with reduced permeability to beta-lactams; antibiotic efflux regulatory protein, observed 0, truth 0.0236 (ratio 0.00, limit 2x)
