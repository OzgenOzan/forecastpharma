# Pacman, version 0.4.1 is used to organize the packages used in R.

library(pacman)

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

result_matrix <- matrix(, nrow = 20, ncol = 1149)

for(i in 1:1149){
  
  res_i <- croston(tt[, i], h=8)
    res_i <- append(res_i$x, res_i$mean)
      result_matrix[, i] <- res_i
  
  }

write.table(result_matrix, "resultmatrix.csv", sep = ";")
