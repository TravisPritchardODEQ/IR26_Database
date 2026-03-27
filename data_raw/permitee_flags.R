library(tidyverse)
library(DBI)
library(openxlsx)
library(duckdb)


# Get list of permittee organizations -------------------------------------


Permittee_orgs <- read.xlsx('data_raw/Permittees.xlsx',
                            sheet = 'Permittees')


# Get Org/param combos --------------------------------------------------------------------------------------------

con <- DBI::dbConnect(odbc::odbc(), "IR_Dev")


org_param <- tbl(con, "InputRaw") |> 
  select(AU_ID, OrganizationID, Pollu_ID, wqstd_code) |> 
  distinct() |> 
  collect()

DBI::dbDisconnect(con)
# Combine -----------------------------------------------------------------

permitting_data <- org_param |>
  filter(OrganizationID %in% Permittee_orgs$OrganizationID) |> 
  mutate(permittee = TRUE) |> 
  group_by(AU_ID, Pollu_ID, wqstd_code) |> 
  summarise(permittee = case_when(any(permittee == TRUE) ~ TRUE,
                                 TRUE ~ FALSE),
            permittee_orgs = stringr::str_c(unique(OrganizationID), collapse = "; "),) |> 
  mutate(Pollu_ID = as.character(Pollu_ID),
         wqstd_code = as.character(wqstd_code))
  


save(permitting_data, file = 'data/permitting_data.Rdata')


# join ------------------------------------------------------------------------------------------------------------


con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")

dec <- tbl(con, 'AU_decisions') |> 
  collect() |> 
  left_join(permitting_data) |> 
  mutate(permittee = case_when(is.na(permittee) ~ FALSE,
                              TRUE ~ permittee ))

dbWriteTable(con, "AU_decisions", dec, overwrite = TRUE)
duckdb::dbDisconnect(con, shutdown=TRUE)

