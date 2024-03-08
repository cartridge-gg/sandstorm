#!/usr/bin/env sh

# Read from stdin
cat > program_input.json && \

cairo-run \
    --program program_compiled.json \
    --layout recursive \
    --program_input program_input.json \
    --air_public_input program_public_input.json \
    --air_private_input program_private_input.json \
    --trace_file program_trace.bin \
    --memory_file program_memory.bin \
    --proof_mode \
    2>&1 > /dev/null && \

sandstorm-cli \
    --air-public-input program_public_input.json \
    --program program_compiled.json \
    prove \
    --air-private-input program_private_input.json \
    --fri-folding-factor $FRI_FOLDING_FACTOR \
    --fri-max-remainder-coeffs $FRI_MAX_REMAINDER_COEFFS \
    --lde-blowup-factor $LDE_BLOWUP_FACTOR \
    --num-queries $NUM_QUERIES \
    --output program_proof.bin \
    --proof-of-work-bits $PROOF_OF_WORK_BITS \
    2>&1 > /dev/null && \

# Write to stdout
cat program_proof.bin
