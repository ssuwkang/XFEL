#1/bin/bash
###################################################################################################
# Run partialator for each stream file in a directory separately
# Usage: ./run_partialator_batch.sh <input_stream_dir> <output_hkl_dir> <laue_group> <num_cores>
###################################################################################################

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <input_stream_dir> <output_hkl_dir> <laue_group> <num_cores>"
    exit 1
fi

# Input variables
INPUT_DIR="$1"
OUTPUT_DIR="$2"
LAUE_GROUP="$3"
NUM_CORES="$4"

# Create output and log directories if they don't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p logs

# Loop through each stream file and run partialator
for stream_file in "$INPUT_DIR"/*.stream; do
    filename=$(basename "$stream_file" .stream)
    output_file="${OUTPUT_DIR}/${filename}.hkl"
    log_file="logs/${filename}.log"

    echo "[INFO] Running partialator on: $stream_file -> $output_file"
    
    # Run partialator in background, redirect stdout and stderr to log file
    partialator -i "$stream_file" -o "$output_file" \
        -y "$LAUE_GROUP" \
        --iterations=1 \
        --model=unity \
        --push-res=0.5 \
        -j "$NUM_CORES" > "$log_file" 2>&1 &

done

# Wait for all background jobs to finish
wait
echo "[INFO] All jobs completed."
