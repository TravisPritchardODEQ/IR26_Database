library(tidyverse)
library(openxlsx)
library(odeqIRtools)
library(odeqtmdl)
library(duckdb)




filepath <- 'C:/Users/tpritch/OneDrive - Oregon/DEQ - Integrated Report - IR_2026/Code outputs/Draft Outputs/'

# Filenames -------------------------------------------------------------------------------------------------------

bact_coast <- 'bacteria coast contact- 2026-03-17.xlsx'
bact_fresh <- 'bacteria_freshwater_contact-2026-01-21.xlsx'

chl <- 'chl-a-2025-12-17.xlsx'

DO <- 'DO-2025-12-19.xlsx'

pH <- 'pH-2025-12-02.xlsx'

temp <- 'temperature-2025-12-30.xlsx'

tox_al <- 'Tox_AL-2026-01-07.xlsx'

tox_hh <- 'Tox_HH-2025-12-01.xlsx'

turb <- 'turbidity-2025-12-04.xlsx'

biocriteria <- 'biocriteria2026-01-20-updated_post_review.xlsx'

non_R <- 'non_R-2026-01-20.xlsx'


## Bacteria --------------------------------------------------------------------------------------------------------



bact_coast_Coast_Contact_Raw_Data <- read.xlsx(paste0(filepath, bact_coast),
                                               sheet = 'Coast Contact Raw Data')

bact_coast_Coast_Contact_WS_Data <- read.xlsx(paste0(filepath, bact_coast),
                                              sheet = 'Coast Contact WS Data')

bact_coast_Coast_Contact_other_Data <- read.xlsx(paste0(filepath, bact_coast),
                                                 sheet = 'Coast Contact other Data')


# fresh -----------------------------------------------------------------------------------------------------------


bact_fresh_Fresh_Bacteria_Data_WS<- read.xlsx(paste0(filepath, bact_fresh),
                                              sheet = 'Fresh Bacteria Data_WS')

bact_fresh_Fresh_Bacteria_Data_other<- read.xlsx(paste0(filepath, bact_fresh),
                                                 sheet = 'Fresh Bacteria Data_other')

bact_fresh_Fresh_Entero_Bact_Data_other<- read.xlsx(paste0(filepath, bact_fresh),
                                                    sheet = 'Fresh Entero Bact Data_other')

bact_fresh_Fresh_Entero_Bact_Data_WS<- read.xlsx(paste0(filepath, bact_fresh),
                                                 sheet = 'Fresh Entero Bact Data_WS')


# chl -------------------------------------------------------------------------------------------------------------


Chl_a_Raw_Data <- read.xlsx(paste0(filepath, chl),
                            sheet = 'Chl-a Raw Data')


Chl_a_WS_Data<- read.xlsx(paste0(filepath, chl),
                          sheet = 'Chl-a WS Data')
Chl_a_other_Data<- read.xlsx(paste0(filepath, chl),
                             sheet = 'Chl-a other Data')


# DO --------------------------------------------------------------------------------------------------------------

DO_Data_Inst_yearround<- read.xlsx(paste0(filepath, DO),
                                   sheet = 'DO Data Inst yearround')

DO_Data_Cont_yearround <- read.xlsx(paste0(filepath, DO),
                                    sheet = 'DO Data Cont yearround')

DO_Data_Inst_spawn <- read.xlsx(paste0(filepath, DO),
                                sheet = 'DO Data Inst spawn')

DO_Data_Cont_spawn <- read.xlsx(paste0(filepath, DO),
                                sheet = 'DO Data Cont spawn')



# pH --------------------------------------------------------------------------------------------------------------

pH_WS_Data <- read.xlsx(paste0(filepath, pH),
                        sheet = 'pH WS Data')

pH_other_Data <- read.xlsx(paste0(filepath, pH),
                           sheet = 'pH other Data')


# temp ------------------------------------------------------------------------------------------------------------


Temperature_Data <- read.xlsx(paste0(filepath, temp),
                              sheet = 'Temperature_Data')


# tox_al ----------------------------------------------------------------------------------------------------------


tox_AL_data <- read.xlsx(paste0(filepath, tox_al),
                         sheet = 'tox_AL_data')

tox_AL_hard_data <- read.xlsx(paste0(filepath, tox_al),
                              sheet = 'tox_AL_hard_data')

tox_AL_penta_data <- read.xlsx(paste0(filepath, tox_al),
                               sheet = 'tox_AL_penta_data')

tox_AL_Ammonia_data <- read.xlsx(paste0(filepath, tox_al),
                                 sheet = 'tox_AL_Ammonia_data')

tox_AL_Aluminum_data <- read.xlsx(paste0(filepath, tox_al),
                                  sheet = 'tox_AL_Aluminum_data')

tox_AL_Copper_data <- read.xlsx(paste0(filepath, tox_al),
                                sheet = 'tox_AL_Copper_data')


# tox_hh ----------------------------------------------------------------------------------------------------------


HH_Tox_Data <- read.xlsx(paste0(filepath, tox_hh),
                         sheet = 'HH Tox Data')


# biocriteria -----------------------------------------------------------------------------------------------------



biocriteria_data <- read.xlsx(paste0(filepath, biocriteria),
                              sheet = 'Data')


# HABS ------------------------------------------------------------------------------------------------------------


