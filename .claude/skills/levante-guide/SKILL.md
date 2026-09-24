---
name: levante-guide
description: Orientation and code review for LEVANTE child-development data (Redivis datasets, the levante / levantemodels R packages, the levante-analysis notebooks). Use it to find which analyses already exist for a task, site, or question — and what they concluded, on which data, and how settled it is — and to check R analysis code or an analysis plan against known LEVANTE data and scoring pitfalls (unpinned versions, stale datasets, θ floors, score_type mixing, mirt column order, cross-site mean comparisons, ToM/Memory/SDS issues). Use it whenever someone starts or reviews a LEVANTE analysis, asks "has anyone looked at X", asks what's known about a LEVANTE task or dataset, or writes code that calls get_scores/get_trials/score_irt — even if they don't ask for a review.
---

# LEVANTE guide

Two jobs: **find prior analyses** and **check analysis code or plans**. When
someone is starting a new analysis, do both: find what already exists first
(so they build on it rather than redo it), then review their plan.

Paths below are relative to the LEVANTE root, the directory holding the
cloned repos as siblings (see `levante-data-meta/README.md`). This skill lives
in `levante-data-meta/.claude/skills/levante-guide/`, so `LEVANTE.md` is three
levels above this file.

## Finding prior analyses

The `levante-analysis` notebooks carry structured `levante:` frontmatter
(schema: `levante-analysis/ANALYSIS_METADATA.md`). Query it with the bundled
script rather than grepping prose:

```bash
Rscript --vanilla <skill-dir>/scripts/find_analyses.R --task vocab --dataset bogota
Rscript --vanilla <skill-dir>/scripts/find_analyses.R --text "test.retest|reliab" --full
```

Filters (combine with AND): `--task` (long id or short name: `math`, `tom`,
`sds`, …), `--dataset` (substring, e.g. `bogota`, `mpieva`), `--status`,
`--text` (regex over title, summary, findings). `--full` adds data sources,
dependencies, and findings. `--repo PATH` if `levante-analysis` isn't a
sibling of `levante-data-meta`. Run it with no filters to list everything.

Start broad (one filter) and add `--full` once you've narrowed down. Then
open the notebooks that matter; the metadata is an index, not a substitute
for reading the analysis.

When you report back, carry the provenance with each finding, because it
decides how much weight the finding can bear:

- **`status`**: `draft` means AI-generated and not verified line by line by
  a human (currently every notebook). Say so; don't present draft findings as
  established results. For `superseded`, send the reader to `superseded_by`
  and say which of the old findings still stand.
- **`last_run` and `data` versions**: findings reflect the data as of that
  date. If the user is working with newer data, the numbers may have moved
  (e.g. ToM changed substantially in the v2_3 re-scoring).
- **`datasets`**: a finding from Leipzig and Bogotá doesn't automatically
  extend to other sites.

If the script lists notebooks under "No `levante:` metadata", they weren't
indexed; check their titles and the `levante-analysis/README.md` notebook
table by hand. Other repos (`levante-pilots`, `papers/*`) have no metadata
yet; mention them when relevant (the core-tasks paper lives in
`levante-pilots`).

## Checking analysis code or plans

Read `references/checks.md`. It lists 23 concrete checks, each with what to
look for, why it matters, and the `LEVANTE.md` section with the full story.
Go through the code or plan against every check, and read the linked
`LEVANTE.md` section whenever a check applies and you need the detail.
`LEVANTE.md` is authoritative; if it and `checks.md` disagree, go with
`LEVANTE.md` and mention the mismatch.

Only report what you can point to. A check that doesn't apply (no ToM in the
analysis, no hand-rolled scoring) is not a finding; a vague "consider
versioning" without a line to point at is noise. Where the code is ambiguous
(e.g. a data frame whose source you can't see), say what you'd need to know
rather than guessing.

Report format:

```
## LEVANTE checks: <file or plan name>

### Issues
1. [error] <file:line> — <what's wrong, in one sentence>
   Why: <consequence for the results>
   Fix: <concrete change>
2. [warn] ...

### Checked, no issue
<one line listing the checks that applied and passed, by number>

### Not applicable
<one line listing check numbers that don't apply>
```

Order issues by severity (error, warn, note). For a plan rather than code,
use the plan's section or step instead of `file:line`. If the analysis
overlaps with existing notebooks, end with a short "Related prior work" list
from the finder.
