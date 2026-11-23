# 0014 - Each phenomenon has a refresh interval

- Status: accepted
- Date: 2026-11-22
- Amends: `0012-configurable-phenomena.md`

## Context

A phenomenon's index is computed from all of its reports by its weighting function (ADR
0012). Recomputing it on every read, or on every new report, is not needed for every
phenomenon: some change slowly, others need a fresher map (#44). How often the index is
recomputed is therefore something an admin decides per phenomenon, and it needs a shape
in the contract.

**An ISO 8601 duration**: readable, but a string that has to be parsed and validated by
hand, and `P1M`, a month, is easily confused with `PT1M`, a minute.

**Cron**: allows fixed times of day, but an expression is hard to bound, and the rule
wanted is "at least once per interval", not "at these times".

## Decision

**The refresh interval is part of the definition.** An admin sets it, and it is saved with
the rest of the definition, under the same revision and optimistic concurrency as ADR
0012. Like the rest of a published definition, it is public.

**It is a whole number of minutes, from 5 to 43200 (30 days).** It is an int32 with
`@minValue` and `@maxValue`, like every other numeric limit in the contract, so the request
validator enforces the range.

**It bounds how stale a map can be.** The index is recomputed at least once per interval;
between runs, the map shows the last computed index. A change takes effect from the next
run and does not change past values.

**A new phenomenon starts with 60.** The interval is changed by updating the phenomenon.
Every phenomenon read carries it. On an update, omitting it keeps the current value.

**Existing phenomena get 60.** A migration adds `refresh_interval_minutes` with that value
to every phenomenon already saved.

## Consequences

Good:

- Retuning how fresh a map is needs no release of any component.
- The range is validated by the contract, with no code of its own.
- Creating a phenomenon is unchanged.

Bad, and accepted deliberately:

- On an update, omitting the field keeps the current value. That departs from ADR 0012's
  "a definition is saved as a whole", so that a client built before this field cannot
  silently reset it.
- The interval cannot be set when creating a phenomenon, only by a later update.
- No fixed times of day.
- One-minute resolution.
