# Analyze UK Biobank fat data using the method from Liu and Lin (JASA
# 2018).
library(MPAT)
library(data.table)
library(purrr)

MAF_CUTOFF <- 0.05
traits <- c("23111", "23115", "23119", "23123", "23127")
trait_dt_lst <- list()

# read in each trait one by one
for (trait in traits) {
    message(sprintf("Reading trait %s...", trait))
    fname <- sprintf("nealelab-uk-biobank/%s_irnt.gwas.imputed_v3.both_sexes.tsv.bgz",
                     trait)
    trait_dt <- fread(cmd = paste("zcat", fname))
    setkey(trait_dt, variant)
    trait_dt_lst[[trait]] <-
        trait_dt[!low_confidence_variant & minor_AF >= MAF_CUTOFF,
                 .(variant, tstat)]
}

# sanity check
lapply(trait_dt_lst, nrow)

# rename columns
walk2(trait_dt_lst, names(trait_dt_lst),
      function(dt, name) {
          newname <- paste0("tstat_", name)
          setnames(dt, old = "tstat", new = newname)
      })

# merge all traits together
traitdt_merged <- reduce(trait_dt_lst, merge, all = TRUE)

pheno_corr <- readRDS("pheno_corr.rds")

# run variance component test, ignore errors
runVC <- function(zstats, Sigma = pheno_corr) {
    ret <- NA
    try({
        ret <- VC(zstats, Sigma)
    })
    return(ret)
}

system.time({
    vc_stats <- apply(traitdt_merged[, -1], 1, runVC)
})
vc_dt <- data.table(variant = traitdt_merged$variant,
                    vc_stat = vc_stats)
saveRDS(vc_dt, "mpat_dt.rds")
