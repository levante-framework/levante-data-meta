# LEVANTE — cross-session context

Orientation doc for any Claude session touching LEVANTE (the R package, the
data, Redivis, the analysis repos, or the manuscripts). Read this first so you
don't have to re-ingest papers, package docs, and the researcher website.

Last substantially updated 2026-07.

---

## What LEVANTE is

The **Learning Variability Network Exchange (LEVANTE)** is a federated,
longitudinal cohort study of child development (ages 2–12; current waves focus
on 5–12). Funded by the Jacobs Foundation. Goal: measure **variability and
change** in children's learning across individuals, contexts, and cultures, via
a shared open measurement battery collected by sites worldwide. Data are
de-identified and released openly on a rolling basis.

**Mike Frank (Stanford)** is the PI and **head of the Data Coordinating Center
(DCC)** — i.e. he can authorize changes to measures, scoring, validation, and
data design. If a session uncovers a data/scoring/infrastructure problem, it is
in-scope to flag it for the DCC.

Two manuscripts (PDFs in `levante-longitudinal/papers/`):
- **Frank et al. 2025, *Child Development*** — the framework paper (rationale,
  federated design, constructs, governance, scientific aims).
- **Kachergis, O'Reilly et al. (dec 2025 ms)** — the **core tasks** paper
  (the 9 tasks, IRT scoring, measurement invariance, CAT construction).

## The core tasks (9 tasks, 5 constructs)

| Construct | Task | long `task_id` | short |
|---|---|---|---|
| Executive function | Hearts & Flowers | `hearts-and-flowers` | hf |
| Executive function | Memory (Corsi) | `memory-game` | mg |
| Executive function | Same & Different | `same-different-selection` | sds |
| Reasoning | Pattern Matching (Matrix) | `matrix-reasoning` | matrix |
| Spatial cognition | Shape Rotation (Mental Rot.) | `mental-rotation` | mrot |
| Math | Math (EGMA) | `egma-math` | math |
| Language | Vocabulary | `vocab` | vocab |
| Language | Sentence Understanding (TROG) | `trog` | trog |
| Social cognition | Stories (Theory of Mind) | `theory-of-mind` | tom |

Plus literacy/validation measures: ROAR-Word (`swr`), ROAR-Sentence (`sre`),
ROAR-Phoneme (`pa`), and the commercial MEFS (`mefs`). Tasks are
multi-alternative forced choice (≤4 options); mostly untimed; jsPsych-based;
English/Spanish/German + expanding. `task_id` uses long forms; the pilots-paper
SEM code uses short forms — expect to remap.

## Infrastructure map

- **Tasks (stimuli/code):** `github.com/levante-framework/core-tasks`,
  jsPsych. Demos at `researcher.levante-network.org`. CC-BY-NC.
- **Dashboard:** forked from ROAR (Rapid Online Assessment of Reading);
  assigns task bundles + surveys to children/caregivers/teachers.
- **Data flow:** dashboard → harmonization + validation → **Redivis** data
  repository → periodic releases (6-month embargo, then public).
- **R packages (split from the old `rlevante`, 2026-07):** two repos,
  `packages/levante-r` and `packages/levantemodels` (see
  `levante-data-meta/README.md` for the standard directory layout).
  - **`levante-r`** (package `levante`,
    `github.com/levante-framework/levante-r`) — **data access only**:
    `get_scores()`, `get_trials()`, `get_participants()`, `get_surveys()`,
    `get_parameters()` (processed item parameters), `get_raw_table()` (raw
    per-site tables).
  - **`levantemodels`** (renamed from `rlevante`,
    `github.com/levante-framework/levantemodels`) — **all processing,
    recoding, and scoring**: `process_trials_prelim()`/`process_trials()`,
    `process_runs()`, `process_participants()`, `process_surveys()` /
    `link_surveys()`, `recode_trials()`; scoring/registry:
    `fetch_scoring_table()`, `fetch_scoring_parameters()` (raw
    `item_parameters` metadata table), `fetch_registry_dir()` (renamed from
    `fetch_registry_table()`), `get_model_spec()`, `get_model_record()`,
    `score()`/`score_irt()`, the `ModelRecord` S4 class. `levantemodels`
    **depends on `levante`** for its underlying data queries (calls
    `levante:::get_datasets_data()` etc. internally) — `levante` is the base
    layer, `levantemodels` sits on top for anything scoring-related.
