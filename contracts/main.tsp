// The Phenomena Atlas API contract.
//
// This file is the source of truth. It is written before the code that implements it.
// See ../docs/adr/0002-spec-first-contract.md and ../docs/adr/0003-typespec-authoring-openapi-artifact.md
//
// generated/openapi.yaml is compiled from this file. Never edit the generated document:
// CI recompiles and fails if the two disagree.

import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./lib/geojson.tsp";

using Http;
using OpenAPI;

@service(#{ title: "Phenomena Atlas API" })
@info(#{
  version: "0.1.0",
  summary: "The API behind Phenomena Atlas, consumed by the web and mobile clients.",
})
@doc("""
  Every Phenomena Atlas client reaches domain data through this API. No client talks
  to the database directly.
  
  Before 1.0.0 the contract covers accounts and roles only. The domain operations depend
  on the glossary in ../docs/domain.md defining what a phenomenon is.
  """)
// TODO(team): replace with the real environments once hosting is decided.
@server("http://localhost:8000", "Local development")
@useAuth(BearerAuth)
namespace PhenomenaAtlas;

@doc("The error shape returned by every failing request.")
@error
model Error {
  @doc("Stable machine-readable identifier. Clients branch on this, never on message.")
  @example("phenomenon_not_found")
  code: string;

  @doc("Human-readable explanation. Not stable, not for client logic.")
  message: string;

  @doc("Optional structured context. Its shape depends on code.")
  details?: Record<unknown>;
}

model Health {
  status: "ok";
}

@doc("""
  Returns successfully when the service is running. Carries no domain meaning and
  is safe to call without authentication.
  """)
@summary("Liveness probe.")
@route("/health")
@get
@useAuth(NoAuth)
op getHealth(): Health;

// TODO(team): the domain endpoints. Blocked on ../docs/domain.md, which defines what a
// phenomenon is. Design the resources here before writing any handler. Geometries come
// from lib/geojson.tsp; do not redefine them.

// Authorization
//
// Every operation that requires a BearerAuth token also states the minimum role it needs,
// with the `x-minimum-role` extension. Roles form a hierarchy (user < analyst < admin), so
// an account passes when its role is that one or above. The API reads the extension from
// this document and enforces it; no handler decides permissions on its own. An operation
// that requires a token and lacks the extension is a contract bug, and the API refuses to
// serve it. See ../docs/roles.md and ../docs/adr/0009-hierarchical-roles-enforced-by-the-api.md.

@doc("""
  What an account may do. Each role includes everything the role before it can do:
  user, then analyst, then admin.
  """)
enum Role {
  user,
  analyst,
  admin,
}

@doc("""
  A person known to the API, created the first time they call it with a valid token.
  The profile fields are copied from that token and refreshed when they change.
  """)
model Account {
  @doc("The API's own identifier for the account.")
  @format("uuid")
  id: string;

  @doc("The login name the identity provider reports. Absent until the person first signs in.")
  username?: string;

  @doc("The person's display name, when the identity provider has one.")
  name?: string;

  @doc("The person's email address, when the identity provider has one.")
  email?: string;

  role: Role;

  @doc("When the account was created.")
  createdAt: utcDateTime;
}

@doc("One page of accounts, oldest first.")
model AccountPage {
  items: Account[];

  @doc("Pass as `cursor` to get the next page. Absent on the last page.")
  nextCursor?: string;
}

@doc("The request does not match the contract. `details` lists what was wrong.")
@error
model BadRequestError {
  @statusCode _: 400;
  ...Error;
}

@doc("The access token is missing, invalid or expired.")
@error
model UnauthorizedError {
  @statusCode _: 401;
  @header("WWW-Authenticate") wwwAuthenticate: "Bearer";
  ...Error;
}

@doc("The caller's role does not allow this operation, or the operation's own rules forbid it.")
@error
model ForbiddenError {
  @statusCode _: 403;
  ...Error;
}

@doc("The resource does not exist.")
@error
model NotFoundError {
  @statusCode _: 404;
  ...Error;
}

@route("/accounts")
namespace Accounts {
  @doc("""
    Returns the caller's own account, creating it with the role `user` on the first call.
    Clients use it to learn which role the signed-in person holds.
    """)
  @summary("The caller's account.")
  @route("/me")
  @get
  @extension("x-minimum-role", "user")
  op getMyAccount(): Account | UnauthorizedError;

  @doc("Lists every account and its role, oldest first.")
  @summary("List accounts.")
  @get
  @extension("x-minimum-role", "admin")
  op listAccounts(
    @doc("How many accounts to return. Defaults to 50.")
    @query
    @minValue(1)
    @maxValue(200)
    limit?: int32,

    @doc("The `nextCursor` of the previous page.")
    @query
    cursor?: string,
  ): AccountPage | BadRequestError | UnauthorizedError | ForbiddenError;

  @doc("""
    Changes an account's role. Admins cannot change their own role, which answers 403 with
    the code `own_role_change_forbidden`; this keeps the system from losing its last admin.
    """)
  @summary("Change an account's role.")
  @route("/{accountId}/role")
  @put
  @extension("x-minimum-role", "admin")
  op changeAccountRole(
    @path
    @format("uuid")
    accountId: string,

    @body body: {
      role: Role;
    },
  ):
    | Account
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError;
}
