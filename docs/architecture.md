# Architecture

## Components

```
                   contracts/main.tsp  (TypeSpec, source of truth)
                             |  compiles to
                   contracts/generated/openapi.yaml
                   (versioned, published as a package)
                             |
              +--------------+--------------+
              |              |              |
         implements       consumes       consumes
              |              |              |
         +----v----+    +----v----+   +-----v-----+
         |   API   |    |   Web   |   |  Mobile   |
         +----+----+    +---------+   +-----------+
              |
         +----v----+
         | Database|
         +---------+
```

**API** owns the domain and is the only component with database access. Every other
component reaches the data through the API, with no exceptions. If a client needs
something the API does not expose, the fix is a contract change, never a side channel.

**Web** and **Mobile** are clients. They hold presentation logic and client state. They
hold no domain rules that the API does not also enforce: a client-side check is a
convenience for the user, never the thing that protects an invariant.

## Why three repositories and not one

See `adr/0001-polyrepo-with-contracts.md`. In short: the components deploy on different
cadences, and the coupling between them is handled explicitly by the contract rather
than implicitly by living in the same tree.

The cost of that choice is that nothing stops an API change from breaking a client at
runtime. The contract package and its conformance test are what buy that safety back,
which is why they are not optional.

## The contract seam

`contracts/main.tsp` is the only agreed interface between the API and its clients. It is
authored in TypeSpec and compiled to `contracts/generated/openapi.yaml`, which is what
gets published and consumed. See `adr/0003-typespec-authoring-openapi-artifact.md`.

- It is written before the code that implements it. See `adr/0002-spec-first-contract.md`.
- The API proves it complies through a conformance test run in CI.
- Clients generate their types from it with `openapi-typescript` and call through
  `openapi-fetch`. Hand-written request code that bypasses the generated types is how
  drift starts.
- It is versioned with semver and published as `@quetzalsoft/phenomena-atlas-contract`.
  Clients pin a version, so an API deploy can never silently change what a client was
  built against.
- **An incompatible change fails CI.** `oasdiff breaking --fail-on ERR` compares every
  contract pull request against the base revision. This is the single check that makes
  the polyrepo split safe; everything else in this document assumes it is working.

Geospatial shapes live in `contracts/lib/geojson.tsp` and are reused, not repeated.
Coordinate order is longitude then latitude, per RFC 7946.

## Deployment

Each component deploys independently from its own repository.

> TODO(team): record the hosting target, environments and deploy trigger for each
> component once decided.

## Settled constraints

**The API is public or partner-facing.** Not today, but it is an accepted direction, and
it is why the contract is OpenAPI rather than protobuf. It also means the contract is
read by people outside this team: operation names, descriptions and error codes are part
of the product, not internal detail.

**The stack is TypeScript throughout.** API in TypeScript, web in React, mobile in React
Native with Expo. Because every client is TypeScript, all three can consume the same
generated types from the contract package; the contract itself stays language-neutral so
that third parties are not shut out.

**The API uses NestJS and PostgreSQL with PostGIS.** Its internal structure follows
domain-driven-hexagon, and conformance is proved by validating real responses against the
pinned OpenAPI document. See `adr/0006-api-framework-and-architecture.md`. The design itself
is in `docs/architecture.md` in the API repository.

**The web client uses Next.js and MapLibre GL JS.** Pages are rendered on the server so that
phenomena can be indexed and shared, and the map is a client component. The Next.js server
is not a backend: it reaches data only through the API, like any other client. See
`adr/0007-web-framework-and-map.md`. The design itself is in `docs/architecture.md` in the
web repository.

**Users authenticate with a self-hosted Keycloak.** It issues OpenID Connect tokens, and the
API checks them on every operation the contract protects. Roles and permissions live in
the API database and are enforced there, never read from the token. See
`adr/0008-authentication-with-keycloak.md`.

## Open decisions

> TODO(team): hosting, environments and deploy triggers, as noted above.

> TODO(team): the basemap tile provider for the web map. The style URL is configuration, so
> this changes no code, but it has cost, usage limits and attribution consequences.
