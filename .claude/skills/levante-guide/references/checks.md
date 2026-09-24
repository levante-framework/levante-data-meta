# LEVANTE analysis checks

Concrete things to look for when reviewing LEVANTE analysis code or an
analysis plan. Each check says what to look for, why it matters, and where the
full story lives. Section names refer to `levante-data-meta/LEVANTE.md`, which
is authoritative: if it disagrees with this file, trust it and point out the
mismatch.

Severity: **error** = produces wrong numbers; **warn** = results may not be
reproducible or interpretable as intended; **note** = worth knowing.

## Data source and versions

1. **Unpinned Redivis versions (warn).** Look for `get_scores()`,
   `get_trials()`, `get_raw_table()`, etc. called with no `version` or with
   `version = "current"`. Datasets change under the same name, so results
   won't reproduce. Pin with `name:code:version`. The unreleased `next` draft
   is mutable too: cache the pull and record when it was made.
   → "Redivis datasets", "Auth"
2. **`levante_data_latest` v1_0 (error).** Mis-scored by the column-order bug.
   Use v1_1+ or the per-site datasets. → "Known data issues" (RESOLVED item)
3. **`levante_data_latest` treated as current (warn).** It is stale (June
   v1_2 snapshot, and v1_2 was later extended in place under the same version
   string). Newer data live only in the per-site `*_processed` datasets; see
   `levante-analysis/common.R::levante_site_specs` and
   `load_levante_scores_sites()`. → "Redivis datasets"
4. **Newest per-site processing quirks not handled (error).** Each ToM run
   has an all-NA placeholder duplicate row; unscoreable runs arrive as
   `exclusion` rows with no score; `site` can be NA. Code that counts runs or
   averages scores without dropping these is wrong.
   → `levante-analysis/common.R::load_levante_scores_sites()` and
   `clean_levante_scores()`
5. **Short vs long task names mixed (note).** `task_id` uses long forms
   (`egma-math`); older SEM code uses short forms (`math`). Joins silently
   drop rows if they are mixed. → "The core tasks"

## Scores and scoring

6. **Pooling across `score_type` (error).** `sre` is a z-scored
   guessing-adjusted count, not an IRT θ; `swr` is a CAT θ (`ability_cat`).
   Pooling, thresholding "extreme" scores, or putting them on one axis
   without checking `score_type` mixes scales. → "Scoring pipeline"
7. **θ = −6 treated as a real score (error).** It is a floor code
   (ROAR-Word CAT, and the running `theta_estimate` in raw CAT trials).
   Floor runs are rushers or at-chance non-readers; filter them (accuracy <
   0.4 or median RT < 500 ms) before change scores. → "Known data issues"
   (ROAR-Word), "Downward-extension datasets"
8. **Hand-rolled rescoring with `mirt::fscores(response.pattern = ...)` (error
   unless handled).** `fscores` matches columns by position, not name. The
   response matrix must be reordered to `items(mod_rec)` first; this is the
   v1.0 bug. Prefer `levantemodels::score_irt()` (fixed) or
   `levante-analysis/common.R::score_task_irt()`. Validate against
   `ModelRecord@scores` (expect r = 1.000). → "Hard-won scoring/validation
   handles"
9. **Scoring without `recode_trials()` (error).** Recoding (H&F RT rules, SDS
   rescoring, slider thresholds, ToM disaggregation, answer fixes) must happen
   before scoring. → "How trial→item identity is constructed"
10. **Treating LEVANTE "Rasch" as pure 1PL (warn).** Models include a fixed
    guessing floor `g = 1/#alts`, and the `item_parameters` table omits `g`.
    Person-fit, sumscore-sufficiency, or IRF-based reasoning must use the
    item's chance level. → "Scoring pipeline";
    `levante-analysis/06_within_child_variability.qmd`
11. **Same & Different status (check before use).** `LEVANTE.md` and
    `levante-analysis` disagree on whether the corrected SDS scoring has
    landed (registry v2_3). Check `levante-analysis/01_data_integrity.qmd`'s
    summary and the current scoring registry, and say which you relied on.
    `levantemodels::recode_sds()` had a repeat-detection bug (raw-string
    comparison); confirm the installed version compares sorted pairs.
    → "Known data issues" (Same & Different)

## Comparisons and longitudinal claims

12. **Cross-site mean comparisons (warn).** Scalar invariance fails across
    sites; site-mean differences are also confounded with sampling and
    administration. Within-site change and cross-site *associations* are the
    interpretable targets. → "When in doubt";
    `levante-analysis/03_structure_invariance.qmd`
13. **θ change across the adaptive/non-adaptive boundary (warn).** EAP
    shrinks short/CAT sessions harder toward the group mean, so T1→T2
    differences that cross a mode boundary (or a big test-length change) are
    biased. Check `adaptive` per wave. ~235 early-beta runs have
    `adaptive = NA`; they are non-adaptive (backfill FALSE, DCC-confirmed).
    → "Scoring pipeline", "Known data issues"
14. **Two-wave growth read as individual growth (note).** With 2 waves,
    individual slope reliability is ≈ 0. → `levante-analysis/06_within_child_variability.qmd`
15. **Full-battery FIML across all sites (warn).** Bogotá's partial battery
    leaves some task pairs with zero joint observations; use per-site models
    or a DE + Canada multigroup. → "Known data issues"

## Task-specific

16. **Theory of Mind (warn).** Early-deployment item-identity defects
    (inverted keys, hostile-attribution content under ToM uids, trial-map
    shifts); reality-check controls are not comparable across sites. ToM also
    changed most in the v2_3 re-scoring (r = 0.88 vs June), so re-check
    older ToM conclusions. → "Known data issues" (ToM);
    `levante-analysis/tasks/tom_reality_check_bug.qmd`
17. **Memory sumscores across grid sizes (error).** Raw sumscores are not
    comparable across 2×2 and 3×3 grids; use θ. Uncalibrated `len8` trials
    should be excluded. → `levante-analysis/tasks/memory.qmd`
18. **TROG German item `trog_embedding_cat_cow_chase_black` (warn).** Broken
    (~6.5-logit DIF); exclude from item-level cross-language work.
19. **Hearts & Flowers ceiling (note).** θ is capped ≈ 2.0 (~10% of runs at
    perfect accuracy); top-end differences are censored.
20. **Math item bank (note).** Nearly all items above β = 1 are number-line,
    so high-ability CAT sessions are mostly number-line items.
21. **Ages 2–5 (warn).** No validated scoring models; official θs come from
    5–12 calibrations with large SEs, and the downward-extension matrix
    variant is essentially unscorable. → "Downward-extension datasets";
    `levante-analysis/10_downward_extension.qmd`

## Surveys

22. **Survey data looked for in `scores`/`trials` (error).** Surveys come from
    `levante::get_surveys()`. The analysis-ready `value` is already
    reverse-coded (and `reverse_value()` silently NAs out-of-range responses);
    sites ran different caregiver batteries. → "Surveys"

## Raw tables

23. **Raw-table placeholders (error).** Raw `runs`/`trials`/`variants` carry a
    literal `schema_row` placeholder row; practice trials are marked by
    `is_practice_trial`. → "Downward-extension datasets" (raw-table gotchas)
