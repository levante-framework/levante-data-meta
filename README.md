# levante-data-meta

Shared, cross-repo orientation docs for anyone (human or Claude session)
working on LEVANTE data, packages, or analyses:

- **`CLAUDE.md`** — general working/behavioral guidelines (how to collaborate,
  coding style, when to ask vs. proceed).
- **`LEVANTE.md`** — LEVANTE-specific context: project goals, the core tasks,
  infrastructure map, Redivis datasets, scoring pipeline, and known data
  issues/gotchas. Read this before touching LEVANTE data or packages.

## Directory structure

The convention is a single **LEVANTE root directory** (name it whatever you
like, e.g. `levante/`) containing this repo alongside every other LEVANTE
repo, cloned as siblings:

```
levante/                        # your local root — pick any name
├── levante-data-meta/          # this repo — shared CLAUDE.md / LEVANTE.md
├── levante-data-processing/
├── levante-datapage/
├── levante-longitudinal/
├── levante-pilots/
├── packages/
│   ├── levante-r/
│   └── levantemodels/
└── papers/
    ├── mental-rotation/
    ├── survey-caregiver/
    └── survey-child/
    └── tasks-paper/
```

Clone commands (adjust protocol/org as needed):

```sh
mkdir levante && cd levante
git clone git@github.com:levante-framework/levante-data-meta.git
git clone git@github.com:levante-framework/levante-data-processing.git
git clone git@github.com:levante-framework/levante-datapage.git
git clone git@github.com:levante-framework/levante-longitudinal.git
git clone git@github.com:levante-framework/levante-pilots.git

mkdir packages && cd packages
git clone git@github.com:levante-framework/levante-r.git
git clone git@github.com:levante-framework/levantemodels.git
cd ..

mkdir papers && cd papers
git clone https://github.com/levante-framework/mental-rotation
git clone git@github.com:levante-framework/survey-caregiver.git
git clone git@github.com:levante-framework/survey-child.git
git clone git@github.com:levante-framework/tasks-paper.git
```

## Repos

- **`levante-data-meta`** (this repo) — shared `CLAUDE.md` / `LEVANTE.md`
  orientation docs for humans and Claude sessions working anywhere in the
  LEVANTE ecosystem.
- **`levante-data-processing`** — scripts for LEVANTE item/data processing:
  item bank & corpus syncing, item mapping, scoring table/registry updates,
  codebook sync.
- **`levante-datapage`** — interactive web data browser for LEVANTE data
  (participant/assessment counts, ability scores by age, item IRT
  parameters).
- **`levante-longitudinal`** — exploratory longitudinal analyses of LEVANTE
  core-task data as a sequence of reproducible Quarto notebooks; home of the
  data-integrity investigations and corrected-scoring work.
- **`levante-pilots`** — analysis repo backing the LEVANTE core-tasks paper
  (Kachergis, O'Reilly et al.); pilot data processing, scoring, and the SEM +
  manuscript source.
- **`packages/levante-r`** (R package `levante`) — user-facing data-access
  package: `get_scores()`, `get_trials()`, `get_participants()`,
  `get_surveys()`, `get_parameters()`, `get_raw_table()`.
- **`packages/levantemodels`** — internal R tooling for processing, recoding,
  and IRT scoring (trial recoding, scoring pipeline, model registry,
  `ModelRecord`); depends on `levante-r` for data access.
- **`papers/mental-rotation`** — analysis and manuscript code for the mental
  rotation task paper.
- **`papers/survey-caregiver`** — figures/analysis for the caregiver survey
  paper.
- **`papers/survey-child`** — manuscript and code for the child survey
  paper.
- **`papers/tasks-paper`** — manuscript and code for the tasks
  paper.

## Note on `CLAUDE.md` discovery

Claude Code auto-loads `CLAUDE.md` by walking *up* from the working directory
toward the filesystem root — it does not look into sibling directories. So a
session started inside e.g. `levante-pilots/` would **not** automatically
pick up this repo's `CLAUDE.md`/`LEVANTE.md` just because they're siblings
under the same root.

To fix this, every other repo listed above has a one-line stub `CLAUDE.md`
that imports the shared file via Claude Code's `@path` import syntax:

```
@../levante-data-meta/CLAUDE.md
```

(or `@../../levante-data-meta/CLAUDE.md` for repos nested under `packages/`
or `papers/`). If you clone a repo that's missing this stub, add it.
