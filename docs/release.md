# Shipping a change

Every repository has two protected branches: `main` is what is in production and
`develop` is where the sprint is integrated. Why, and what it costs, is in ADR 0005.

## Within a single component

Branch off `develop`, open a pull request into `develop`, get a review, merge. Nothing
special. It reaches production with the next release.

## Across components

A change to what the API exposes is three pull requests into `develop`, in this order.
Merging them out of order breaks the clients.

### 1. The contract

In this repository:

1. Edit `contracts/main.tsp` (or `contracts/lib/geojson.tsp`). Never the generated document.
2. Run `bun run build` in `contracts/`.
3. Bump `version` in `contracts/package.json` using the table below.
4. Commit the regenerated `contracts/generated/` along with the source.

Review focuses on the shape of the interface, not on implementation, and the committed
diff of `generated/openapi.yaml` is what makes that reviewable. On merge into `develop`,
a prerelease `X.Y.Z-dev.N` is published as `@quetzalsoft/phenomena-atlas-contract` under
the `next` dist-tag. The stable `X.Y.Z` is published under `latest` when the release
reaches `main`.

CI will stop you if the generated document is stale, or if the change is incompatible
with the contract currently on the base branch.

Versioning follows semver, judged from the point of view of a client:

| Change | Bump |
|---|---|
| New optional field, new endpoint | minor |
| New required request field, removed field, renamed field, narrowed type | major |
| Description or example only | patch |

### 2. The API

Bump the contract dependency to the prerelease, implement the change. The conformance test proves the
running API matches the spec it claims to implement. A green API build with a stale
contract version is the failure this step exists to prevent.

### 3. The clients

Bump the contract dependency in `web/` and `mobile/` to the prerelease and consume the
new types. Both are TypeScript, so both import from the same package; the generated types
turn a contract mismatch into a compile error instead of a production incident.

## Releasing to production

A release is a pull request from `develop` into `main`, merged with a merge commit (the
only method `main` allows). It goes through the same order as above:

1. **This repository** first. The `contract` check compares the release against the
   contract on `main`, which is the one in production. On merge, the stable `X.Y.Z` is
   published.
2. **`api/`**: on `develop`, move the pin from `X.Y.Z-dev.N` to `X.Y.Z`, then release.
3. **`web/` and `mobile/`**: the same, after the API is in production.

Never release a component that still pins a `-dev` version.

## Hotfixes

Branch `hotfix/<short-name>` off `main`, open a pull request into `main`, merge. Then open
a pull request from `main` into `develop`, so the fix is not undone by the next release.
The `source-branch` check on `main` rejects any other head branch, which is why the name
matters.

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
- [ ] Did the `contract` check run its `No breaking changes` step and pass, rather than
      reporting green with verification skipped?
- [ ] Does this decision constrain future work? If yes, write an ADR.

## If the breaking-change check gets in your way

It is doing its job. The check compares against the contract on the base branch
(`develop` for a contract change, `main` for a release) and fails on anything a pinned
client could not survive.

Do not disable it, and do not reach for a major bump as a shortcut. A major bump is
honest only when every client can be migrated before the old shape disappears, and the
mobile application cannot be migrated on demand: old versions stay installed. The route
through is expand/contract, above.

`oasdiff` exits 0 even when it finds breaking changes unless it is run with
`--fail-on ERR`. If the check ever goes quiet, verify that flag is still in
`.github/workflows/contract.yml` before believing the contract is safe.
