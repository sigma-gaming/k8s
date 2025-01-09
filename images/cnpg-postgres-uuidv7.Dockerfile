FROM ghcr.io/cloudnative-pg/postgresql:17.2-28 AS base

FROM ghcr.io/fboulnois/pg_uuidv7:1.6.0 AS pg_uuidv7

FROM base AS final

COPY --from=pg_uuidv7 /usr/lib/postgresql/17/lib/pg_uuidv7.so /usr/lib/postgresql/17/lib
COPY --from=pg_uuidv7 /usr/share/postgresql/17/extension/pg_uuidv7.control /usr/share/postgresql/17/extension
COPY --from=pg_uuidv7 /usr/share/postgresql/17/extension/pg_uuidv7--1.6.sql /usr/share/postgresql/17/extension
