import requests

# Define input and output file paths
input_file = "dbAMP_Antibacterial_filtered.fasta"
output_file = "to_be_modeled.fasta"

# Base URL for PDB files
base_url = "https://awi.cuhk.edu.cn/dbAMP/esmfold/"

# Function to check if PDB file exists
def check_pdb_availability(seq_name):
    url = f"{base_url}{seq_name}.pdb"
    response = requests.head(url)
    return response.status_code == 200

# Function to read sequences and check PDB availability
def filter_sequences(input_path, output_path):
    with open(input_path, "r") as infile, open(output_path, "w") as outfile:
        seq_name = ""
        sequence = ""
        for line in infile:
            if line.startswith(">"):  # Header line
                if seq_name and sequence:  # Check previous sequence
                    if not check_pdb_availability(seq_name):
                        outfile.write(f">{seq_name}\n{sequence}\n")
                seq_name = line[1:].strip()
                sequence = ""
            else:
                sequence += line.strip()

        # Check the last sequence
        if seq_name and sequence and not check_pdb_availability(seq_name):
            outfile.write(f">{seq_name}\n{sequence}\n")

# Run the function
filter_sequences(input_file, output_file)
print(f"Sequences without PDB files have been saved to {output_file}")
