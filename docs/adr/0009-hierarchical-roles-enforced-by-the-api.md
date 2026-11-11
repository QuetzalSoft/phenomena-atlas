# 0009 - Three hierarchical roles, one per account, enforced by the API

- Status: accepted
- Date: 2026-11-11

## Context

ADR 0008 decided that Keycloak only authenticates, and that roles live in the API database
keyed by the token's subject and are enforced by the API. It left the roles themselves
undefined. Every endpoint in the contract will need to state who may call it, so the model
had to be settled before the first domain endpoint is written.

The product needs three kinds of account: people who consume the atlas and report
incidents, people who feed it with data, and people who run it. Three shapes were
considered:

- **A fixed hierarchy, one role per account.** Each role includes the one below it.
- **Independent roles, several per account.** Each role is its own set of permissions and
  an account holds any combination.
- **Fine-grained permissions** stored in tables and grouped into roles that admins define
  at runtime.

Two further questions shaped it: whether anonymous visitors can read anything, and
whether incident reports go through a review before they count.

## Decision

**Three fixed roles in a hierarchy: `admin` ⊇ `analyst` ⊇ `user`.** Every account holds
exactly one. The permission matrix in `docs/roles.md` is the authoritative list of what
each one may do; anything not in it is denied.

**The contract states, per operation, whether it is public and otherwise the minimum
role it requires.** The API enforces that with a single comparison against the account's
role. Code does not decide permissions the contract does not state.

**Anonymous visitors can browse and query phenomena and their index.** Everything else
requires a token.

**New accounts are `user`.** Only an admin changes a role, never their own. The first admin
is seeded from deployment configuration.

**Incident reports are not reviewed.** They are accepted as filed and are immutable. A
weighting function over all the reports of a phenomenon produces its index, which is what
everyone sees on the maps. Individual reports are visible only to analysts, admins and
their own author. An admin can remove a report for abuse or to erase personal data.

## Consequences

Good:

- Authorization is one ordered comparison per request, simple to implement, test and
  audit. Every matrix row can be tested for each role and for anonymous access.
- A role change takes effect on the next request, as ADR 0008 already gives.
- The public part of the atlas needs no account, which suits a map people find through
  search and share by link.
- No review queue means no moderation workload and no lag between a report and the index.

Bad, and accepted deliberately:

- A role that is not a superset of the one below it, such as a moderator who should not
  load data, does not fit. Adding one means a new ADR and likely leaving the hierarchy.
- One role per account means a capability cannot be granted to a single person without
  promoting them to everything that role carries.
- Unreviewed reports can be spammed or filed in bad faith. The weighting function (#24)
  has to resist that, and admin removal is the only other defence.
- Immutable reports mean a user who made a mistake cannot fix it; they file another one.
- Individual reports carry location and free text from identifiable accounts, so analysts
  and admins see personal data. Removal for erasure is an admin task, not self-service.
- The contract today applies `@useAuth(BearerAuth)` to the whole namespace. Public reads
  need that changed, and a client must cope with the same operation answering with or
  without a token.
