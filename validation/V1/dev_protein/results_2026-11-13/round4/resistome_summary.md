# seq-resistome summary

seq-resistome 0.1.0dev. CARD 4.0.2 (the release this pipeline version was validated with). ARG reads counted by DIAMOND blastx (count_mode protein).

26 sample(s) analysed, 0 left out.

| Sample | Status | Reads analysed | Host reads removed | 16S reads | ARGs detected | ARG copies per 16S copy (all detected) |
|---|---|---:|---:|---:|---:|---:|
| bg_gut | analysed | 1,986,320 | 0.0% | 9170 | 42 | 1.78 |
| bg_wastewater | analysed | 1,994,634 | 0.0% | 3030 | 40 | 0.25 |
| E1_mgenitalium | analysed | 38,670 | 0.0% | 71 | 0 | 0 |
| E2_lambda | analysed | 3,230 | 0.0% | 0 | 0 | NA |
| E3_host | analysed | 830 | 99.8% | 2 | 0 | 0 |
| mix_gut_GCF_051561185.1_0.5x | analysed | 2,003,364 | 0.0% | 9206 | 70 | 1.8 |
| mix_gut_GCF_051561185.1_2x | analysed | 2,054,490 | 0.0% | 9342 | 82 | 1.86 |
| mix_gut_GCF_051561185.1_8x | analysed | 2,259,000 | 0.0% | 9850 | 86 | 2.13 |
| mix_gut_GCF_051562295.1_0.5x | analysed | 2,003,358 | 0.0% | 9206 | 67 | 1.79 |
| mix_gut_GCF_051562295.1_2x | analysed | 2,054,468 | 0.0% | 9328 | 78 | 1.83 |
| mix_gut_GCF_051562295.1_8x | analysed | 2,258,912 | 0.0% | 9836 | 80 | 2 |
| mix_gut_GCF_051617105.1_0.5x | analysed | 2,007,078 | 0.0% | 9214 | 73 | 1.8 |
| mix_gut_GCF_051617105.1_2x | analysed | 2,069,348 | 0.0% | 9362 | 88 | 1.87 |
| mix_gut_GCF_051617105.1_8x | analysed | 2,318,432 | 0.0% | 9908 | 92 | 2.12 |
| mix_wastewater_GCF_051561185.1_0.5x | analysed | 2,011,678 | 0.0% | 3066 | 58 | 0.326 |
| mix_wastewater_GCF_051561185.1_2x | analysed | 2,062,804 | 0.0% | 3202 | 74 | 0.555 |
| mix_wastewater_GCF_051561185.1_8x | analysed | 2,267,314 | 0.0% | 3710 | 83 | 1.43 |
| mix_wastewater_GCF_051562295.1_0.5x | analysed | 2,011,672 | 0.0% | 3066 | 63 | 0.296 |
| mix_wastewater_GCF_051562295.1_2x | analysed | 2,062,782 | 0.0% | 3188 | 79 | 0.491 |
| mix_wastewater_GCF_051562295.1_8x | analysed | 2,267,226 | 0.0% | 3696 | 81 | 1.09 |
| mix_wastewater_GCF_051617105.1_0.5x | analysed | 2,015,392 | 0.0% | 3074 | 62 | 0.325 |
| mix_wastewater_GCF_051617105.1_2x | analysed | 2,077,662 | 0.0% | 3222 | 75 | 0.555 |
| mix_wastewater_GCF_051617105.1_8x | analysed | 2,326,746 | 0.0% | 3768 | 83 | 1.4 |
| pure_GCF_051561185.1 | analysed | 340,850 | 0.0% | 874 | 50 | 6.75 |
| pure_GCF_051562295.1 | analysed | 340,740 | 0.0% | 799 | 43 | 5.48 |
| pure_GCF_051617105.1 | analysed | 415,140 | 0.0% | 906 | 52 | 6.69 |

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
