library(tidyverse)
library(openxlsx)
library(odeqIRtools)
library(odeqtmdl)
library(duckdb)
source('functions/dup_checks.R')

# 
# filepath <- 'C:/Users/tpritch/OneDrive - Oregon/DEQ - Integrated Report - IR_2026/Code outputs/Draft Outputs/'
# #
# # # Filenames -------------------------------------------------------------------------------------------------------
# #
# bact_coast <- 'bacteria coast contact- 2025-11-25.xlsx'
# bact_fresh <- 'bacteria_freshwater_contact-2025-11-25.xlsx'
# #
# chl <- 'chl-a-2025-12-17.xlsx'
# #
# DO <- 'DO-2025-12-19.xlsx'
# 
# pH <- 'pH-2025-12-02.xlsx'
# #
# temp <- 'temperature-2025-12-30.xlsx'
# #
# tox_al <- 'Tox_AL-2026-01-07.xlsx'
# #
# tox_hh <- 'Tox_HH-2025-12-01.xlsx'
# #
# turb <- 'turbidity-2025-12-04.xlsx'
# 
# biocriteria <- 'biocriteria2025-10-24.xlsx'
# #
# non_R <- 'non_R-2026-01-20.xlsx'
# #
# #
# #
# # # Pull data in ----------------------------------------------------------------------------------------------------
# #
# #
# #
# # ## Bacteria --------------------------------------------------------------------------------------------------------
# #
# #
# #
# au_bact_coast <- read.xlsx(paste0(filepath, bact_coast),
#                            sheet = 'AU_Decisions') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_bact_coast <- read.xlsx(paste0(filepath, bact_coast),
#                              sheet = 'WS GNIS categorization')
# 
# au_bact_fresh <- read.xlsx(paste0(filepath, bact_fresh),
#                            sheet = 'AU_Decisions') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_bact_fresh <- read.xlsx(paste0(filepath, bact_fresh),
#                              sheet = 'WS GNIS categorization') |>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# ## Chl -------------------------------------------------------------------------------------------------------------
# 
# 
# au_chl <- read.xlsx(paste0(filepath, chl),
#                            sheet = 'AU_Decisions')|>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_chl <- read.xlsx(paste0(filepath, chl),
#                              sheet = 'WS GNIS categorization')|>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# ## DO --------------------------------------------------------------------------------------------------------------
# 
# au_do <- read.xlsx(paste0(filepath, DO),
#                     sheet = 'AU_Decisions') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_do <- read.xlsx(paste0(filepath, DO),
#                       sheet = 'WS GNIS categorization')|>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# ## pH --------------------------------------------------------------------------------------------------------------
# 
# au_pH <- read.xlsx(paste0(filepath, pH),
#                    sheet = 'AU_Decisions')|>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_pH <- read.xlsx(paste0(filepath, pH),
#                      sheet = 'WS GNIS categorization') |>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# ## temperature -----------------------------------------------------------------------------------------------------
# 
# 
# au_temp <- read.xlsx(paste0(filepath, temp),
#                    sheet = 'AU_Decisions')|>
#   mutate(Char_Name = 'Temperature, water') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_temp <- read.xlsx(paste0(filepath, temp),
#                      sheet = 'WS_GNIS_categorization')  |>
#   mutate(Char_Name = 'Temperature, water') |>
#   mutate(across(1:24, .fns = as.character))
# 
# ## tox AL -----------------------------------------------------------------------------------------------------
# 
# 
# au_tox_al <- read.xlsx(paste0(filepath, tox_al),
#                      sheet = 'AU_Decisions') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_tox_al <- read.xlsx(paste0(filepath, tox_al),
#                        sheet = 'GNIS_cat')  |>
#   mutate(across(1:25, .fns = as.character))
# 
# ## tox HH -----------------------------------------------------------------------------------------------------
# 
# 
# au_tox_hh <- read.xlsx(paste0(filepath, tox_hh),
#                        sheet = 'AU_Decisions')|>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_tox_hh <- read.xlsx(paste0(filepath, tox_hh),
#                          sheet = 'WS GNIS categorization') |>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# 
# ## turbidity -----------------------------------------------------------------------------------------------------
# 
# 
# au_turb <- read.xlsx(paste0(filepath, turb),
#                        sheet = 'AU_Decisions') |>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_turb <- read.xlsx(paste0(filepath, turb),
#                          sheet = 'WS GNIS categorization') |>
#   mutate(across(1:16, .fns = as.character))
# 
# 
# 
# 
# # Biocriteria -----------------------------------------------------------------------------------------------------
# 
# au_biocriteria <- read.xlsx(paste0(filepath, biocriteria),
#                        sheet = 'AU_Decisions')|>
#   mutate(across(1:22, .fns = as.character))
# 
# gnis_biocriteria <- read.xlsx(paste0(filepath, biocriteria),
#                          sheet = 'WS GNIS categorization') |>
#   mutate(across(1:24, .fns = as.character))
# 
# 
# # # non_R -----------------------------------------------------------------------------------------------------------
# au_nonR <- read.xlsx(paste0(filepath, non_R),
#                             sheet = 'AU_Decisions')|>
#   mutate(across(1:21, .fns = as.character))
# 
# gnis_nonR <- read.xlsx(paste0(filepath, non_R),
#                               sheet = 'WS GNIS categorization') |>
#   mutate(across(1:24, .fns = as.character))
# 
# #
# #
# # # Put all together ------------------------------------------------------------------------------------------------
# #
# #
# AU_decisions <- bind_rows(au_bact_coast, au_bact_fresh, au_chl, au_do, au_pH, au_temp, au_tox_al,
#                           au_tox_hh, au_turb,au_biocriteria,
#                           au_nonR
#                           )
# 
# 
# 
# # initial dup check -------------------------------------------------------
# 
# dup_check <- AU_decisions |>
#   group_by(AU_ID, Char_Name, Pollu_ID, wqstd_code, period) |>
#   filter(n() > 1)
# 
# #all dups had the same AU conclusion
# AU_decisions <- AU_decisions |>
#   group_by(AU_ID, Char_Name, Pollu_ID, wqstd_code, period) |>
#   filter(row_number() == 1)
# 
# 
# #
# #
# #
# # # Get unassessed pollutants to move forward -----------------------------------------------------------------------
# #
# #
# #
# assessed_polluids <- unique(AU_decisions$Pollu_ID)
# 
# 
# 
# unassessed_params <- odeqIRtools::prev_list_AU |>
#   filter(!Pollu_ID %in% assessed_polluids) |>
#   rename(Char_Name = Pollutant) |>
#   mutate(final_AU_cat = prev_category,
#          Rationale = prev_rationale,
#          status_change = "No change in status- No new assessment") |>
#   join_TMDL(type = 'AU')
# 
# AU_decisions_joined <- AU_decisions |>
#   bind_rows(unassessed_params)
# 
# #
# #
# # # Missing----------------------------------------------------------------------------------------------------
# #
# antijoin <- odeqIRtools::prev_list_AU |>
#   anti_join(AU_decisions_joined, by = join_by(AU_ID, Pollu_ID, wqstd_code, period)) |>
#   rename(Char_Name = Pollutant) |>
#   mutate(final_AU_cat = prev_category,
#          Rationale = prev_rationale,
#          status_change = "No change in status- No new assessment") |>
#   join_TMDL(type = 'AU')
# 
# 
# AU_decisions_joined <- AU_decisions_joined |>
#   bind_rows(antijoin)
# 
# 
# dup_check(AU_decisions_joined)
# #
# #
# #
# #
# # pollutant rename ------------------------------------------------------------------------------------------------
# #open connection to database
# con <- DBI::dbConnect(odbc::odbc(), 'IR_Dev')
# 
# 
# db_qry <- glue::glue_sql( "SELECT distinct [Pollu_ID]
#       ,[Pollutant_DEQ WQS] as Char_Name
#   FROM [IntegratedReport].[dbo].[LU_Pollutant]", .con = con)
# 
# # Send query to database and return with the data
# Char_rename <-  DBI::dbGetQuery(con, db_qry)
# 
# Char_rename <- Char_rename |>
#   mutate(Pollu_ID = as.character(Pollu_ID))
# 
# 
# 
# AU_decisions <- AU_decisions_joined |>
#   select(-Char_Name) |>
#   left_join(Char_rename) |>
#   relocate(Char_Name, .after = AU_ID)|>
#   select(-AU_Name, -AU_UseCode, -HUC12) |>
#   join_AU_info() |>
#   join_hucs() |>
#   arrange(AU_ID, Char_Name)
# 
# 
# dup_check(AU_decisions)
# 
# 
# #
# # # Get assessment labels -------------------------------------------------------------------------------------------
# con <- DBI::dbConnect(odbc::odbc(), 'IR_Dev')
# 
# 
# wqstd_info <- tbl(con, "LU_Wqstd_Code") |>
#   collect() |>
#   mutate(wqstd_code = as.character(wqstd_code) ) |>
#   rename('Assessment' = 'wqstd')
# 
# DBI::dbDisconnect(con)
# 
# AU_decisions <- AU_decisions |>
#   left_join(wqstd_info) |>
#   relocate(Assessment, .after = Char_Name)
# 
# 
# dup_check(AU_decisions)
# 
# 
# # Write duckdb database -------------------------------------------------------------------------------------------
# 
# 
# con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")
# dbWriteTable(con, "AU_decisions", AU_decisions, overwrite = TRUE)
# duckdb::dbDisconnect(con, shutdown=TRUE)
# 
# # GNIS ------------------------------------------------------------------------------------------------------------
# 
# GNIS_Decisions <- bind_rows(gnis_bact_fresh, gnis_biocriteria, gnis_chl, gnis_do, gnis_nonR,
#                             gnis_pH, gnis_temp, gnis_tox_al, gnis_tox_hh, gnis_turb)
# 
# 
# dups <- dup_check_GNIS(GNIS_Decisions)
# 
# GNIS_Decisions <- GNIS_Decisions |>
#   group_by(AU_ID, AU_GNIS_Name, Char_Name, Pollu_ID, wqstd_code, period) |>
#   filter(row_number() == 1) |>
#   ungroup()
# 
# ## Get unassessed pollutants to move forward -----------------------------------------------------------------------
# 
# 
# 
# assessed_polluids <- GNIS_Decisions$Pollu_ID
# 
# 
# 
# unassessed_params <- odeqIRtools::prev_list_GNIS |>
#   filter(!Pollu_ID %in% assessed_polluids) |>
#   rename(Char_Name = Pollutant) |>
#   mutate(final_GNIS_cat = prev_GNIS_category,
#          Rationale_GNIS = prev_GNIS_rationale,
#          status_change = "No change in status- No new assessment") |>
#   join_TMDL(type = 'GNIS')
# #
# GNIS_decisions <- GNIS_Decisions |>
#   bind_rows(unassessed_params)
# 
# dup_check_GNIS(GNIS_decisions)
# 
# #
# #
# antijoin2 <- odeqIRtools::prev_list_GNIS |>
#   anti_join(GNIS_decisions, by = join_by(AU_ID, Pollu_ID, wqstd_code, period)) |>
#   filter(!(Pollu_ID == 79 & wqstd_code == 15)) |>
#   rename(Char_Name = Pollutant) |>
#   mutate(final_GNIS_cat = prev_GNIS_category,
#          Rationale_GNIS = prev_GNIS_rationale,
#          status_change = "No change in status- No new assessment") |>
#   join_TMDL(type = 'GNIS')
# #
# #
# GNIS_decisions <- GNIS_Decisions |>
#   bind_rows(antijoin2)
# 
# dup_check_GNIS(GNIS_decisions)
# 
# 
# con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")
# dbWriteTable(con, "GNIS_decisions", GNIS_decisions, overwrite = TRUE)
# dbDisconnect(con, shutdown=TRUE)



