library(qqman)
library(data.table)
library(tidyr)
library(dplyr)

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

png("manhattan.png", width = 960, height = 960)
manhattan(mpat_dt, p = "vc_stat", main = "VC Test Manhattan Plot")
dev.off()
