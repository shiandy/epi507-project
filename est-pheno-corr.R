# estimate phenotype correlation

library(data.table)

filtered_variants <- readRDS("filtered_variants.rds")
setkey(filtered_variants, variant)

traits <- c("23111", "23115", "23119", "23123", "23127")
tstats_indep_lst <- list()

# read in traits one by one and merge with filtered variants from PLINK
for (trait in traits) {
    message(sprintf("Working on trait %s...", trait))
    fname <- sprintf("nealelab-uk-biobank/%s_irnt.gwas.imputed_v3.both_sexes.tsv.bgz",
                     trait)
    trait_dt <- fread(cmd = paste("zcat", fname))
    setkey(trait_dt, variant)
    trait_indep <- trait_dt[filtered_variants, .(variant, rsid, tstat),
                             nomatch = 0]
    tstats_indep_lst[[trait]] <- trait_indep
}

# sanity check: make sure equal number of rows and same variants
lapply(tstats_indep_lst, nrow)
variants_lst <- lapply(tstats_indep_lst, function(x) { x$variant })
rsid_lst <- lapply(tstats_indep_lst, function(x) { x$rsid })

for (ind in 1:4) {
    stopifnot(all.equal(variants_lst[[ind]], variants_lst[[ind + 1]]))
    stopifnot(all.equal(rsid_lst[[ind]], rsid_lst[[ind + 1]]))
}

# do the estimation
teststats <- vapply(tstats_indep_lst, function(x) { x$tstat },
                    rep(1, nrow(tstats_indep_lst[[1]])))
pheno_corr <- cor(teststats)
saveRDS(pheno_corr, "pheno_corr.rds")