Basins <- read.xlsx('data_raw/AU_2_Basin.xlsx') |>
  distinct()


# Get conclusions from rollup ---------------------------------------------

AU_decisions_import <- read.xlsx("C:/Users/tpritch/OneDrive - Oregon/DEQ - Integrated Report - IR_2026/Draft IR/Public_draft/IR_2026_Draft_Rollup-2026-03-30.xlsx",
                          sheet = 'AU_decisions')


GNIS_decisions <-  read.xlsx("C:/Users/tpritch/OneDrive - Oregon/DEQ - Integrated Report - IR_2026/Draft IR/Public_draft/IR_2026_Draft_Rollup-2026-03-30.xlsx",
                          sheet = 'GNIS_decisions')


AU_decisions <- AU_decisions_import |>
  left_join(Basins, relationship = "many-to-many") |>
  relocate(any_of(c('AU_UseCode', 'HUC12', 'Pollu_ID', 'wqstd_code')), .after = last_col()) |>
  relocate(Assessment, .after = 'AU_Name' ) |>
  relocate(status_change, .after = Rationale) |>
  select(-recordID) |>
  mutate(Pollu_ID = as.character(Pollu_ID),
         wqstd_code = as.character(wqstd_code)
  )

# Write duckdb database -------------------------------------------------------------------------------------------


con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")
dbWriteTable(con, "AU_decisions", AU_decisions, overwrite = TRUE)
dbWriteTable(con, "GNIS_decisions", GNIS_decisions, overwrite = TRUE)
duckdb::dbDisconnect(con, shutdown=TRUE)
# 

# Prep_nesting ----------------------------------------------------------------------------------------------------
source('functions/nesting_functions.R')

con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")

AU_decisions <- tbl(con, 'AU_decisions') |>
  collect()

GNIS_decisions <- tbl(con, 'GNIS_decisions') |>
  collect()
dbDisconnect(con, shutdown=TRUE)


nested <-  create_nested_exam_table(AU_decisions,GNIS_decisions, joinby = c('AU_ID', 'Pollu_ID', 'wqstd_code', 'period'))

nest_data <- nested |>
  select(AU_ID, Pollu_ID, wqstd_code, period, `_details`)


save(nest_data, file = 'data/nest_data.Rdata')
load('data/nest_data.Rdata')

