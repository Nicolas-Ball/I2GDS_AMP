#!/bin/bash
# run_single_af.sh: template job script for running AlphaFold on Tinkercliffs A100 nodes
# Usage:
# 1. Supply input and output paths
# 2. Run with "sbatch run_single_af.sh"
# 3. Update <your allocation account>,<your email>,<JOBNAME>, <path to fasta input file(s)>, and <path to desired output directory>
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --gres=gpu:1
#SBATCH -p a100_normal_q
#SBATCH -t 12:00:00
#SBATCH -A <your allocation account>
#SBATCH --mail-type=all
#SBATCH --mail-user=<your email>@vt.edu
#SBATCH --job-name=<JOBNAME>
#SBATCH --export=NONE

# Load the AlphaFold module (Loads the module making the software accessible)
module load AlphaFold/2.0.0-fosscuda-2020b

# Path to databases (Sets the path to AlphaFold's required databases)
export ALPHAFOLD_DATA_DIR=/global/biodatabases/alphafold

# Path to single sequence fasta file (Defines the input fasta file containing the sequence)

FASTA_INPUT=<path to fasta input file(s)>

# Base output directory (Defines where the output files will be written)
OUTPUT_BASE_DIR=<path to desired output directory>

# Run AlphaFold for this sequence using the monomer model (Main command to run AlphaFold)
alphafold --data_dir $ALPHAFOLD_DATA_DIR \
          --output_dir $OUTPUT_BASE_DIR \
          --model_names model_1 \
          --fasta_paths $FASTA_INPUT \
          --max_template_date 2022-6-2 \
