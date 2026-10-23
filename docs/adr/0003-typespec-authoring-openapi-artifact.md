# 0003 - TypeSpec authors the contract, OpenAPI remains the artifact

- Status: accepted
- Date: 2026-10-22
- Amends: `0002-spec-first-contract.md`

## Context

`0002-spec-first-contract.md` established that the specification is written before the
code. It did not establish a format: the hand-written `contracts/openapi.yaml` it left
behind was a default, not a decision.

Two things have since been settled. The stack is TypeScript on the API, React on the web
and React Native on mobile. And three facts about the product are now known: the API will
be **public or partner-facing**, it serves **geospatial** data, and its use is dominated
by **search and repeated reads**.

That reopens the format question, because the obvious alternative was no longer obvious.

**Protobuf with Connect** was the serious contender. Connect solved gRPC's browser
problem, speaks plain HTTP without a proxy, and has stable TypeScript support. Its real
advantage is `buf breaking`: detection of incompatible changes built into the toolchain
rather than bolted on, backed by a format where deleting a field forces you to reserve
its number. For an architecture whose stated reason to exist is that mobile clients hold
old versions for months, that is the right kind of safety.

It lost on the three product facts, not on the stack:

- A public API is expected to publish OpenAPI. Protobuf is not the lingua franca for
  third parties.
- GeoJSON is native to REST and would have to be re-modelled in protobuf.
- An atlas dominated by repeated reads of the same content caches trivially behind ETags
  and a CDN. Connect sends POST for unary calls unless methods are explicitly marked free
  of side effects, so caching becomes something you configure rather than something you
  get.

**Hand-written OpenAPI** keeps all of that but does not scale as an authoring format. A
geospatial API repeats geometry models constantly, and YAML has no real mechanism for
reuse beyond `$ref` by hand.

**TypeSpec** is not a third protocol. It is a concise, modular language that compiles to
OpenAPI. The published artifact stays OpenAPI, so nothing in the ecosystem is given up.

## Decision

The contract is authored in TypeSpec and published as OpenAPI.

- `contracts/main.tsp` is the source of truth. `contracts/lib/geojson.tsp` holds the
  GeoJSON primitives, reused rather than repeated.
- `contracts/generated/openapi.yaml` is compiled from it and **committed**, so that pull
  requests show the diff of the real interface and so there is a baseline to compare
  against. CI recompiles and fails if the committed document is stale.
- **`oasdiff breaking --fail-on ERR` is a blocking check on every contract pull request.**

That last point is inseparable from the rest of the decision. Choosing OpenAPI over
protobuf gave up the one thing protobuf did better, and `oasdiff` is how it is bought
back. TypeSpec on its own improves only ergonomics; it adds no safety whatsoever.

## Consequences

Good:

- Geometry models are written once. The first geospatial endpoint inherits them.
- The published artifact is the format third parties and non-TypeScript clients expect.
- The output version is a build setting, so moving between OpenAPI 3.0 and 3.1 does not
  touch the source.
- TypeScript types for the web and mobile clients fall out of the same artifact via
  `openapi-typescript`, so the contract is enforced by the compiler on both clients.

Bad, and accepted deliberately:

- A two-step build, and a generated file in version control that can go stale. Mitigated
  by the drift check, which is itself a thing that can be switched off.
- Safety now depends on a CI check rather than on the format. Protobuf would have made
  a breaking change hard to express; here it is easy to express and merely caught. If
  `oasdiff` is ever made advisory, the architecture reverts to what ADR 0001 rejected
  while still looking safe.
- One more tool for five people to learn.

## Operational notes found while implementing this

- **`oasdiff` exits 0 by default even when it reports breaking changes.** Without
  `--fail-on ERR` the check prints the error and the merge proceeds. Verified against
  oasdiff 1.34.1. Anyone editing `.github/workflows/contract.yml` must keep that flag.
- The TypeSpec compiler ships a `node` shebang, and this team's machines may only have
  `bun`. The package scripts invoke it as `bun --bun`, which works under both.
- `@typespec/openapi3` 1.17.0 emits a duplicate suffixed schema for a named array model
  referenced at more than one nesting depth. `lib/geojson.tsp` works around it with an
  alias and documents the revert.
