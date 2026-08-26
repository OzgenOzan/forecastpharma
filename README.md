# Forecasting Pharmaceutical Products with intermittent demand

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

## Code

The full script lives in [`forecastpharma.R`](forecastpharma.R) (previously the entire script was duplicated in this README; the copy was removed to avoid drift).

## Data

- `filename.xlsx`: 12,710 import records, 489 unique product codes, covering 2018-01-05 to 2020-12-11 (12 quarters).
- **Provenance / terms:** the source of this import data is not documented in this repository. The owner should confirm the rights to publish/redistribute this dataset; if that is not possible, it should be replaced with a synthetic sample.

## Dependencies

R (developed on R 4.1). Packages: readxl, readr, ggplot2, forecast, fpp3, tidyverse, TTR, tibble, tsibble, tsibbledata, feasts, fable, dplyr, zoo, lubridate, janitor, xts — loaded via `pacman::p_load`, which installs the **latest** CRAN versions at run time (unpinned). After running, capture `sessionInfo()` and record the output, or adopt `renv` for version pinning.

## Output format

`resultmatrix.csv` (semicolon-separated):

- **Columns:** one per product, labeled with the product code.
- **Rows 1–12:** observed quarterly totals, labeled with the quarter (e.g. `2018`, `2018.25`, ...).
- **Rows 13–20:** 8-quarter-ahead Croston forecasts, labeled `forecast_1` … `forecast_8`.

## Status / disclaimer

The forecasts are exploratory and **unvalidated**: there is no train/test split, no accuracy evaluation, no benchmark comparison, and Croston is applied to all series including non-intermittent ones. See [issue #1](../../issues/1) before using any output.

Since croston method for forecasting is valid for intermittent demand. I've to organize the data according to infrequently imported pharmaceuticals and frequently imported pharmaceuticals. And for the frequent ones, i should find a suitable method for forecasting.
