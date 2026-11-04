# 0005 - main is production, develop integrates the sprint

- Status: accepted
- Date: 2026-11-04

## Context

Until now every repository was trunk-based: short-lived branches off `main`, merged
straight back into it. That made `main` two things at once: the branch the team
integrates its work on, and the branch that describes what is in production. The team
works in sprints, and an issue that is finished and reviewed is not necessarily one that
should reach production yet. With a single branch there is nowhere for that work to wait.

The contract adds a constraint of its own. It is published when it merges, and the
components pin a published version. Whatever branch the components integrate on has to be
able to consume a contract change before that change is in production.

## Decision

Every repository (this one, `phenomena-atlas-api`, `phenomena-atlas-web`, and
`phenomena-atlas-mobile` once it exists) has two long-lived branches:

- `main` is what is in production. It only receives releases and hotfixes.
- `develop` is where the sprint's issues are merged. It is the default branch, so a new
  branch starts from it and a new pull request targets it.

The flow:

- **Issues**: branch off `develop`, pull request into `develop`.
- **Release**: a pull request from `develop` into `main`, merged with a merge commit.
- **Hotfix**: branch `hotfix/*` off `main`, pull request into `main`, then a pull request
  from `main` into `develop` so the fix is not lost at the next release.

Both branches are protected by a ruleset of their own, with the same rules: changes go
through a pull request with one approving review, and the branch cannot be deleted or
force-pushed. Organisation admins can bypass them, as before. On top of that:

- `main` only accepts merge commits. A squashed or rebased release gives `main` commits
  that `develop` does not have, and every later release shows them as conflicts.
- `main` requires the `source-branch` check (`.github/workflows/source-branch.yml`), which
  fails any pull request whose head is not `develop` or `hotfix/*` in the same repository.
  Rulesets cannot restrict the source branch of a pull request; the check is how it is
  enforced.
- In this repository the `contract` check is required on both branches. A contract pull
  request is compared against `develop`, and the release against `main`.

The contract is published from both branches (`.github/workflows/publish-contract.yml`):

- A merge into `develop` with a new version publishes `X.Y.Z-dev.N` under the `next`
  dist-tag. The components' `develop` branches pin that prerelease.
- A merge into `main` publishes the stable `X.Y.Z` under `latest`. A component pins the
  stable version before it is released itself.

## Consequences

Good:

- `main` always says what is in production, and work can be finished without being
  shipped.
- A release is one reviewable pull request with the whole sprint's diff, and in this
  repository the release is checked for breaking changes against the contract that is
  actually in production.
- The components can implement a contract change during the sprint without that change
  first reaching production.

Bad, and accepted deliberately:

- `develop` is a long-lived branch, which trunk-based development avoided. Work merged
  there is integrated, not released; a defect can sit in it until the next release.
- A hotfix is two pull requests, and forgetting the back-merge into `develop` loses the
  fix at the next release. Nothing automates it.
- A component on `develop` pins a prerelease, and has to move to the stable version
  before its own release. Releasing a component that still pins `-dev.N` ships a contract
  version that `latest` does not describe.
- The release order across repositories still follows `docs/release.md`: the contract
  first, then the API, then the clients. Two branches per repository make that order
  apply twice, once on `develop` and once on `main`.
- `source-branch` relies on a branch name. Anyone who can push a branch called
  `hotfix/anything` can open a pull request into `main` with arbitrary content; the
  required review is what stops that, not the check.
