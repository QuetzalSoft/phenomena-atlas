# Shipping a change

## Within a single component

Branch off `main`, open a pull request, get a review, merge. Nothing special.

## Across components

A change to what the API exposes is three pull requests, in this order. Merging them out
of order breaks the clients.

### 1. The contract

In this repository, change `contracts/openapi.yaml`. Review focuses on the shape of the
interface, not on implementation. On merge, a new contract version is published.

Versioning follows semver, judged from the point of view of a client:

| Change | Bump |
|---|---|
| New optional field, new endpoint | minor |
| New required request field, removed field, renamed field, narrowed type | major |
| Description or example only | patch |

### 2. The API

Bump the contract dependency, implement the change. The conformance test proves the
running API matches the spec it claims to implement. A green API build with a stale
contract version is the failure this step exists to prevent.

### 3. The clients

Bump the contract dependency in `web/` and `mobile/`, regenerate, consume. The generated
types turn a contract mismatch into a compile error instead of a production incident.

## Removing or renaming anything

Never in one step. Mobile clients stay installed on old versions for months, so an old
shape has to keep working long after the new one exists.

**Expand**: add the new field or endpoint alongside the old one. Both work. Minor bump.

**Migrate**: move every client to the new shape and release them. For mobile this means
waiting until the old app versions fall below whatever threshold you accept, which is a
product decision, not an engineering one.

**Contract**: remove the old shape. Major bump.

The temptation is to skip the middle step because the web interface deployed in an hour.
Mobile is the component that makes this discipline necessary; the web interface is just
the one that makes it feel unnecessary.

## Checklist before merging a contract change

- [ ] Does this break an existing client? If yes, is it expand/contract rather than a cut?
- [ ] Is the glossary in `docs/domain.md` still accurate?
- [ ] Is the version bump right, judged from a client's point of view?
- [ ] Does this decision constrain future work? If yes, write an ADR.
