#!/bin/bash
###################################################################################################
# Run or submit partialator for each stream file in a directory
# Usage:
# input_dir: contains several stream files
# output_dir: script will make.
# --local: batch mode
# --condor: 
#   ./run_partialator_batch.sh <input_dir> <output_dir> <laue_group> <cores> [--local|--condor]
###################################################################################################

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <input_dir> <output_dir> <laue_group> <cores> [--local|--condor]"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
LAUE_GROUP="$3"
NUM_CORES="$4"
MODE="${5:---condor}"  # default to --condor

LOG_DIR="logs_partialator"
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

for stream_file in "$INPUT_DIR"/*.stream; do
    filename=$(basename "$stream_file" .stream)
    output_file="${OUTPUT_DIR}/${filename}.hkl"
    log_prefix="${LOG_DIR}/${filename}"

    if [[ "$MODE" == "--condor" ]]; then
        cat <<EOF | condor_submit
universe        = vanilla
should_transfer_files = IF_NEEDED
executable      = /bin/bash
arguments       = -c \"partialator -i $stream_file -o $output_file -y $LAUE_GROUP --iterations=1 --model=unity --push-res=0.5 -j $NUM_CORES\"
output          = ${log_prefix}.out
error           = ${log_prefix}.err
log             = ${log_prefix}.log
request_cpus    = $NUM_CORES
request_memory  = 4 GB
queue
EOF
        echo "[INFO] Submitted partialator job for $stream_file"

    elif [[ "$MODE" == "--local" ]]; then
        echo "[INFO] Running partialator locally on: $stream_file"
        partialator -i "$stream_file" -o "$output_file" \
            -y "$LAUE_GROUP" --iterations=1 --model=unity \
            --push-res=0.5 -j "$NUM_CORES" > "${log_prefix}.out" 2> "${log_prefix}.err"
    else
        echo "[ERROR] Unknown mode: $MODE"
        exit 1
    fi
done
