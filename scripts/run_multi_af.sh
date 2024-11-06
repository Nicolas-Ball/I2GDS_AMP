#!/bin/bash
# run_multi_af.sh: template job script for running AlphaFold on Tinkercliffs A100 nodes
# Usage:
# 1. Supply input and output paths
# 2. Run with "sbatch run_multi_af.sh"
# 3. Update <your allocation account>,<your email>,<JOBNAME>, <path to fasta input file(s)>, and <path to desired output directory>
# 4. It may be necessary to increase the allowed time depending number and size of sequences.
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --gres=gpu:1
#SBATCH -p a100_normal_q
#SBATCH -t 48:00:00
#SBATCH -A <your allocation account>
#SBATCH --mail-type=all
#SBATCH --mail-user=<your email>@vt.edu
#SBATCH --job-name=JOBNAME
#SBATCH --export=NONE

# Load the AlphaFold module (Loads the module making the software accessible)
module load AlphaFold/2.0.0-fosscuda-2020b

# Path to databases (Sets the path to AlphaFold's required databases)
export ALPHAFOLD_DATA_DIR=/global/biodatabases/alphafold

# Path to single sequence fasta file (Defines the input fasta file containing the sequence)

FASTA_INPUT=<path to fasta input file(s)>

# Base output directory (Defines where the output files will be written)
OUTPUT_BASE_DIR=<path to desired output directory>

# Function to parse the FASTA file and extract each sequence with its identifier
parse_fasta() {
    awk '/^>/ {if (seqlen){print seqid,seqlen}; seqlen=0; seqid=$0; next;} {seqlen+=length($0)} END {if (seqlen) print seqid,seqlen}' $1
}

# Function to extract a single sequence from the FASTA file and write to a temporary file
extract_sequence_to_file() {
    awk -v id="$1" 'BEGIN {print_seq=0} 
    /^>/ {print_seq=0} 
    $0 ~ id {print_seq=1; print $0; next} 
    print_seq==1 {print $0}' $2 > $3
}

# Parse the FASTA file to get all sequence identifiers
sequences=$(parse_fasta $FASTA_INPUT)

# Loop through each sequence in the FASTA file
while IFS= read -r line; do
    seq_id=$(echo $line | awk '{print $1}' | sed 's/^>//' | tr -d '\r')
    echo "Processing sequence: $seq_id"

    # Define output directory for this sequence
    OUTPUT_DIR="${OUTPUT_BASE_DIR}/${seq_id}_output"
    mkdir -p $OUTPUT_DIR

    # Temporary FASTA file for this sequence
    TEMP_FASTA="${seq_id}.fasta"
    
    # Extract the sequence to the temporary FASTA file
    extract_sequence_to_file "$seq_id" $FASTA_INPUT $TEMP_FASTA

    # Run AlphaFold for this sequence using the monomer model
    alphafold --data_dir $ALPHAFOLD_DATA_DIR \
              --output_dir $OUTPUT_BASE_DIR \
              --model_names model_1 \
              --fasta_paths $TEMP_FASTA \
              --max_template_date 2022-6-2 \

    # Clean up the temporary FASTA file
    rm $TEMP_FASTA

done <<< "$sequences"

echo "All sequences have been processed."





