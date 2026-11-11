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
