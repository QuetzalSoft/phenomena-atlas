# 0001 - Polyrepo with an explicit contract

- Status: accepted
- Date: 2026-10-22

## Context

Phenomena Atlas is one API with two clients, a web interface and a mobile application,
built by five developers. The three components share a domain model, which means the
coupling between them is high by design rather than by accident. The question was how to
organise that coupling in version control.

Three options were considered.

**Monorepo**, one repository with all components and a shared contract package. A change
crossing the API and a client is one atomic pull request, and the build fails before
merge if a client does not compile against the new contract. The cost is path-filtered
CI, ambiguous release tagging when the mobile application has its own store cadence, and
workspace tooling the team would have to adopt.

**Polyrepo with no shared contract**, the layout that existed before this decision. It
is the cheapest to start and the most dangerous to continue: when the API changes its
response shape, both repositories stay green in CI and the system is broken anyway.
Nothing reports the failure until production.

**Polyrepo with an explicit contract**, separate repositories plus a versioned API
specification that clients generate from and the API is tested against.

## Decision

Polyrepo with an explicit contract.

Three component repositories deploy independently. A fourth repository, this one, holds
the specification, the domain documentation and the shared agent context, and is also
the workspace root into which the components are cloned.

The deciding factor was the mobile application. Mobile clients remain installed on old
versions for months, so some form of explicit contract versioning is required whatever
the repository layout is. Given that the versioned contract has to exist anyway, the
atomicity advantage of the monorepo shrinks to something the three-pull-request flow can
cover.

## Consequences

Good:

- Each component deploys on its own cadence with no coordination.
- The interface between components is an artifact that can be reviewed, versioned and
  tested, rather than knowledge held by whoever wrote the API.
- CI per repository stays simple: no path filters, no build orchestration.

Bad, and accepted deliberately:

- Adding one field is three pull requests across two repositories. That is real friction
  for a team of five who talk to each other daily, and it will feel like bureaucracy
  before it feels like safety.
- Version skew between components is a new state to keep an eye on.
- A package registry and a publishing pipeline have to be set up and maintained.
- Refactoring a domain concept across all components is manual, where a monorepo would
  make it a single search and replace.

If the mobile application is cancelled, or ships as a thin web wrapper, this decision
should be revisited. Without a client that holds old versions for months, the balance
moves back towards the monorepo.

Related: `0002-spec-first-contract.md`.
