# Evaluating `levante-guide`

`evals.json` holds four realistic test prompts, each with a list of
checkable expectations:

1. Review a seeded analysis script (`files/seeded_analysis.R`, six planted
   mistakes).
2. "Has anyone looked at vocab growth in Bogotá?" (finder, provenance).
3. "What's the current understanding of Bogotá math regression to the
   mean?" (superseded notebooks).
4. Review a plan to compare ToM across countries (plan review, no code).

## Prerequisites

- The LEVANTE root laid out as in `levante-data-meta/README.md`, with
  `levante-analysis` checked out at a commit that has the `levante:` notebook
  metadata.
- R with the `yaml` package.
- Claude Code with the Anthropic `skill-creator` skill available.

## Running the evaluation

From a Claude Code session started in `levante-data-meta`, ask:

> Use skill-creator to evaluate the levante-guide skill with its
> evals/evals.json, against a no-skill baseline.

skill-creator then:

1. Runs each prompt twice in separate sessions, once with the skill and once
   without (8 sessions for 4 prompts).
2. Grades every output against its expectations.
3. Opens a review page with two tabs: **Outputs** (each answer side by side,
   with a feedback box) and **Benchmark** (pass rates, time, and tokens,
   with vs without the skill).

Leave feedback on the page and submit it; skill-creator uses it to revise
the skill and can rerun the evaluation as a new iteration. Workspace files
go in `levante-guide-workspace/` next to the skill directory; don't commit
them.

**What the baseline measures.** Baseline sessions still load `CLAUDE.md`,
which tells Claude to read `LEVANTE.md`. So the comparison is "Claude with
the repo docs" vs "Claude with the docs plus this skill", not vs a blank
Claude. A small gap on eval 4 would mean `LEVANTE.md` alone already covers
plan review; the finder evals (2, 3) should show the larger difference.

**Cost.** Each run is a full agent session; expect several minutes and a
noticeable token spend for the 8 sessions.

## Triggering (optional)

A separate question is whether Claude invokes the skill without being told
to. skill-creator's description optimizer tests the `description` field on
~20 should/shouldn't-trigger prompts and proposes a better one. Ask for
"optimize the levante-guide skill description" after the main evaluation
looks good. It needs the `claude` CLI.

## When to rerun

After changing `SKILL.md`, `references/checks.md`, or the finder script, and
after notebook metadata changes that affect evals 2–3 (e.g. a notebook marked
`reviewed` or `superseded`). Update the expectations when the underlying facts
change, e.g. after the Same & Different status is settled (https://github.com/levante-framework/levante-data-meta/issues/3).
