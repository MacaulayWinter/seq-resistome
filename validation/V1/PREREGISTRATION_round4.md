# Validation V1, round 4: pre-registration (pipeline fixed, marks unchanged)

Written and committed on 2026-11-05, **before any round-4 data is chosen,
fetched, simulated or looked at** (the commit adding this file is the
proof). Round 3 (scored by location) failed marks 1-3 narrowly (CLAUDE.md
D17). The user asked for the failed parts to be fixed in the pipeline, not
the marks changed (2026-10-29 and 2026-11-05). The four fixes are D19 and D20.
Their settings were chosen on round 1-3 data only (development results,
D20), never on round-4 data.

**The marks are round 3's, word for word.** Scoring, truth and edge cases are
unchanged too. If any mark fails, round 4 fails and Claude stops and asks
the user. A miss that falls inside the gene's own 95% interval is still a
miss.

## 1. Pipeline under test

The commit that adds this file, with its defaults. These include:

- `--card_variants true`: CARD 4.0.2 plus its variants collection 4.0.2.
- `--min_read_identity __THRESHOLD__`.
- `--min_16s_bases 50`.
- `--min_arg_reads 2`.
- `--min_breadth_ratio 0.5`.

It is run as `validation/V1/run_V1.sh` runs it, with `SCORER=score_V1_round3.R`.

## 2. Scoring

Scoring is as round 3 (`PREREGISTRATION_round3.md` section 2), unchanged:

- detection by location (100% of truth loci at 2x and 8x);
- 0 unexplained detected AROs;
- accuracy per location group (pure genomes within 1.5x; 8x mixtures within 2x);
- edge cases E1-E4;
- the CARD cache.

For mark 5, the cache check now also covers the variants archive: reuse,
damage reported, and a refetch that matches its pinned checksum.

Truth stays CARD 4.0.2's own reference sequences (`locate.sh`). Truth does
not use the variants collection, so the fix cannot mark its own work.

Reported, not marked:

- each unit's 95% interval, and whether the truth lies inside it;
- the number of 16S short hits dropped;
- all round-3 reports.

## 3. Fresh data, by rules written now

- **Spike genomes:** take the round-3 draw (`genomes_round3.tsv`, saved
  2026-10-29 before round 3; draws 1-3 used). Use the first three genomes,
  in draw order, from draws not yet used whose species is not already
  taken. Distinct species test the pipeline beyond E. coli, which rounds 3
  and 4 would otherwise be all of. Only species names, which are in the
  draw table, were seen to write this rule; no genome's genes were seen.
  All are 2025 assemblies, newer than the variants collection's sequences
  (dated November 2023), so a spike genome itself cannot be in the
  collection.
- **Backgrounds:** for each type, the first run after backup 2 in its
  candidate list (`candidates_<type>.tsv`, draw order) that is
  paired-end Illumina and can be fetched. Take its first 1,000,000 pairs.
- **Simulation:** ART seed **20261105**. Depths are 0.5x, 2x and 8x;
  pure genomes are at 10x. E1 and E2 are as before, with the new seed.
  E3 uses HG002 pairs 600,001-800,000. E4 uses round 4's first spike genome.
- Mark 5 is repeated with the real cache.