- **Researcher site:** `researcher.levante-network.org` — task demos, data
  portal (`/data`), and "Scoring and Psychometrics" docs.
- **Public dashboard / data overview:**
  `levante-framework.github.io/levante-datapage` (good sanity check for "what
  data exists").
- **Network/landing:** `levante-network.org`.

## Redivis datasets (the ones that matter)

- **`levante_data_latest:e9pf`** — unified dataset binding ALL sites together.
  Tables `scores` and `trials`. Has both `site` (e.g. `pilot_uniandes_co`,
  rolls bogotá+rural together) and `dataset` (e.g. `pilot_uniandes_co_bogota`,
  preserves sub-site). **Prefer this** for analysis of processed data.
  **Version history matters: v1.0 was scored with the column-order bug (do
  not use); v1.1/v1.2+ are corrected.** Pin v1_2 or later.
- **`levante_metadata_scoring:e97h`** — scoring metadata. Tables:
  `item_parameters:4cvk` (IRT difficulty/discrimination per item — NOT in the
  trials table), `model_registry:rqwv` (model file ids), `scoring_models:t416`
  (which model spec applies to each task×dataset).
- **`levante_metadata_items:czjv`** — item-identity metadata used by
  processing: `trial_items` (retroactive trial_id → item_uid map for early
  data), `mapping_items` (content-keyed map), `corpus_items` (item_uid →
  task/group/entry/chance).
- **Per-site datasets come in two flavors:** `*_processed` (analysis-ready)
  and **raw** (same name *without* the suffix, e.g.
  `pilot_uniandes_co_bogota`, `pilot_mpieva_de_main`). Raw datasets carry the
  tables `trials` (with `item_id`, `corpus_trial_type`, `answer`,
  `distractors`, `server_timestamp`, `trial_index`, `valid_trial`…), `runs`
  (`task_version`, `variant_id`, `time_started`, `completed`, `valid_run`),
  and `variants` (language, adaptive, corpus). Access via
  `levante::get_raw_table()`, or `levantemodels::process_trials_prelim()` /
  `process_runs()` with a dataset spec. Raw data is the ground truth for any
  item-identity / deployment forensics.

- **Downward-extension (ages 2–5) datasets** (2026-08): **Boston Children's**
  raw `pilot_bostonchildrens_us_main_raw:7e6c` (first tranche v4_26: 31 kids,
  228 runs, 9 tasks) and processed **`pilot_bostonchildrens_us_main:2fj2`**
  (v0_1, EAP θ from the 5–12-calibrated models — θ tracks hand accuracy
  r≈0.8–1.0 but SEs are 0.4–0.9, exclusions strip most under-3 runs, and
  **matrix is unscorable, 1/32 runs: the "Downward Extension" matrix variant's
  items don't map into the calibrated bank**). Analysis + task-selection
  verdict for 2-year-olds (keep vocab/trog, drop math/memory) in
  `levante-longitudinal/10_downward_extension.qmd`. Other downex raw datasets:
  `pilot_langcog_us_downex_raw:a6kb` (Stanford) and
  `partner_sparklab_us_downex_raw:4n9e`. To resolve a Redivis admin-URL id
  (e.g. `…/datasets/7e6c-…`) to a `name:code` reference, list
  `redivis$organization("levante")$list_datasets()` and match the code prefix.
  Raw-table gotchas: a literal `schema_row` placeholder row/`task_id` to drop;
  `is_practice_trial` separates practice; `distractors` is a JSON-ish dict
  (chance = 1/(n+1)); `runs` carries dashboard `num_attempted`/`num_correct`
  (hand scores match exactly on mrot/pa/trog/vocab); CAT tasks store a running
  `theta_estimate` per trial with a **hard floor at θ = −6** (floor code, not a
  measurement); pipeline validity flags `less_than_10_test_trials` /
  `straightlining_10` in `validation_msg_run`.

**Auth:** Redivis calls trigger browser OAuth — user clicks once per session;
not bypassable headlessly. **Pin versions** with the qualified reference
`name:hash:version` (e.g. `levante_data_latest:e9pf:v1_2`); both packages warn
if you don't.

## Scoring pipeline (how scores are made)

- Tasks scored with **multi-group IRT** via the `mirt` package.
- Cross-site tasks use **`multigroup_site` scalar** Rasch (math, matrix,
  hf, mg, trog) or 2PL (sds, mrot — more discrimination spread).
  `vocab`, `swr`, `pa`, `tom` use **`by_language`** single-group models.
  `sre` is not IRT at all (speeded guessing-adjusted z-scored count);
  `swr` is a CAT θ (`ability_cat`); mind the `score_type` column before
  pooling or thresholding "extreme" scores.
- LEVANTE "Rasch" models are **Rasch + a fixed guessing floor** `g = 1/#alts`
  (0.25 for 4AFC). They are *not* pure 1PL — this matters for any
  raw-score-sufficiency reasoning.
- Person scores are **EAP** with a per-group prior N(mean, var). EAP shrinks
  toward the group mean with strength inversely proportional to test
  information → short/CAT sessions shrink harder. This biases naïve
  longitudinal comparisons across administrations of differing length.
  (Empirically, with correct scoring and ~40+ item sessions the EAP–WLE
  difference is small; the DCC decided to stay on EAP. WLE is the lever to
  revisit if very short forms appear.)
- Most tasks have **adaptive (CAT)** and **non-adaptive (fixed-form)** variants;
  CAT was added mid-pilot. Residual cross-mode differences on corrected data
  are modest (< ~0.75 logits) — mild non-adaptive ceiling + EAP shrinkage.

### How trial→item identity is constructed (fragile; know this before item work)

`levantemodels` processing (`process-trials.R`) assigns each trial's `item_uid`
from up to three **competing sources**: the deployed task's own `item_uid`
(only written by later task builds), the **retroactive `trial_items` map**
(trial_id → uid, hand/script-assigned — the *only* source for early-2024
data), and a content-keyed `mapping_items` join. Notes that stay true:

- Early-epoch data (≈ pre-July 2024, incl. ALL Bogotá ToM) has **no deployed
  uids** — identity rests wholly on the retro map; deployed-uid and map-based
  epochs **don't overlap**, so sources can't cross-validate each other.
- The published trials table **drops `item_uid_source`** and the raw fields;
  re-run the internals on raw data if you need them.
- ToM story-level uids (`tom_story4_…`) are **constructed at recode time**
  (`recode_tom`): story number = leading digits of the raw `item` string,
  question identity = corpus `entry`. The raw `item` string is a deployment
  **version code** (`1c`, `4d`, `4c_new3`); `answer`/`distractors` are
  **English stimulus keys** (`rug`, `shelf`) in every language — these two
  fields are the durable, language-independent ground truth for identity
  forensics.
- **Question order within a block can differ by site** — never use
  position-based retro-mapping across sites.
- `recode_trials()` must be applied before scoring (HF RT recodes, SDS
  rescoring, slider thresholds, ToM disaggregation, answer fixes).

### Hard-won scoring/validation handles (permanent)

- **`mirt::fscores(response.pattern=)` matches columns BY POSITION, not
  name.** Always reorder the response matrix to `items(mod_rec)` before
  scoring (root cause of the v1.0 mis-scoring bug).
- **`ModelRecord@scores`** holds calibration-time EAP scores — the gold
  standard to validate any hand-rolled rescoring against (expect r = 1.000).
- **Below-chance accuracy per item × site is a key-defect detector**: a
  comprehension item can't score below chance unless its answer key is
  wrong/inverted. Run this screen before interpreting DIF.
- Trials → scores rescoring chain (all in `levantemodels`):
  `fetch_scoring_table()` → `get_model_spec()` → `get_model_record()` (via
  `fetch_registry_dir()`) → `recode_trials()` → shape wide → reorder columns
  → `fscores()`. A corrected reference implementation lives at
  `levante-longitudinal/common.R::score_with_method()`.

## Surveys (caregiver / teacher / child) — separate pipeline from scores

Survey/questionnaire data does **not** live in `scores`/`trials`. Pull it with
`levante::get_surveys()` (internals: `process_surveys()` + `link_surveys()` in
`packages/levantemodels/R/process-surveys.R`). **Caregiver-survey
psychometrics live in `papers/survey-caregiver`** (separate repo;
`analysis/00–03` + `analysis/common.R` + editable `analysis/constructs.csv`
catalog). Two realities there: (1) **RESOLVED as of the `levantemodels` split**
— published `rlevante` 0.1.0's `link_surveys()` was stale (it filtered old
`survey_part` levels `caregiver`/`child_specific` and returned 0 caregiver rows
on current data); current `levantemodels::link_surveys()` correctly handles
`general`/`specific`. (2)
**Sites ran different caregiver batteries** — Leipzig ran the full ~102-item
reduced set, Bogotá/Western only ~29 shared items, so cross-site invariance is
possible for only ~8 subconstructs (mostly Caregiver Well-Being). Long format
keyed by `survey_type`
(caregiver/teacher/child), `survey_part` (caregiver = `general` household +
`specific` per-child), `construct`, `variable`, and an analysis-ready `value`
that is **already reverse-coded** (verify the recode — `reverse_value()` silently
NAs out-of-range responses). Caregiver↔child links are many-to-many
(`parent1_id`/`parent2_id`). **Strategy + style handoff for survey psychometrics:**
`levante-longitudinal/reports/survey_caregiver_handoff.md`.

## Repo notes

Paths below are relative to the LEVANTE root directory — see
`levante-data-meta/README.md` for the standard directory layout (this repo
and its siblings, including `packages/levante-r`, `packages/levantemodels`,
`levante-longitudinal`, `levante-pilots`).

- **`levante-longitudinal`** — exploratory longitudinal analyses (this is
  where the data-integrity/trial-level investigations + the
  corrected-scoring work live). Sequential Quarto notebooks 00→10, plus
  `tasks/` (per-task deep dives), `reports/`, and `common.R` (shared
  loaders/palettes/`score_with_method()`). It is a **Quarto book** that
  publishes to a **public** Quarto Pub URL; `_quarto.yml` renders only
  `0[0-9]_*.qmd` + `tasks/*.qmd`, so new chapters (e.g. `10_…`) are *not*
  published unless deliberately wired in — mind this for unreleased data.
  **renv gotcha (2026-08):** the repo uses renv; a fresh checkout needs
  `renv::restore()`, but the lockfile pins `Matrix`/`survival`/`RcppArmadillo`
  at versions with no CRAN binaries → source build fails on this Mac
  (`libintl.h` missing) and cascades to lme4/mgcv/ggplot2. Fix:
  `renv::install(c("Matrix","survival","RcppArmadillo"), type="binary")` then
  `renv::restore(exclude = c("Matrix","survival","RcppArmadillo"))`.
- **`levante-pilots`** — the core-tasks paper repo. `03_summaries/sem.qmd`
  and `04_paper/ms_mfc.Rmd` have the published SEM + manuscript.
  Ground-truth scored data at
  `02_scoring_outputs/scores/scores_combined.rds`.
- `levante_bench`, `levante_tom` — other LEVANTE sub-projects that exist but
  aren't part of the standard directory layout yet (not characterized here).

## Known data issues / gotchas (as of 2026-06, data v1.2 / metadata v1_14)

- **RESOLVED: the v1.0 column-order scoring bug.** `score_irt` didn't reorder
  response columns to the model's item order before `fscores()` (which
  matches by position) → all IRT-scored tasks in v1.0 were mis-scored (worst
  for CAT/guessing items). Fixed in rlevante; data re-released as
  **v1.1/v1.2**. Most apparent v1.0 "longitudinal declines" and
  "CAT-vs-non-CAT step shifts" were this bug. Writeup:
  `levante-longitudinal/reports/rlevante_handoff.md`. Lesson retained above
  (fscores positional matching).
