import os
CHROM = list(map(str, range(1, 23)))
CHROM.append("X")

rule all:
    input:
        "manhattan.png"

# get individuals of GBR ancestry
rule get_indiv:
    input:
        "1000-genomes/integrated_call_samples_v3.20130502.ALL.panel"
    output:
        "1000-genomes/gbr_individuals.txt"
    shell:
        "grep -P 'GBR\tEUR' {input} | cut -f1 > {output}"

# Filter, keep MAF >= 0.05 and GBR ancestry
rule vcf_to_plink_autosome:
    input:
        "1000-genomes/ALL.chr{chrom}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz"
    output:
        "1000-genomes/GBR_chr{chrom}.ped",
        "1000-genomes/GBR_chr{chrom}.map"
    shell:
        "vcftools --gzvcf {input} "
        "--out 1000-genomes/GBR_chr{wildcards.chrom} "
        "--keep 1000-genomes/gbr_individuals.txt "
        "--maf 0.05 --plink"

# Filter, keep MAF >= 0.05 and GBR ancestry. Had to tweak slightly to
# work for X chromosome
rule vcf_to_plink_X:
    input:
        "1000-genomes/ALL.chrX.phase3_shapeit2_mvncall_integrated_v1b.20130502.genotypes.vcf.gz"
    output:
        "1000-genomes/GBR_chrX.ped",
        "1000-genomes/GBR_chrX.map"
    shell:
        "vcftools --gzvcf {input} --out 1000-genomes/GBR_chrX "
        "--remove-indels "
        "--keep 1000-genomes/gbr_individuals.txt "
        "--maf 0.05 --plink"

# Run plink to find list of SNPs that are "independent"
rule plink_filter_LD:
    input:
        "1000-genomes/GBR_chr{chrom}.ped",
        "1000-genomes/GBR_chr{chrom}.map"
    output:
        "1000-genomes/GBR_chr{chrom}.prune.in"
    shell:
        "plink --file 1000-genomes/GBR_chr{wildcards.chrom} "
        "--indep-pairwise 50 5 0.01 "
        "--out 1000-genomes/GBR_chr{wildcards.chrom}"

# split the variants file by chromosome since it is too big right now
rule split_variants:
    input:
        "nealelab-uk-biobank/variants.tsv.bgz"
    output:
        expand("nealelab-uk-biobank/variants_chr{chrom}.tsv",
            chrom = CHROM)
    shell:
        "zcat {input} | python split_variants.py /dev/stdin"

rule filter_variants:
    input:
        expand("nealelab-uk-biobank/variants_chr{chrom}.tsv",
            chrom = CHROM)
    output:
        "filtered_variants.rds"
    shell:
        "Rscript filter-variants.R"

rule est_pheno_corr:
    input:
        "filtered_variants.rds"
    output:
        "pheno_corr.rds"
    shell:
        "Rscript est-pheno-corr.R"

rule analysis:
    input:
        "pheno_corr.rds"
    output:
        "mpat_dt.rds"
    shell:
        "Rscript analysis.R"

rule plot:
    input:
        "mpat_dt.rds"
    output:
        "manhattan.png"
    shell:
        "Rscript plot.R"
