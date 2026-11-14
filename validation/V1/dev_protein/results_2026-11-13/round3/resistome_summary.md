# seq-resistome summary

seq-resistome 0.1.0dev. CARD 4.0.2 (the release this pipeline version was validated with). ARG reads counted by DIAMOND blastx (count_mode protein).

26 sample(s) analysed, 0 left out.

| Sample | Status | Reads analysed | Host reads removed | 16S reads | ARGs detected | ARG copies per 16S copy (all detected) |
|---|---|---:|---:|---:|---:|---:|
| bg_gut | analysed | 1,999,978 | 0.0% | 3154 | 28 | 0.636 |
| bg_wastewater | analysed | 1,937,682 | 0.0% | 3757 | 90 | 0.523 |
| E1_mgenitalium | analysed | 38,670 | 0.0% | 97 | 0 | 0 |
| E2_lambda | analysed | 3,230 | 0.0% | 0 | 0 | NA |
| E3_host | analysed | 808 | 99.8% | 2 | 0 | 0 |
| mix_gut_GCF_051559745.1_0.5x | analysed | 2,017,272 | 0.0% | 3181 | 61 | 0.706 |
| mix_gut_GCF_051559745.1_2x | analysed | 2,069,154 | 0.0% | 3295 | 77 | 0.916 |
| mix_gut_GCF_051559745.1_8x | analysed | 2,276,682 | 0.0% | 3753 | 81 | 1.64 |
| mix_gut_GCF_051563765.1_0.5x | analysed | 2,017,304 | 0.0% | 3192 | 59 | 0.692 |
| mix_gut_GCF_051563765.1_2x | analysed | 2,069,284 | 0.0% | 3314 | 64 | 0.843 |
| mix_gut_GCF_051563765.1_8x | analysed | 2,277,202 | 0.0% | 3777 | 66 | 1.33 |
| mix_gut_GCF_051618695.1_0.5x | analysed | 2,017,000 | 0.0% | 3195 | 65 | 0.71 |
| mix_gut_GCF_051618695.1_2x | analysed | 2,068,058 | 0.0% | 3309 | 75 | 0.886 |
| mix_gut_GCF_051618695.1_8x | analysed | 2,272,298 | 0.0% | 3772 | 77 | 1.56 |
| mix_wastewater_GCF_051559745.1_0.5x | analysed | 1,954,976 | 0.0% | 3784 | 105 | 0.583 |
| mix_wastewater_GCF_051559745.1_2x | analysed | 2,006,858 | 0.0% | 3898 | 120 | 0.79 |
| mix_wastewater_GCF_051559745.1_8x | analysed | 2,214,386 | 0.0% | 4356 | 126 | 1.49 |
| mix_wastewater_GCF_051563765.1_0.5x | analysed | 1,955,008 | 0.0% | 3795 | 105 | 0.556 |
| mix_wastewater_GCF_051563765.1_2x | analysed | 2,006,988 | 0.0% | 3917 | 113 | 0.703 |
| mix_wastewater_GCF_051563765.1_8x | analysed | 2,214,906 | 0.0% | 4380 | 121 | 1.23 |
| mix_wastewater_GCF_051618695.1_0.5x | analysed | 1,954,704 | 0.0% | 3798 | 107 | 0.58 |
| mix_wastewater_GCF_051618695.1_2x | analysed | 2,005,762 | 0.0% | 3912 | 118 | 0.744 |
| mix_wastewater_GCF_051618695.1_8x | analysed | 2,210,002 | 0.0% | 4375 | 125 | 1.42 |
| pure_GCF_051559745.1 | analysed | 345,880 | 0.0% | 750 | 55 | 7.55 |
| pure_GCF_051563765.1 | analysed | 346,530 | 0.0% | 783 | 42 | 5.28 |
| pure_GCF_051618695.1 | analysed | 340,400 | 0.0% | 739 | 54 | 6.84 |

## Notes

- **E2_lambda**: No 16S reads: copies per 16S copy are missing (NA), not zero or infinite.

## How to read these numbers

- **reads**: reads whose translated sequence matches a CARD protein best, at 70% amino-acid identity or more, found by DIAMOND blastx (each mate of a pair counts once).
- **rpm**: reads per million reads analysed (after QC and host removal).
- **rpkm**: reads per kilobase of the CARD reference gene per million reads analysed.
- **copies_per_16s**: copies_per_16s counts ARG copies per 16S rRNA gene copy. Bacterial genomes carry 1 to about 15 16S copies (most 1 to 7), so this is not ARGs per cell or per genome, and communities whose members carry more 16S copies look poorer in ARGs.
- **detected**: at least 2 reads, spread along the gene at least 0.5 times as widely as reads landing at random would be, matching the CARD reference at 90% amino-acid identity or more on average. Hits that fail are kept in arg_long.tsv with the reason, and left out of the matrices.
- Only CARD's protein homolog models are searched: genes whose presence alone confers resistance. Resistance by point mutation (e.g. in gyrA) cannot be called from reads mapped this way and is not reported.
- Gene lengths, aligned bases and coverage are protein lengths times 3 (the coding sequence), so rpkm and copies are on the same scale as in DNA mode. rgi_percent_coverage, completely_mapped_reads and average_mapq are RGI's and are missing (NA) in protein mode.
- Counts are of reads, not organisms: which organisms carry these genes, and whether on plasmids, is for later versions.
