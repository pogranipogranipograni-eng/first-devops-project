# ADR-0001: Use Git Flow as the branching strategy

- **Status:** Accepted
- **Date:** 2026-11-09
- **Author:** Konrad

## Context

This project is developed as part of a DevOps course, which requires a clear
branching strategy. The course requirements specify the Git Flow model. So far
the repository has used a single `main` branch, so we need a defined way of
introducing changes and marking versions.

## Decision

We use **Git Flow** with the following branches:

| Branch | Purpose | Branches off | Merges into |
|---|---|---|---|
| `main` | stable releases, every commit tagged with a version | - | - |
| `develop` | ongoing work, feature integration | `main` (once) | - |
| `feature/*` | a new feature or exercise | `develop` | `develop` |
| `release/*` | release preparation (stabilization) | `develop` | `main` and `develop` |
| `hotfix/*` | urgent production fix | `main` | `main` and `develop` |

Additional rules:

- versioning follows **Semantic Versioning** (`vMAJOR.MINOR.PATCH`),
  releases are marked with tags (e.g. `v1.0.0`)
- commit messages follow **Conventional Commits** (`feat:`, `fix:`,
  `docs:`, `chore:`, etc.)
- merges use `--no-ff` so that branches remain visible in the history
- changes reach `develop` and `main` through pull requests

## Rationale

- course requirement
- clear separation between ongoing work (`develop`) and stable releases (`main`)
- ability to stabilize a version on `release/*` without blocking new work
- a dedicated path for production fixes (`hotfix/*`)

## Alternatives considered

- **GitHub Flow:** simpler, but does not meet the course requirements and has
  no release stabilization stage.
- **Trunk-based development:** requires mature automated tests and feature
  flags; too demanding for this project.

## Consequences

**Positive:**
- clear structure and a defined place for every kind of work
- controlled, tagged releases

**Negative:**
- more branches and steps (merging into two places for `release` and `hotfix`)
- less frequent integration, higher risk of conflicts on long-lived branches

## Implementation

1. Create `develop` from the current `main`: `git switch -c develop`
2. Push it: `git push -u origin develop`
3. Protect `main` and `develop` on GitHub (pull request required)
4. Continue work according to the table above
