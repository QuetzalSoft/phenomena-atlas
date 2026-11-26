# 0016 - The phenomenon index is stored and recomputed when due

- Status: accepted
- Date: 2026-11-22
- Amends: `0012-configurable-phenomena.md`, `0013-incident-reports.md`

## Context

ADR 0012 left how the index is evaluated and stored to #24. ADR 0013 left how reports
filed in a region that a later partition version retires count in the current partition.
ADR 0015 gives each phenomenon a refresh interval, which only means something if the
index is kept between computations.

**Computing on read**: always fresh, but the cost of every map view grows with the
reports, and the refresh interval would mean nothing.

## Decision

**The index is stored, not computed on read.** Two tables hold it:

- `phenomenon_index`: one value per phenomenon and region, double precision. NULL means
  the region has no index, which is distinct from 0.
- `phenomenon_index_computation`: one row per phenomenon, with `computed_at`,
  `phenomenon_revision` and `partition_version`.

Only the last computation is kept.

**A computation replaces the phenomenon's values in one transaction**: a delete, then one
`INSERT ... SELECT`. Readers always see the previous computation complete or the new one
complete, never a mix and never nothing. A failed computation rolls back, and the previous
one stays.

**Every region of the current partition gets a row**, with or without reports.

**Reports in a retired region count in the current region that overlaps most with it.** A
region is retired by a later partition version (in practice, by a merge, ADR 0011). Its
reports count in the current region that overlaps most with the retired region's last
shape, so no report is lost. Ties go to the lowest region id, so that the computation is
reproducible.

**The weighting function is translated node by node into fixed SQL fragments with
parameters**, as ADR 0012 requires:

- `population`: the region's population in the current partition;
- `count`;
- `coalesce(sum, 0)`, so that a sum over no reports is 0;
- `mean` (SQL `avg`), `min` and `max`, which give NULL over no values;
- division with `NULLIF(divisor, 0)`, so that a division by zero gives NULL.

Categories use the current weight of each option, retired ones included; yes/no counts as
1 or 0; reports without a value are left out by sum, mean, min and max; count counts every
report in the region.

**A published phenomenon is due** when it was never computed, its interval has elapsed
since the last computation started, its revision changed, or the partition version
changed. Drafts are never computed. Archived phenomena keep their last values and are not
recomputed.

**Publishing computes the index in the same transaction**, and so does publishing again,
so a published phenomenon always has an index. If the computation fails, the phenomenon is
not published.

**Time comes from Postgres.** `computed_at` is `now()`, the start of the transaction, so
the cadence does not drift by the length of a run.

**One transaction and one transaction-level advisory lock per phenomenon.** A scheduled
run skips a phenomenon whose lock is taken; publishing waits for it. Due phenomena are
computed one at a time, most overdue first.

**The computation lives in the API's `phenomenon` module.** It reads the incident report
and region tables in one read-only SQL query. That is an explicit exception to the rule
that modules reach each other only through events or a `*.public.ts` facade, made because
ADR 0012 requires evaluating in SQL.

## Consequences

Good:

- The state lives in Postgres, so any trigger and any hosting works.
- Readers never see a partial or empty map.
- Merging regions loses no reports.

Bad, and accepted deliberately:

- There is no history of the index.
- Publishing is slower, and fails if the computation fails.
- The cross-module read is an exception to the API's module rule.
- After a later split, the reports of an absorbed region go to the piece that overlaps
  most, because reports carry a region, not a point (ADR 0013).
- Any revision change, even of the name, triggers one extra computation.
- When the partition changes, every published phenomenon is due at once and they are
  computed one at a time, so for a few minutes some maps still show values computed on
  the previous partition.
