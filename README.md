# labelandforecastpharma

I am working on a project regarding demand forecasting for pharmaceuticals.

The raw import data which used includes information of; import dates, labels of active pharmaceutical ingredient (Product Code), and quantities in an excel table. For example:

| Import Date | Product Code | Quantity |
|-------------|--------------|----------|
| 14/09/2018  |       1      |    300   |
| 18/06/2019  |       1      |   9400   |
| 18/06/2019  |       1      |   5430   |
| 05/06/2019  |       2      |   7000   |
| 17/09/2018  |       3      |   2300   |

First of all i need to merge the same dated and same labelled entries, for example, there is only one importation on 18/06/2019 for product labelled as "1". Also i need to convert the data frame to time series, sorted by dates and with 'Product Code' as a character and 'Quantity' as numeric.

```

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

```

Since croston method for forecasting is valid for intermittent demand. I've to organize the data according to infrequently imported pharmaceuticals and frequently imported pharmaceuticals. And for the frequent ones, i should find a suitable method for forecasting.


