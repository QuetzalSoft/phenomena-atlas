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

From a fresh machine to the API and the web interface running locally. Each component's
`AGENTS.md` (`api/AGENTS.md`, `web/AGENTS.md`) is the authority on its own commands; if
this section disagrees with one of them, the component file wins, and this section
should be fixed.

### 1. Prerequisites

- Git, with an SSH key registered on GitHub (the components are cloned over SSH)
- Docker, running
- Node.js at the version in each component's `.node-version`. It is required, not
  optional: without `node`, Bun stands in for it and the API test suite hangs.
- Bun, the package manager
- The GitHub CLI (`gh`), signed in with access to the QuetzalSoft organisation

### 2. Clone the workspace

```sh
git clone git@github.com:QuetzalSoft/phenomena-atlas.git
cd phenomena-atlas
./scripts/bootstrap.sh
```

This clones every component into the right place. Always work from this layout: the
shared context in `AGENTS.md` assumes it, and so do the other four of us.

### 3. Get access to the contract package

Both components depend on `@quetzalsoft/phenomena-atlas-contract`, which is published
privately on GitHub Packages. Installing needs a token with `read:packages` in every shell
that runs `bun install`:

```sh
gh auth refresh -s read:packages
export GITHUB_TOKEN=$(gh auth token)
```

### 4. Start the API

```sh
cd api
cp .env.example .env
bun install
docker compose up -d --wait   # PostGIS on :5432, Keycloak on :8080
bun run build                 # the next three commands run from dist/
bun run migrate
bun run set-role 00000000-0000-4000-8000-000000000001 admin
bun run load-regions
bun run dev                   # http://localhost:8000
```

- `set-role` makes the realm's `admin` user an admin. It is needed once per database.
- `load-regions` builds version 1 of the region partition by downloading INEGI and
  IMEPLAN data (ADR 0010), so it needs internet access. The data is never committed, so
  every database has to load it once. It refuses to run when a partition already exists.
  Two loads months apart can differ slightly, because IMEPLAN's layer has no fixed
  edition.

### 5. Start the web interface

In a second terminal, with `GITHUB_TOKEN` exported there too:

```sh
cd web
cp .env.example .env.local    # then set AUTH_SECRET to the output of `openssl rand -base64 32`
bun install
bun run dev                   # http://localhost:3000
```

### 6. Check that it works

1. Open http://localhost:3000/dashboard. It checks the API from the server and from the
   browser, so both must show as reachable.
2. Sign in as `admin` / `admin` (admin) or `dev` / `dev` (regular user). These accounts
   come from the local Keycloak realm and exist only for development.
3. As `admin`, open http://localhost:3000/admin/regions. The map shows about 1,470
   regions across the four municipalities.

### Day to day

```sh
cd api && docker compose up -d --wait && bun run dev   # terminal 1
cd web && bun run dev                                  # terminal 2
```

After pulling API changes that add migrations, run `bun run build && bun run migrate` in
`api/`.

### Common problems

- `bun install` fails with 401 or 403: `GITHUB_TOKEN` is not exported in that shell, or
  the token lacks `read:packages`.
- On Apple silicon the database is slow to start: PostGIS publishes only amd64 images, so
  Docker runs it emulated.
- A service fails to start: something else is already using port 5432, 8080, 8000 or
  3000.

## What to read first

1. `docs/architecture.md` - how the pieces fit together
2. `docs/domain.md` - the vocabulary we all use
3. `contracts/main.tsp` - the API contract, source of truth
   (`contracts/generated/openapi.yaml` is the compiled output, never edited by hand)
4. `docs/release.md` - how to ship a change that crosses components
