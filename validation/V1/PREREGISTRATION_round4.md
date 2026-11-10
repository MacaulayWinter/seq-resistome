# Validation V1, round 4: pre-registration (pipeline fixed, marks unchanged)

**DRAFT, not yet in force.** All fixes are built (D20-D24) and round 3
passes every mark in development. Still to do before this note is removed:
the user's go-ahead, and a full -profile test run on the final commit.
This file counts as the pre-registration only from the commit that removes
this note.

Written and committed on 2026-11-05, **before any round-4 data is chosen,
fetched, simulated or looked at** (the commit adding this file is the
proof). Round 3 (scored by location) failed marks 1-3 narrowly (CLAUDE.md
D17). The user asked for the failed parts to be fixed in the pipeline, not
the marks changed (2026-10-29 and 2026-11-05). The fixes are D19-D24
(read identity judged read by read with a share rule, the 16S identity
floor and short-hit filter, allele merging, the per-gene interval);
CARD's variants collection was tried and removed (D20). The truth uses the
depth actually simulated (D21). Their settings were chosen on round 1-3 data only (development results,
D20), never on round-4 data.

**The marks are round 3's, word for word.** Edge cases are unchanged; the
truth now uses the depth actually simulated (section 2; user, 2026-11-09). If any mark fails, round 4 fails and Claude stops and asks
the user. A miss that falls inside the gene's own 95% interval is still a
miss.

## 1. Pipeline under test

The commit that adds this file, with its defaults. These include:

- CARD 4.0.2 alone.
- `--min_read_identity 0.85` (judged read by read), `--min_identity_share 0.5`.
- `--min_allele_identity 0.95`.
- `--min_16s_identity 0.90`.
- `--min_16s_bases 50`.
- `--min_arg_reads 2`.
- `--min_breadth_ratio 0.5`.

It is run as `validation/V1/run_V1.sh` runs it, with `SCORER=score_V1_round4.R`,
after `validation/V1/simulated_depth.sh` (in its pinned image, not `NATIVE=1`).

## 2. Scoring

The marks' wording is round 3's. The truth uses the depth actually
simulated (user, 2026-11-09; CLAUDE.md D21; `score_V1_round4.R`):

- **Mark 3:** truth copies per 16S copy = the summed simulated depth of the
  group's loci / (the summed simulated depth of the genome's complete 16S
  copies, plus the background's 16S copies for mixtures).
- **Mark 1:** a locus in a 2x or 8x mixture is marked only if the locus
  itself was simulated at 1x or more.

The nominal truth is still reported. Everything else is as round 3
(`PREREGISTRATION_round3.md` section 2):

- detection by location (100% of truth loci at 2x and 8x);
- 0 unexplained detected AROs;
- accuracy per location group (pure genomes within 1.5x; 8x mixtures within 2x);
- edge cases E1-E4;
- the CARD cache.

Truth stays CARD 4.0.2's own reference sequences (`locate.sh`).

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
- **Backgrounds:** for each type, the first run after backup 2 in its
  candidate list (`candidates_<type>.tsv`, draw order) that is
  paired-end Illumina and can be fetched. Take its first 1,000,000 pairs.
- **Simulation:** ART seed **20261105**. Depths are 0.5x, 2x and 8x;
  pure genomes are at 10x. E1 and E2 are as before, with the new seed.
  E3 uses HG002 pairs 600,001-800,000. E4 uses round 4's first spike genome.
- Mark 5 is repeated with the real cache.
