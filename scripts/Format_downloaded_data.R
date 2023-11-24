# Format_downloaded_data.R

# This script formats and cleans clinical and expression data
# - Creates "CLIN.txt" 
# - Creates "EXPR.txt.gz"

# Load necessary libraries
library(readxl)

# Path for clinical data file
clin_file_path <- "~/BHK lab/ICB_Wolf/source_data/NIHMS1829047-supplement-3.xlsx"

# Read and format clinical data
clin <- read_excel(clin_file_path)
colnames(clin) <- clin[1, ]
clin <- clin[-1, ]

# Save clinical data as CLIN.txt
clin_output_path <- "~/BHK lab/ICB_Wolf/data/CLIN.txt"
write.table(clin, clin_output_path, quote = FALSE, sep = "\t", row.names = FALSE)

# Path for expression data file
expr_file_path <- "~/BHK lab/ICB_Wolf/source_data/GSE194040_ISPY2ResID_AgilentGeneExp_990_FrshFrzn_GPL20078_ProbeLevel_n654.txt"

# Read and process expression data
expr <- read.table(expr_file_path, header = TRUE, sep = "\t")
colnames(expr) <- sub("^X", "", colnames(expr))

# Check for any duplicate column names after renaming
if (any(duplicated(colnames(expr)))) {
  stop("Duplicate found in colnames(expr).") #no duplication founc
}

# Sort the row names of 'expr'
expr <- expr[sort(rownames(expr)), ]

# Confirm that all column values are numeric
if (!all(sapply(expr, is.numeric))) {
  stop("Non-numericin expr") # no non-numericin founc
}

# Save expression data as EXPR.txt.gz
expr_output_path <- "~/BHK lab/ICB_wolf/data/EXPR.txt.gz"
gz_conn <- gzfile(expr_output_path, "w")
write.table(expr, gz_conn, sep = "\t", row.names = TRUE, quote = FALSE)
close(gz_conn)
