# Roles and permissions

Who can see and do what in Phenomena Atlas. The terms are defined in `domain.md`; the
reasons behind the model are in ADR 0009. Keycloak says who a user is (ADR 0008); the API
decides what that user may do, using the rules below.

## Roles

| Role | Purpose |
|---|---|
| `admin` | Operate and govern the system: phenomena, regions, accounts and their roles |
| `analyst` | Feed the atlas with data and read the individual incident reports behind it |
| `user` | Consume the atlas and file incident reports about phenomena |

The roles are a hierarchy: `admin` ⊇ `analyst` ⊇ `user`. Each role can do everything the
role below it can. Every account holds exactly one role.

An **anonymous visitor** is anyone calling without a valid token. It is not a role and
has no account; it gets only what the matrix grants it.

The set of roles is fixed. Adding, removing or reshaping a role needs a new ADR.

## Permission matrix

| Capability | Anonymous | `user` | `analyst` | `admin` |
|---|---|---|---|---|
| Browse and query published phenomena and their index | allow | allow | allow | allow |
| File an incident report | deny | allow | allow | allow |
| See one's own incident reports | deny | allow | allow | allow |
| See any individual incident report | deny | deny | allow | allow |
| Edit or withdraw an incident report | deny | deny | deny | deny |
| Remove an incident report (abuse, personal data) | deny | deny | deny | allow |
| See draft and archived phenomena | deny | deny | deny | allow |
| Define a phenomenon: create, change its characteristics and weighting function, publish, archive, delete a draft | deny | deny | deny | allow |
| Bulk ingestion | deny | deny | allow | allow |
| Read the municipalities and the current region partition | allow | allow | allow | allow |
| Change the region partition | deny | deny | deny | allow |
| Read past partition versions and their history | deny | deny | deny | allow |
| List accounts and their roles | deny | deny | deny | allow |
| Change an account's role | deny | deny | deny | allow, except their own |
| Edit one's own account details | deny | allow | allow | allow |
| Edit another account's details | deny | deny | deny | allow |
| Define new roles | deny | deny | deny | deny |

Anything not in this table is denied until it is added here.

## Assigning roles

- An account is created in the API the first time a valid token reaches it, keyed by the
  token's subject, with the role `user`.
- Only an admin changes an account's role, in either direction.
- An admin cannot change their own role. This keeps the system from losing its last admin.
- The first admin is seeded from deployment configuration, since no admin exists to
  promote one.

## Incident reports

An incident report is accepted as filed. Nobody reviews or approves it, and it has no
states: once filed, it counts toward the index of its phenomenon.

- It is immutable. Its author cannot edit or withdraw it.
- Analysts and admins can read individual reports, without their author. A user can read
  only their own.
- A report records a region, never an exact location (ADR 0013).
- Everyone, anonymous visitors included, sees the result of weighting all the reports of a
  phenomenon: its index, which is what the maps show.
- An admin can remove a report, for abuse or to erase personal data. Removing it is the
  only way it stops counting.

## Future work

- Authorization in the contract and the API: #22
- Incident reports in the API: #46
- Computing the phenomenon index from its weighting function: #24
- The bulk ingestion entry point, restricted to analysts and admins: #25
