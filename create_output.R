# ============================================
# CREATE OUTPUT FILES
# Run this AFTER your solutions
# ============================================

# Load cleaned data (assuming you saved it)
if(!exists("messy")) {
  messy <- readRDS("data/messy_transactions.rds")
}

# Create output folder if it doesn't exist
if(!dir.exists("output")) dir.create("output")

cat("📊 Generating output files...\n")

# 1. Save cleaned version
saveRDS(messy, "output/cleaned_transactions.rds")
cat("  ✓ Cleaned data saved\n")

# 2. Create customer summary using apply functions
customers_unique <- unique(messy$customer_id)
customer_summary <- data.frame(
  customer_id = customers_unique,
  total_spend = sapply(customers_unique, function(id) {
    sum(messy$clean_amount[messy$customer_id == id], na.rm = TRUE)
  }),
  avg_spend = sapply(customers_unique, function(id) {
    mean(messy$clean_amount[messy$customer_id == id], na.rm = TRUE)
  }),
  transaction_count = sapply(customers_unique, function(id) {
    sum(messy$customer_id == id)
  })
)
write.csv(customer_summary, "output/customer_summary.csv", row.names = FALSE)
cat("  ✓ Customer summary saved\n")

# 3. Category summary using tapply
category_summary <- data.frame(
  category = names(tapply(messy$clean_amount, messy$category, sum)),
  total = tapply(messy$clean_amount, messy$category, sum),
  avg = tapply(messy$clean_amount, messy$category, mean),
  count = tapply(messy$clean_amount, messy$category, length)
)
write.csv(category_summary, "output/category_summary.csv", row.names = FALSE)
cat("  ✓ Category summary saved\n")

# 4. Text report
sink("output/summary_report.txt")
cat("========================================\n")
cat("SA BANKING ANALYSIS REPORT\n")
cat("========================================\n\n")
cat("Generated:", date(), "\n\n")
cat("DATA OVERVIEW\n")
cat("  Total transactions:", nrow(messy), "\n")
cat("  Total customers:", length(unique(messy$customer_id)), "\n")
cat("  Date range:", min(messy$standardized_date, na.rm = TRUE), 
    "to", max(messy$standardized_date, na.rm = TRUE), "\n\n")
cat("FINANCIAL SUMMARY\n")
cat("  Total spend: R", format(sum(messy$clean_amount, na.rm = TRUE), 
                               big.mark = ",", digits = 2), "\n")
cat("  Average transaction: R", format(mean(messy$clean_amount, na.rm = TRUE), 
                                       digits = 2), "\n")
cat("  Median transaction: R", format(median(messy$clean_amount, na.rm = TRUE), 
                                      digits = 2), "\n\n")
cat("DATA QUALITY\n")
cat("  Missing categories filled:", sum(is.na(messy$category_filled)), "\n")
cat("  Outliers detected:", sum(messy$is_outlier, na.rm = TRUE), "\n")
cat("  Invalid IDs:", sum(!grepl("^TXN[0-9]{8}$", messy$transaction_id)), "\n")
sink()
cat("  ✓ Text report saved\n")

# 5. Create a simple bar plot
png("output/spending_by_category.png", width = 800, height = 500)
category_totals <- tapply(messy$clean_amount, messy$category, sum)
barplot(sort(category_totals, decreasing = TRUE), 
        main = "Total Spending by Category",
        xlab = "Category", ylab = "Total Spend (R)",
        las = 2, cex.names = 0.8,
        col = "steelblue")
dev.off()
cat("  ✓ Plot saved\n\n")

cat("✅ OUTPUT FOLDER POPULATED!\n")
cat("Check the 'output' folder for:\n")
cat("  - cleaned_transactions.rds\n")
cat("  - customer_summary.csv\n")
cat("  - category_summary.csv\n")
cat("  - summary_report.txt\n")
cat("  - spending_by_category.png\n")