# Multiple Phenotype Analysis of Body Fat Percentage in UK Biobank

Final Project for EPI 507 taught at Harvard TH Chan School of Public
Health, Fall 2018.

# Getting the files

To run the code, you will need to download files from 1000 Genomes and
from the Neale Lab UK Biobank GWAS.

1. Download the data from 1000 genomes into a folder called
   `1000-genomes` from this website: [http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/)

2. Copy the `download.sh` script to a folder called
   `nealelab-uk-biobank`, and execute it using `bash ./download.sh`.
   This will download the Neale Lab UK Biobank summary statistics.

# Running the code

This project is built using Snakemake. If you want to reproduce the
analysis, you need to set up Snakemake according to [these
instructions](https://snakemake.readthedocs.io/en/stable/tutorial/setup.html).
Use the `environment.yaml` file provided here instead of the one given
in the tutorial.

Then, simply run `snakemake` to execute the analysis pipeline. Snakemake
will run the code according to the `Snakefile` file. See that file for
information about each of the analysis steps.
