# Global variables
ARG ALPINE_VERSION="3.24.2" \
    RUST_VERSION="1.99-alpine3.24" \
    IMAGE_VERSION="1.0.0"

# -----------------------------------------------------------------------------------------------

# Set build image
FROM rust:${RUST_VERSION} AS builder

# Build arguments
ARG RUST_VERSION

# Set shell options
SHELL ["/bin/ash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

# Set Workdir
WORKDIR /app

# Initiate Cargo
RUN cargo init

# Copy Cargo files
COPY build/Cargo.* ./

# Build dummy project with dependencies to get them compiled and cached
RUN cargo build --release --locked --target "$(rustc --print host-tuple)"

# Copy full app code
COPY build/src/ src/

# Updated modified timestamp so build runs again
RUN touch src/main.rs

# build full app to host arch and copy to generic location
RUN ARCH="$(rustc --print host-tuple)"; \
    cargo build --release --locked --target "${ARCH}" && \
    mkdir build && \
    cp "target/${ARCH}/release/docker-proxy-filter" build/docker-proxy-filter

# -----------------------------------------------------------------------------------------------

# Set base image
FROM alpine:${ALPINE_VERSION} AS docker-proxy-filter

# Build arguments
ARG ALPINE_VERSION \
        IMAGE_VERSION \
        PROXY_USER="docker-proxy-filter" \
        PROXY_USER_UID="1000" \
        PROXY_USER_GID="1000"

# Set shell options
SHELL ["/bin/ash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

# Set environment variables
ENV PORT="2375" \
        RUST_LOG="info" \
        TZ="Europe/Vienna"

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["/files/scripts/healthcheck.sh"]

# Install runtime dependencies
# RUN apt-get update && \
#         # Install OpenSSL
#         apt-get install --yes --no-install-recommends \
#             openssl \
#             tini \
#             tzdata && \
#         # Clean up
#         apt-get clean && \
#         # Delete apt lists
#         rm -rf /var/lib/apt/lists/*

# Install runtime dependencies
        # Fix CVE-2026-85091 until new alpine Image is released
RUN apk upgrade --no-cache && \
        apk add --no-cache \
            tini \
            tzdata

# Add Docker Proxy Filter user and group
# RUN groupadd --gid "${PROXY_USER_GID}" "${PROXY_USER}" && \
#         useradd --uid "${PROXY_USER_UID}" --gid "${PROXY_USER_GID}" \
#             --no-create-home --shell /usr/sbin/nologin "${PROXY_USER}"

# Add Docker Proxy Filter user and group
RUN addgroup -g "${PROXY_USER_GID}" -S "${PROXY_USER}" && \
    adduser -u "${PROXY_USER_UID}" -S -D -H -G "${PROXY_USER}" "${PROXY_USER}"

# Copy Files
# No chown -> root owns files
COPY --chmod=755 files /files

# Copy built app
COPY --chmod=755 --from=builder /app/build/docker-proxy-filter /usr/local/bin/docker-proxy-filter

# Set build date argument here, because caching would break otherwise
# It is set during the build process in the reusable workflow
ARG BUILD_DATE

# Set labels
LABEL org.opencontainers.image.authors="Bleala" \
      org.opencontainers.image.vendor="Bleala" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="Docker-Proxy-Filter-DOCKERIZED" \
      org.opencontainers.image.description="Docker Proxy Filter - Filter the contents of Docker API responses. DOCKERIZED!" \
      org.opencontainers.image.documentation="https://github.com/FoxxMD/docker-proxy-filter/blob/main/README.md" \
      org.opencontainers.image.url="https://hub.docker.com/r/bleala/docker-proxy-filter" \
      org.opencontainers.image.source="https://github.com/Bleala/Docker-Proxy-Filter-DOCKERIZED"

# Socket
EXPOSE 2375/tcp

# Switch to user
USER "${PROXY_USER}"

# Entrypoint
# ENTRYPOINT ["/usr/bin/tini", "--", "docker-proxy-filter"]
ENTRYPOINT ["/sbin/tini", "--", "docker-proxy-filter"]