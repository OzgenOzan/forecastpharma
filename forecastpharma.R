# Pacman, version 0.4.1 is used to organize the packages used in R.

library(pacman)

# --- Dependencies -------------------------------------------------------------
# p_load() installs the LATEST CRAN versions at run time (unpinned). Developed
# on R 4.1 (2021). Packages: readxl, readr, ggplot2, forecast, fpp3, tidyverse,
# TTR, tibble, tsibble, tsibbledata, feasts, fable, dplyr, zoo, lubridate,
# janitor, xts.
# After running p_load, capture your exact environment with `sessionInfo()` and
# record it (e.g. paste the output into an issue or a session-info.txt), or
# adopt `renv` for version pinning.
# ------------------------------------------------------------------------------

p_load(readxl, readr, ggplot2, forecast, fpp3, tidyverse, TTR, tibble, tsibble, tsibbledata, feasts, fable, dplyr, zoo, lubridate, janitor, xts)

# If you are using additional packages, or feel like it, you can use `conflict_scout()` command from *conflicted* package to check conflicts betweeen packages.

dat <- read_xlsx("~/Desktop/filename.xlsx", col_names=T)

# We need to format the 'Import Date' column as Date format (Year/Month), and sort by Date. And also since labeling is done numerically, we need to convert the 'Product Code' column from numeric format to character format in R.

dat <- transform(dat, 'Product Code' = as.character(dat$`Product Code`))

class(dat)

z <- dat %>%
  type.convert(as.is = TRUE) %>%
  read.zoo(format = "%Y-%m-%d", FUN = as.yearqtr, index.column = 1,
           split = "Product.Code", aggregate = sum)

tt <- merge(z, zoo(, seq(start(z), end(z), 1/4))) |>
  as.ts()

tt[is.na(tt)]=0

# Dimensions are derived from the data, not hardcoded (the committed dataset has
# 489 product codes; the previous hardcoded 1149 crashed with "subscript out of
# bounds"). 12 observed quarters + 8 forecast quarters = 20 rows.
h_forecast <- 8                 # forecast horizon in quarters
n_products <- ncol(tt)

result_matrix <- matrix(, nrow = nrow(tt) + h_forecast, ncol = n_products)
colnames(result_matrix) <- colnames(tt)   # product codes as column labels
rownames(result_matrix) <- c(as.character(time(tt)),                    # observed quarters
                             paste0("forecast_", seq_len(h_forecast)))  # forecast rows

for(i in seq_len(n_products)){
  
  res_i <- croston(tt[, i], h = h_forecast)
    res_i <- append(res_i$x, res_i$mean)
      result_matrix[, i] <- res_i
  
  }

write.table(result_matrix, "resultmatrix.csv", sep = ";")
