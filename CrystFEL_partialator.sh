#!/bin/bash
###################################################################################################
# CrystFEL_partialator.sh
# Runs partialator sequentially on stream files listed in stream.lst (e.g., ./aaa.stream)
# Usage: ./CrystFEL_partialator.sh <symmetry> <num_cores>
# Output files go to output_hkl/
# Logs are stored in logs_partialator/
# updated: Apr 11 2025
###################################################################################################

f [[ $# -ne 2 ]]; then
    echo "Usage: $0 <symmetry> <num_cores>"
    exit 1
fi

SYMMETRY="$1"
NUM_CORES="$2"


INPUT_LIST="stream.lst"
OUTPUT_DIR="output_hkl"
LOG_DIR="logs_partialator"

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

while IFS= read -r STREAM_PATH; do
    [[ -z "$STREAM_PATH" ]] && continue

    STREAM_PATH=$(echo "$STREAM_PATH" | xargs)

    if [[ ! -f "$STREAM_PATH" ]]; then
        echo "[ERROR] Stream file not found: '$STREAM_PATH'"
        continue
    fi

    BASENAME=$(basename "$STREAM_PATH" .stream)
    OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}.hkl"
    LOG_OUT="${LOG_DIR}/${BASENAME}.out"
    LOG_ERR="${LOG_DIR}/${BASENAME}.err"

    echo "[RUNNING] partialator on $STREAM_PATH"
    partialator -i "$STREAM_PATH" -o "$OUTPUT_FILE" \
        -y "$SYMMETRY" --iterations=1 --model=unity --push-res=0.5 -j "$NUM_CORES" \
        > "$LOG_OUT" 2> "$LOG_ERR"
done < "$INPUT_LIST"

echo "[DONE] All partialator jobs attempted."
