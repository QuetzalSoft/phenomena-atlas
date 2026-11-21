# 0014 - Account details are edited through the API, which writes them to Keycloak

- Status: proposed
- Date: 2026-11-20
- Amends: `0008-authentication-with-keycloak.md`

## Context

Accounts show a username, a name and an email, and people cannot change them in the
product. Keycloak is the source of truth for these fields: on every authenticated request
the API refreshes the account's local profile from the access token when the values differ.
A change stored only in the API would be put back the next time a token with the old values
arrives.

ADR 0008 decided that Keycloak authenticates and the API only checks tokens. Editing a
profile means the API also has to write to Keycloak, which that record did not anticipate.
Issue #36 asks for two things: people edit their own details, and admins correct other
people's from the accounts panel.

Two options were considered:

- **The API writes to Keycloak's Admin REST API through a service account client.** One
  mechanism covers both cases, and the change shows at once inside the product. The cost is
  a runtime dependency on Keycloak and a credential held by the API.
- **People are sent to Keycloak's account console.** Simpler, with no new credential. But it
  does nothing for an admin correcting someone else's details, it takes people out of the
  product, and the local profile only catches up with the next token.

## Decision

**The API writes account details to Keycloak, through a service account client.**

**Only first name, last name and email are editable.** Keycloak keeps a first and a last
name, and the display name is the two together, so the product edits them as Keycloak keeps
them instead of splitting one name and guessing where it divides. The username is not
editable: it is how people and admins recognise an account, and nothing in the product needs
it to change.

**The service account has the minimum Keycloak permissions** to find and update users, and
nothing else. It is a confidential client in the realm. Its secret comes from deployment
configuration, never from the repository; local development uses a development-only value,
like the seeded `dev` and `admin` accounts.

**Authorization stays in the API.** The API decides who may edit what from its own roles, as
in ADR 0009 and `docs/roles.md`: anyone edits their own details, and only an admin edits
another account's. Only after that check does the API use the service account. No token of
a person is ever given authority in Keycloak.

**Keycloak is written first, then the local row.** If Keycloak refuses the change or cannot
be reached, nothing changes locally. If Keycloak accepts it and the local write fails, the
API reports a failure, and the local profile catches up from the next token that carries the
new values.

**Tokens issued before an edit do not undo it.** A token issued before the change still
carries the old names and email until it is refreshed or the person signs in again, and the
API refreshes the local profile from whatever token arrives. So the API does not refresh
names and email from a token issued before the profile's last edit. This needs the time of
the last edit on the account and the token's issue time.

**Refusals have their own error codes.** Keycloak decides whether an email is already taken
or invalid, and the API maps its answers instead of duplicating the rules. The contract
declares distinct codes for an email already in use, for an invalid value, and for an update
that could not be completed because Keycloak refused it for another reason or could not be
reached. In all three the local row is untouched. Clients branch on the code and show their
own text. The code names and status codes are set in the contract.

**Whether changing an email requires verifying the new address is not decided here.** It is
left open and tracked in its own issue.

## Consequences

Good:

- One mechanism serves both a person editing their own details and an admin editing
  someone else's.
- Keycloak stays the source of truth, and roles stay in the API. No person's token gains
  power over Keycloak.
- A change shows immediately in the product, and survives signing out and in.

Bad, and accepted deliberately:

- The API now depends on Keycloak at runtime for these operations. While Keycloak is
  unavailable, details cannot be edited.
- The API holds a credential that can edit every user in the realm. Combined with password
  recovery by email, a leaked secret allows taking over accounts. Limiting its permissions
  reduces the damage but does not remove it.
- Keycloak and the local row are written one after the other, with no transaction across
  both. A failure between the two leaves them different until the next token.
- The rule about older tokens adds a timestamp to the account and one more comparison on
  every authenticated request.
- Until the open question is settled, a person can set an email address they do not own,
  since nothing verifies it.
- ADR 0008's statement that the API only checks tokens no longer holds without exception.
