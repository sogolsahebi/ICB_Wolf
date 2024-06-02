# Microarray Data Processing.
# File:Save Format_EXPR.csv- (dimension is 19134-987)

# Read libraries.
library(data.table)

# Data Reading
# expr is single gene-level dataset after batch-adjusting using ComBat
expr <- as.data.frame(fread("files/EXPR.txt.gz", sep = "\t", dec = ",", stringsAsFactors = FALSE))

# Clean up the data
rownames(expr) <- expr[, 1]
expr <- expr[, -1]  # 19134   987

# Data Filtering
case <- read.csv("files/cased_sequenced.csv", sep = ";")

# Filter the 'expr' dataset to include only patients with expr value of 1 in the 'case' dataset
expr <- expr[, colnames(expr) %in% case[case$expr == 1, ]$patient]
expr <- as.data.frame(lapply(expr, as.numeric), row.names = rownames(expr))

# Write the transformed data to csv file.
write.table( expr, "files/EXPR.csv", quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )
