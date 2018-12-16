# Filter variants from Neale Lab variants.tsv.bgz file, using variants
# pruned by PLINK to be in low LD.

library(data.table)

chrom_lst <- as.character(1:22)
chrom_lst <- c(chrom_lst, "X")

merged_var_lst <- list()
for (chrom in chrom_lst) {
    message(sprintf("Working on chr %s...", chrom))
    fname_variants <- sprintf("nealelab-uk-biobank/variants_chr%s.tsv",
                              chrom)
    fname_1000g <- sprintf("1000-genomes/GBR_chr%s.prune.in", chrom)

    variants <- fread(fname_variants)
    setkey(variants, rsid)
    ref <- fread(fname_1000g, header = FALSE, col.names = "rsid")
    setkey(ref, rsid)

    merged <- variants[ref, nomatch = 0]
    merged_var_lst[[chrom]] <- merged
}

merged_var <- do.call(rbind, merged_var_lst)
saveRDS(merged_var, file = "filtered_variants.rds")