- **`adaptive` flag missing** on ~235 runs in v1.2 (early-beta task_versions
  of Bogotá Memory + Leipzig/Western Math); all are non-adaptive
  (DCC-confirmed); backfill to FALSE.
- **ToM (Stories) early-deployment item-identity defects** (forensics:
  `levante-longitudinal/tasks/tom_reality_check_bug.qmd`): inverted answer
  keys on specific cells (CO `moral_reasoning_reality_check_1` at 8% on 2AFC;
  CO `reference_reference`; late-DE `deception_reality_check_2/_3`); 110 DE
  runs (Sept–Oct 2024) with hostile-attribution answer keys under ToM uids;
  trial-map shifts in DE `6c/6d` (86 runs) and `2f` (47 runs); ~4,200 valid
  CO ToM trials unmappable/dropped. This manufactured most of the
  reality-check cross-site DIF (repairing provable defects removes ~70% of
  scalar non-invariance). Until fixed upstream, treat ToM controls as
  non-comparable across sites.
- **Memory**: release notes flag the 2×2/3×3 scoring concern, but grid size
  is already a separate calibrated item dimension — the DROP flag is likely
  obsolete on corrected data (`tasks/memory.qmd`).
- **Same & Different** has new scoring models pending implementation; hold
  analysis until they land. Full model comparison + recommendation (2026-07):
  `levante-pilots/03_explore_tasks/blockCAT/sds/model_tree_mirt/sds_scoring_report.qmd`.
  Three findings to propagate: (1) **`levantemodels::recode_sds()` has a
  repeat-detection bug** — it compares raw response strings, so re-selecting
  the same pair in the opposite card order counts as "new"/correct (~6.5% of
  selections, 2/3 of runs, buggy-vs-corrected score r = .92); fix = compare
  sorted parsed pairs, as `_recode_sds.R` does. (2) Theory-derived random-pair
  guessing floors are misspecified (children perseverate *below* floor on
  "new" nodes) and cost ~.05 test–retest reliability — score SDS match blocks
  with **status-aware dichotomous items (`sds_{block}_{choice}_{status}`),
  `chance = 0`**; IRTree scoring is measurement-equivalent (r = .99) but not
  worth the pipeline surgery; keep the tree for diagnostics (stable signal is
  perseveration-resistance, not match-finding). (3) The corpus chance metadata
  for SDS match items (0.5/0.75/0) matches no guessing model.
