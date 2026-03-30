con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")


AU_decisions <- tbl(con, 'AU_decisions') |> 
  collect()

GNIS_decisions <- tbl(con, 'GNIS_decisions') |> 
  collect()
duckdb::dbDisconnect(con, shutdown=TRUE)




map_display <- AU_decisions |> 
  mutate(final_AU_cat = factor(final_AU_cat, 
                               levels=c('Unassessed', '3D',"3", "3B","3C", "2", "5",'5C', '4A', '4B', '4C'), ordered=TRUE)) |> 
  mutate(pollutant_strd = case_when(!is.na(period) ~ paste0(Char_Name, "- ", period),
                                    wqstd_code == 15 ~  paste0(Char_Name, "- Aquatic Life Toxics"),
                                    wqstd_code == 16 ~  paste0(Char_Name, "- Human Health Toxics"),
                                    TRUE ~ Char_Name
  )) |> 
  group_by(AU_ID) %>%
  summarise(AU_status = case_when(any(str_detect(final_AU_cat, '5') | str_detect(final_AU_cat, '4') | str_detect(final_AU_cat, '5C'))~ 'Impaired',
                                  any(str_detect(final_AU_cat, '2')) ~ "Attaining",
                                  all(str_detect(final_AU_cat, '3')) ~ "Insufficient Data",
                                  TRUE ~ "ERROR"),
            year_last_assessed = max(year_last_assessed, na.rm = TRUE),
            Year_listed = ifelse(AU_status == 'Impaired', as.integer(min(Year_listed),  na.rm = TRUE), NA_integer_ ) ,
            Cat_5_count = length(pollutant_strd[final_AU_cat == '5' | final_AU_cat == '5C']),
            Cat_4_count = length(pollutant_strd[str_detect(final_AU_cat, '4')]),
            Impaired_count = Cat_5_count + Cat_4_count,
            Impaired_parameters = str_flatten(unique(pollutant_strd[!is.na(final_AU_cat) & (str_detect(final_AU_cat, '5') | str_detect(final_AU_cat, '4'))]), ", "),
            Cat_5_parameters =   str_flatten(unique(pollutant_strd[!is.na(final_AU_cat) & (str_detect(final_AU_cat, '5') )]), ", "),
            Cat_4_parameters =  str_flatten(unique(pollutant_strd[!is.na(final_AU_cat) & (str_detect(final_AU_cat, '4') )]), ", "),
            Cat_2_count = length(pollutant_strd[final_AU_cat == '2']),
            Attaining_parameters = str_flatten(unique(pollutant_strd[!is.na(final_AU_cat) & final_AU_cat == '2']), ", "),
            Cat_3_count = length(pollutant_strd[final_AU_cat == '3']),
            Cat_3B_count = length(pollutant_strd[final_AU_cat == '3B']),
            Cat_3D_count = length(pollutant_strd[final_AU_cat == '3D']),
            Cat_3_count_total = sum(Cat_3_count, Cat_3B_count, Cat_3D_count),
            Insufficient_parameters = str_flatten(unique(pollutant_strd[!is.na(final_AU_cat) & str_detect(final_AU_cat, '3')]), ", ")
  )

map_display_GNIS <- GNIS_decisions |> 
  mutate(final_GNIS_cat = factor(final_GNIS_cat, 
                                 levels=c('Unassessed', '3D',"3", "3B","3C", "2", "5",'5C', '4A', '4B', '4C'), ordered=TRUE)) |> 
  mutate(pollutant_strd = case_when(!is.na(period) ~ paste0(Char_Name, "- ", period),
                                    wqstd_code == 15 ~  paste0(Char_Name, "- Aquatic Life Toxics"),
                                    wqstd_code == 16 ~  paste0(Char_Name, "- Human Health Toxics"),
                                    TRUE ~ Char_Name
  )) |> 
  group_by(AU_ID, AU_GNIS_Name) %>%
  summarise(AU_status = case_when(any(str_detect(final_GNIS_cat, '5') | str_detect(final_GNIS_cat, '4')| str_detect(final_GNIS_cat, '5C'))~ 'Impaired',
                                  any(str_detect(final_GNIS_cat, '2')) ~ "Attaining",
                                  all(str_detect(final_GNIS_cat, '3')) ~ "Insufficient Data",
                                  TRUE ~ "ERROR"),
            #year_last_assessed = max(year_last_assessed, na.rm = TRUE),
            #Year_listed = ifelse(AU_status == 'Impaired', as.integer(min(Year_listed),  na.rm = TRUE), NA_integer_ ) ,
            Cat_5_count = length(pollutant_strd[final_GNIS_cat == '5' | final_GNIS_cat == '5C']),
            Cat_4_count = length(pollutant_strd[str_detect(final_GNIS_cat, '4')]),
            Impaired_count = Cat_5_count + Cat_4_count,
            Impaired_parameters = str_flatten(unique(pollutant_strd[!is.na(final_GNIS_cat) & (str_detect(final_GNIS_cat, '5') | str_detect(final_GNIS_cat, '4'))]), ", "),
            Cat_5_parameters =  str_flatten(unique(pollutant_strd[!is.na(final_GNIS_cat) & (str_detect(final_GNIS_cat, '5'))]), ", "),
            Cat_4_parameters =  str_flatten(unique(pollutant_strd[!is.na(final_GNIS_cat) & (str_detect(final_GNIS_cat, '4'))]), ", "),
            Cat_2_count = length(pollutant_strd[final_GNIS_cat == '2']),
            Attaining_parameters = str_flatten(unique(pollutant_strd[!is.na(final_GNIS_cat) & final_GNIS_cat == '2']), ", "),
            Cat_3_count = length(pollutant_strd[final_GNIS_cat == '3']),
            Cat_3B_count = length(pollutant_strd[final_GNIS_cat == '3B']),
            Cat_3D_count = length(pollutant_strd[final_GNIS_cat == '3D']),
            Cat_3_count_total = sum(Cat_3_count, Cat_3B_count, Cat_3D_count),
            Insufficient_parameters = str_flatten(unique(pollutant_strd[!is.na(final_GNIS_cat) & str_detect(final_GNIS_cat, '3')]), ", ")
  )



# Write table -------------------------------------------------------------

library(openxlsx)

table_list <- list('map_display' = map_display,
                   'map_display_GNIS' = map_display_GNIS)


write.xlsx(table_list, "internal_review_map_display.xlsx")
