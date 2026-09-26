# Pacman, version 0.4.1 is used to organize the packages used in R.

library(pacman)

# --- Dependencies -------------------------------------------------------------
# p_load() installs the LATEST CRAN versions at run time (unpinned). Developed
# on R 4.1 (2021). Only packages actually used by this script are loaded
# (FP-2): readxl (read_xlsx), dplyr (%>% / mutate), zoo (read.zoo, zoo,
# as.yearqtr, merge), forecast (croston, ses). The previously loaded packages
# (readr, ggplot2, fpp3, tidyverse, TTR, tibble, tsibble, tsibbledata, feasts,
# fable, lubridate, janitor, xts) were not referenced anywhere in the script.
# For reproducible environments, adopt renv:
#   install.packages("renv"); renv::init(); renv::snapshot()
# and commit the generated renv.lock. Until then, capture your exact
# environment with `sessionInfo()` and record it (e.g. paste the output into
# an issue or a session-info.txt).
# ------------------------------------------------------------------------------

p_load(readxl, dplyr, zoo, forecast)

# If you are using additional packages, or feel like it, you can use `conflict_scout()` command from *conflicted* package to check conflicts betweeen packages.

# --- Input/output paths (FP-1) ------------------------------------------------
# Usage: Rscript forecastpharma.R [input.xlsx] [output.csv]
# Defaults preserve the previous file names, but no longer assume ~/Desktop.
args <- commandArgs(trailingOnly = TRUE)
input_path  <- if (length(args) >= 1) args[[1]] else "filename.xlsx"
output_path <- if (length(args) >= 2) args[[2]] else "resultmatrix.csv"

dat <- read_xlsx(input_path, col_names = TRUE)

# We need to format the 'Import Date' column as Date format (Year/Month), and sort by Date. And also since labeling is done numerically, we need to convert the 'Product Code' column from numeric format to character format in R.
# (modern dplyr equivalent of the deprecated transform() idiom)

dat <- dat %>%
  mutate(`Product Code` = as.character(`Product Code`))

class(dat)

z <- dat %>%
  type.convert(as.is = TRUE) %>%
  read.zoo(format = "%Y-%m-%d", FUN = as.yearqtr, index.column = 1,
           split = "Product.Code", aggregate = sum)

tt <- merge(z, zoo(, seq(start(z), end(z), 1/4))) |>
  as.ts()

tt[is.na(tt)] <- 0

# Dimensions are derived from the data, not hardcoded (the committed dataset has
# 489 product codes; the previous hardcoded 1149 crashed with "subscript out of
# bounds"). 12 observed quarters + 8 forecast quarters = 20 rows.
h_forecast <- 8                 # forecast horizon in quarters
n_products <- ncol(tt)

result_matrix <- matrix(, nrow = nrow(tt) + h_forecast, ncol = n_products)
colnames(result_matrix) <- colnames(tt)   # product codes as column labels
rownames(result_matrix) <- c(as.character(time(tt)),                    # observed quarters
                             paste0("forecast_", seq_len(h_forecast)))  # forecast rows

# --- Croston applicability guard (FP-3) ---------------------------------------
# Croston's method is designed for *intermittent* demand. Applying it to
# smooth/regular series is not meaningful, so we compute the mean inter-demand
# interval (IDI) per series and only route intermittent series to Croston.
# Heuristic: IDI >= 1.32 indicates intermittent demand per the Syntetos-Boylan
# categorization (Syntetos & Boylan, 2005, International Journal of
# Forecasting; the 1.32 cutoff is a widely used heuristic, NOT a threshold
# validated on this dataset — methodology validation remains tracked in
# issue #1). Non-intermittent series fall back to forecast::ses()
# (simple exponential smoothing), a conservative baseline.
IDI_THRESHOLD <- 1.32

for(i in seq_len(n_products)){

  series_i <- as.numeric(tt[, i])
  demand_idx <- which(series_i != 0)
  # Series with fewer than two demand occurrences cannot have a meaningful IDI;
  # treat them as intermittent and keep Croston.
  idi <- if (length(demand_idx) < 2) Inf else mean(diff(demand_idx))

  if (idi < IDI_THRESHOLD) {
    message(sprintf("Series %s: mean inter-demand interval %.2f < %.2f; not intermittent, using forecast::ses() fallback.",
                    colnames(tt)[i], idi, IDI_THRESHOLD))
    fit_i <- forecast::ses(series_i, h = h_forecast)
    res_i <- c(series_i, as.numeric(fit_i$mean))
  } else {
    res_i <- croston(tt[, i], h = h_forecast)
    res_i <- c(as.numeric(res_i$x), as.numeric(res_i$mean))
  }

  result_matrix[, i] <- res_i

}

write.table(result_matrix, output_path, sep = ";")