- **ROAR-Word** floor (θ=−6) runs: mix of true non-readers and rushers
  (filter: trial accuracy <40% or median RT <500ms).
- **TROG German `trog_embedding_cat_cow_chase_black` is broken** (1% correct
  in German vs 42–55% elsewhere; ~6.5-logit DIF) — mistranslation/wrong key.
- **Math item bank** is skewed: nearly all items above β=1 are number-line,
  so CAT routes high-ability kids almost entirely onto number-line items.
  Math cross-language DIF concentrates in multiply/subtract — likely
  curriculum timing, not translation.
- **Hearts & Flowers** has a hard ceiling: θ capped ≈ 2.0, reached exactly by
  perfect-accuracy kids (~10% of runs; ~16% in Canada) — no items hard enough
  at the top.
- **Bogotá's partial-battery assignment** leaves some task pairs with zero
  joint observations (e.g. swr×sre at T2) — full multigroup FIML across all
  sites is infeasible; per-site CFAs or 2-group (DE+Canada) multigroup work.

## When in doubt

- Site-to-site **mean comparisons are discouraged** (confounded by
  sampling/recruitment/administration). Within-site change and cross-site
  *associations* are the interpretable targets.
- For longitudinal work, mind the adaptive/non-adaptive boundary and EAP
  shrinkage before reading θ differences as growth.
