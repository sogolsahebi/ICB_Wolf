# Microarray Data Processing.
# File: Format_EXPR.R

# Read libraries.
library(data.table)

# Data Reading
expr_path <- "~/BHK lab/ICB_Wolf/data/EXPR.txt.gz"
expr <- as.data.frame(fread(expr_path, sep = "\t", dec = ",", stringsAsFactors = FALSE))

# Clean up the data
rownames(expr) <- expr[, 1]
expr <- expr[, -1]  # 19123   988

# Data Filtering
case_path <- "~/BHK lab/ICB_Wolf/data/cased_sequenced.csv"
case <- read.csv(case_path, sep = ";")

# Filter the 'expr' dataset to include only patients with expr value of 1 in the 'case' dataset
expr <- expr[, colnames(expr) %in% case[case$expr == 1, ]$patient]

expr <- as.data.frame(sapply(expr, as.numeric))

#TODO: Number of missing values in 'expr': 2831 
# Count the number of missing values (NA) in the entire data frame
missing_count <- sum(is.na(expr))
cat("Number of missing values in 'expr':", missing_count, "\n")

# Data Transformation
# Convert TPM data to log2-TPM for consistency with other data formats
expr <- log2(expr + 0.001)

dim(expr)  # 19134   986

# Write the transformed data to a file (uncomment this line if needed)
# write.table(expr, file = file.path(output_dir, "EXPR.csv"), quote = FALSE, sep = ";", col.names = TRUE, row.names = TRUE)
path <- "~/BHK lab/ICB_Wolf/data/EXPR.csv"
write.table(expr, path, quote = FALSE, sep = ";", col.names = TRUE, row.names = TRUE)

