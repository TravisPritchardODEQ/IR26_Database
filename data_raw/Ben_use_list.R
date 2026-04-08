
con <- DBI::dbConnect(odbc::odbc(), "IR_Dev")

ben_use_list <- tbl(con, 'LU_BU_Assessment') %>%
  select(ben_use) |> 
  distinct() |> 
  collect() |> 
  pull()

save(ben_use_list, file = 'data/ben_use_list.Rdata')