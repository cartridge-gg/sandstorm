#!/usr/bin/env sh

# Read from stdin
cat > program_proof.bin && \

sandstorm-cli \
    --air-public-input program_public_input.json \
    --program program_compiled.json \
    verify \
    --proof program_proof.bin
