# Define input and output file paths
input_file = "dbAMP_Antibacterial_2024.fasta"
output_file = "dbAMP_Antibacterial_filtered.fasta"

# Define length limits
min_length = 20
max_length = 40

# Function to read and filter FASTA file without importing any modules
def filter_fasta(input_path, output_path, min_len, max_len):
    with open(input_path, "r") as infile, open(output_path, "w") as outfile:
        write_seq = False
        for line in infile:
            if line.startswith(">"):  # Header line
                if write_seq:  # Write previous sequence if it met criteria
                    outfile.write(header + sequence + "\n")
                header = line
                sequence = ""
                write_seq = False  # Reset write condition
            else:
                sequence += line.strip()
                # Update the write condition if sequence length is within range
                if min_len <= len(sequence) <= max_len:
                    write_seq = True

        # Write the last sequence if it met the criteria
        if write_seq:
            outfile.write(header + sequence + "\n")

# Run the filtering function
filter_fasta(input_file, output_file, min_length, max_length)
print(f"Filtered sequences saved to {output_file}")
