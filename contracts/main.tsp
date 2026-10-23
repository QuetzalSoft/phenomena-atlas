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
  version: "0.0.0",
  summary: "The API behind Phenomena Atlas, consumed by the web and mobile clients.",
})
@doc("""
  Every Phenomena Atlas client reaches domain data through this API. No client talks
  to the database directly.

  Version 0.0.0 means the contract has not been designed yet. The first real version
  depends on the domain glossary in ../docs/domain.md being filled in.
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
