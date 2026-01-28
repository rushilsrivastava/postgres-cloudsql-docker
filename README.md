# postgres-cloudsql-docker

This Docker image is based on [PostgreSQL](https://hub.docker.com/_/postgres), [PostGIS](https://postgis.net/), [pg_cron](https://github.com/citusdata/pg_cron), and [postgres_hll](https://github.com/citusdata/postgresql-hll). Other extensions may be added in the future with the goal of mirroring the [GCP CloudSQL extensions](https://cloud.google.com/sql/docs/postgres/extensions).

### NOTE: Not all extensions have been added yet. See an extension missing? [Open an issue](https://github.com/rushilsrivastava/postgres-cloudsql-docker/issues/new) or submit a pull request.

## Image tags

Images are tagged by PostgreSQL major and minor versions:

- `rushilsrivastava/postgres-cloudsql:15`
- `rushilsrivastava/postgres-cloudsql:15.2`

Supported extensions:

This image installs PostGIS, pg_cron, postgres_hll, plus `postgresql-contrib`
and a best-effort set of Cloud SQL extensions when they are available in the
PostgreSQL APT repository for the selected major version. Some extensions are
only available for specific PostgreSQL versions or require extra configuration
(`shared_preload_libraries`, database flags, etc.), so availability can vary.

Core:

- postgis (includes postgis_raster, postgis_sfcgal, postgis_tiger_geocoder,
  postgis_topology, address_standardizer, address_standardizer_data_us)
- pg_cron
- postgres_hll
- pgrouting (when available)

Cloud SQL extension targets (from the official list):
https://docs.cloud.google.com/sql/docs/postgres/extensions

- amcheck
- auto_explain
- autoinc
- bloom
- btree_gin
- btree_gist
- chkpass
- citext
- cube
- dblink
- decoderbufs
- dict_int
- earthdistance
- fuzzystrmatch
- google_ml_integration
- hstore
- insert_username
- intagg
- intarray
- ip4r
- isn
- lo
- ltree
- moddatetime
- oracle_fdw
- orafce
- pageinspect
- pgaudit
- pg_background
- pg_bigm
- pg_buffercache
- pg_fincore
- pg_freespacemap
- pg_hint_plan
- pg_ivm
- pg_partman
- pg_prewarm
- pg_proctab
- pg_repack
- pg_roaringbitmap
- pgrowlocks
- pg_similarity
- pg_squeeze
- pg_stat_statements
- pg_trgm
- pgtap
- pgtt
- pgvector
- pg_visibility
- pg_wait_sampling
- pglogical
- plproxy
- plv8
- plpgsql
- plpgsql_check
- prefix
- postgresql_anonymizer
- postgres_fdw
- pgcrypto
- pgstattuple
- refint
- rdkit
- sslinfo
- tablefunc
- tcn
- tds_fdw
- temporal_tables
- tsm_system_rows
- tsm_system_time
- unaccent
- uuid-ossp

Additional extensions (not on CloudSQL list, but available on CloudSQL instances):

- hypopg

## Cloud SQL extension versions by PostgreSQL major

Version data is sourced from the Cloud SQL documentation:
https://docs.cloud.google.com/sql/docs/postgres/extensions

If the docs do not specify a version for an extension, it is marked as `not specified`.
For PostGIS, Cloud SQL lists 3.5.2 for PG14–PG17. The Docker base image uses the
`postgis/postgis:<pg>-3.5` tag, which tracks the latest 3.5.x patch release.

| Extension | PG14 | PG15 | PG16 | PG17 |
| --- | --- | --- | --- | --- |
| PostGIS | 3.5.2 | 3.5.2 | 3.5.2 | 3.5.2 |
| amcheck | not specified | not specified | not specified | not specified |
| auto_explain | not specified | not specified | not specified | not specified |
| autoinc | 1.0 | 1.0 | 1.0 | 1.0 |
| bloom | 1.0 | 1.0 | 1.0 | 1.0 |
| btree_gin | 1.3 | 1.3 | 1.3 | 1.3 |
| btree_gist | 1.6 | 1.7 | 1.7 | 1.7 |
| chkpass | not supported | not supported | not supported | not supported |
| citext | 1.6 | 1.6 | 1.6 | 1.6 |
| cube | 1.5 | 1.5 | 1.5 | 1.5 |
| dblink | 1.2 | 1.2 | 1.2 | 1.2 |
| decoderbufs | not specified | not specified | not specified | not specified |
| dict_int | 1.0 | 1.0 | 1.0 | 1.0 |
| earthdistance | 1.1 | 1.1 | 1.1 | 1.2 |
| fuzzystrmatch | 1.1 | 1.1 | 1.2 | 1.2 |
| google_ml_integration | 1.4.3 | 1.4.3 | 1.4.3 | 1.4.3 |
| hstore | 1.8 | 1.8 | 1.8 | 1.8 |
| insert_username | 1.0 | 1.0 | 1.0 | 1.0 |
| intagg | 1.1 | 1.1 | 1.1 | 1.1 |
| intarray | 1.5 | 1.5 | 1.5 | 1.5 |
| ip4r | 2.4.2 | 2.4.2 | 2.4.2 | 2.4.2 |
| isn | 1.2 | 1.2 | 1.2 | 1.2 |
| lo | 1.1 | 1.1 | 1.1 | 1.1 |
| ltree | 1.2 | 1.2 | 1.2 | 1.3 |
| moddatetime | 1.0 | 1.0 | 1.0 | 1.0 |
| oracle_fdw | 1.2 | 1.2 | 1.2 | 1.2 |
| orafce | 4.13 | 4.13 | 4.13 | 4.13 |
| pageinspect | 1.8 | 1.11 | 1.12 | 1.12 |
| pgaudit | 1.6.1 | 1.7.0 | 16.0 | 17.0 |
| pg_background | 1.3 | 1.3 | 1.3 | 1.3 |
| pg_bigm | not specified | not specified | not specified | not specified |
| pg_buffercache | 1.3 | 1.3 | 1.4 | 1.5 |
| pg_cron | 1.6.4 | 1.6.4 | 1.6.4 | 1.6.4 |
| pgcrypto | 1.3 | 1.3 | 1.3 | 1.3 |
| pgfincore | 1.3.1 | 1.3.1 | 1.3.1 | 1.3.1 |
| pg_freespacemap | 1.2 | 1.2 | 1.2 | 1.2 |
| pg_hint_plan | not specified | not specified | not specified | not specified |
| pg_ivm | 1.9 | 1.9 | 1.9 | 1.9 |
| pg_partman | 5.2.4 | 5.2.4 | 5.2.4 | 5.2.4 |
| pg_prewarm | 1.2 | 1.2 | 1.2 | 1.2 |
| pg_proctab | not specified | not specified | not specified | not specified |
| pg_repack | 1.5.0 | 1.5.0 | 1.5.0 | 1.5.0 |
| pg_roaringbitmap | 0.5 | 0.5 | 0.5 | 0.5 |
| pgrowlocks | 1.2 | 1.2 | 1.2 | 1.2 |
| pg_similarity | 1.0 | 1.0 | 1.0 | 1.0 |
| pg_squeeze | 1.8 | 1.8 | 1.8 | 1.8 |
| pg_stat_statements | 1.9 | 1.10 | 1.10 | 1.11 |
| pg_trgm | 1.6 | 1.6 | 1.6 | 1.6 |
| pgtap | 1.3.0 | 1.3.0 | 1.3.0 | 1.3.0 |
| pgtt | 4.0 | 4.0 | 4.0 | 4.0 |
| pgvector | 0.8.0 | 0.8.0 | 0.8.0 | 0.8.0 |
| pg_visibility | 1.2 | 1.2 | 1.2 | 1.2 |
| pg_wait_sampling | 1.1.5 | 1.1.5 | 1.1.5 | 1.1.5 |
| pglogical | 2.4.5 | 2.4.5 | 2.4.5 | 2.4.5 |
| plproxy | 2.11.0 | 2.11.0 | 2.11.0 | 2.11.0 |
| plv8 | 3.2.2 | 3.2.2 | 3.2.2 | 3.2.2 |
| plpgsql | 1.0 | 1.0 | 1.0 | 1.0 |
| plpgsql_check | 2.8 | 2.8 | 2.8 | 2.8 |
| prefix | 1.2.0 | 1.2.0 | 1.2.0 | 1.2.0 |
| postgres_fdw | 1.1 | 1.1 | 1.1 | 1.1 |
| postgresql_anonymizer | 1.0.0 | 1.0.0 | 1.0.0 | 1.0.0 |
| postgres_hll | 2.18 | 2.18 | 2.18 | 2.18 |
| rdkit | 4.6.1 | 4.6.1 | 4.6.1 | 4.6.1 |
| refint | 1.0 | 1.0 | 1.0 | 1.0 |
| sslinfo | 1.2 | 1.2 | 1.2 | 1.2 |
| tablefunc | 1.0 | 1.0 | 1.0 | 1.0 |
| tcn | 1.0 | 1.0 | 1.0 | 1.0 |
| tds_fdw | 2.0.4 | 2.0.4 | 2.0.4 | 2.0.4 |
| temporal_tables | 1.2.2 | 1.2.2 | 1.2.2 | 1.2.2 |
| tsm_system_rows | 1.0 | 1.0 | 1.0 | 1.0 |
| tsm_system_time | 1.0 | 1.0 | 1.0 | 1.0 |
| unaccent | 1.1 | 1.1 | 1.1 | 1.1 |
| uuid-ossp | 1.1 | 1.1 | 1.1 | 1.1 |

Additional extensions (not in Cloud SQL list):

| Extension | PG14 | PG15 | PG16 | PG17 |
| --- | --- | --- | --- | --- |
| hypopg | not specified | not specified | not specified | not specified |
