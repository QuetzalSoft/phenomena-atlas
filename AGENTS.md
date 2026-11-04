# Phenomena Atlas

An atlas of phenomena. One API owns the domain and the data; a web interface and a
mobile application consume it. Nothing else talks to the database.

> TODO(team): replace this paragraph with a precise product definition once scope is
> settled. Keep it to three sentences. See `docs/domain.md` for the vocabulary.

## This repository

This is the **system repository**. It holds everything that belongs to Phenomena Atlas
as a whole rather than to any single component:

- `contracts/main.tsp` - the API contract. Source of truth, spec-first, authored in
  TypeSpec. `contracts/lib/geojson.tsp` holds the geospatial primitives.
- `contracts/generated/openapi.yaml` - compiled from the above. **Generated. Never edit.**
- `docs/domain.md` - the domain glossary. Shared vocabulary for all components.
- `docs/architecture.md` - how the pieces fit together.
- `docs/release.md` - how a change that crosses components is shipped.
- `docs/adr/` - decisions and why they were made.

It is also the **workspace root**. The three component repositories are cloned inside
it and are git-ignored here. Run `scripts/bootstrap.sh` to get the layout:

```
phenomena-atlas/          this repo
  api/                    QuetzalSoft/phenomena-atlas-api     (separate repo)
  web/                    QuetzalSoft/phenomena-atlas-web     (separate repo)
  mobile/                 QuetzalSoft/phenomena-atlas-mobile  (separate repo, not created yet)
```

Keep this layout identical on every machine. This file is inherited by any Claude Code
session opened under it, including sessions opened inside `api/` or `web/`, so the paths
above must mean the same thing for everyone.

## Where knowledge lives

| Scope | File | Rule |
|---|---|---|
| The system | this file, `docs/` | True even if a component were deleted |
| One component | `api/AGENTS.md`, `web/AGENTS.md` | Dies with that component |

If you are about to write a stack detail, a build command or a directory listing here,
it belongs in the component's own `AGENTS.md` instead.

## The contract is the interface

`contracts/main.tsp` is spec-first: the spec is written first and the API implements it.
The API is verified against the spec by a conformance test; the clients generate their
types from it. Do not describe endpoints in prose anywhere in this repository. Read the
spec.

**Edit `main.tsp`, never `generated/openapi.yaml`.** The generated document is committed
so that pull requests show the diff of the real interface and so breaking-change
detection has a baseline. CI recompiles and fails if the two disagree.

Build it with `bun run build` in `contracts/`. That compiles the OpenAPI document and
regenerates the TypeScript types. The scripts invoke the TypeSpec compiler through
`bun --bun` because it ships a `node` shebang and not every machine here has node.

The spec is published as a versioned package, `@quetzalsoft/phenomena-atlas-contract`,
carrying both the OpenAPI document and the generated types. Clients pin a version.
Release is triggered only by changes under `contracts/**`; documentation changes do not
bump it. A merge into `develop` publishes a prerelease under the `next` dist-tag, a merge
into `main` the stable version under `latest`.

A pull request that introduces an incompatible change fails CI. See ADR 0003: that check
is what replaces the safety protobuf would have given, and it is not advisory.

## Changing something that crosses components

Three pull requests, in this order, never merged out of order:

1. **This repo** - change `contracts/main.tsp`, run `bun run build`, bump the version in
   `contracts/package.json`, commit the regenerated document, merge into `develop`. A
   prerelease `X.Y.Z-dev.N` publishes; the stable `X.Y.Z` publishes when it reaches
   `main`.
2. **`api/`** - bump the contract dependency, implement, conformance test proves it.
3. **`web/` and `mobile/`** - bump the contract dependency, consume the new types.

Removing or renaming a field is never one step. Use expand/contract: add the new shape,
migrate every client, then remove the old shape in a later release. Mobile clients stay
on old versions for months after release, so the contract phase must outlive them.

Full detail in `docs/release.md`.

## Conventions

- All project text is English: code, comments, commits, documentation, issue titles.
- `main` is production, `develop` integrates the sprint (ADR 0005). Branch off `develop`
  and open pull requests into it. `main` only takes releases from `develop` and fixes
  from `hotfix/*`; a hotfix is back-merged from `main` into `develop`.
- Work is tracked on the org-level GitHub Project "Phenomena Atlas", not per repository.
- Record a decision as an ADR in `docs/adr/` when it constrains future work.

## `main` and `develop` are protected

All three repositories are public, and each has a ruleset on `main` and another on
`develop`. Shared by all of them:

- Changes go through a pull request. Direct pushes are rejected.
- One approving review is required.
- Neither branch can be deleted or force-pushed.

On `main` only, in every repository:

- Pull requests merge with a merge commit; squash and rebase are disabled, so `main`
  never gains commits `develop` lacks.
- The `source-branch` check must pass. It rejects any pull request that does not come
  from `develop` or `hotfix/*` in the same repository.

**In this repository only**, the `contract` check must also pass, on both branches, so a
pull request carrying an incompatible contract change cannot be merged. That is the
mechanism ADR 0003 depends on. The component repositories have no other required check
yet because they have no test suite yet; adding one is part of standing up each
component's test suite, and is not optional once there is code to test.

Organisation admins can bypass all of the above, including pushing straight to `main`.
That exists so the work does not stall while the team is still forming, not as a normal
route. Bypassing the `contract` check merges a change that a pinned client cannot
survive; `docs/release.md` explains why that is expensive to undo once the mobile
application is shipping.
