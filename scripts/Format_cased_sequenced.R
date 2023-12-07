# File: Format_cased_sequnced.R
# Goal: Save cased_sequenced.csv

# Load the clinical merged data from the specified file path.
clin_path <- "~/BHK lab/ICB_Wolf/data/CLIN.txt"
clin <- read.table(clin_path, sep="\t", header=TRUE)
colnames(clin)[colnames(clin) == "Patient.Identifier"] <- "patient"

# Extract unique patients and sort them.
patient <- sort(unique(clin$patient))

# Initialize a data frame for 'case' with the unique patients and default values
case <- as.data.frame(cbind(patient, rep(0, length(patient)), rep(0, length(patient)), rep(0, length(patient))))
colnames(case) <- c("patient", "snv", "cna", "expr")
rownames(case) <- patient

# Convert the case values to numeric.
case$snv <- as.numeric(as.character(case$snv))
case$cna <- as.numeric(as.character(case$cna))
case$expr <- as.numeric(as.character(case$expr))

# Load the RNA data
expr_path <- "~/BHK lab/ICB_Wolf/data/EXPR.txt.gz"
expr <- read.csv(expr_path, stringsAsFactors=FALSE , sep="\t", check.names = FALSE)

# Check for any duplicate column names after renaming
duplicate_colnames <- colnames(expr)[duplicated(colnames(expr))]
print(duplicate_colnames)  # Should print nothing ideally

# Sort the row names of 'expr'
expr <- expr[sort(rownames(expr)),]

# Check the overlap of patient IDs between the 'case' and 'expr' data
sum(rownames(case) %in% colnames(expr))

# Update the 'expr' column in 'case' based on the presence of patient IDs in the 'expr' data
for(i in 1:nrow(case)) {
  if(rownames(case)[i] %in% colnames(expr)) {
    case$expr[i] = 1
  }
}

#TODO: case with two 629606?
# Identify different names
different_names <- colnames(expr)[!colnames(expr) %in% rownames(case)]
print(different_names) # "629606.GPL16233" "629606.GPL20078"

different_names2 <- rownames(case)[!rownames(case) %in% colnames(expr)]
print(different_names2) # "629606"

# Save the updated 'case' data frame to a CSV file.
path_case <- "~/BHK lab/ICB_Wolf/data/cased_sequenced.csv"
write.table( case , path_case , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )
