# 0008 - Users authenticate with a self-hosted Keycloak, and roles live in the API

- Status: accepted
- Date: 2026-11-11

## Context

The contract has declared Bearer authentication on every operation except the liveness
probe since it was first written, but nothing issued or checked those tokens. The API's
validator ran with security checks off, and the web and API repositories both listed the
token issuer as an open decision.

Three kinds of answer were considered:

- **Authentication built into the API**: users and password hashes in the API database,
  tokens issued by the API. Full control, but registration, login, password recovery,
  email verification, token rotation, lockout and MFA all become this team's security
  surface, on an API meant to become public.
- **A managed identity provider** (Auth0, Clerk, Cognito, Supabase Auth). Least work today.
  Users and password hashes live with the vendor, so leaving means migrating users, and
  some vendors cannot import password hashes at all.
- **A self-hosted OpenID Connect server** (Keycloak, Zitadel, Logto, Ory). The same
  protocol as a managed provider, run by the team.

Where roles live was a separate question: as claims in the token, managed in the identity
provider, or in the API database keyed by the user's id.

## Decision

**Keycloak, self-hosted, is the identity provider.** It handles login, registration and
everything around credentials, and issues OpenID Connect tokens. Keycloak was chosen over
the other self-hosted servers for maturity and its Apache 2.0 licence. Its state is a
container and its own PostgreSQL database, separate from the API's, so moving it between
hosts is a database copy rather than a user migration.

**Keycloak gets its own domain from the start**, such as `auth.<product domain>`. Tokens
carry the issuer URL, so keeping the hostname is what makes a later move invisible to the
API and the clients.

**The API only checks tokens.** For every operation the contract protects, it verifies the
signature against Keycloak's published keys, the issuer, the expiry, and that the audience
includes `phenomena-atlas-api`. Which operations need a token is decided by the contract,
not by API code.

**Roles and permissions live in the API database**, keyed by the token's subject, and are
enforced by the API. Keycloak says who the user is; the API decides what that user may do.
Nothing in the API reads a role claim from a token or references Keycloak's tables. Roles
are not defined yet: they come from the domain in `docs/domain.md`.

**Clients log in through Keycloak's own pages**, with the authorization code flow and PKCE.
Where the web client keeps the token, and how its Server Components forward it, is decided
in the web repository. The mobile client gets its own Keycloak client when it exists.

The local setup, the realm file and the token checks are in the API repository.

## What was verified

Keycloak 26.8 ran locally with a realm imported from a file, next to the API on Node 26:

- A login through the web client's authorization code flow with PKCE, driven the way a
  browser drives it, returned an access token whose issuer, audience and subject were the
  ones the API expects.
- The API's verifier accepted that token, and refused a token minted for another
  audience, a token from another issuer, a token with altered claims and a string that is
  not a token.
- When Keycloak's keys could not be fetched, the verifier reported its own failure rather
  than blaming the caller.
- The liveness probe still answered without a token, and with a bad one.

It did not cover a protected operation over HTTP, because the contract has none yet, nor
running Keycloak on production settings, nor clustering.

## Consequences

Good:

- No credential handling in this team's code. Password storage, recovery, MFA and social
  login come from Keycloak.
- Moving Keycloak to another host keeps users, password hashes and signing keys, so nobody
  has to reset a password.
- A role change takes effect on the next request, and roles can depend on domain data,
  such as a region a user moderates.
- Changing identity provider later does not touch the role model. It still means migrating
  users, as leaving any provider does.

Bad, and accepted deliberately:

- The team operates Keycloak: security updates, backups, monitoring and upgrades. While it
  is down, nobody can log in to any client.
- Keycloak runs on the JVM and needs noticeably more memory than the API.
- Roles in the API database mean tables, migrations and an administration path that a
  role claim in the token would not need, plus a lookup per request.
- Keycloak's login pages need theming to match the product, and its theming is awkward.
- The API's test suite starts a real Keycloak, which makes every run slower.
