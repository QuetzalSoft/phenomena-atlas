# Domain glossary

The vocabulary of Phenomena Atlas. One term, one meaning, used identically in the
contract, the database, the API, both clients, and in conversation.

When a term here changes, it changes everywhere in the same pull request. A rename that
lands in the API but not in the web interface is how a codebase starts lying.

## Status

This glossary is a skeleton. Filling it is the first real design task, and it should
happen before the first endpoint is written, because the contract depends on it.

## Terms

### Phenomenon

> TODO(team): the central entity. Define precisely what counts as one and what does not.
> What are its required attributes? What makes two records the same phenomenon?

### (further terms)

> TODO(team): add one section per term as the model takes shape. Likely candidates based
> on the product being an atlas: classification or taxonomy, location, time or period,
> source and evidence, confidence. Do not add a term here until it has a real definition;
> an empty heading is worse than an absent one.

## Naming rules

- English everywhere, including identifiers in the database and the contract.
- Singular for an entity (`phenomenon`), plural for a collection endpoint (`/phenomena`).
- The name used in `contracts/openapi.yaml` wins. If the database or a client disagrees
  with the contract, the contract is right and the other side is a bug.
