---
name: levante-guide
description: Orientation and review for LEVANTE child-development data (Redivis datasets, the levante / levantemodels R packages, the levante-analysis notebooks). Use it to find which analyses already exist for a task, site, or question, what they concluded, on which data, and how settled that is; and to review R analysis code or an analysis plan against LEVANTE's known data and scoring pitfalls. Use it whenever someone starts or reviews a LEVANTE analysis, asks "has anyone looked at X", asks what's known about a LEVANTE task or dataset, or writes code that calls get_scores / get_trials / score_irt, even if they don't ask for a review.
---

# LEVANTE guide

Paths are relative to the LEVANTE root, the directory holding the cloned
repos as siblings. This skill lives in
`levante-data-meta/.claude/skills/levante-guide/`; `LEVANTE.md` is three
levels up. When someone starts a new analysis, find the prior work first,
then review their plan.

## Finding prior analyses

The `levante-analysis` notebooks carry `levante:` frontmatter (schema:
`levante-analysis/ANALYSIS_METADATA.md`). Query it with:

```bash
Rscript --vanilla <skill-dir>/scripts/find_analyses.R --task vocab --dataset bogota
Rscript --vanilla <skill-dir>/scripts/find_analyses.R --text "regress|RTM" --full
```

Filters combine with AND: `--task` (long id or short name), `--dataset`
(substring), `--status`, `--text` (regex over title, summary, findings).
`--full` adds data sources, dependencies, findings. `--repo PATH` if
`levante-analysis` isn't a sibling. Task-specific notebooks list first.

The metadata is an index. Two habits turn it into a trustworthy answer:

1. **Check each finding's provenance against the notebook itself.** Read
   the notebook's text for the claims you report and confirm the metadata's
   `data` versions and `last_run` are consistent with it. Metadata was
   partly back-filled and can be wrong; a notebook comparing "published
   (buggy)" scores with corrected ones, for instance, was computed on v1.0
   data whatever its header says. When they disagree, say so and say which
   you believe.
2. **Look for stale restatements.** Findings get superseded, but slides,
   reports, READMEs, `LEVANTE.md`, and older notebooks keep repeating the old
   version. Grep for the claim across `levante-analysis` (incl. `slides/`,
   `reports/`, `README.md`) and `levante-data-meta/LEVANTE.md`, and list
   documents that contradict the current understanding, so the user knows
   what not to cite.

Report each finding with what decides its weight: `status` (`draft` means
AI-generated and not human-verified: currently every notebook; for
`superseded`, point to the replacement and say which old findings still
hold), the data version it was computed on, and which datasets it covers.
Mention other repos (`levante-pilots` holds the core-tasks paper) when
relevant; they have no metadata.

## Reviewing analysis code or plans

Read `levante-data-meta/LEVANTE.md` in full. It is the authoritative list of
data, scoring, and interpretation pitfalls; review the code or plan against
all of it, and open the linked notebooks when you need the detail.

Before applying a pitfall, establish what the code actually touches: which
dataset and version it loads, which tasks, raw vs processed tables. Many
pitfalls are specific to one data source (e.g. the ToM placeholder rows
exist only in the newest per-site processing, `schema_row` only in raw
tables). Report a pitfall as present only when the code hits it; put
"if you switch to X" advice separately.

Report issues ordered by severity (wrong numbers → reproducibility or
interpretation → worth knowing), each with a line number (or plan step),
what goes wrong, and the fix. If the analysis overlaps existing notebooks,
end with the related prior work from the finder, with provenance.
