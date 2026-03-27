# Load in data files ------------------------------------------------------


con <- DBI::dbConnect(duckdb(), dbdir = "data/decisions.duckdb")

# populate values in selectize boxes
#get a vector of unique AUs
AU_s <- tbl(con, "AU_decisions") %>%
  select(AU_ID) %>%
  distinct() %>%
  collect() %>%
  pull(AU_ID)


AU_Names <- tbl(con, "AU_decisions") %>%
  select(AU_Name) %>%
  distinct() %>%
  filter(!is.na(AU_Name)) %>%
  collect() %>%
  pull(AU_Name)

pollutants<- tbl(con, "AU_decisions") %>%
  select(Char_Name) %>%
  distinct() %>%
  filter(!is.na(Char_Name)) %>%
  arrange(Char_Name) %>%
  collect() %>%
  pull(Char_Name)

Parameter_category <-  tbl(con, "AU_decisions") %>%
  select(final_AU_cat) %>%
  distinct() %>%
  filter(!is.na(final_AU_cat)) %>%
  arrange(final_AU_cat) %>%
  collect() %>%
  pull(final_AU_cat)

huc4_name <-  tbl(con, "AU_decisions") %>%
  select(HUC4_NAME) %>%
  distinct() %>%
  filter(!is.na(HUC4_NAME)) %>%
  arrange(HUC4_NAME) %>%
  collect() %>%
  pull(HUC4_NAME)

huc6_name <- tbl(con, "AU_decisions") %>%
  select(HUC6_NAME) %>%
  distinct() %>%
  filter(!is.na(HUC6_NAME)) %>%
  arrange(HUC6_NAME) %>%
  collect() %>%
  pull(HUC6_NAME)

huc8_name <- tbl(con, "AU_decisions") %>%
  select(HUC8_NAME) %>%
  distinct() %>%
  filter(!is.na(HUC8_NAME)) %>%
  arrange(HUC8_NAME) %>%
  collect() %>%
  pull(HUC8_NAME)

huc10_name <- tbl(con, "AU_decisions") %>%
  select(HUC10_NAME) %>%
  distinct() %>%
  filter(!is.na(HUC10_NAME)) %>%
  arrange(HUC10_NAME) %>%
  collect() %>%
  pull(HUC10_NAME)





status_change <- tbl(con, "AU_decisions") %>%
  select(status_change) %>%
  distinct() %>%
  filter(!is.na(status_change)) %>%
  arrange(status_change) %>%
  collect() %>%
  pull(status_change)
#admin_basins <- sort(unique(Parameter_assessments$OWRD_Basin))

status <-  c("Attains", "Insufficient", "Impaired")


ben_uses <- c(
  "Aesthetic Quality",
  "Fish and Aquatic Life",
  "Fishing",
  "Private Domestic Water Supply",
  "Public Domestic Water Supply",
  "Water Contact Recreation",
  "Boating",
  "Livestock Watering"
)

OWRD_Basin_list <- c(
  c("North Coast",
    "Mid Coast",
    "South Coast",
    "Owyhee",
    "Malheur Lake",
    "Malheur",
    "Powder",
    "Grande Ronde",
    "Umatilla",
    "John Day",
    "Deschutes",
    "Hood",
    "Goose & Summer Lakes",
    "Sandy",
    "Willamette",
    "Umpqua",
    "Rogue",
    "Klamath")
  
)

dbDisconnect(con, shutdown=TRUE)
