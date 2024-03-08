FROM rust:1-alpine AS chef
RUN rustup toolchain install nightly
RUN rustup default nightly
# Use apk for package management in Alpine
RUN apk add --no-cache build-base
RUN cargo install cargo-chef

FROM chef AS planner
WORKDIR /app
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
WORKDIR /app
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook \
    --release \
    --features parallel \
    --package sandstorm-cli \
    --recipe-path recipe.json
# Build application
COPY . .
RUN cargo build \
    --release \
    --features parallel \
    --package sandstorm-cli

# We do not need the Rust toolchain to run the binary!
FROM python:3.9.18-alpine AS runtime
COPY --from=builder /app/target/release/sandstorm-cli /bin/sandstorm-cli
COPY prover-entrypoint.sh /bin/prover-entrypoint.sh
RUN apk add --no-cache build-base gmp-dev
RUN pip install --upgrade pip
RUN pip install cairo-lang==0.12.3

WORKDIR /tmp/workspace
COPY program.cairo .
RUN cairo-compile \
    --proof_mode \
    --output program_compiled.json \
    program.cairo
ENTRYPOINT [ "prover-entrypoint.sh" ]
