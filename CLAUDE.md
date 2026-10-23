# Phenomena Atlas

An atlas of phenomena. One API owns the domain and the data; a web interface and a
mobile application consume it. Nothing else talks to the database.

> TODO(team): replace this paragraph with a precise product definition once scope is
> settled. Keep it to three sentences. See `docs/domain.md` for the vocabulary.

## This repository

This is the **system repository**. It holds everything that belongs to Phenomena Atlas
as a whole rather than to any single component:

- `contracts/openapi.yaml` - the API contract. Source of truth, spec-first.
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
| One component | `api/CLAUDE.md`, `web/CLAUDE.md` | Dies with that component |

If you are about to write a stack detail, a build command or a directory listing here,
it belongs in the component's own `CLAUDE.md` instead.

## The contract is the interface

`contracts/openapi.yaml` is spec-first: the spec is written first and the API implements
it. The API is verified against the spec by a conformance test; the clients generate
their types from it. Do not describe endpoints in prose anywhere in this repository.
Read the spec.

The spec is published as a versioned package. Clients pin a version. Release is
triggered only by changes under `contracts/**`; documentation changes do not bump it.

## Changing something that crosses components

Three pull requests, in this order, never merged out of order:

1. **This repo** - change `contracts/openapi.yaml`, merge, a new contract version publishes.
2. **`api/`** - bump the contract dependency, implement, conformance test proves it.
3. **`web/` and `mobile/`** - bump the contract dependency, consume the new types.

Removing or renaming a field is never one step. Use expand/contract: add the new shape,
migrate every client, then remove the old shape in a later release. Mobile clients stay
on old versions for months after release, so the contract phase must outlive them.

Full detail in `docs/release.md`.

## Conventions

- All project text is English: code, comments, commits, documentation, issue titles.
- Trunk-based: short-lived branches off `main`, pull requests, no long-running branches.
- Work is tracked on the org-level GitHub Project "Phenomena Atlas", not per repository.
- Record a decision as an ADR in `docs/adr/` when it constrains future work.
