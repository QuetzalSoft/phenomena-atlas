# Domain glossary

The vocabulary of Phenomena Atlas. One term, one meaning, used identically in the
contract, the database, the API, both clients, and in conversation.

When a term here changes, it changes everywhere in the same pull request. A rename that
lands in the API but not in the web interface is how a codebase starts lying.

## Status

This glossary is a skeleton. Filling it is the first real design task, and it should
happen before the first endpoint is written, because the contract depends on it.

## Terms

### Phenomenon

> TODO(team): the central entity. Define precisely what counts as one and what does not.
> What are its required attributes? What makes two records the same phenomenon?

### Incident report

An account's statement that something related to one phenomenon happened. It records the
phenomenon it refers to, the account that filed it, when it was filed, where the incident
took place, and a free-text description. It is accepted as filed, with no review, and
cannot be edited or withdrawn; only an admin can remove one. Individual reports are seen
by analysts, admins and their own author. See `roles.md`.

### Phenomenon index

The value that results from weighting all the incident reports of a phenomenon. It is
what the maps show, and everyone can see it, anonymous visitors included. The weighting
function is not defined yet (#24).

### Account

A person known to the API. It is created, with the role user, the first time that person
calls the API with a valid token, and is keyed by the identity provider's id for them. It
keeps a copy of their username, name and email from that token, so admins can tell
accounts apart. Credentials are not part of it; they stay in the identity provider.

### Role

What an account is allowed to do. There are three, in a hierarchy where each includes
the one below it: admin, analyst, user. Every account holds exactly one. The permission
matrix is in `roles.md`.

### Admin

The role that operates and governs the system. It can do everything an analyst can, and
manage accounts and their roles.

### Analyst

The role that feeds the atlas with data. It can do everything a user can, plus create and
edit phenomena, load data in bulk, and read individual incident reports.

### User

The role every new account gets. It browses and queries the atlas and files incident
reports.

### Anonymous visitor

Anyone calling without a valid token. Not a role: it can only browse and query phenomena
and their index.

### Metropolitan area

The part of the world the atlas covers: the municipalities of Guadalajara, Zapopan, San
Pedro Tlaquepaque and Tonalá, in Jalisco. It is the union of their municipality
boundaries.

### Municipality

One of the four municipalities of the metropolitan area, identified by its five-digit
INEGI key (for example `14039` for Guadalajara), with its name and its boundary from
INEGI's census 2020 Marco Geoestadístico. Municipalities are reference data: loaded once,
never edited through the API. See ADR 0010.

### Region

An area of the metropolitan area that the maps paint in its own colour. It has an id, a
name, a population and the municipality it lies in, and its shape is a multipolygon
entirely inside that municipality. The id is a positive integer assigned by the API. It
never changes and is never reused, so it is how anything refers to a region. Names may
repeat. See ADR 0011.

### Region partition

The set of regions that, together, cover the metropolitan area exactly: no two overlap
and no point is left out. Admins change it; everyone can read it. It is always valid,
because the API refuses any change that would break it.

### Partition version

One saved state of the region partition. Every change an admin saves creates the next
version, numbered from 1, recording who saved it, when, and which regions it added,
changed and retired. Versions are immutable and all of them stay readable. Version 1 is
the initial load from the colonias of each municipality.

### (further terms)

> TODO(team): add one section per term as the model takes shape. Likely candidates based
> on the product being an atlas: classification or taxonomy, location, time or period,
> source and evidence, confidence. Do not add a term here until it has a real definition;
> an empty heading is worse than an absent one.

## Naming rules

- English everywhere, including identifiers in the database and the contract.
- Singular for an entity (`phenomenon`), plural for a collection endpoint (`/phenomena`).
- Geometries are not redefined per entity. They come from `contracts/lib/geojson.tsp`.
- The name used in `contracts/main.tsp` wins. If the database or a client disagrees
  with the contract, the contract is right and the other side is a bug.
