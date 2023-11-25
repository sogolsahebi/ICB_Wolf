# Libraries and Source Files
library(tibble)
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

# Data Loading for Clinical Data
file_path_clin <- "~/BHK lab/ICB_Wolf/data/CLIN.txt"
clin <- read.csv(file_path_clin, stringsAsFactors = FALSE, sep = "\t")
rownames(clin) <- clin$Patient.Identifier

# Data Curation for Clinical Data
selected_cols <- c("Patient.Identifier", "Arm", "pCR")
clin <- cbind(clin[, selected_cols], "Lung", NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)
colnames(clin) <- c("patient", "drug_type", "recist", "primary", "age", "sex", "stage", "response", "t.os", "t.pfs", "histo", "stage", "os", "pfs", "dna", "rna", "response.other.info")



# Error Handling and Response Calculation
# clin$response = Get_Response(data = clin)  # Uncomment when Get_Response function is working


# Modify stage values for better clarity.
clin$stage <- NA

# Assign 'tpm' and 'wes' values based on RNA_All and WES_All respectively.
clin$dna <- NA
#clin$rna <- #TODO: after Farnoosh Mondays' comment 

#TODO: make sure we dont have two column of aems


# Reorder columns.
clin <- clin[, c(
  "patient", "sex", "age", "primary", "histo", "stage", 
  "response.other.info", "recist", "response", "drug_type", "dna", "rna", "t.pfs", 
  "pfs", "t.os", "os"
)]


# Use the format_clin_data function for further formatting.
clin <- format_clin_data(clin, "patient", selected_cols, clin)

#add survival_unit and survival_type columns. and use  'curation_tissue.csv' file to set clin$tissueid column
#annotation_tissue <- read.csv("~/BHK lab/Ravi/deleted repo/Ravi_version2/Common files/curation_tissue.csv")

#Read curation_tissue.cv file
#TODO : add WOlf to the dafa files
path <- "https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv"
#annotation_tissue<- read.csv(file.path(annot_dir, 'curation_tissue.csv'))
annotation_tissue<- read.csv(path )

clin <- annotate_tissue(clin=clin, study='Wolf', annotation_tissue=annotation_tissue, check_histo=FALSE)

#add column treatment id after tissueid column.
clin <- add_column(clin, treatmentid= clin$Agent_PD1, .after='tissueid')

# Adding drug_type based on treatmentid.
# Print unique values of treatmentid.
print(unique(clin$treatmentid))

#clin$drug_typ<- # TODO: based on Farnoosh chategorization decision on adding chemo

# Print unique values of drugtype
print(unique(clin$drug_type))

# Replace empty string values with NA.
clin[clin == ""] <- NA

# Save the processed data as CLIN.csv file
#write.csv(clin , file=file.path(output_dir, "CLIN.csv") , row.names=TRUE )

file <- "~/BHK lab/ICB_Wolf/data/CLIN.csv"
write.csv(clin, file, row.names = TRUE)



