
# 1. Downloading and Cleaning AMP sequences

## Downloading AMP sequences
A set of about 7,000 antibacterial peptide sequences can be downloaded from [dbAMP 3.0](https://awi.cuhk.edu.cn/dbAMP/index.php)

```bash
  wget 'https://awi.cuhk.edu.cn/dbAMP/download/3.0/activity/dbAMP_Antibacterial.fasta' -O dbAMP_Antibacterial_2024.fasta

```

We then want to remove sequences that are shorter than 20 or longer than 40 amino acids long for better comparisons. We can do this with the [run_limit_amp_length.py](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/scripts/run_limit_amp_length.py) python script.

```bash
  python run_limit_amp_length.py
```

Then we need to see which of the peptide structures we still need to model with the [check_pdb_avalibility.py](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/scripts/check_pdb_avalibility.py) python script. This script checks if there is an availible pdb structure for the sequences, if not, the sequence is added to a new fasta file called `to_be_modeled.fasta`.

*** Peer grader: Dont run this it can overload the server ***
```bash
  python check_pdb_avalibility.py
```

In the next step we will use AlphaFold to model these peptides.
# 2. Modeling Proteins Using AlphaFold with Advanced Research Computing (ARC) at Virginia Tech
![hippo](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/images/example_protein.gif)
## Introduction
This is a tutorial for running AlphaFold on ARC at Virginia tech. 


Additional documentation can be found here: [ARC User Documentation](https://www.docs.arc.vt.edu/software/alphafold.html)
## The basics of submitting jobs on ARC

ARC uses the Simple Linux Utility for Resource Management (SLURM) where submitted jobs enter a queuing system (scheduler).Job submissions must describe what computer resources the job requires like gpu(s), cpu(s), time limit, allocation, ect.

```bash
  #!/bin/bash
  #SBATCH --nodes=1
  #SBATCH --ntasks-per-node=16
  #SBATCH --gres=gpu:1
  #SBATCH -p a100_normal_q
  #SBATCH -t 8:00:00
  #SBATCH -A <your allocation account>
  #SBATCH --mail-type=all
  #SBATCH --mail-user=<your email>@vt.edu
  #SBATCH --job-name=<JOBNAME>
  #SBATCH --export=NONE
```
- `--nodes=1`: Requests 1 compute node.
- `--ntasks-per-node=16`: Requests 16 tasks (or cores) per node.
- `--gres=gpu:1`: Requests 1 GPU for the job.
- `-p a100_normal_q`: Specifies the partition or queue to run the job in (a100_normal_q and dgx_normal_q are for GPU jobs)
- `-t 8:00:00`: Sets a time limit of 8 hours for the job.
- `-A <your allocation account>`: Specifies the project or account under which the job is run.
- `--mail-type=all`: Sends email notifications for all job events.
- `--mail-user=<your email>@vt.edu`: The email address to send notifications to.
- `--job-name=<JOBNAME>`: Names the job for easier tracking.
- `--export=NONE`: Makes sure current environment variables arent inherited.

Jobs can be submitted to the queue with the `sbatch` command.
```bash
  sbatch example_script.sh
```
You can view the status of submitted jobs with the `squeue` command.
```bash
  squeue -u <your username>
```

jobs can be canceled with the `scancel` command using the job ID returned from `sbatch` or `squeue`.
```bash
  scancel 1234567
```
## Availability
-	AlphaFold is currently available only on Tinkercliffs
-	A100 GPU nodes (`a100_normal_q`) have Alphafold v2.0
-	DGX nodes nodes (`dgx_normal_q`) have Alphafold v2.2.2

The databases required for AlphaFold to run are located in a central repository (`/global/biodatabases/alphafold`) so you dont need to maintain your own copy. 

## Duration
Typical runs on a single input have taken 1-2 hours for sequences with 150-1000 bases. The majority of the time is spent in high I/O while AlphaFold references the databases in the central repository. 

## Computational resources to request
Because relatively little time is spent on the GPU, it is recommended to only request a single GPU for each job. It is also recommended to request a proportional amount of CPU for the job. A100 nodes have 128 cores in total, ammounting to 16 cores/GPU. When 16 cores are requested, 512GB of memory will automatically be allocated for the job.

## Interface
On ARC AlphaFold and all it's dependencies have been installed via EasyBuild. The interface for AlphaFold is available via command-line scripts. It is recommended to submit AlphaFold batch jobs for all but the smallest proteins.

The software and all its dependencies are available via modules:

AlphaFold v2.2.2 on Tinkercliffs DGX nodes
```bash
  module load AlphaFold/2.2.2-foss-2021a-CUDA-11.3.1
```
AlphaFold v2.0 Tinkercliffs A100 nodes
```bash
  module load AlphaFold/2.0.0-fosscuda-2020b
```

## Scripts
By default AlphaFold only accepts single sequence files. It supports .fasta, .faa, and .txt files (that are in fasta format). The output folder(s) will have a number of .pdb structure files ranked by energy. The rank 0 pdb file is the best output model.

A template script for running AlphaFold on a single-sequence fasta file, on the `a100_normal_q` partition, can be found here [run_single_af.sh](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/scripts/run_single_af.sh). If you have several single sequence fasta files you can provide them as a comma-separated list in the input specification. 

```bash
  FASTA_INPUT= file1.fasta, file2.fasta, file3.fasta
```

For some use cases where dozens of small proteins need to be modeled, it is often easier to use a single fasta file that contains all of the sequences. A template script for running AlphaFold on a multi sequence fasta file, on the `a100_normal_q` partition, can be found here [run_multi_af.sh](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/scripts/run_multi_af.sh). This script automatically creates temporary fasta files for each individual sequence and creates output directories for each sequence. For better organization, the output directories are named according to the sequence names provided in the fasta file.

To switch from AlphaFold 2 to AlphaFold 2.2.2, change the partition and module to the DGX node specific version in the scripts.


```bash
  #SBATCH -p a100_normal_q -> #SBATCH -p dgx_normal_q
```

```bash
  module load AlphaFold/2.0.0-fosscuda-2020b -> module load AlphaFold/2.2.2-foss-2021a-CUDA-11.3.1
```


## Reminders

Make sure to replace placeholders such as `<your allocation account>`,`<your email>`,`<JOBNAME>`, `<path to fasta input file(s)>`, and `<path to desired output directory>` with your specific paths and account information.
## Test files

A test fasta file containing one sequence can be found here [example_single_sequence.fasta](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/fasta%20files/example_single_sequence.fasta)

A test fasta file containing three sequences can be found here [example_multi_sequence.fasta](https://github.com/Nicolas-Ball/I2GDS_AMP/blob/main/fasta%20files/example_multi_sequence.fasta)


## Test files

A test fasta file containing one sequence can be found here [example_single_sequence.fasta](https://github.com/nb3228/i2gdstest/blob/main/fasta%20files/example_single_sequence.fasta)

A test fasta file containing three sequences can be found here [example_multi_sequence.fasta](https://github.com/nb3228/i2gdstest/blob/main/fasta%20files/example_multi_sequence.fasta)


## Viewing 3D protein structures

You can view the protein structure files using programs like [PyMOL](https://www.pymol.org/) for free with an educational license.

