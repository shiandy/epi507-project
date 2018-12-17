library(qqman)
library(data.table)
library(tidyr)
library(dplyr)

MAF_CUTOFF <- 0.05

mpat_dt <- readRDS("mpat_dt.rds")
mpat_dt[, sum(vc_stat <= 5e-8, na.rm = TRUE)]

samp <- mpat_dt[sample(1:nrow(mpat_dt), 10000),]
qq(samp$vc_stat)

mpat_dt <- separate(mpat_dt, variant,
                    into = c("CHR_STR", "BP", "REF", "ALT"), sep = ":")
mpat_dt[, CHR := ifelse(CHR_STR == "X", 23, as.integer(CHR_STR))]
mpat_dt[, BP := as.integer(BP)]
mpat_dt[, SNP := NA]
mpat_dt <- mpat_dt[!is.na(vc_stat),]

png("manhattan.png", width = 1024, height = 960)
manhattan(mpat_dt, p = "vc_stat", main = "VC Test Manhattan Plot")
dev.off()

fname <- sprintf("nealelab-uk-biobank/%s_irnt.gwas.imputed_v3.both_sexes.tsv.bgz",
                 "23111")
trait_dt <- fread(cmd = paste("zcat", fname))
setkey(trait_dt, variant)
trait_dt_filter <-
    trait_dt[!low_confidence_variant & minor_AF >= MAF_CUTOFF,
             .(variant, pval)]

trait_dt_filter <- trait_dt_filter %>%
    separate(variant, into = c("CHR_STR", "BP", "REF", "ALT"), sep = ":")
trait_dt_filter[, CHR := ifelse(CHR_STR == "X", 23, as.integer(CHR_STR))]
trait_dt_filter[, BP := as.integer(BP)]
trait_dt_filter[, SNP := NA]
trait_dt_filter <- trait_dt_filter[!is.na(pval),]

pltname <- sprintf("manhattan_%s.png", "23111")
png(pltname, width = 1024, height = 960)
manhattan(trait_dt_filter, p = "pval", main = "Leg Fat (right)")
dev.off()
