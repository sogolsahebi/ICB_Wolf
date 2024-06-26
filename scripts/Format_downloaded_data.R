# Format_downloaded_data.R

# This script formats and cleans clinical and expression data.
# - Creates "CLIN.txt" ,dimension 987 x 54
# - Creates "EXPR.txt.gz", dimension 19134 x 987

# Load necessary libraries
library(readxl)

# Path for clinical data file
clin_file_path <- "~/BHK lab/ICB_Wolf/source_data/NIHMS1829047-supplement-3.xlsx"

# Read and format clinical data
clin <- read_excel(clin_file_path)
colnames(clin) <- clin[1, ]
clin <- clin[-1, ]

# Rename the 'Patient.Identifier' column to 'patient'
colnames(clin)[colnames(clin) == "Patient Identifier"] <- "patient"

# Add "X" to patient column for matching purpose.
clin$patient <- paste0("X", clin$patient)

# Save clinical data as CLIN.txt
clin_output_path <- "~/BHK lab/ICB_Wolf/files/CLIN.txt"
write.table(clin, clin_output_path, quote = FALSE, sep = "\t", row.names = FALSE)

# Path for expression data file
expr_file_path <- "~/BHK lab/ICB_Wolf/source_data/GSE194040_ISPY2ResID_AgilentGeneExp_990_FrshFrzn_meanCol_geneLevel_n988.txt"

# Read and process expression data
expr <- read.table(expr_file_path, header = TRUE, sep = "\t")

# Confirm no duplication.
all(!duplicated(colnames(clin))) ==  TRUE

# Calculate the row-wise average of gene expression data from two samples ("629606.GPL16233" and "629606.GPL20078")
# and store it in a new column ('629606'), ignoring missing values
expr$`X629606` <- rowMeans(sapply(expr[c("X629606.GPL16233", "X629606.GPL20078")], as.numeric), na.rm = TRUE)
expr$`X629606.GPL16233` <- NULL
expr$`X629606.GPL20078` <- NULL #now dim(expr) is 19134   987.

# Sort the row names of 'expr'
expr <- expr[sort(rownames(expr)), ]

# Confirm that all column values are numeric
all(sapply(expr, is.numeric)) == TRUE

# Save expression data as EXPR.txt.gz
expr_output_path <- "~/BHK lab/ICB_wolf/files/EXPR.txt.gz"
gz_conn <- gzfile(expr_output_path, "w")
write.table(expr, gz_conn, sep = "\t", row.names = TRUE, quote = FALSE)
close(gz_conn)