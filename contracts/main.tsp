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
  
  Before 1.0.0 the contract covers accounts and roles, and the municipalities and region
  partition of the metropolitan area. The phenomenon operations depend on the glossary in
  ../docs/domain.md defining what a phenomenon is.
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

@doc("The resource changed since the version the request was based on.")
@error
model ConflictError {
  @statusCode _: 409;
  ...Error;
}

// Municipalities and regions
//
// The metropolitan area is the union of four municipalities. Admins divide it into
// regions, which the maps paint one colour each. The regions always form a full
// partition, and every saved change is a new immutable version. See
// ../docs/adr/0010-region-data-sources.md and ../docs/adr/0011-versioned-region-partition.md.

@doc("A municipality's five-digit INEGI key: state then municipality, e.g. `14039`.")
@pattern("^[0-9]{5}$")
@example("14039")
scalar MunicipalityCode extends string;

@doc("A region's id. Assigned by the API, never changed and never reused.")
@minValue(1)
scalar RegionId extends int32;

model MunicipalityProperties {
  @doc("The municipality's name as INEGI writes it.")
  name: string;
}

@doc("One municipality of the metropolitan area, with its INEGI boundary.")
model Municipality is GeoJson.Feature<MunicipalityProperties, GeoJson.MultiPolygon> {
  id: MunicipalityCode;
}

@doc("The four municipalities of the metropolitan area.")
model MunicipalityCollection is GeoJson.FeatureCollection<Municipality>;

model RegionProperties {
  @minLength(1)
  @maxLength(200)
  name: string;

  @doc("How many people live in the region.")
  @minValue(0)
  population: int32;

  @doc("The municipality the region lies entirely inside.")
  municipalityCode: MunicipalityCode;
}

@doc("An area of the metropolitan area that the maps paint in its own colour.")
model Region is GeoJson.Feature<RegionProperties, GeoJson.MultiPolygon> {
  id: RegionId;
}

@doc("""
  The regions of one partition version. Together they cover the metropolitan area
  exactly, with no overlap.
  """)
model RegionPartition is GeoJson.FeatureCollection<Region> {
  @doc("The partition version these regions belong to.")
  @minValue(1)
  version: int32;

  @doc("When that version was saved.")
  createdAt: utcDateTime;
}

@doc("Who saved a partition version.")
model PartitionVersionAuthor {
  @format("uuid")
  id: string;

  username?: string;
  name?: string;
}

@doc("One saved state of the region partition, and what it changed.")
model PartitionVersion {
  @minValue(1)
  number: int32;

  createdAt: utcDateTime;

  @doc("The admin who saved it. Absent for version 1, the initial load.")
  author?: PartitionVersionAuthor;

  @doc("Regions this version created.")
  added: RegionId[];

  @doc("Regions this version renamed, reshaped or gave a new population.")
  changed: RegionId[];

  @doc("Regions this version retired.")
  retired: RegionId[];
}

@doc("One page of partition versions, newest first.")
model PartitionVersionPage {
  items: PartitionVersion[];

  @doc("Pass as `cursor` to get the next page. Absent on the last page.")
  nextCursor?: string;
}

@doc("A region as a change sends it: new when it has no id, an existing region otherwise.")
model RegionDraft {
  @doc("The id of the region to change. Omit it to create a region.")
  id?: RegionId;

  ...RegionProperties;
  geometry: GeoJson.MultiPolygon;
}

@doc("A change to the region partition, applied as a whole or not at all.")
model PartitionChange {
  @doc("The version the change was made against. It must still be the latest.")
  @minValue(1)
  baseVersion: int32;

  @doc("Regions to create or change. Each region appears at most once.")
  regions: RegionDraft[];

  @doc("Regions to retire. Their area must be covered by the regions above.")
  retiredRegionIds: RegionId[];
}

@doc("The municipalities and regions of the metropolitan area.")
namespace Regions {
  @doc("""
    Returns the four municipalities of the metropolitan area with their boundaries.
    """)
  @summary("List municipalities.")
  @route("/municipalities")
  @get
  @useAuth(NoAuth)
  op listMunicipalities(): MunicipalityCollection;

  @doc("""
    Returns every region of the latest partition version. Answers 404 with the code
    `partition_not_loaded` before the initial partition is loaded.
    """)
  @summary("The current region partition.")
  @route("/region-partition")
  @get
  @useAuth(NoAuth)
  op getRegionPartition(): RegionPartition | NotFoundError;

  @doc("Lists the saved partition versions and what each one changed, newest first.")
  @summary("List partition versions.")
  @route("/region-partition/versions")
  @get
  @extension("x-minimum-role", "admin")
  op listPartitionVersions(
    @doc("How many versions to return. Defaults to 50.")
    @query
    @minValue(1)
    @maxValue(200)
    limit?: int32,

    @doc("The `nextCursor` of the previous page.")
    @query
    cursor?: string,
  ): PartitionVersionPage | BadRequestError | UnauthorizedError | ForbiddenError;

  @doc("""
    Returns every region as it was in one partition version. Answers 404 with the code
    `partition_version_not_found` when there is no such version.
    """)
  @summary("A past region partition.")
  @route("/region-partition/versions/{number}")
  @get
  @extension("x-minimum-role", "admin")
  op getPartitionVersion(
    @path
    @minValue(1)
    number: int32,
  ):
    | RegionPartition
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError;

  @doc("""
    Saves a change to the region partition as the next version. The change is applied
    atomically and then validated; if any rule fails, nothing is saved.

    Errors, each with its own `code`. In `details`, `regionIds` lists the existing regions
    involved, `draftIndexes` the positions in `regions` of new ones, and `geometry` the
    offending area when there is one:

    - 400 `empty_change`: no region to create, change or retire.
    - 400 `duplicate_region_in_change`: a region appears more than once.
    - 400 `region_not_found`: an id that does not exist or was already retired.
    - 400 `invalid_geometry`: a geometry that is empty or not valid.
    - 400 `region_crosses_municipality`: a region reaches into another municipality, or
      a changed region moves to another municipality.
    - 400 `region_out_of_area`: a region reaches outside the metropolitan area.
    - 400 `region_overlap`: two regions overlap.
    - 400 `partition_gap`: part of a municipality is left without a region.
    - 409 `partition_version_conflict`: `baseVersion` is no longer the latest version.

    Overlaps and gaps under one square metre are tolerated. Coordinates are returned
    exactly as stored, so geometries built from them match their neighbours' borders.
    """)
  @summary("Save a partition version.")
  @route("/region-partition/versions")
  @post
  @extension("x-minimum-role", "admin")
  op savePartitionVersion(@body body: PartitionChange):
    | {
        @statusCode _: 201;
        @body version: PartitionVersion;
      }
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | ConflictError;
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

  @doc("""
    Lists accounts and their roles, oldest first. Every filter is optional, and the ones
    given combine: an account is listed only when it matches all of them.

    A cursor is only valid with the filters of the request that returned it; pass the same
    filters again with it. When both dates are given, `createdFrom` must be earlier than
    `createdBefore`, or the API answers 400 with the code `invalid_date_range`.
    """)
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

    @doc("Only accounts with this role.")
    @query
    role?: Role,

    @doc("""
      Only accounts whose username, name or email contains this text, ignoring case.
      Every character is taken literally.
      """)
    @query
    @minLength(1)
    @maxLength(100)
    q?: string,

    @doc("Only accounts created at or after this instant.")
    @query
    createdFrom?: utcDateTime,

    @doc("Only accounts created before this instant. Together with `createdFrom`, a half-open range.")
    @query
    createdBefore?: utcDateTime,
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
