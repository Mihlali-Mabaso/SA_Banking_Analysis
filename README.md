# SA Banking Transaction Analysis - Apply Family Mastery

## Project Overview
This project demonstrates mastery of R's apply family functions by processing realistic South African banking transaction data with intentional "messy" data problems.

## Dataset
- **500 customers** with different account types (Gold, Platinum, Student, Basic)
- **10,000 transactions** across 2024
- **South African merchants** (Checkers, Woolworths, Sasol, Nando's, etc.)

## Messy Data Problems Created
1. Mixed amount formats (numeric + "R 123.45" strings)
2. Missing merchant categories
3. Inconsistent date formats
4. Outlier transactions
5. Duplicate transaction IDs

## Apply Family Functions Used
| Function | Use Case |
|----------|----------|
| `lapply()` | Fill missing categories by looking up merchant data |
| `sapply()` | Fix mixed amount formats and extract patterns |
| `apply()` | Row-wise date standardization |
| `tapply()` | Group outliers by customer |
| `vapply()` | Validate transaction ID formats |
| `mapply()` | Calculate monthly spending changes |

## How to Run
```r
# 1. Generate the data
source("generate_data.R")

# 2. Try the challenges
source("apply_challenges.R")

# 3. Check solutions
source("apply_solutions.R")