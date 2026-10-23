# Phenomena Atlas

System repository for Phenomena Atlas: the API contract, the domain documentation and
the shared context for the whole product.

Phenomena Atlas is built as three components in separate repositories, all speaking
through one contract:

| Component | Repository |
|---|---|
| API | [phenomena-atlas-api](https://github.com/QuetzalSoft/phenomena-atlas-api) |
| Web interface | [phenomena-atlas-web](https://github.com/QuetzalSoft/phenomena-atlas-web) |
| Mobile application | not created yet |

## Getting started

```sh
git clone git@github.com:QuetzalSoft/phenomena-atlas.git
cd phenomena-atlas
./scripts/bootstrap.sh
```

This clones every component into the right place. Always work from this layout: the
shared context in `CLAUDE.md` assumes it, and so do the other four of us.

## What to read first

1. `docs/architecture.md` - how the pieces fit together
2. `docs/domain.md` - the vocabulary we all use
3. `contracts/main.tsp` - the API contract, source of truth
   (`contracts/generated/openapi.yaml` is the compiled output, never edited by hand)
4. `docs/release.md` - how to ship a change that crosses components
