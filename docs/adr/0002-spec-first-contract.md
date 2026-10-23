# 0002 - The API specification is written before the code

- Status: accepted, amended by `0003-typespec-authoring-openapi-artifact.md`
- Date: 2026-10-22

## Context

`0001-polyrepo-with-contracts.md` made an explicit contract the mechanism that keeps the
API and its clients honest. That leaves the question of which direction the contract
flows.

**Code-first**: the API is written, and the specification is generated from annotations
in it. The specification always matches the implementation, because it is derived from
it.

**Spec-first**: the specification is written and reviewed first, and the API implements
it. A conformance test in the API's CI proves the implementation matches.

Code-first is easier and gives a false sense of safety. A generated specification cannot
disagree with the API, so it can never catch an unintended breaking change: the API ships
a renamed field, the specification faithfully reports the new name, and every client
still breaks. The specification becomes a mirror with a delay, not a contract.

Spec-first also puts interface design in front of the client developers before the API is
built, which is when their feedback is cheap to act on.

## Decision

Spec-first. `contracts/openapi.yaml` is hand-written and reviewed as the primary artifact.
The API implements it and proves compliance through a conformance test. Clients generate
their types and request layer from it.

## Consequences

Good:

- A breaking change has to be written down deliberately before it can happen, which makes
  it reviewable in the same way code is.
- Clients can generate against a new version and start work before the API implements it.
- The specification is a design document, not a build artifact.

Bad, and accepted deliberately:

- Writing the specification by hand is slower than annotating handlers, and the team has
  to resist drifting into code-first when a change is urgent.
- The conformance test is load-bearing. If it is allowed to be flaky and gets skipped, the
  whole arrangement reverts to the no-contract option that ADR 0001 rejected, while still
  looking safe. It must be treated as a blocking test, never as advisory.

## Notes

Hand-written specification does not mean no tooling: linting it and validating examples in
CI is expected. The rule is only about which side is the source of truth.
