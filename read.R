
# read rds files

rds_files <- list.files("output/sessions", pattern = "\\.rds$", full.names = TRUE)

results <- file.info(list.files("output/results", pattern = "\\.rds$", full.names = TRUE))

latest <- rownames(results)[which.max(results$mtime)]

res <- readRDS(latest)

res
