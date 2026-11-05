# 0006 - The API uses NestJS and the domain-driven-hexagon architecture

- Status: accepted
- Date: 2026-11-04

## Context

The API framework was still an open decision. The requirement left by earlier decisions
was specific: whatever is chosen must be able to
validate real responses against the pinned OpenAPI document, because the conformance test
is what makes the polyrepo split safe (ADR 0001, ADR 0002).

The API owns the domain and enforces its rules, and the product is expected to grow into a
public API. That calls for an internal structure that keeps domain rules away from the
framework and the database, and that five people can follow consistently.

[domain-driven-hexagon](https://github.com/Sairyss/domain-driven-hexagon) (DDH) is a
reference architecture for this on NestJS, combining domain-driven design, hexagonal
architecture and command-query separation. It is not directly usable here: it generates
its specification from code, which ADR 0002 rejects, and it has its own error shape, which
the contract does not allow.

## Decision

**Framework and runtime.** The API uses NestJS on Express, running on the active Node.js LTS.
Bun stays as the package manager, as in `contracts/`, but does not run the API: the NestJS
documentation names only Node.js as its runtime.

**Architecture.** The API follows DDH: vertical slices per use case, layers with dependencies
pointing inward, separate command and query paths, and rules enforced by
`dependency-cruiser`. The contract and accepted ADRs win wherever DDH disagrees with them.

**Conformance.** `express-openapi-validator` validates requests against the pinned document in
every environment, and responses during the end-to-end suite. Schemathesis also runs against
the running API. Both are blocking.

**Persistence.** PostgreSQL with PostGIS, accessed through Kysely. The contract speaks GeoJSON
and the product is geospatial, so spatial queries and indexes are core functionality. Kysely
replaces DDH's Slonik so that query mistakes surface at compile time.

The full design and every deviation from DDH are in `docs/architecture.md` in the API
repository.

## What was verified

A throwaway prototype ran on Node 26, NestJS 12.3 and `express-openapi-validator` 5.6 against
the contract document:

- A handler returning the wrong shape was caught by response validation and by Schemathesis.
- A clean `/health` passed Schemathesis with `--checks all`.
- Validator errors reached the global filter and were rendered as the contract's `Error`.
- `dependency-cruiser` caught deliberate layer violations and cross-module imports.
- Kysely read GeoJSON from PostGIS through `ST_AsGeoJSON`.

It did not cover authentication, Kysely migrations or the transactional write path.

## Consequences

Good:

- The conformance requirement has a tested answer, and a route the contract does not declare
  answers 404 even if a controller exists.
- Domain rules can be tested without the framework or a database.
- Layer boundaries are checked in CI rather than left to review.
- Read paths get direct SQL control, which suits a product dominated by search and repeated
  reads.

Bad, and accepted deliberately:

- A lot of ceremony per use case. A simple write needs a controller, a command, a service, a
  repository method and a mapper, which is more than a simple feature deserves. Value objects
  and ports must be justified individually or the structure turns into overhead.
- Node must be installed on every development machine, and some of them only have Bun today.
- Express is now a load-bearing choice, because `express-openapi-validator` is Express
  middleware. Moving to Fastify would mean replacing the validation approach.
- Several things break if set up wrong, some of them silently, and the API repository documents
  each of them. The body parser must be registered before the validator, event handlers must
  set `suppressErrors: false`, and `dependency-cruiser` checks nothing under TypeScript 7.
- `dependency-cruiser` holds TypeScript back at version 6 until it supports 7.
- `express-openapi-validator` is a single point of failure for conformance. Its last release
  (2026-01) predates NestJS 12, and it only works here because it is plain Express middleware.
- Neither the validator nor Schemathesis rejects extra response fields, because the generated
  schemas allow them. Protection against leaking fields rests on explicit response mapping, so
  on code review.
- DDH targets NestJS 9. Its code is a reference for structure, not something to copy.
