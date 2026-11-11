# 0011 - The region partition is versioned, validated by the API, and edited as a whole

- Status: accepted
- Date: 2026-11-11

## Context

Admins divide the Guadalajara metropolitan area into regions. Each region has a name and
a population, and the maps paint each region in its own colour (#33). The questions to
settle were:

- what shape the set of regions must keep;
- how other things refer to a region;
- how changes are saved and kept.

The answers had to work for about 1,500 regions edited by several admins.

## Decision

**A full partition.** The regions of the current version cover the four municipalities
exactly. No two regions overlap, every point of the area is in some region, and every
region lies entirely inside one municipality. The API enforces this with PostGIS on every
save and refuses a save that breaks it, with a specific error code per rule. Overlaps and
gaps under one square metre are tolerated, as floating-point noise from geometry
operations. Coordinates are exchanged at full precision rather than rounded: a client that
reshapes a region next to one it did not touch must reproduce their shared border exactly,
and rounding to a few decimals would open slivers far larger than the tolerance.

**Stable integer ids.** The API assigns each region a positive integer id from a database
sequence. The id never changes and is never handed out again.

| Change | What happens to ids |
|---|---|
| Rename or reshape a region | It keeps its id |
| Split a region | The original keeps its id; the new piece gets a new one |
| Merge two regions | The one the admin keeps retains its id; the other's is retired |

An integer is short enough to say aloud and type, which a UUID is not.

**A save is one change to the whole partition.** A single edit, such as moving a border
or adding a region, breaks the partition until the neighbouring regions are changed as
well. So a save carries every region it adds, changes or retires, and the API applies it
atomically. Validation runs after the change is applied; if it fails, nothing is kept.

Saves use optimistic concurrency. The client sends the version it started from, and the
API answers 409 if another save happened since. Without that, two admins editing the
same area would overwrite each other without either noticing.

**Every save is a new, immutable version.** A version records:

- its number;
- when it was saved and who saved it;
- which regions it added, changed and retired.

Past versions are never edited or deleted, and any of them can be read. There is no
restore operation. To go back, an admin saves the old shape again, as a new version, so
history only grows. Regions are stored as states, each valid from one version until the
version that replaces it, so reading version N is a query rather than a replay.

**Reading is public; changing and history are admin only.** The current partition and
the municipal boundaries are what the public maps paint, so anonymous visitors can read
them. Only admins can save a version or browse past ones.

**The editor only offers operations that keep the partition.** The web client offers
three:

- split a region with a line;
- merge two neighbouring regions of the same municipality;
- reassign an area: the admin draws a polygon, and the land inside it, within one
  municipality, moves to a chosen region, while the neighbours are clipped.

Moving a shared border is a reassignment. Free dragging of vertices is not offered: with
1,500 regions it opens a gap or an overlap at almost every move, and keeping shared
vertices in step needs a topology model in the client. The API does not trust the
client. It validates every save the same way, whatever produced it.

## Consequences

Good:

- The partition the maps paint is always valid, because an invalid one can never be
  saved.
- Ids can be used safely by other entities and in conversation.
- Every change is attributable, and any earlier state can be inspected.
- Concurrent edits fail loudly instead of losing work.

Bad, and accepted deliberately:

- History is never pruned, so storage grows with every save. Each save stores only the
  regions it touched.
- Validation runs PostGIS operations on the affected municipalities on every save, which
  is slower than storing whatever arrives. Saves are rare, admin-only operations.
- Tolerating slivers under one square metre means the partition is exact only to that
  tolerance.
- Admins cannot nudge a single vertex. They redraw the area instead, which is coarser
  for small corrections.
- Without a restore operation, undoing a bad save means repeating the old shape by hand
  or through a client feature built on reading a past version.