RecreationsHabs_data <- read.xlsx(paste0(filepath, non_R),
                                  sheet = 'RecreationsHabs_data')


# Ocean Acidification ---------------------------------------------------------------------------------------------

OceanAcidification_data <- read.xlsx(paste0(filepath, non_R),
                                     sheet = 'OceanAcidification_data')


# Marine DO -------------------------------------------------------------------------------------------------------


MarineDO_benchmark_data <- read.xlsx(paste0(filepath, non_R),
                                     sheet = 'MarineDO_benchmark_data')

MarineDO_Background_data <- read.xlsx(paste0(filepath, non_R),
                                      sheet = 'MarineDO_Background_data')


# Aquatic Trash ---------------------------------------------------------------------------------------------------



AquaticTrash_data <- read.xlsx(paste0(filepath, non_R),
                               sheet = 'AquaticTrash_data')




# Write to db -----------------------------------------------------------------------------------------------------

#Remove everything from environment that is not the target dataframes

targets <- ls()

con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb")

for(i in 1:length(targets)){
  
  dbWriteTable(con, targets[i], get(targets[i]), overwrite = TRUE)
  
  
}




# Confirm ---------------------------------------------------------------------------------------------------------

dbListTables(con)
dbDisconnect(con, shutdown = TRUE)



# Write excel sheets ----------------------------------------------------------------------------------------------


## workbooks -------------------------------------------------------------------------------------------------------
bacteria_workbooks <- list('Coast_Contact_Raw_Data'       = bact_coast_Coast_Contact_Raw_Data       ,
                           'Coast_Contact_WS_Data'        = bact_coast_Coast_Contact_WS_Data,
                           'Coast_Contact_other_Data'     = bact_coast_Coast_Contact_other_Data,
                           'Fresh_Bacteria_Data_WS'       = bact_fresh_Fresh_Bacteria_Data_WS       ,
                           'Fresh_Bacteria_Data_other'    = bact_fresh_Fresh_Bacteria_Data_other    ,
                           'Fresh_Entero_Bact_Data_other' = bact_fresh_Fresh_Entero_Bact_Data_other ,
                           'Fresh_Entero_Bact_Data_WS'    = bact_fresh_Fresh_Entero_Bact_Data_WS    )

chl_workbook <- list('Chl_a_Raw_Data' = Chl_a_Raw_Data,
                     'Chl_a_WS_Data' = Chl_a_WS_Data,
                     'Chl_a_other_Data' = Chl_a_other_Data)

DO_workbook <- list('DO_Data_Inst_yearround' = DO_Data_Inst_yearround,
                    'DO_Data_Cont_yearround' = DO_Data_Cont_yearround,
                    'DO_Data_Inst_spawn' = DO_Data_Inst_spawn,
                    'DO_Data_Cont_spawn' = DO_Data_Cont_spawn)

pH_Workbook <- list('pH_WS_Data' = pH_WS_Data,
                    'pH_other_Data' = pH_other_Data)

temp_Workbook <- list('Temperature_Data' = Temperature_Data)

toxal_workbook <- list('tox_AL_data' = tox_AL_data,
                       'tox_AL_hard_data' = tox_AL_hard_data,
                       'tox_AL_penta_data' = tox_AL_penta_data,
                       'tox_AL_Ammonia_data' = tox_AL_Ammonia_data,
                       'tox_AL_Aluminum_data' = tox_AL_Aluminum_data,
                       'tox_AL_Copper_data' = tox_AL_Copper_data
)

toxhh_workbook <- list('HH_Tox_Data' = HH_Tox_Data)

biocriteria_workbook <- list('biocriteria_data' = biocriteria_data)


RecreationsHabs_workbook <- list('RecreationsHabs_data' = RecreationsHabs_data)

OceanAcidification_data_workbook <- list('OceanAcidification_data' = OceanAcidification_data)

marine_DO_workbook <- list('MarineDO_benchmark_data' = MarineDO_benchmark_data,
                           'MarineDO_Background_data' = MarineDO_Background_data)

AquaticTrash_data_workbook <- list('AquaticTrash_data' = AquaticTrash_data)



write.xlsx(bacteria_workbooks, file =               "Bacteria.xlsx"                  )
write.xlsx(chl_workbook, file =                     "chl-a.xlsx"                     )
write.xlsx(DO_workbook, file =                      "Dissolved_Oxygen.xlsx"          )
write.xlsx(pH_Workbook, file =                      "pH.xlsx"                        )
write.xlsx(temp_Workbook, file =                    "Temperature.xlsx"               )
write.xlsx(toxal_workbook, file =                   "Aquatic Life Toxics.xlsx"       )
write.xlsx(toxhh_workbook, file =                   "Human Health Toxics.xlsx"       )
write.xlsx(biocriteria_workbook, file=              "Biocriteria.xlsx"               )
write.xlsx(RecreationsHabs_workbook, file =         "Recreational HABS.xlsx"         )
write.xlsx(OceanAcidification_data_workbook, file = "Ocean Acidification.xlsx"       )
write.xlsx(marine_DO_workbook, file =               "Marine Dissolved Oxygen.xlsx"   )
write.xlsx(AquaticTrash_data_workbook, file =       "Aquatic Trash.xlsx"             )



