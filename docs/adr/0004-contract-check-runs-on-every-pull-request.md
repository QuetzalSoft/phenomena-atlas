# 0004 - The contract check runs on every pull request

- Status: accepted
- Date: 2026-10-23

## Context

`0003-typespec-authoring-openapi-artifact.md` made `oasdiff breaking --fail-on ERR` a
blocking check on every contract pull request. It is enforced by `main`'s ruleset, which
requires a status named `contract` before a pull request can merge.

The workflow that produces that status originally ran only when `contracts/**` changed,
through a `paths` filter on its `pull_request` trigger. GitHub cannot tell a workflow that
a path filter skipped from one that has not reported yet, so a required check behind a path
filter stays "Expected - waiting for status to be reported" forever. Every pull request that
left `contracts/` untouched, which is most of them, could never merge.

Three ways to report a status without verifying an unchanged contract were considered:

- **A job-level `if:`.** A job skipped by a condition reports success, so it would unblock
  merges. But it reports success whatever the reason it was skipped. If the condition
  depends on an earlier job that detects changes and that job fails, the dependent job is
  skipped and the required check passes with nothing verified.
- **A second "skip" workflow** on the inverse path filter, reporting the same `contract`
  name. This is GitHub's documented workaround. It leaves two workflows claiming one status
  whose filters must be kept exact inverses by hand; any drift either reopens the deadlock
  or lets a contract change through unverified.
- **One job that always runs, with the decision made by its steps.** A detector step works
  out whether the contract changed, and every verification step is conditional on it.

## Decision

The `contract` job runs on every pull request, and whether it verifies anything is decided
by steps inside it.

- `on.pull_request` in `.github/workflows/contract.yml` has no `paths` filter, and the job
  has no job-level `if:`.
- A `Detect contract changes` step diffs the pull request against its base over
  `contracts/` and the workflow file itself. Every verification step depends on its answer.
- The detector fails closed. If it cannot tell whether the contract changed, the check
  fails rather than passing unverified.
- The detector's pathspec stays a superset of `on.push.paths`, so the two agree on what "the
  contract changed" means.

The workflow repeats these rules in comments at the places a future edit would break them.

## Consequences

Good:

- Pull requests that leave the contract alone get a green `contract` in seconds and can
  merge.
- A broken detector fails the check instead of passing it, which neither alternative
  guarantees.
- One workflow owns the `contract` status. There is nothing to keep in sync with a twin.

Bad, and accepted deliberately:

- A green `contract` no longer proves the contract was verified. When nothing under
  `contracts/` changed, the verification steps are skipped and the job still succeeds.
  Reviewers of a contract change have to check that the `No breaking changes` step ran,
  which `docs/release.md` asks them to do.
- Every pull request now starts a runner and does a full-history checkout, even when there
  is nothing to verify.
- The detector's pathspec and `on.push.paths` express one rule twice, and only a comment
  keeps them aligned.
- Like any workflow in a public repository, a pull request from a first-time external
  contributor's fork waits for a maintainer to approve the run, and `contract` stays
  pending until then. That is GitHub's fork policy and no workflow change removes it.
