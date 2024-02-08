# Microarray Data Processing.
# File:Save Format_EXPR.csv- (dimension is 19134-987)

# Read libraries.
library(data.table)

# Data Reading
expr_path <- "~/BHK lab/ICB_Wolf/files/EXPR.txt.gz"
expr <- as.data.frame(fread(expr_path, sep = "\t", dec = ",", stringsAsFactors = FALSE))

# Clean up the data
rownames(expr) <- expr[, 1]
expr <- expr[, -1]  # 19134   987

# Data Filtering
case_path <- "~/BHK lab/ICB_Wolf/files/cased_sequenced.csv"
case <- read.csv(case_path, sep = ";")

# Filter the 'expr' dataset to include only patients with expr value of 1 in the 'case' dataset
expr <- expr[, colnames(expr) %in% case[case$expr == 1, ]$patient]

expr <- as.data.frame(lapply(expr, as.numeric), row.names = rownames(expr))

#TODO: Number of missing values.
sum(is.na(expr))  #2831 NA values.

# Write the transformed data to csv file.
path <- "~/BHK lab/ICB_Wolf/files/EXPR.csv"
write.table( expr, path , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )
