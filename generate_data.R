install.packages("tidyverse")
install.packages("lubridate")

library(tidyverse)  # For data manipulation (optional but helpful)
library(lubridate)  # For dates

# For reproducibility
set.seed(2024)  # So you get the same "random" results each time

#Create data directory if it does not exist
if(!dir.exists("data"))
  dir.create("data")
if (!dir.exists("output")) dir.create("output")

cat("🔨 Generating SA Banking Data...\n")
# ============================================
# STEP 1: Generate Customer Base
# ============================================
cat("  📋 Creating 500 customers...\n")

customers <- data.frame(
  customer_id = paste0("SA", sprintf("%05d", 1:500)),
  first_name = sample(c("Thabo", "Lerato", "Sipho", "Nomsa", "Johan", 
                        "Maria", "Ahmed", "Priya", "Michael", "Fatima",
                        "David", "Sarah", "Kevin", "Lisa", "Thando"), 500, replace = TRUE),
  last_name = sample(c("Nkosi", "Naidoo", "Van der Merwe", "Petersen", 
                       "Govender", "Dlamini", "Smith", "Patel", "Coetzee",
                       "Jacobs", "Williams", "Brown", "Jones"), 500, replace = TRUE),
  account_type = sample(c("Gold", "Platinum", "Student", "Basic"), 500, replace = TRUE, 
                        prob = c(0.2, 0.1, 0.3, 0.4)),
  join_date = sample(seq.Date(as.Date("2015-01-01"), as.Date("2024-12-01"), by = "month"), 500, replace = TRUE),
  stringsAsFactors = FALSE
)

# ============================================
# STEP 2: Define South African Merchants
# ============================================
cat("  🏪 Creating merchant database...\n")

merchants <- list(
  Groceries = c("Checkers", "Woolworths", "Pick n Pay", "Spar", "Food Lover's Market"),
  Fuel = c("Sasol", "Engen", "BP", "Shell", "TotalEnergies"),
  Retail = c("Game", "Makro", "Edgars", "Foschini", "Mr Price", "Woolworths"),
  Dining = c("Nando's", "Steers", "Ocean Basket", "Spur", "KFC", "McDonald's"),
  Health = c("Dis-Chem", "Clicks", "Mediclinic"),
  Transport = c("Gautrain", "Uber SA", "Bolt", "Metrorail"),
  Utilities = c("Eskom", "City of Cape Town", "Rand Water", "Telkom"),
  Insurance = c("OUTsurance", "Discovery", "Momentum", "Sanlam"),
  Entertainment = c("Ster-Kinekor", "MultiChoice", "Showmax", "TicketPro")
)

merchant_df <- data.frame(
  merchant = unlist(merchants),
  category = rep(names(merchants), times = sapply(merchants, length)),
  stringsAsFactors = FALSE
)

# ============================================
# STEP 3: Generate Clean Transactions
# ============================================
cat("  💰 Generating 10,000 transactions...\n")

n_transactions <- 10000

# Sample customers
transaction_customers <- sample(customers$customer_id, n_transactions, replace = TRUE)

# Get account types for amount calculation
account_types <- customers$account_type[match(transaction_customers, customers$customer_id)]

# Generate amounts based on account type (log-normal distribution for realistic spending)
amount <- round(case_when(
  account_types == "Gold" ~ rlnorm(n_transactions, meanlog = 5.5, sdlog = 0.6),     # ~ R245 avg
  account_types == "Platinum" ~ rlnorm(n_transactions, meanlog = 6.0, sdlog = 0.7), # ~ R403 avg
  account_types == "Student" ~ rlnorm(n_transactions, meanlog = 4.0, sdlog = 0.5),   # ~ R55 avg
  account_types == "Basic" ~ rlnorm(n_transactions, meanlog = 4.5, sdlog = 0.6)      # ~ R90 avg
), 2)

# Sample merchants
selected_merchants <- sample(merchant_df$merchant, n_transactions, replace = TRUE)
categories <- merchant_df$category[match(selected_merchants, merchant_df$merchant)]

