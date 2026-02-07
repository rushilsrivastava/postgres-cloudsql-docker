ARG PG_VERSION=18
ARG POSTGIS_VERSION=3.5
ARG HLL_VERSION=2.18

# Build stage for HLL
FROM postgres:${PG_VERSION} AS builder

# Re-declare build args after FROM
ARG PG_VERSION
ARG POSTGIS_VERSION
ARG HLL_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y \
    postgresql-server-dev-${PG_VERSION%%.*} \
    make \
    gcc \
    g++ \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN wget https://github.com/citusdata/postgresql-hll/archive/refs/tags/v${HLL_VERSION}.tar.gz -O postgresql-hll.tar.gz && \
    mkdir postgresql-hll && \
    tar xf ./postgresql-hll.tar.gz -C postgresql-hll --strip-components 1
WORKDIR /src/postgresql-hll
RUN make && make install

# Final stage
FROM postgres:${PG_VERSION}

# Add PostgreSQL repository for extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(. /etc/os-release && echo $VERSION_CODENAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && PG_MAJOR="${PG_VERSION%%.*}" \
    && BASE_PACKAGES="postgresql-${PG_MAJOR}-cron postgresql-contrib postgresql-${PG_MAJOR}-postgis-3 postgresql-${PG_MAJOR}-postgis-3-scripts" \
    && OPTIONAL_PACKAGES="\
        postgresql-${PG_MAJOR}-pgaudit \
        postgresql-${PG_MAJOR}-pgvector \
        postgresql-${PG_MAJOR}-pg-partman \
        postgresql-${PG_MAJOR}-repack \
        postgresql-${PG_MAJOR}-pglogical \
        postgresql-${PG_MAJOR}-pgrouting \
        postgresql-${PG_MAJOR}-hypopg \
        postgresql-${PG_MAJOR}-pg-background \
        postgresql-${PG_MAJOR}-plv8 \
        postgresql-${PG_MAJOR}-pghintplan \
        postgresql-${PG_MAJOR}-pg-hint-plan \
        postgresql-${PG_MAJOR}-pg-squeeze \
        postgresql-${PG_MAJOR}-pg-wait-sampling \
        postgresql-${PG_MAJOR}-pg-bigm \
        postgresql-${PG_MAJOR}-pg-roaringbitmap \
        postgresql-${PG_MAJOR}-pg-ivm \
        postgresql-${PG_MAJOR}-pgtt \
        postgresql-${PG_MAJOR}-pgtap \
        postgresql-${PG_MAJOR}-pg-similarity \
        postgresql-${PG_MAJOR}-pg-proctab \
        postgresql-${PG_MAJOR}-pg-fincore \
        postgresql-${PG_MAJOR}-pgfincore \
        postgresql-${PG_MAJOR}-plpgsql-check \
        postgresql-${PG_MAJOR}-tds-fdw \
        postgresql-${PG_MAJOR}-oracle-fdw \
        postgresql-${PG_MAJOR}-plproxy" \
    && INSTALL_PACKAGES="${BASE_PACKAGES}" \
    && for pkg in ${OPTIONAL_PACKAGES}; do \
        if apt-cache show "${pkg}" >/dev/null 2>&1; then \
            INSTALL_PACKAGES="${INSTALL_PACKAGES} ${pkg}"; \
        else \
            echo "Skipping unavailable package: ${pkg}"; \
        fi; \
    done \
    && apt-get install -y --no-install-recommends ${INSTALL_PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy HLL extension files from builder
COPY --from=builder /usr/share/postgresql/${PG_VERSION%%.*}/extension/hll*.sql /usr/share/postgresql/${PG_VERSION%%.*}/extension/
COPY --from=builder /usr/share/postgresql/${PG_VERSION%%.*}/extension/hll.control /usr/share/postgresql/${PG_VERSION%%.*}/extension/
COPY --from=builder /usr/lib/postgresql/${PG_VERSION%%.*}/lib/hll.so /usr/lib/postgresql/${PG_VERSION%%.*}/lib/

# Configure shared preload libraries and pg_cron defaults
RUN { \
    echo "shared_preload_libraries = 'pg_cron,hll,pg_stat_statements'"; \
    echo "cron.database_name = 'postgres'"; \
    echo "cron.use_background_workers = on"; \
    echo "max_worker_processes = 20"; \
    echo "cron.host = ''"; \
  } >> /usr/share/postgresql/postgresql.conf.sample

# Set default cron database
ENV POSTGRES_CRON_DB=postgres

# Copy initialization scripts
COPY init-pg-cron.sh /docker-entrypoint-initdb.d/00-init-pg-cron.sh

# Make the scripts executable
RUN chmod +x /docker-entrypoint-initdb.d/00-init-pg-cron.sh

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD pg_isready -U postgres || exit 1