# V3 Addendum A: the pipeline commit under test

Written 2026-11-14, after Amendment 1 and before any V3 genome was listed, fetched or simulated.
It names a commit and nothing else (PREREGISTRATION.md section 1).

**Pipeline commit: 93eb4e8** (branch `protein-mode`). Between 6b1af46 (the probable-homolog class)
and 93eb4e8 (the 4-read minimum for the "or" route) the only changes are those two features.
Pipeline files at the HEAD that carries this addendum are identical to 93eb4e8 (`git diff 93eb4e8 HEAD`
over `main.nf nextflow.config nextflow_schema.json bin conf modules subworkflows workflows assets lib` is empty);
`run_V3.sh` checks it.

Tests on 93eb4e8 before this addendum:
- Unit tests `tests/resistome_tables/test_resistome_tables.R`: 77 checks pass (cases 17-19 cover the "or" route,
  the probable-homolog class and the 4-read minimum).
- `-profile test,docker,arm64` in protein mode and in DNA mode, with `tests/e2e/check_test_profile.R`:
  protein "all checks passed (4 samples analysed, 0 left out, 58 detected gene calls)", DNA "all checks
  passed (4 samples analysed, 0 left out, 60 detected gene calls)" (`test_profile/check_protein.out`,
  `check_dna.out`). The detected-gene counts match the earlier "or" build, so detection did not change on the test data.
  The test profile holds no probable homologs; the class is covered by the unit tests.
- The DNA-mode end-to-end CI step has not yet run on GitHub (nothing is pushed).

Files fixed by this addendum, run by `run_V3.sh` and checked for uncommitted changes:
`PREREGISTRATION.md` (with Amendment 1), `ADDENDUM_A.md`, `score_V3.R`, `repeats.sh`, `run_V3.sh`,
`v3.config`, `v3_e4.config`.