# Generate dates across 2024
transaction_dates <- sample(seq.Date(as.Date("2024-01-01"), 
                                     as.Date("2024-12-31"), 
                                     by = "day"), 
                            n_transactions, replace = TRUE)

# Transaction types
trans_types <- sample(c("POS", "Online", "ATM", "Transfer"), 
                      n_transactions, 
                      replace = TRUE,
                      prob = c(0.6, 0.2, 0.15, 0.05))

# Build clean dataframe
clean_transactions <- data.frame(
  transaction_id = paste0("TXN", sprintf("%08d", 1:n_transactions)),
  customer_id = transaction_customers,
  date = transaction_dates,
  amount = amount,
  merchant = selected_merchants,
  category = categories,
  transaction_type = trans_types,
  stringsAsFactors = FALSE
)

# ============================================
# STEP 4: Inject Messy Data Problems
# ============================================
cat("  🐛 Injecting intentional messiness...\n")

messy_transactions <- clean_transactions  # Start with clean copy

# PROBLEM 1: Mixed amount formats (500 transactions with "R " prefix)
set.seed(456)
string_indices <- sample(1:n_transactions, 500)
messy_transactions$amount[string_indices] <- paste0("R ", messy_transactions$amount[string_indices])

# PROBLEM 2: Missing categories (200 transactions)
set.seed(789)
missing_cat_indices <- sample(1:n_transactions, 200)
messy_transactions$category[missing_cat_indices] <- NA

# PROBLEM 3: Inconsistent date formats (100 transactions as YYYY/MM/DD)
set.seed(101)
date_indices <- sample(1:n_transactions, 100)
messy_transactions$date[date_indices] <- format(messy_transactions$date[date_indices], "%Y/%m/%d")

# PROBLEM 4: Outliers (50 transactions with 100x normal amount)
set.seed(112)
outlier_indices <- sample(1:n_transactions, 50)
# Need to handle both numeric and character amounts carefully
numeric_amounts <- as.numeric(gsub("R ", "", messy_transactions$amount[outlier_indices]))
messy_transactions$amount[outlier_indices] <- numeric_amounts * 100

# PROBLEM 5: Duplicate transaction IDs (10 duplicates)
set.seed(131)
dup_indices <- sample(1:n_transactions, 10)
for (i in 1:length(dup_indices)) {
  messy_transactions$transaction_id[dup_indices[i]] <- messy_transactions$transaction_id[dup_indices[1]]
}

# ============================================
# STEP 5: Save All Data
# ============================================
cat("  💾 Saving data files...\n")

saveRDS(customers, "data/customers.rds")
saveRDS(clean_transactions, "data/clean_transactions.rds")
saveRDS(messy_transactions, "data/messy_transactions.rds")
saveRDS(merchant_df, "data/merchants.rds")

# Also save as CSV for easy viewing
write.csv(customers, "data/customers.csv", row.names = FALSE)
write.csv(clean_transactions, "data/clean_transactions.csv", row.names = FALSE)
write.csv(messy_transactions, "data/messy_transactions.csv", row.names = FALSE)
write.csv(merchant_df, "data/merchants.csv", row.names = FALSE)

# ============================================
# STEP 6: Summary Report
# ============================================
cat("\n✅ DATA GENERATION COMPLETE!\n")
cat("========================================\n")
cat("📊 Summary Statistics:\n")
cat("  - Customers:", nrow(customers), "\n")
cat("  - Transactions:", nrow(clean_transactions), "\n")
cat("  - Merchants:", nrow(merchant_df), "\n")
cat("\n🐛 Messy Data Problems Injected:\n")
cat("  - Mixed amount formats (R prefix):", length(string_indices), "rows\n")
cat("  - Missing categories:", length(missing_cat_indices), "rows\n")
cat("  - Inconsistent dates:", length(date_indices), "rows\n")
cat("  - Outliers:", length(outlier_indices), "rows\n")
cat("  - Duplicate IDs:", length(unique(dup_indices)), "duplicates\n")
cat("\n📁 Files saved in /data folder\n")
cat("========================================\n")

source()