# Clinical Data Processing
# Goal: save CLIN.csv

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
selected_cols <- c("patient", "Arm", "pCR")
clin <- cbind(clin[, selected_cols], "Breast", "F", "microarray", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)

colnames(clin) <- c("patient", "drug_type", "response.other.info", "primary", "sex", "rna", "age", "stage", "recist", "t.os", "t.pfs", "histo", "os", "pfs", "dna", "response")

# Set "sex" ,"rna" and "rna_info" columns
#clin$rna <- "microarray"
#clin$rna_info <- "quantile" 

# Define "response" based on values in "response.other.info"
clin$response <- Get_Response(data = clin) 

# Reordering Columns for Structured Data
clin <- clin[, c("patient", "sex", "age", "primary", "histo", "stage", "response.other.info", "recist", "response", "drug_type", "dna", "rna", "t.pfs", "pfs", "t.os", "os")]


# Formatting clinical data using a custom function
clin <- format_clin_data(clin, "patient", selected_cols, clin)


# Annotating Tissue Data
# Survival_unit and survival_type columns will be added in annotate_tissue
annotation_tissue <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv")
clin <- annotate_tissue(clin=clin, study='Wolf', annotation_tissue= annotation_tissue, check_histo=FALSE)

# TODO: Address the issue of missing survival PFS (Progression-Free Survival) and OS (Overall Survival) data
clin$survival_unit <- NA

#Set "rna_info" column as "quantile" .
clin$rna_info <- "quantile" 
clin$dna_info <- NA

# TODO: Verify treatmentid columns with Sisira
annotation_drug <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_drug.csv")
clin <- add_column(clin, treatmentid=annotate_drug('Wolf', clin$drug_type, annotation_drug), .after='tissueid')

#TODO: delete this line later.
#clin$treatmentid <- NA 

#TODO: delete next line later.
# print(unique(clin$drug_type))

# TODO: Update 'drug_type' based on Farnoosh's decision on chemo categorization
# clin$drug_type <- 

# Replace empty string values with NA
clin[clin == ""] <- NA

# Save the processed data as CLIN.csv file
file <- "~/BHK lab/ICB_Wolf/data/CLIN.csv"
write.csv(clin, file, row.names = TRUE)
