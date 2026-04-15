# ============================================
# APPLY FAMILY SOLUTIONS
# Check your answers against these solutions
# ============================================

# Load the messy data
messy <- readRDS("data/messy_transactions.rds")
customers <- readRDS("data/customers.rds")
merchants <- readRDS("data/merchants.rds")

cat("✅ APPLY FAMILY SOLUTIONS\n")
cat("==========================\n\n")

# ============================================
# SOLUTION 1: Fix Amounts with sapply()
# ============================================
cat("SOLUTION 1: Fix mixed amount formats\n")
cat("---------------------------------------\n")

# Using sapply to clean each amount
messy$clean_amount <- sapply(messy$amount, function(x) {
  if(is.character(x)) {
    as.numeric(gsub("R ", "", x))
  } else {
    as.numeric(x)
  }
})

cat("Before cleaning:\n")
cat("  Type:", class(messy$amount[1]), "\n")
cat("  Sample:", head(messy$amount, 3), "\n")
cat("After cleaning:\n")
cat("  Type:", class(messy$clean_amount), "\n")
cat("  Sample:", head(messy$clean_amount, 3), "\n\n")


# ============================================
# SOLUTION 2: Fill Missing Categories with lapply()
# ============================================
cat("SOLUTION 2: Fill missing merchant categories\n")
cat("-----------------------------------------------\n")

# Create lookup vector for fast matching
category_lookup <- merchants$category
names(category_lookup) <- merchants$merchant

# Use lapply to fill missing categories
messy$category_filled <- unlist(lapply(1:nrow(messy), function(i) {
  if(is.na(messy$category[i])) {
    category_lookup[messy$merchant[i]]
  } else {
    messy$category[i]
  }
}))

cat("Missing categories filled:", sum(is.na(messy$category_filled)), "remaining\n\n")


# ============================================
# SOLUTION 3: Standardize Dates with apply()
# ============================================
cat("SOLUTION 3: Standardize date formats\n")
cat("---------------------------------------\n")

# Create a temporary dataframe with date strings
date_df <- data.frame(date_str = as.character(messy$date), stringsAsFactors = FALSE)

# Use apply with MARGIN=1 to process each row
messy$standardized_date <- as.Date(apply(date_df, 1, function(row) {
  date_str <- row["date_str"]
  if(grepl("/", date_str)) {
    as.Date(date_str, format = "%Y/%m/%d")
  } else {
    as.Date(date_str, format = "%Y-%m-%d")
  }
}), origin = "1970-01-01")

cat("Date standardization complete\n")
cat("  Class:", class(messy$standardized_date), "\n")
cat("  Range:", range(messy$standardized_date, na.rm = TRUE), "\n\n")


# ============================================
# SOLUTION 4: Detect Outliers with tapply()
# ============================================
cat("SOLUTION 4: Detect outliers by customer\n")
cat("------------------------------------------\n")

# Calculate mean and SD per customer using tapply
customer_means <- tapply(messy$clean_amount, messy$customer_id, mean, na.rm = TRUE)
customer_sds <- tapply(messy$clean_amount, messy$customer_id, sd, na.rm = TRUE)

# Create lookup vectors
mean_lookup <- customer_means[messy$customer_id]
sd_lookup <- customer_sds[messy$customer_id]

# Flag outliers (> 3 SD above mean)
messy$is_outlier <- messy$clean_amount > (mean_lookup + 3 * sd_lookup)

cat("Outliers detected:", sum(messy$is_outlier, na.rm = TRUE), "transactions\n")
cat("  Percentage:", round(100 * sum(messy$is_outlier, na.rm = TRUE) / nrow(messy), 2), "%\n\n")


# ============================================
# SOLUTION 5: Validate IDs with vapply()
# ============================================
cat("SOLUTION 5: Validate transaction IDs\n")
cat("---------------------------------------\n")

# Validation function
validate_id <- function(id) {
  grepl("^TXN[0-9]{8}$", id)
}

# Use vapply for type-safe validation
validation_results <- vapply(messy$transaction_id, validate_id, logical(1))

cat("Valid IDs:", sum(validation_results), "out of", length(validation_results), "\n")
cat("Invalid IDs:", sum(!validation_results), "\n")

# Find duplicates
duplicate_ids <- messy$transaction_id[duplicated(messy$transaction_id)]
cat("Duplicate IDs found:", length(unique(duplicate_ids)), "\n\n")


# ============================================
# SOLUTION 6: Monthly Changes with mapply()
# ============================================
cat("SOLUTION 6: Calculate monthly spending changes\n")
cat("-------------------------------------------------\n")

# Create month column
messy$month <- format(messy$standardized_date, "%Y-%m")

# Aggregate monthly spending per customer
monthly_agg <- tapply(messy$clean_amount, 
                      list(messy$customer_id, messy$month), 
                      sum, na.rm = TRUE)

# Get a single customer for demo
demo_customer <- rownames(monthly_agg)[1]
demo_spend <- monthly_agg[demo_customer, ]
demo_spend <- demo_spend[!is.na(demo_spend)]

# Calculate month-over-month changes using mapply
if(length(demo_spend) > 1) {
  pct_changes <- mapply(function(current, previous) {
    ((current - previous) / previous) * 100
  }, demo_spend[2:length(demo_spend)], demo_spend[1:(length(demo_spend)-1)])
  
  cat("Demo customer:", demo_customer, "\n")
  cat("Monthly spending:", round(demo_spend, 2), "\n")
  cat("% changes:", round(pct_changes, 2), "%\n\n")
}


# ============================================
# BONUS SOLUTION: Performance Comparison
# ============================================
cat("BONUS: Performance comparison\n")
cat("---------------------------------------\n")

# Create test data
test_vector <- sample(c(1:100, paste0("R ", 1:100)), 10000, replace = TRUE)

# sapply approach
sapply_time <- system.time({
  result_sapply <- sapply(test_vector, function(x) {
    if(is.character(x)) as.numeric(gsub("R ", "", x)) else as.numeric(x)
  })
})

# vapply approach (with template)
vapply_time <- system.time({
  result_vapply <- vapply(test_vector, function(x) {
    if(is.character(x)) as.numeric(gsub("R ", "", x)) else as.numeric(x)
  }, FUN.VALUE = numeric(1))
})

cat("sapply() time:", sapply_time[3], "seconds\n")
cat("vapply() time:", vapply_time[3], "seconds\n")
cat("vapply() is typically faster AND safer!\n\n")

# ============================================
# FINAL SUMMARY
# ============================================
cat("========================================\n")
cat("🎉 APPLY FAMILY MASTERY ACHIEVED!\n")
cat("========================================\n")
cat("\nFunctions used:\n")
cat("  ✓ lapply() - filled missing categories\n")
cat("  ✓ sapply() - cleaned amount formats\n")
cat("  ✓ apply()  - standardized dates row-wise\n")
cat("  ✓ tapply() - detected outliers by group\n")
cat("  ✓ vapply() - validated IDs with type safety\n")
cat("  ✓ mapply() - calculated monthly changes\n")
cat("\nSave your cleaned data:\n")
cat("  saveRDS(messy, 'data/cleaned_transactions.rds')\n")
cat("========================================\n")