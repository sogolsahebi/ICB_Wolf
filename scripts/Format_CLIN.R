# Libraries and Source Files
library(tibble)

# Sourcing functions from GitHub for processing clinical data
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

# Data Loading for Clinical Data
file_path_clin <- "~/BHK lab/ICB_Wolf/data/CLIN.txt"
clin <- read.csv(file_path_clin, stringsAsFactors = FALSE, sep = "\t")
rownames(clin) <- clin$Patient.Identifier

# Data Curation for Clinical Data
# Selecting Specific Columns for Analysis
selected_cols <- c("Patient.Identifier", "Arm", "pCR")
clin <- cbind(clin[, selected_cols], rep(NA, 15))

colnames(clin) <- c("patient", "drug_type", "recist", "primary", "age", "sex", "stage", "response.other.info", "t.os", "t.pfs", "histo", "stage", "os", "pfs", "dna", "rna", "response")

# Define response based on values in "response.other.info"
clin$response <- Get_Response(data = clin) 

# Set sex, stage, dna, dna_info columns at NA
clin$sex <- "F"
clin$stage <- NA
clin$dna <- NA
clin$dna_info <- NA

# Microarray and RNA-seq
clin$rna <- "Microarray"

# TODO: Check if linearization could be in rna_info
clin$rna_info <- "NA"          

# Reordering Columns for Structured Data
clin <- clin[, c(
  "patient", "sex", "age", "primary", "histo", "stage", 
  "response.other.info", "recist", "response", "drug_type", "dna", "dna_info", "rna","rna_info", "t.pfs", 
  "pfs", "t.os", "os"
)]

# Formatting clinical data using a custom function.
clin <- format_clin_data(clin, "patient", selected_cols, clin)

# Add survival_unit and survival_type columns, use 'curation_tissue.csv' file to set clin$tissueid column
# TODO: Add Wolf to the data files

# Annotate Tissue Data
path <- "https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv"
annotation_tissue <- read.csv(path)

clin <- annotate_tissue(clin=clin, study='Wolf', annotation_tissue=annotation_tissue, check_histo=FALSE)

# Add column 'treatmentid' after 'tissueid' column.
clin <- add_column(clin, treatmentid = clin$Agent_PD1, .after='tissueid')

# Adding drug_type based on treatmentid.
# Print unique values of treatmentid.
print(unique(clin$treatmentid))

# clin$drug_typ <- # TODO: Based on Farnoosh categorization decision on adding chemo

# Replace empty string values with NA.
clin[clin == ""] <- NA

# Save the processed data as CLIN.csv file
file <- "~/BHK lab/ICB_Wolf/data/CLIN.csv"
write.csv(clin, file, row.names = TRUE)
