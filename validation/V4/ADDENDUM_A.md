# V4 Addendum A: the pipeline commit under test

Written 2026-11-15, after the V4 pre-registration was in force and before any V4 genome was listed,
fetched or simulated. It names a commit and nothing else.

**Pipeline commit: ba34ac5** (branch `protein-mode`): 93eb4e8 plus the argument-order fix and the test that reads the
settings back (`tests/e2e/check_test_profile.R`). Pipeline files at the HEAD that carries this addendum are identical
to ba34ac5 (`git diff ba34ac5 HEAD` over `main.nf nextflow.config nextflow_schema.json bin conf modules subworkflows workflows assets lib`
is empty); `run_V4.sh` checks it.

Tests on ba34ac5 before this addendum:
- Unit tests `tests/resistome_tables/test_resistome_tables.R`: 77 checks pass.
- `-profile test,docker,arm64` in protein and DNA mode, with `check_test_profile.R` including the new settings check:
  protein "all checks passed (4 samples analysed, 0 left out, 57 detected gene calls)", DNA "all checks passed
  (4 samples analysed, 0 left out, 60 detected gene calls)" (`test_profile/check_protein.out`, `check_dna.out`).
  Protein mode finds 57 detected calls, one fewer than V3's run (58), as expected: the 4-read minimum now
  applies, which V3's run did not apply because of the defect.
- The new check fails on V3's saved protein output (negative control): both settings missing from its summary.
- The DNA-mode end-to-end CI step has not yet run on GitHub (nothing is pushed).

Files fixed by this addendum, run by `run_V4.sh` and checked for uncommitted changes:
`PREREGISTRATION.md`, `ADDENDUM_A.md`, `score_V4.R`, `repeats.sh`, `run_V4.sh`, `v4.config`, `v4_e4.config`.
