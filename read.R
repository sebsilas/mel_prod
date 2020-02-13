
# read rds files

rds_files <- list.files("output/sessions", pattern = "\\.rds$", full.names = TRUE)

res <- readRDS("output/sessions/ac0d756ff66c7254fd08f29b019eb9efa098d3bf6e69bddcfb7eace256896e80/data.rds")
res
