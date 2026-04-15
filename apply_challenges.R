# ============================================
# APPLY FAMILY CHALLENGES
# Solve these using ONLY apply family functions
# No for loops, no dplyr (for learning purposes)
# ============================================

# Load the messy data
messy <- readRDS("data/messy_transactions.rds")
customers <- readRDS("data/customers.rds")
merchants <- readRDS("data/merchants.rds")

cat("🔧 APPLY FAMILY CHALLENGES\n")
cat("==========================\n\n")

# ============================================
# CHALLENGE 1: Fix Amounts with sapply()
# ============================================
cat("CHALLENGE 1: Fix mixed amount formats\n")
cat("---------------------------------------\n")
cat("Problem: Some amounts are numeric, others are 'R 123.45'\n")
cat("Task: Create a clean_amount column (all numeric)\n")
cat("Hint: Use sapply() with grepl() and gsub()\n\n")

# YOUR CODE HERE:
# messy$clean_amount <- sapply(...)

cat("[Write your solution here]\n\n")


# ============================================
# CHALLENGE 2: Fill Missing Categories with lapply()
# ============================================
cat("CHALLENGE 2: Fill missing merchant categories\n")
cat("-----------------------------------------------\n")
cat("Problem: 200 transactions have NA in category column\n")
cat("Task: Fill missing categories using merchant name lookup\n")
cat("Hint: Use lapply() on the category column, match to merchants dataframe\n\n")

# YOUR CODE HERE:
# messy$category_filled <- lapply(...)

cat("[Write your solution here]\n\n")


# ============================================
# CHALLENGE 3: Standardize Dates with apply() MARGIN=1
# ============================================
cat("CHALLENGE 3: Standardize date formats\n")
cat("---------------------------------------\n")
cat("Problem: Dates are mixed: '2024-01-15' and '2024/01/15'\n")
cat("Task: Create a standardized_date column (all Date objects)\n")
cat("Hint: Use apply() with MARGIN=1, check format with grepl()\n\n")

# YOUR CODE HERE:
# messy$standardized_date <- apply(...)

cat("[Write your solution here]\n\n")


# ============================================
# CHALLENGE 4: Detect Outliers with tapply()
# ============================================
cat("CHALLENGE 4: Detect outliers by customer\n")
cat("------------------------------------------\n")
cat("Problem: Some transactions are 100x normal (outliers)\n")
cat("Task: Flag transactions > 3 SD above customer's mean\n")
cat("Hint: Use tapply() to get means and SDs per customer\n\n")

# YOUR CODE HERE:
# customer_stats <- tapply(...)
# messy$is_outlier <- ...

cat("[Write your solution here]\n\n")


# ============================================
# CHALLENGE 5: Validate IDs with vapply()
# ============================================
cat("CHALLENGE 5: Validate transaction IDs\n")
cat("---------------------------------------\n")
cat("Problem: Duplicate IDs exist, format should be 'TXN' + 8 digits\n")
cat("Task: Create validation function, use vapply() to check all IDs\n")
cat("Hint: Use grepl() with pattern '^TXN[0-9]{8}$'\n\n")

# YOUR CODE HERE:
# validate_id <- function(id) {...}
# validation_results <- vapply(...)

cat("[Write your solution here]\n\n")


# ============================================
# CHALLENGE 6: Monthly Changes with mapply()
# ============================================
cat("CHALLENGE 6: Calculate monthly spending changes\n")
cat("-------------------------------------------------\n")
cat("Problem: Need month-over-month % change per customer\n")
cat("Task: Use mapply() to compare consecutive months\n")
cat("Hint: Create monthly aggregates first, then mapply()\n\n")

# YOUR CODE HERE:
# monthly_spend <- tapply(...)
# pct_changes <- mapply(...)

cat("[Write your solution here]\n\n")


# ============================================
# BONUS CHALLENGE: Performance Comparison
# ============================================
cat("BONUS: Compare sapply() vs vapply()\n")
cat("---------------------------------------\n")
cat("Task: Benchmark both on 10,000 iterations\n")
cat("Which is faster? Which is safer?\n\n")

# YOUR CODE HERE:
# system.time(replicate(10000, sapply(...)))
# system.time(replicate(10000, vapply(...)))

cat("[Write your solution here]\n\n")

cat("========================================\n")
cat("When done, check your answers in apply_solutions.R\n")