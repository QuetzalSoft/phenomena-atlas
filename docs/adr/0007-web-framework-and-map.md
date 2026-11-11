# 0007 - The web client uses Next.js and MapLibre GL JS

- Status: accepted
- Date: 2026-11-09

## Context

The web client was only fixed as "React with TypeScript". The framework, the build tool and
the map library were open, and the product is an atlas: a map is the main surface, and
individual phenomena are pages that people will search for and share.

Earlier decisions constrain the choice. The API is the only component with database access
and the only place domain rules are enforced (`docs/architecture.md`). Clients consume the
contract through generated types and `openapi-fetch`, and never call the API by hand
(ADR 0002, ADR 0003).

A single-page application served as static files was the simplest option, but it renders
an empty document until JavaScript runs, so search engines and link previews do not see a
phenomenon's content. That was judged not acceptable for a public atlas.

## Decision

**Framework and runtime.** The web client uses Next.js with the App Router, running on the
active Node.js LTS. Bun is the package manager and does not run the application, matching
the API (ADR 0006).

**The Next.js server is not a backend.** It renders pages and calls the public API through
the contract types, exactly as a browser would. It has no database access, holds no domain
rules, and exposes no server actions. Route handlers are allowed only for concerns that
carry no domain data, such as a liveness probe or a generated preview image. Anything else
the client needs is a contract change.

**Map.** MapLibre GL JS, used through `react-map-gl/maplibre`. The map is a client
component that never renders on the server.

**Basemap.** Not decided. The style URL is configuration, so choosing a tile provider
changes no code. It is tracked with hosting in `docs/architecture.md`.

The full design is in `docs/architecture.md` in the web repository.

## What was verified

A throwaway prototype ran on Node 26.13 (LTS), Next.js 16.4, React 19.3, `react-map-gl` 8.1,
MapLibre GL JS 6.17, `openapi-fetch` 0.17 and `openapi-react-query` 0.5, installed with Bun,
against the contract package and a stub API:

- A Server Component called `GET /health` through the typed client, and the result reached
  both the rendered HTML and the page metadata.
- Calling an undeclared path or reading a field the contract does not declare failed `tsc`.
- The same client worked in the browser through TanStack Query.
- A Point and a Polygon typed with the contract's GeoJSON schemas rendered on the map with
  no coordinate conversion, because MapLibre and RFC 7946 both use longitude first.
- The map viewport round-tripped through the URL and survived a reload, in `next build`
  and in `next dev`.
- ESLint rules rejected a server action, a database driver import and a raw `fetch`.

Three things did not work out of the box, and the web repository documents each of them:

- `ssr: false` on `next/dynamic` is rejected in a Server Component. The map needs a small
  client wrapper.
- MapLibre 6 loads its worker relative to its own module. Bundling breaks that, and the
  map renders blank with "Worker failed to load". The worker URL must be set explicitly.
- `typescript-eslint` refuses to run under TypeScript 7.

It did not cover authentication, mutations, or the testing setup.

## Consequences

Good:

- Phenomenon pages are rendered on the server, so they can be indexed and previewed when
  shared.
- The same typed contract client is used on the server and in the browser, so there is one
  way to call the API.
- Map data needs no translation: contract GeoJSON goes straight into a map source.
- Basemap tiles can be changed without touching code.
- A shared map view is a URL.

Bad, and accepted deliberately:

- The web client needs a Node server in production rather than static files, which makes
  hosting and operations heavier.
- Code runs in two environments, server and browser, and each component must be placed
  in the right one. Getting it wrong fails at build time at best and at runtime at worst.
- The map, the main surface of the product, gets no benefit from server rendering.
- Next.js makes it easy to grow a second backend through route handlers and server
  actions. Lint rules catch the obvious cases. The rest depends on code review.
- Next.js majors arrive often and change conventions. The project follows them or falls
  behind.
- TypeScript stays at version 6 until `typescript-eslint` supports 7, as the API does for
  `dependency-cruiser`.
- MapLibre's worker setup depends on bundler behaviour and can break silently on a Next.js
  or MapLibre upgrade. The end-to-end suite must load a real map to catch it.
