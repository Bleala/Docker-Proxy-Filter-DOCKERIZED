# Global variables
ARG DEBIAN_VERSION="13.7-slim" \
    RUST_VERSION="1.99.1-trixie" \
    IMAGE_VERSION="1.0.0"

# -----------------------------------------------------------------------------------------------

# Set build image
FROM rust:${RUST_VERSION} AS builder

# Build arguments
ARG RUST_VERSION 

# Set shell options
SHELL ["/bin/bash", "-e", "-u", "-x", "-o", "pipefail", "-c"]

# Set Workdir
WORKDIR /app

# Initiate Cargo
RUN cargo init

# Copy Cargo files
COPY cargo/ ./

# Build dummy project with dependencies to get them compiled and cached
RUN cargo build --release --target "$(rustc --print host-tuple)"

# Copy full app code
COPY src/ src/

# Updated modified timestamp so build runs again
RUN touch src/main.rs

# build full app to host arch and copy to generic location
RUN ARCH="$(rustc --print host-tuple)"; \
    export ARCH && \
    cargo build --release --target "${ARCH}" && \
    mkdir build && \
    cp "target/${ARCH}/release/docker-proxy-filter" build/docker-proxy-filter && \
    # Strip binary
    strip /app/build/docker-proxy-filter

# Set base image
FROM debian:${DEBIAN_VERSION} AS docker-proxy-filter

# Build arguments
ARG DEBIAN_VERSION \
        IMAGE_VERSION

# Set environment variables
ENV RUST_LOG=info\
        docker_proxy_filter=debug

# Need SSL for web server
RUN apt-get update && \
        # Install OpenSSL
        apt-get install --yes --no-install-recommends \
            openssl && \
        # Clean up
        apt-get clean && \
        # Delete apt lists
        rm -rf /var/lib/apt/lists/*

# Copy built app
COPY --from=builder /app/build/docker-proxy-filter /usr/local/bin/docker-proxy-filter

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

# Entrypoint
ENTRYPOINT ["docker-proxy-filter"]