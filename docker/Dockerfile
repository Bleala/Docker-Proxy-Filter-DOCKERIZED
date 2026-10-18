# Set build image
FROM rust:1.99.1-trixie AS builder

# Set Workdir
WORKDIR /app

# Initiate Cargo
RUN cargo init

# Copy Cargo files
COPY Cargo.lock Cargo.toml ./

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
    cp "target/${ARCH}/release/docker-proxy-filter" build/docker-proxy-filter

# Set base image
FROM debian:13.7-slim AS docker-proxy-filter

ENV RUST_LOG=info,docker_proxy_filter=debug

# Need SSL for web server
RUN apt-get update && \
        # Install OpenSSL
        apt-get install --yes --no-install-recommends openssl && \
        # Clean up
        apt-get clean && \
        # Delete apt lists
        rm -rf /var/lib/apt/lists/*

# Copy built app
COPY --from=builder /app/build/docker-proxy-filter /usr/local/bin/docker-proxy-filter

# Entrypoint
ENTRYPOINT ["docker-proxy-filter"]