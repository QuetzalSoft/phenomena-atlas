# Shipping a change

## Within a single component

Branch off `main`, open a pull request, get a review, merge. Nothing special.

## Across components

A change to what the API exposes is three pull requests, in this order. Merging them out
of order breaks the clients.

### 1. The contract

In this repository:

1. Edit `contracts/main.tsp` (or `contracts/lib/geojson.tsp`). Never the generated document.
2. Run `bun run build` in `contracts/`.
3. Bump `version` in `contracts/package.json` using the table below.
4. Commit the regenerated `contracts/generated/` along with the source.

Review focuses on the shape of the interface, not on implementation, and the committed
diff of `generated/openapi.yaml` is what makes that reviewable. On merge, that version
is published as `@quetzalsoft/phenomena-atlas-contract`.

CI will stop you if the generated document is stale, or if the change is incompatible
with the contract currently on the base branch.

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

Bump the contract dependency in `web/` and `mobile/` and consume the new types. Both are
TypeScript, so both import from the same package; the generated types turn a contract
mismatch into a compile error instead of a production incident.

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
- [ ] Is `contracts/generated/` committed and up to date?
- [ ] Did the Contract workflow actually run and pass, rather than being skipped?
- [ ] Does this decision constrain future work? If yes, write an ADR.

## If the breaking-change check gets in your way

It is doing its job. The check compares against the contract on the base branch and
fails on anything a pinned client could not survive.

Do not disable it, and do not reach for a major bump as a shortcut. A major bump is
honest only when every client can be migrated before the old shape disappears, and the
mobile application cannot be migrated on demand: old versions stay installed. The route
through is expand/contract, above.

`oasdiff` exits 0 even when it finds breaking changes unless it is run with
`--fail-on ERR`. If the check ever goes quiet, verify that flag is still in
`.github/workflows/contract.yml` before believing the contract is safe.
