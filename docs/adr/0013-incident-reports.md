# 0013 - Incident reports record a region and a date, never a point or a time

- Status: accepted
- Date: 2026-11-16

## Context

Any signed-in account can file an incident report about a published phenomenon (ADR 0009,
ADR 0012). Reports are not reviewed and feed the public index of every region. Some
phenomena, gender violence first among them, are reported by people who are at risk if
the report can be traced back to them.

ADR 0012 left a report's location, time, description and author as fields of every
report, without saying what they are. Questions to settle:

- how a report says where the incident took place;
- how it says when;
- who sees the author of a report;
- whether the description is required;
- what happens to a report's region when the partition changes (ADR 0011).

## Decision

**A report records a region, not a point.** The reporter picks one region of the current
partition, by name. The API refuses a region that is not part of the current partition.
No coordinates are ever sent, stored or returned. A point would locate a home, a school or
a workplace, and a set of points from one account could identify the person behind it.
The index is computed per region anyway (ADR 0012), so a point adds nothing the maps use.

**A report records a date, not a time.** The incident date is a calendar date, in the
metropolitan area's time zone, and cannot be later than the day it is filed. When the
report was filed is recorded separately by the API.

**Analysts and admins read reports without their author.** The author is stored so that an
account can list its own reports, and so that an admin can find and remove abusive ones.
No operation returns a report's author to anyone but that author.

**The description is optional.** Free text is where a reporter is most likely to write a
name, an address or a detail that identifies someone, the very thing the rules above keep
out. Asking for it pushes people to write more than they need to, or to fill it with
filler. The index is computed from characteristics, not from the description, so a
phenomenon that needs context from every report gets a required text characteristic, and
each phenomenon decides for itself.

**Values are keyed by characteristic key and validated on filing.** Every active
characteristic may carry a value and every required one must. A value must match its
characteristic's type and settings: a number within its limits, and whole when the
characteristic is; a yes/no; the key of an active category option; a text no longer than
the maximum; a date. A value for an unknown or retired characteristic is refused. Each
refusal has its own error code and points at the offending value.

**A report keeps its region id for good.** Region ids are never reused (ADR 0011), so a
report always refers to the same region, even after a later partition version retires it.
How such reports count in the current partition's index is part of #24.

## Consequences

Good:

- A report cannot reveal where its author lives or works, even to an analyst or an admin
  reading the database.
- The form needs no map interaction, only a searchable list of region names, which works
  the same on the web and on the mobile application.
- Every report counts toward exactly one region, with no geometric join.
- A report can be filed with no free text at all, the least it can say about anyone.

Bad, and accepted deliberately:

- The atlas cannot show anything finer than a region, and cannot move reports to new
  regions by location when the partition is redrawn.
- A reporter who does not know the name of the region must find it; the web shows the
  chosen region on a map to help.
- Analysts cannot tell whether many reports come from the same account. Resistance to one
  account filing many reports has to be built into the API (#24), not left to people.
- A date is too coarse for phenomena where the time of day matters. Adding a time later is
  a new optional field, and a new decision.
