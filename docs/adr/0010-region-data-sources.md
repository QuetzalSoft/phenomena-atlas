# 0010 - Region data comes from INEGI and IMEPLAN, downloaded at load time

- Status: accepted
- Date: 2026-11-11

## Context

The maps paint the Guadalajara metropolitan area by region (#33). The area is the four
municipalities of Guadalajara (INEGI key 14039), Zapopan (14120), San Pedro Tlaquepaque
(14098) and Tonalá (14101). The first set of regions is the colonias (neighbourhoods) of
those municipalities, each with its population. That needs three kinds of data: the
municipal boundaries, the colonia polygons, and a population per colonia.

What was found, checked on 2026-11-11:

**Municipal boundaries.**

- INEGI's Marco Geoestadístico, census 2020 edition, has them as layer `14mun` in the
  Jalisco file. It is a shapefile in Mexico ITRF2008 LCC (EPSG:6372), published under
  INEGI's "Términos de libre uso", which allows any use with attribution. Its keys are
  the ones the 2020 census uses, so boundaries and population line up.
- Later INEGI editions (2024, 2025) exist, but they no longer match the census blocks
  exactly.
- IIEG Jalisco publishes boundaries under CC-BY 4.0. They follow state decrees, are
  marked "preliminary" (2019), and disagree with INEGI's. IMEPLAN even publishes a layer
  of the conflicts.

**Colonia polygons.** No official, licensed layer exists.

- The best one found is IMEPLAN's SIGmetro layer `sigmetro:ColoniaJalisco`, served by
  WFS. It holds 1,479 colonias in the four municipalities: 289 in Guadalajara, 645 in
  Zapopan, 250 in Tlaquepaque and 295 in Tonalá. Its fields are `municipio`, `nombre`,
  `cp` and `superficie`, and it has no population.
- Its municipality codes are not INEGI's: 41, 120, 99 and 102 stand for 039, 120, 098
  and 101.
- Names repeat inside a municipality.
- In Zapopan and Tonalá it covers only the urban area.
- It states no license and no edition date.
- INE's electoral colonias, which IIEG uses for its own studies, could not be downloaded
  outside a browser and were not evaluated.
- Rejected:
  - OpenStreetMap, whose neighbourhoods are mostly points and very incomplete outside
    Guadalajara and Zapopan.
  - SEPOMEX, which has names and postal codes but no geometry.
  - Postal-code polygons, which are not colonias.

**Population.**

- INEGI's 2020 census publishes total population (`POBTOT`) per urban block. The Jalisco
  CSV is `ageb_mza_urbana_14_cpv2020_csv.zip`, and the matching block polygons are the
  layer `14m` in the same Marco Geoestadístico edition.
- IIEG builds its population-per-colonia figures by summing blocks into colonias.
- Population for the rural area outside blocks is only known per locality and per
  municipality.

## Decision

**Sources.**

| Data | Source |
|---|---|
| Municipal boundaries | INEGI Marco Geoestadístico, census 2020 edition, layer `14mun`: https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463807469/14_jalisco.zip |
| Colonias | IMEPLAN WFS, `https://geoserver.imeplan.mx/geoserver/sigmetro/wfs`, type `sigmetro:ColoniaJalisco`, filtered to the four municipalities and requested in EPSG:4326 |
| Population | INEGI Censo de Población y Vivienda 2020, results by urban block for Jalisco: https://www.inegi.org.mx/contenidos/programas/ccpv/2020/datosabiertos/ageb_manzana/ageb_mza_urbana_14_cpv2020_csv.zip, joined to layer `14m` of the same Marco Geoestadístico file |

**Downloaded at load time, never committed.** The API has a loader command that
downloads the three sources, builds the initial partition in PostGIS, and stores it as
version 1. No file derived from IMEPLAN is committed to any repository, because IMEPLAN
states no license and the repositories are public. The loader runs once per environment
and refuses to run when a partition already exists.

**How version 1 is built.**

1. Every geometry is made valid and transformed to EPSG:4326.
2. IMEPLAN's municipality codes are mapped to INEGI keys. Each colonia goes to the
   municipality it overlaps most and is clipped to it, so no region crosses a municipal
   boundary.
3. Where two colonias overlap, the smaller keeps the overlap. That is deterministic,
   and small colonias are the ones an overlap would distort most.
4. Area inside a municipality that no colonia covers is split into its separate pieces.
   A piece smaller than one hectare goes to the neighbouring region it shares the
   longest border with, because such pieces are slivers between colonias. The rest
   becomes one region per municipality named "<municipality> - outside colonias".
5. Each census block is assigned to the region that contains a point inside it
   (`ST_PointOnSurface`), and its `POBTOT` is added to that region. A suppressed value
   (`*`) counts as 0, and the loader reports how many there were.
6. Repeated colonia names are kept. A region is identified by its id, not its name
   (ADR 0011).

The loader prints the population per municipality next to the census totals, so a bad
join is visible.

## Consequences

Good:

- Boundaries and population come from the same census, so they agree with each other.
- Every source is public and can be fetched again, so any environment can rebuild
  version 1.
- No repository redistributes data whose license is unknown.
- Admins start from a partition close to how people name the city, not from a blank map.

Bad, and accepted deliberately:

- Loading depends on INEGI and IMEPLAN being online and keeping their URLs. IMEPLAN's
  layer has no stable edition, so two loads months apart may produce different version
  1s. Once loaded, a partition is the system's own data and no longer depends on them.
- IMEPLAN's license is unknown. Using it to seed internal data is a judgement call. If
  the product goes public with these regions, ask IMEPLAN for permission or replace the
  layer, for example with INE's colonias.
- INEGI's municipal boundaries differ from the state's decree boundaries in places.
  Anyone comparing against IIEG maps will see differences at the edges.
- The remainder regions in Zapopan and Tonalá are large, mostly rural, and their
  population is only what census blocks fall in them, which undercounts dispersed rural
  dwellings.
- Counting suppressed values as 0 undercounts slightly. The census suppresses only tiny
  blocks, so the effect is small.
- The census is from 2020. Population is editable by admins, so newer figures replace
  it region by region.
