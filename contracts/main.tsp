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
  
  Before 1.0.0 the contract covers accounts and roles, the municipalities and region
  partition of the metropolitan area, the definition of phenomena: their
  characteristics and their weighting function, and the incident reports filed about
  them.
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
  The profile fields are copied from that token and refreshed when they change. The first
  name, last name and email can also be edited, with `updateMyProfile` and
  `updateAccountProfile`.
  """)
model Account {
  @doc("The API's own identifier for the account.")
  @format("uuid")
  id: string;

  @doc("The login name the identity provider reports. Absent until the person first signs in.")
  username?: string;

  @doc("The person's display name, when the identity provider has one.")
  name?: string;

  @doc("The person's first name, when the identity provider has one.")
  firstName?: string;

  @doc("The person's last name, when the identity provider has one.")
  lastName?: string;

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

@doc("""
  The details of an account that its owner, or an admin, can edit. The display name is
  not one of them: it is the first and last name together. The username is not one
  either: it comes from the identity provider and does not change.
  """)
model AccountProfile {
  @doc("The person's first name, as the identity provider keeps it.")
  @minLength(1)
  @maxLength(100)
  firstName: string;

  @doc("The person's last name, as the identity provider keeps it.")
  @minLength(1)
  @maxLength(100)
  lastName: string;

  @doc("The person's email address.")
  @format("email")
  @maxLength(254)
  email: string;
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

@doc("""
  The request conflicts with the current state of the resource: it changed since the
  version the request was based on, or the value asked for is already taken.
  """)
@error
model ConflictError {
  @statusCode _: 409;
  ...Error;
}

@doc("""
  The service could not complete the request right now. Nothing was changed, and the
  request can be tried again.
  """)
@error
model ServiceUnavailableError {
  @statusCode _: 503;
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
model Municipality is GeoJson.Feature<
  MunicipalityProperties,
  GeoJson.MultiPolygon
> {
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
  ):
    | PartitionVersionPage
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError;

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

// Phenomena
//
// A phenomenon is what one map of the atlas shows, such as gender violence or
// contaminated water. Admins define what every incident report of it records (its
// characteristics) and how the reports in a region become that region's index (its
// weighting function). See ../docs/adr/0012-configurable-phenomena.md.

@doc("A phenomenon's id. Assigned by the API, never changed and never reused.")
@minValue(1)
scalar PhenomenonId extends int32;

@doc("""
  Where a phenomenon is in its life:
  
  - `draft`: being defined. Only admins see it, and it accepts no reports.
  - `published`: public, and accepts reports.
  - `archived`: hidden from everyone but admins. Its reports are kept; it accepts no new ones.
  """)
enum PhenomenonStatus {
  draft,
  published,
  archived,
}

@doc("""
  How a characteristic or a category option is referred to by reports and by the
  weighting function. Lowercase letters, digits and underscores, starting with a letter.
  It never changes once saved.
  """)
@pattern("^[a-z][a-z0-9_]{0,39}$")
@example("victims")
scalar CharacteristicKey extends string;

@doc("What every characteristic has, whatever its type.")
model CharacteristicFields {
  key: CharacteristicKey;

  @doc("What a person filing a report sees.")
  @minLength(1)
  @maxLength(100)
  label: string;

  @doc("Help shown next to the field when filing a report.")
  @maxLength(500)
  description?: string;

  @doc("Whether a new report must carry a value for it.")
  required: boolean;

  @doc("""
    A retired characteristic is kept on the reports that already carry it, but new
    reports do not carry it and the weighting function cannot use it.
    """)
  retired: boolean;
}

@doc("A number. In the weighting function it counts as its value.")
model NumberCharacteristic {
  type: "number";
  ...CharacteristicFields;

  @doc("Whether only whole numbers are accepted.")
  integer: boolean;

  @doc("The smallest value accepted, when there is one.")
  minimum?: float64;

  @doc("The largest value accepted, when there is one. Not less than `minimum`.")
  maximum?: float64;

  @doc("The unit the value is expressed in, shown next to it.")
  @maxLength(20)
  unit?: string;
}

@doc("Yes or no. In the weighting function, yes counts as 1 and no as 0.")
model BooleanCharacteristic {
  type: "boolean";
  ...CharacteristicFields;
}

@doc("One of a closed list of options. In the weighting function it counts as the chosen option's weight.")
model CategoryCharacteristic {
  type: "category";
  ...CharacteristicFields;

  @doc("The options, in the order they are offered. At least one must not be retired.")
  @minItems(1)
  options: CategoryOption[];
}

@doc("One option of a category characteristic.")
model CategoryOption {
  key: CharacteristicKey;

  @minLength(1)
  @maxLength(100)
  label: string;

  @doc("What the option counts as in the weighting function.")
  weight: float64;

  @doc("A retired option is kept on existing reports but not offered for new ones.")
  retired: boolean;
}

@doc("Free text. Recorded with the report, but not usable in the weighting function.")
model TextCharacteristic {
  type: "text";
  ...CharacteristicFields;

  @doc("The longest text accepted, in characters.")
  @minValue(1)
  @maxValue(5000)
  maxLength: int32;
}

@doc("A calendar date. Recorded with the report, but not usable in the weighting function.")
model DateCharacteristic {
  type: "date";
  ...CharacteristicFields;
}

@doc("""
  One field that every incident report of a phenomenon carries. Its key and its type
  never change once saved.
  """)
@discriminated(#{ envelope: "none", discriminatorPropertyName: "type" })
union Characteristic {
  number: NumberCharacteristic,
  boolean: BooleanCharacteristic,
  category: CategoryCharacteristic,
  text: TextCharacteristic,
  date: DateCharacteristic,
}

@doc("A constant.")
model WeightingNumber {
  kind: "number";
  value: float64;
}

@doc("The population of the region being computed.")
model WeightingPopulation {
  kind: "population";
}

@doc("""
  How an aggregate combines the reports of a region:
  
  - `count`: how many reports there are. Takes no characteristic.
  - `sum`, `mean`, `min`, `max`: of the values of one characteristic. Reports without a
    value for it are left out.
  """)
enum AggregateFunction {
  count,
  sum,
  mean,
  min,
  max,
}

@doc("""
  A value computed from the reports located in the region. The characteristic must be a
  number, yes/no or category characteristic that is not retired.
  """)
model WeightingAggregate {
  kind: "aggregate";
  function: AggregateFunction;

  @doc("The characteristic to aggregate. Required for every function but `count`, which takes none.")
  characteristicKey?: CharacteristicKey;
}

enum WeightingOperator {
  add,
  subtract,
  multiply,
  divide,
}

@doc("An arithmetic operation on two expressions: `left` operator `right`.")
model WeightingOperation {
  kind: "operation";
  operator: WeightingOperator;
  left: WeightingExpression;
  right: WeightingExpression;
}

@doc("""
  A part of the function not filled in yet. Allowed only while the phenomenon is a draft,
  so that a function can be saved half-built.
  """)
model WeightingBlank {
  kind: "blank";
}

@doc("""
  The weighting function, as a tree. It is evaluated once per region of the current
  partition, over the reports located in that region. When the result is undefined, such
  as a division by zero or a mean over no values, the region has no index, which is not
  the same as an index of 0. At most 100 nodes and 20 levels deep.
  """)
@discriminated(#{ envelope: "none", discriminatorPropertyName: "kind" })
union WeightingExpression {
  number: WeightingNumber,
  population: WeightingPopulation,
  aggregate: WeightingAggregate,
  operation: WeightingOperation,
  blank: WeightingBlank,
}

@doc("What an admin defines about a phenomenon.")
model PhenomenonDefinition {
  @minLength(1)
  @maxLength(200)
  name: string;

  @doc("What the phenomenon is and what its map shows.")
  @maxLength(2000)
  description: string;

  @doc("The fields every incident report carries, in the order they are shown. Keys are unique.")
  @maxItems(50)
  characteristics: Characteristic[];

  weightingFunction: WeightingExpression;
}

@doc("Something the atlas maps, with the fields its reports carry and how its index is computed.")
model Phenomenon {
  id: PhenomenonId;
  ...PhenomenonDefinition;
  status: PhenomenonStatus;

  @doc("Grows by one on every change. Send it back as `baseRevision` to change the phenomenon.")
  @minValue(1)
  revision: int32;

  createdAt: utcDateTime;
  updatedAt: utcDateTime;
}

@doc("The phenomena the caller can see, by name.")
model PhenomenonList {
  items: Phenomenon[];
}

@doc("A new definition for an existing phenomenon, replacing the previous one as a whole.")
model PhenomenonChange {
  @doc("The revision the change was made against. It must still be the latest.")
  @minValue(1)
  baseRevision: int32;

  ...PhenomenonDefinition;
}

@doc("A change of a phenomenon's status.")
model PhenomenonStatusChange {
  @doc("The revision the change was made against. It must still be the latest.")
  @minValue(1)
  baseRevision: int32;

  status: PhenomenonStatus;
}

@doc("""
  Phenomena and their definitions.
  
  A definition is refused with 400 and its own `code` when it breaks a rule. `details.path`
  is a JSON Pointer into the request body to the part at fault, such as
  `/characteristics/2/options/0` or `/weightingFunction/left/right`:
  
  - `duplicate_characteristic_key`: two characteristics share a key.
  - `duplicate_category_option_key`: two options of one category share a key.
  - `category_without_options`: every option of a category is retired.
  - `invalid_number_range`: `minimum` is greater than `maximum`.
  - `characteristic_removed`: a saved characteristic is missing. Retire it instead.
  - `category_option_removed`: a saved option is missing. Retire it instead.
  - `characteristic_type_changed`: a saved characteristic has a different type.
  - `unknown_characteristic`: the function refers to a key no characteristic has.
  - `characteristic_retired`: the function uses a retired characteristic.
  - `characteristic_not_aggregable`: the function aggregates a text or date characteristic.
  - `invalid_aggregate`: `count` with a characteristic, or another function without one.
  - `weighting_function_too_large`: more than 100 nodes or more than 20 levels.
  - `incomplete_weighting_function`: a blank in the function of a phenomenon that is, or
    is being, published.
  """)
@route("/phenomena")
namespace Phenomena {
  @doc("""
    Lists phenomena by name. Admins see every phenomenon and can filter by status; anyone
    else, signed in or not, sees only published ones, and asking for another status
    answers 403 with the code `forbidden`.
    """)
  @summary("List phenomena.")
  @get
  @useAuth(NoAuth | BearerAuth)
  op listPhenomena(
    @doc("Only phenomena with this status.")
    @query
    status?: PhenomenonStatus,
  ): PhenomenonList | BadRequestError | ForbiddenError;

  @doc("""
    Returns one phenomenon. Drafts and archived phenomena are visible to admins only;
    for anyone else the API answers 404 with the code `phenomenon_not_found`, as it does
    when there is no such phenomenon.
    """)
  @summary("A phenomenon.")
  @route("/{phenomenonId}")
  @get
  @useAuth(NoAuth | BearerAuth)
  op getPhenomenon(@path phenomenonId: PhenomenonId):
    | Phenomenon
    | BadRequestError
    | NotFoundError;

  @doc("""
    Creates a phenomenon as a draft, at revision 1. A new phenomenon usually starts with
    no characteristics and a `blank` weighting function.
    """)
  @summary("Create a phenomenon.")
  @post
  @extension("x-minimum-role", "admin")
  op createPhenomenon(@body body: PhenomenonDefinition):
    | {
        @statusCode _: 201;
        @body phenomenon: Phenomenon;
      }
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError;

  @doc("""
    Replaces a phenomenon's definition. Characteristics and options already saved must
    all be sent again, with the same key and type: they are retired, never removed.
    Answers 409 with the code `phenomenon_revision_conflict` when `baseRevision` is no
    longer the latest revision.
    """)
  @summary("Change a phenomenon.")
  @route("/{phenomenonId}")
  @put
  @extension("x-minimum-role", "admin")
  op updatePhenomenon(
    @path phenomenonId: PhenomenonId,
    @body body: PhenomenonChange,
  ):
    | Phenomenon
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError
    | ConflictError;

  @doc("""
    Publishes, archives or republishes a phenomenon. A draft can be published, a
    published phenomenon archived, and an archived one published again; nothing goes
    back to draft. Errors:
    
    - 400 `incomplete_weighting_function`: publishing a function with a blank.
    - 409 `invalid_status_transition`: any other change of status.
    - 409 `phenomenon_revision_conflict`: `baseRevision` is no longer the latest revision.
    """)
  @summary("Change a phenomenon's status.")
  @route("/{phenomenonId}/status")
  @put
  @extension("x-minimum-role", "admin")
  op changePhenomenonStatus(
    @path phenomenonId: PhenomenonId,
    @body body: PhenomenonStatusChange,
  ):
    | Phenomenon
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError
    | ConflictError;

  @doc("""
    Deletes a draft. A phenomenon that was ever published may have reports, so it can only
    be archived: deleting one answers 409 with the code `phenomenon_not_draft`.
    """)
  @summary("Delete a draft phenomenon.")
  @route("/{phenomenonId}")
  @delete
  @extension("x-minimum-role", "admin")
  op deletePhenomenon(@path phenomenonId: PhenomenonId):
    | {
        @statusCode _: 204;
      }
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError
    | ConflictError;
}

// Incident reports
//
// Any signed-in account files reports about a published phenomenon. A report is accepted
// as filed and never changes. It records a region and a date, never a point or a time, and
// its author is returned to nobody but that author. See ../docs/adr/0013-incident-reports.md.

@doc("An incident report's identifier, assigned by the API. Never changes and is never reused.")
@minValue(1)
scalar IncidentReportId extends int32;

@doc("""
  The value a report gives one characteristic, by the characteristic's type: a number for
  `number`, `true` or `false` for `boolean`, the key of an active option for `category`,
  the text itself for `text`, and a `YYYY-MM-DD` date for `date`.
  """)
union CharacteristicValue {
  number: float64,
  boolean: boolean,
  string: string,
}

@doc("What a person states when filing an incident report.")
model IncidentReportDraft {
  @doc("The region of the current partition where the incident took place.")
  regionId: RegionId;

  @doc("The day the incident took place, in the metropolitan area. Not later than today.")
  occurredOn: plainDate;

  @doc("""
    What happened, in the reporter's words. Optional: free text is where a reporter is most
    likely to identify someone, so it is never asked for (ADR 0013). Left out when empty.
    """)
  @minLength(1)
  @maxLength(2000)
  description?: string;

  @doc("""
    One value per characteristic, keyed by the characteristic's key. Every required active
    characteristic needs one; an optional one is left out when it has no value.
    """)
  values: Record<CharacteristicValue>;
}

@doc("An incident report as filed. It never carries its author.")
model IncidentReport {
  id: IncidentReportId;
  phenomenonId: PhenomenonId;

  @doc("The phenomenon's name, so that a report can be shown without reading its phenomenon.")
  phenomenonName: string;

  ...IncidentReportDraft;

  @doc("The region's name in its latest state, which may belong to an earlier partition version.")
  regionName: string;

  @doc("When the report was filed.")
  createdAt: utcDateTime;
}

@doc("One page of incident reports, most recently filed first.")
model IncidentReportPage {
  items: IncidentReport[];

  @doc("Pass as `cursor` to get the next page. Absent on the last page.")
  nextCursor?: string;
}

@doc("""
  Filing and reading incident reports.
  
  A report is refused with 400 and its own `code` when it breaks a rule. `details.path` is a
  JSON Pointer into the request body to the value at fault, such as `/values/victims`:
  
  - `region_not_found`: the region is not part of the current partition.
  - `occurred_in_future`: `occurredOn` is later than today in the metropolitan area.
  - `missing_characteristic_value`: a required active characteristic has no value.
  - `unknown_characteristic`: no characteristic of the phenomenon has that key.
  - `characteristic_retired`: the characteristic is retired and takes no new values.
  - `invalid_characteristic_value`: the value's type does not match the characteristic, a
    whole number has decimals, a text is empty, or a date is not a valid `YYYY-MM-DD`.
  - `number_out_of_range`: a number is below the minimum or above the maximum.
  - `text_too_long`: a text is longer than the characteristic's maximum length.
  - `unknown_category_option`: no option of the category has that key.
  - `category_option_retired`: the option is retired and takes no new reports.
  """)
namespace IncidentReports {
  @doc("""
    Files an incident report about a phenomenon. Only a published phenomenon accepts them:
    for a phenomenon the caller cannot see the API answers 404 with the code
    `phenomenon_not_found`, and for a draft or an archived one an admin can see it answers
    409 with the code `phenomenon_not_accepting_reports`.
    """)
  @summary("File an incident report.")
  @route("/phenomena/{phenomenonId}/incident-reports")
  @post
  @extension("x-minimum-role", "user")
  op fileIncidentReport(
    @path phenomenonId: PhenomenonId,
    @body body: IncidentReportDraft,
  ):
    | {
        @statusCode _: 201;
        @body report: IncidentReport;
      }
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError
    | ConflictError;

  @doc("""
    Lists the reports of a phenomenon, most recently filed first, without their authors.
    Every filter is optional, and the ones given combine. A cursor is only valid with the
    filters of the request that returned it.
    
    When both dates are given, `occurredFrom` must be earlier than `occurredBefore`, or the
    API answers 400 with the code `invalid_date_range`. An unknown phenomenon answers 404
    with the code `phenomenon_not_found`.
    """)
  @summary("List the incident reports of a phenomenon.")
  @route("/phenomena/{phenomenonId}/incident-reports")
  @get
  @extension("x-minimum-role", "analyst")
  op listPhenomenonIncidentReports(
    @path phenomenonId: PhenomenonId,

    @doc("How many reports to return. Defaults to 50.")
    @query
    @minValue(1)
    @maxValue(200)
    limit?: int32,

    @doc("The `nextCursor` of the previous page.")
    @query
    cursor?: string,

    @doc("Only reports filed in this region.")
    @query
    regionId?: RegionId,

    @doc("Only incidents that took place on or after this day.")
    @query
    occurredFrom?: plainDate,

    @doc("Only incidents that took place before this day. Together with `occurredFrom`, a half-open range.")
    @query
    occurredBefore?: plainDate,
  ):
    | IncidentReportPage
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError;

  @doc("""
    Lists the reports the caller filed, most recently filed first. A cursor is only valid
    with the filters of the request that returned it.
    """)
  @summary("List my incident reports.")
  @route("/accounts/me/incident-reports")
  @get
  @extension("x-minimum-role", "user")
  op listMyIncidentReports(
    @doc("How many reports to return. Defaults to 50.")
    @query
    @minValue(1)
    @maxValue(200)
    limit?: int32,

    @doc("The `nextCursor` of the previous page.")
    @query
    cursor?: string,

    @doc("Only reports about this phenomenon.")
    @query
    phenomenonId?: PhenomenonId,
  ): IncidentReportPage | BadRequestError | UnauthorizedError | ForbiddenError;

  @doc("""
    Removes a report, for abuse or to erase personal data. It is the only way a report stops
    counting. An unknown report answers 404 with the code `incident_report_not_found`.
    """)
  @summary("Remove an incident report.")
  @route("/incident-reports/{incidentReportId}")
  @delete
  @extension("x-minimum-role", "admin")
  op removeIncidentReport(@path incidentReportId: IncidentReportId):
    | {
        @statusCode _: 204;
      }
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError;
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
    Changes the caller's own first name, last name and email. The change is written to the
    identity provider first and then to the account, so it shows at once and is still there
    after signing out and in. Nothing changes when the request fails.
    
    A value outside the limits of the request body answers 400 `invalid_request`, as
    everywhere else. A value inside them that the identity provider refuses answers 400
    `invalid_account_details`; an email that another account already has answers 409
    `email_already_in_use`; an identity provider that could not be reached, or that failed
    in another way, answers 503 `account_update_unavailable`.
    """)
  @summary("Edit the caller's own details.")
  @route("/me/profile")
  @put
  @extension("x-minimum-role", "user")
  op updateMyProfile(@body body: AccountProfile):
    | Account
    | BadRequestError
    | UnauthorizedError
    | ConflictError
    | ServiceUnavailableError;

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

  @doc("""
    Changes another account's first name, last name and email. Only admins may; the person's
    own details are edited with `updateMyProfile`. It writes and fails the way
    `updateMyProfile` does: 400 `invalid_account_details`, 409 `email_already_in_use` and
    503 `account_update_unavailable`, and nothing changes in any of them. The person sees the
    new details the next time they sign in.
    """)
  @summary("Edit an account's details.")
  @route("/{accountId}/profile")
  @put
  @extension("x-minimum-role", "admin")
  op updateAccountProfile(
    @path
    @format("uuid")
    accountId: string,

    @body body: AccountProfile,
  ):
    | Account
    | BadRequestError
    | UnauthorizedError
    | ForbiddenError
    | NotFoundError
    | ConflictError
    | ServiceUnavailableError;
}
