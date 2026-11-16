# 0012 - Phenomena are defined by admins: their characteristics and weighting function are data

- Status: accepted
- Date: 2026-11-15

## Context

The atlas maps phenomena such as gender violence and contaminated water in the
Guadalajara metropolitan area. Each phenomenon needs its own map, and the map paints every
region of the partition (ADR 0011) by an index computed from the incident reports filed
about it (ADR 0009).

What is worth recording differs from one phenomenon to the next: the number of victims and
the kind of violence for one, the source and the colour of the water for another. How the
reports become an index differs too, and will be tuned as people learn what the map
should show. New phenomena will be added after launch. Writing each phenomenon's fields
and formula in code would mean a release, of every component, for each new phenomenon or
each change of weights.

Questions to settle:

- what is recorded per report, and where the values live;
- what the weighting function can express, and how it is stored and evaluated;
- how a phenomenon's definition can change once immutable reports exist;
- who may define a phenomenon.

## Decision

**A phenomenon is defined by data, not code.** An admin gives it a name, a description, a
list of characteristics and a weighting function. Every phenomenon goes through the same
code paths.

**Characteristics are the fields every report of the phenomenon carries.** Each one has a
key, a label, a description, a required flag, a retired flag and a type:

| Type | Settings | Value in the weighting function |
|---|---|---|
| number | whole only, minimum, maximum, unit | the number |
| yes/no | - | 1 for yes, 0 for no |
| category | options, each with a key, label, weight and retired flag | the chosen option's weight |
| text | maximum length | not usable |
| date | - | not usable |

A report's location, time, description and author are part of every report and are not
characteristics.

**The values live in the reports.** A report stores one value per characteristic, keyed
by the characteristic's key. There is no value per region entered by hand: everything the
index uses about a phenomenon comes from its reports.

**A definition only grows.** Reports are immutable, so a definition must never stop
describing the reports already filed:

- a characteristic's key and type never change once saved;
- characteristics and category options are retired, never removed; a retired one is kept
  on the reports that carry it, offered on no new report, and unusable in the function;
- characteristics can be added, labels and descriptions changed, and a characteristic
  made required or not; reports filed before simply have no value for a new one;
- number limits and text lengths can change; they apply to new reports only;
- category weights can change, and that changes the index for every report already filed.
  That is intended: weights are how an admin tunes the map.

**The weighting function is an expression tree, stored as data.** Its nodes are:

- a constant;
- the region's population, the only input that is not part of the phenomenon;
- an aggregate of the reports located in the region: `count`, or `sum`, `mean`, `min` or
  `max` of one number, yes/no or category characteristic, leaving out reports without a
  value;
- an operation, `add`, `subtract`, `multiply` or `divide`, on two sub-expressions;
- a blank, a part not filled in yet, allowed only in a draft.

The tree has at most 100 nodes and 20 levels. It is evaluated once per region of the
current partition. When the result is undefined, a division by zero or a `mean`, `min` or
`max` over no values, the region has no index, which is distinct from 0 and painted
differently. An aggregate over a region with no reports gives 0 for `count` and `sum`.

A tree rather than a formula in text, because the admin edits it with visual blocks: a
tree cannot be syntactically wrong, needs no parser on either side, and each validation
error points at one node. The API validates every tree it receives and evaluates it by
translating each node into SQL from a fixed set of fragments with parameters; no text from
the request reaches SQL. How the index is evaluated and stored is decided in #24.

**A phenomenon has a status.** A draft is visible to admins only and accepts no reports. A
published phenomenon is public and accepts reports; it must have a function with no
blank. An archived one is hidden from everyone but admins and accepts no new reports, but
keeps the old ones; it can be published again. Nothing returns to draft, and only a draft,
which can have no reports, can be deleted.

**A definition is saved as a whole, with optimistic concurrency.** The client sends the
complete definition and the revision it started from; the API answers 409 when another
save happened since. Each change, status included, increases the revision.

**Only admins define phenomena.** ADR 0009's matrix let analysts create and edit
phenomena. With the definition now including the function that produces the public
index, changing it changes what everyone sees on the maps, which is governance rather
than data entry. Analysts keep bulk ingestion and reading individual reports.

**Published definitions are public.** Anyone can read a published phenomenon with its
characteristics, which a person needs to file a report, and its weighting function, so
that how the map is computed is open to scrutiny.

## Consequences

Good:

- A new phenomenon, or a change of weights, needs no release of any component.
- One validation and one evaluation path serve every phenomenon.
- Reports filed under any earlier definition stay readable and keep counting.
- The function the maps use is visible to everyone who looks at them.

Bad, and accepted deliberately:

- Report values are stored without a column per characteristic, so the database cannot
  enforce their types; the API does, on filing. Queries over them go through JSON.
- A definition can only grow. A characteristic created by mistake stays, retired, for
  good.
- Changing the function or a weight changes the map for past reports too, with no record
  of what the map looked like before. There is no history of definitions yet; if one is
  needed, it is a new decision.
- The function language is deliberately small: no conditions, no time windows, no weights
  by recency. Anything beyond the four operations and the five aggregates needs a contract
  change.
- Moving phenomenon definition from analysts to admins makes admins the bottleneck for
  adding phenomena.
- An admin whose token has expired reads phenomena as an anonymous visitor, seeing only
  published ones, because the read operations accept both.
