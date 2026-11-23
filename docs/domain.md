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

Something the atlas maps, such as gender violence or contaminated water in the
metropolitan area. Each one has its own map, painted by its phenomenon index. It has an
id, a name, a description, a status, a set of characteristics, a weighting function and a
refresh interval. The id is a positive integer assigned by the API that never changes and
is never reused.

Phenomena are generic: what is recorded about each one and how its index is computed are
data an admin defines, not code. Two phenomena are the same only if they have the same id.
See ADR 0012.

### Phenomenon status

Where a phenomenon is in its life. A **draft** is being defined: only admins see it and it
accepts no incident reports. A **published** phenomenon is public and accepts reports. An
**archived** one is hidden from everyone but admins, keeps its reports and accepts no new
ones; it can be published again. Nothing goes back to draft, and only a draft can be
deleted.

### Characteristic

One field that every incident report of a phenomenon carries, such as the number of
victims or the source of the water. It has a key, a label, a description, whether it is
required, whether it is retired, and a characteristic type. The key is how reports and the
weighting function refer to it, and neither the key nor the type ever changes once saved.
A characteristic is never removed, because reports that carry it cannot change; it is
retired instead, which keeps it on those reports but leaves it out of new ones and out of
the weighting function.

### Characteristic type

What kind of value a characteristic holds: a **number** (optionally whole, within a range,
with a unit), **yes/no**, a **category**, free **text**, or a **date**. Number, yes/no and
category characteristics can be used by the weighting function; text and date
characteristics are only recorded.

### Category option

One of the closed list of values of a category characteristic. It has a key, a label and a
numeric weight, which is what the option counts as in the weighting function. Like a
characteristic, it is retired rather than removed.

### Weighting function

How the incident reports of a phenomenon become the index of each region. It is an
expression an admin builds from constants, the region's population, aggregates of the
reports filed in the region (how many there are, or the sum, mean, minimum or maximum of
a characteristic) and addition, subtraction, multiplication and division. The region's
population is the only input that does not come from the phenomenon itself. A draft may
hold an incomplete function; a published phenomenon always has a complete one.

### Refresh interval

How often a phenomenon's index is recomputed, in whole minutes, from 5 minutes to 30 days.
A new phenomenon starts with 60. The index is recomputed at least once per interval, and
the map shows the last computed index in between. It is public once the phenomenon is
published. See ADR 0014.

### Incident report

An account's statement that something related to one phenomenon happened. It records the
phenomenon it refers to, the account that filed it, when it was filed, the region of the
current partition where the incident took place, the date it happened, an optional
free-text description, and a value for each characteristic of the phenomenon that is not retired. No
exact location is recorded, only the region, so that a report cannot point at a person. It
is accepted as filed, with no review, and cannot be edited or withdrawn; only an admin can
remove one. Individual reports are seen by analysts and admins, without their author, and
by their own author. See `roles.md` and ADR 0013.

### Phenomenon index

The value the weighting function of a phenomenon gives each region of the current region
partition, from the incident reports filed in that region. It is what the maps paint,
and everyone can see it, anonymous visitors included. A region where the function is
undefined, such as a division by zero, has no index, which is not the same as an index of
0. It is stored and recomputed when due (see Index computation), and everyone sees the
last complete computation. Incident reports filed in a region that a later partition
version retired count in the current region that overlaps most with it. See ADR 0015.

### Index computation

One run that recomputes a phenomenon's index for every region of the current region
partition, recording when it started and the phenomenon revision and partition version it
used. A published phenomenon is due for one when it never had one, its refresh interval
has elapsed, its revision changed (any saved change to it, its status included) or the
region partition changed. See ADR 0015 and ADR 0016.

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
define phenomena, change the region partition, and manage accounts and their roles.

### Analyst

The role that feeds the atlas with data. It can do everything a user can, plus load data
in bulk and read individual incident reports.

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
