# Architecture

## Components

```
                   contracts/openapi.yaml
                   (spec-first, versioned, published as a package)
                             |
              +--------------+--------------+
              |              |              |
         implements       consumes       consumes
              |              |              |
         +----v----+    +----v----+   +-----v-----+
         |   API   |    |   Web   |   |  Mobile   |
         +----+----+    +---------+   +-----------+
              |
         +----v----+
         | Database|
         +---------+
```

**API** owns the domain and is the only component with database access. Every other
component reaches the data through the API, with no exceptions. If a client needs
something the API does not expose, the fix is a contract change, never a side channel.

**Web** and **Mobile** are clients. They hold presentation logic and client state. They
hold no domain rules that the API does not also enforce: a client-side check is a
convenience for the user, never the thing that protects an invariant.

## Why three repositories and not one

See `adr/0001-polyrepo-with-contracts.md`. In short: the components deploy on different
cadences, and the coupling between them is handled explicitly by the contract rather
than implicitly by living in the same tree.

The cost of that choice is that nothing stops an API change from breaking a client at
runtime. The contract package and its conformance test are what buy that safety back,
which is why they are not optional.

## The contract seam

`contracts/openapi.yaml` is the only agreed interface between the API and its clients.

- It is written before the code that implements it. See `adr/0002-spec-first-contract.md`.
- The API proves it complies through a conformance test run in CI.
- Clients generate their types and request layer from it. Hand-written request code that
  bypasses the generated client is how drift starts.
- It is versioned with semver and published as a package. Clients pin a version, so an
  API deploy can never silently change what a client was built against.

## Deployment

Each component deploys independently from its own repository.

> TODO(team): record the hosting target, environments and deploy trigger for each
> component once decided.

## Open decisions

> TODO(team): mobile stack is not chosen yet. The choice does not affect anything in
> this document, since the contract is language-neutral, but it does determine whether
> the mobile client can reuse the web client's generated package or needs its own
> generator.
