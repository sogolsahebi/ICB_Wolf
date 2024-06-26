# Clinical Data Processing
# Goal: save CLIN.csv (dimensions: 987 x 74).

# Libraries and Source Files
library(tibble)

# Sourcing functions from GitHub for processing clinical data
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

# Data Loading for Clinical Data
clin_original <- read.csv("files/CLIN.txt", stringsAsFactors = FALSE, sep = "\t")

# Data Curation for Clinical Data
# Selecting specific Columns for Analysis
selected_cols <- c("patient", "Arm")

# Combine selected columns with additional columns.
clin <- cbind(clin_original[, selected_cols], "F", "Breast", "microarray", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)

# Set new column names.
colnames(clin) <- c("patient", "drug_type", "sex", "primary", "rna", "rna_info", "age", "stage", "recist", "t.os", "t.pfs", "histo", "os", "pfs", "dna", "dna_info", "response")

# Correct "response.other.info" format.
clin$response.other.info <- ifelse(clin_original$pCR == 0, "NR", "R")

# Define "response" based on values in "response.other.info"
clin$response <- Get_Response(data = clin) 

# Reordering Columns for Structured Data
clin <- clin[, c("patient", "sex", "age", "primary", "histo", "stage", "response.other.info", "recist", "response", "drug_type", "dna","dna_info", "rna","rna_info", "t.pfs", "pfs", "t.os", "os")]

# Formatting clinical data using a custom function
clin <- format_clin_data(clin_original, "patient", selected_cols, clin)

# Annotating Tissue Data
# Survival_unit and survival_type columns will be added in annotate_tissue
annotation_tissue <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv")
clin <- annotate_tissue(clin=clin, study='Wolf', annotation_tissue= annotation_tissue, check_histo=FALSE)

# Set survival unit to NA Missing survival PFS/OS.
clin$survival_unit <- NA

# Set treatmentid based on curation_drug.csv file.
annotation_drug <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_drug.csv")
clin <- add_column(clin, treatmentid=annotate_drug('Wolf', clin$drug_type, annotation_drug), .after='tissueid')

# Update 'drug_type' column based  category for specific 'treatmentid'
clin$drug_type[clin$treatmentid == 'Paclitaxel' ] <- 'chemo'
clin$drug_type[clin$treatmentid == 'Paclitaxel + Pembrolizumab'] <- 'IO+chemo'
clin$drug_type[clin$treatmentid == 'Trastuzumab Emtansine + Pertuzumab'] <- 'targeted'

clin$drug_type[clin$treatmentid %in% c('Paclitaxel + Neratinib', 
                                       'Paclitaxel + Veliparib dihydrochloride + Carboplatinum', 
                                       'Paclitaxel + Trastuzumab', 'Paclitaxel + Trebananib',
                                       'Paclitaxel + MK-2206', 'Paclitaxel + MK-2206 + Trastuzumab', 
                                       'Paclitaxel + Pertuzumab + Trastuzumab',
                                       'Paclitaxel + Trebananib + Trastuzumab', 'Paclitaxel + Ganitumab', 
                                       'Paclitaxel + Ganetespib')] <- 'chemo+targeted'

# Save the processed data as CLIN.csv file
write.table(clin, "files/CLIN.csv", quote=TRUE, sep=";", col.names=TRUE, row.names=FALSE)






