library(shiny)
library(dplyr)
library(shinybusy)
library(knitr)
library(kableExtra)
library(shinythemes)
library(shinyWidgets)
library(openxlsx)
library(zip)
library(DT)
library(duckdb)
library(tidyverse)
library(DBI)
library(waiter)
library(shinyBS)
library(shinyalert)
library(bslib)

load('data/nest_data.Rdata')
source('functions/load_data.R')

ui <- navbarPage("2026 Draft Integrated Report",
                 theme = shinytheme("yeti"),
                 inverse = TRUE,
                 collapsible = TRUE,
                 
        
                 # Assessments tab -------------------------------------------------------------------------------------------------
                 
                 
                 shiny::tabPanel("Assessments",
                                 useWaiter(),
                                # Modal dialog for internal review
                                 #  modalDialog(
                                 #   h3("Internal Use Only"),
                                 #   p("The data provided in this application is provisional and intended solely for internal review purposes prior to public comment. The assessments are subject to change. Do not distribute, share, or use this data for regulatory purposes."),
                                 #   title = "Warning",
                                 #   size = "l",
                                 #   easyClose = FALSE
                                 # ),
                                 
                                 # Application title
                                 titlePanel(
                                   fluidRow(
                                     column(6, img(src = "logo.png")),
                                     column(6,  "2026 Draft Integrated Report",style = "font-family: 'Arial'; font-si16pt; vertical-align: 'bottom'")),
                                   windowTitle = "2026 Draft Integrated Report"
                                 ),
                                 
                                 # Sidebar with a slider input for number of bins
                                 sidebarLayout(
                                   sidebarPanel(
                                     width = 3,
                                     actionButton("go", "Filter",  icon("filter")),
                                     bsTooltip(id = "go",
                                               title = "Not inputting any filters will return all 2026 IR decisions"),
                                     
                                     
                                     selectizeInput("AUs",
                                                    "Select Assessment Unit",
                                                    choices = NULL,
                                                    multiple = TRUE,
                                                    options = list(maxOptions = 7000)),
                                     
                                     selectizeInput("Select_AUName",
                                                    "Select AU Name",
                                                    choices = NULL,
                                                    multiple = TRUE,
                                                    options = list(maxOptions = 7000)),
                                     #   selectizeInput("admin_basin_selector",
                                     #                  "Select Admin Basin",
                                     #                  choices = AU_s,
                                     #                  multiple = TRUE),
                                     selectizeInput("pollutant_selector",
                                                    "Select Pollutant",
                                                    choices = pollutants,
                                                    multiple = TRUE),
                                     selectizeInput("category_selector",
                                                    "Select IR category",
                                                    choices = Parameter_category,
                                                    multiple = TRUE),
                                     selectizeInput("status_selector",
                                                    "Select Parameter Attainment Status",
                                                    choices =status,
                                                    multiple = TRUE),
                                     selectizeInput("status_change_selector",
                                                    "Select status change",
                                                    choices =status_change,
                                                    multiple = TRUE),
                                     selectizeInput("OWRD_selector",
                                                    "Select OWRD Basin",
                                                    choices = OWRD_Basin_list,
                                                    multiple = TRUE),
                                     selectizeInput("huc4_selector",
                                                    "Select HUC 4",
                                                    choices =huc4_name,
                                                    multiple = TRUE),
                                     selectizeInput("huc6_selector",
                                                    "Select HUC 6",
                                                    choices =huc6_name,
                                                    multiple = TRUE),
                                     selectizeInput("huc8_selector",
                                                    "Select HUC 8",
                                                    choices =huc8_name,
                                                    multiple = TRUE),
                                     selectizeInput("huc10_selector",
                                                    "Select HUC 10",
                                                    choices =huc10_name,
                                                    multiple = TRUE),
                                     checkboxInput("permitcheckbox", "Only view assessments that include permittee data.", FALSE), 
                                   ),
                                   
                                   # Show a plot of the generated distribution
                                   mainPanel(
                                     tabsetPanel(type = "tabs",
                                                 id = "Tabset",
                                                 tabPanel("Instructions",
                                                          value = "InstructionTab",
                                                          h2(strong("2026 Draft Integrated Report database access"), style = "font-family: 'Arial'"),
                                                          p("DEQ recommends using the current version of Google Chrome or Mozilla Firefox for this application.", style = "font-family: 'times'"),
                                                          p("Oregon's 2026 Draft Integrated Report is out for public comment. The Draft report will not be finalized until DEQ receives EPA approval.", style = "font-family: 'times'"),
                                                          #p("These assessment conclusions are for internal data review"),
                                                          h3(strong("Database Access:"), style = "font-family: 'Arial'"),
                                                          p("This application offers two ways to access and download the numeric data used in 2026 Integrated Report assessments: ", style = "font-family: 'times'"),
                                                          tags$ol(
                                                            tags$li("Click on", strong("Raw Data Download"),  "in the header at the top of this page to access raw data used in the 2026 assessments.", style = "font-family: 'times'"),
                                                            tags$li("Filter the database based on the search criteria in the fields on the left of this page. Press the filter button to view the results in the ",strong("Assessments")," tab ", style = "font-family: 'times'"),
                                                          ),
                                                          h3(strong("Notes on interpreting records in the assessment tab:"), style = "font-family: 'Arial'"),
                                                          tags$ul(
                                                            tags$li("The current assessment categorizations are described in the “final_AU_cat” report field.", style = "font-family: 'times'"),
                                                            tags$li("The “year_last_assessed” report field indicates the most recent IR cycle the waterbody was assessed. If 2026 is not the year in this field, it means there were no new data and the categories were carried forward from a previous reporting cycle", style = "font-family: 'times'"),
                                                            tags$li("Assessment categorized as Category 4 or Category 5 (including all subcategories) are considered impaired.", style = "font-family: 'times'"),
                                                            tags$li("Watershed Units can have additional information on individual streams within each unit (as defined by the NHD GNIS Name), and can be expanded to show the GNIS waterbody information. Click on the black triangle to the left of the AU_ID in the assessment tab to see individual waterbody information.", style = "font-family: 'times'"),
                                                          ),
                                                          h3(strong("Assessment database metadata:"), style = "font-family: 'Arial'"),
                                                          tags$ul(
                                                            tags$li(strong("AU_ID "), " - Assessment Unit ID", style = "font-family: 'times'"),
                                                            tags$li(strong("AU_Name "), " - Assessment Unit Name", style = "font-family: 'times'"),
                                                            tags$li(strong("OWRD_Basin "), " - Oregon Water Resources Department Administrative Basin", style = "font-family: 'times'"),
                                                            tags$li(strong("Assessment "), " - Parameter being assessed. Includes specific standard, if applicable", style = "font-family: 'times'"),
                                                            tags$li(strong("final_AU_cat "), " - Current Integrated Report category for that specific assessment", style = "font-family: 'times'"),
                                                            tags$ul(
                                                              tags$li(strong("Category 2"), " - Available data and information indicate that some designated uses are supported and the water quality standard is attained", style = "font-family: 'times'"),
                                                              tags$li(strong("Category 3"), " - Insufficient data to determine whether a designated use is supported", style = "font-family: 'times'"),
                                                              tags$ul(
                                                                tags$li(strong("Category 3B"), " - This category is used when there is insufficient data to determine use support, but some data indicate  possible impairment", style = "font-family: 'times'"),
                                                                tags$li(strong("Category 3C"), " - This category is used to identify waters whose biocriteria scores differ from reference condition, but are not classified as impaired", style = "font-family: 'times'"),
                                                                tags$li(strong("Category 3D"), " - This category is used when all the available data has criteria values below the test method’s quantification limits", style = "font-family: 'times'")
                                                                
                                                                
                                                              ),
                                                              tags$li(strong("Category 4"), " - Data indicate that at least one designated use is not supported, but a TMDL is not needed to address the pollutant", style = "font-family: 'times'"),
                                                              tags$ul(
                                                                tags$li(strong("Category 4A"), " - Clean-up plans (also called TMDLs) that will result in the waterbody meeting water quality standards and supporting its beneficial uses have been approved", style = "font-family: 'times'"),
                                                                tags$li(strong("Category 4B"), " - Other pollution control requirements are expected to address pollutant of concern and will result in attainment of water quality standards", style = "font-family: 'times'"),
                                                                tags$li(strong("Category 4C"), " - The impairment is caused by pollution, not a pollutant. For example, flow, or lack of flow, are not considered pollutants, but may be affecting the waterbody’s beneficial uses", style = "font-family: 'times'")
                                                                
                                                                
                                                              ),
                                                              tags$li(strong("Category 5"), " - Data indicate a designated use is not supported or a water quality standard is not attained and a TMDL is needed. This category constitutes the Section 303(d) list that EPA will approve or disapprove under the Clean Water Act", style = "font-family: 'times'"),
                                                              tags$ul(
                                                                tags$li(strong("Category 5C"), " - Data indicate a designated use is not supported or a water quality standard is not attained primarily due to global climate change", style = "font-family: 'times'")
                                                              )
                                                              
                                                            ),
                                                            tags$li(strong("Rationale "), " - Rationale for parameter assessment conclusion, if any", style = "font-family: 'times'"),
                                                            tags$li(strong("Stations"), " - Monitoring stations used in 2026 assessment. Data from these monitoring locations can be downloaded from AWQMS, providing the raw data used in assessment.", style = "font-family: 'times'"),
                                                            tags$li(strong("status_change"), " - Identifies the differece between this cycle and 2022 cycle", style = "font-family: 'times'"),
                                                            tags$li(strong("Year_listed "), " - If Assessment Unit is identified as impaired (Category 4 or 5), year it first appeared on the 303(d) List", style = "font-family: 'times'"),
                                                            tags$li(strong("year_last_assessed"), " - Identifies the IR cycle of last assessment", style = "font-family: 'times'"),
                                                            tags$li(strong("prev_category"), " - Identifies the previous cycle IR category", style = "font-family: 'times'"),
                                                            tags$li(strong("prev_rationale"), " - Identifies the previous cycle IR category rationale", style = "font-family: 'times'"),
                                                            tags$li(strong("TMDLs"), " - Identifies any applicable TMDL", style = "font-family: 'times'"),
                                                            tags$li(strong("action_ids"), " - Identifies any applicable TMDL Action IDs", style = "font-family: 'times'"),
                                                            tags$li(strong("TMDL_pollutants"), " - Identifies any applicable pollutants covered by a TMDL", style = "font-family: 'times'"),
                                                            tags$li(strong("TMDL_Periods"), " - Identifies any applicable time if year covered by a TMDL", style = "font-family: 'times'"),
                                                            
                                                            #tags$li(strong("Beneficial_uses "), " - Which beneficial uses this assessment applies to", style = "font-family: 'times'")
                                                          ),
                                                          # h3(strong("Additional Integrated Report resources:"), style = "font-family: 'Arial'"),
                                                          # p("Specifics about the procedures used to conduct categorical assessment for the Internal Draft 2026 Integrated Report can be found in the" , a("2026 Assessment Methodology.",  href="https://www.oregon.gov/deq/wq/Documents/wqaIR2024method.pdf", target="_blank"), style = "font-family: 'times'"),
                                                          # p("Spatial information about assessment conclusions for the 2024 IR, including water quality standards information, can be found using the " , a("Interactive Web Map",  href="https://geo.maps.arcgis.com/apps/instant/sidebar/index.html?appid=7d13b19e01a44f1dbfd12903576e6d29", target="_blank"), style = "font-family: 'times'"),
                                                          # p("To find fact sheets and additional information on the 2024 Integrated Report visit the DEQ " , a("Internal Draft Integrated Report Webpage",  href="https://www.oregon.gov/deq/wq/Pages/proposedIR.aspx", target="_blank"), style = "font-family: 'times'"),
                                                          # p("In addition to the Raw Data Download tab at the top of this page, water quality data used in assessments can also be downloaded from " , a("AWQMS.",  href="https://www.oregon.gov/deq/wq/Pages/WQdata.aspx", target="_blank"), style = "font-family: 'times'"),
                                                 ),
                                                 tabPanel("Assessments",
                                                          value = "Datatab",
                                                          #downloadButton('downloadassessmentData', label = "Download Assessment Results"),
                                                          
                                                          # Assessment download button --------------------------------------------------------------------------------------
                                                          
                                                          
                                                          downloadButton("dl", "Download"),
                                                          bsTooltip(id = "dl",
                                                                    title = "Download an excel file of filtered assessment decisions"),
                                                          
                                                          # Assessment table ------------------------------------------------------------------------------------------------
                                                          
                                                          
                                                          div(DTOutput("table"), style = "font-size:85%")
                                                 )
                                     )
                                   )
                                   
                                   
                                   
                                   
                                 )
                                 
                                 
                 ), # End tab panel 1
                 
                 # End assessments tab ---------------------------------------------------------------------------------------------
                 
                 
                 # Data panel ------------------------------------------------------------------------------------------------------
                 
                 
                 #Begin tab panel 2
                 tabPanel("Raw Data Download",
                          value = "data",
                          # Application title
                          titlePanel(
                            fluidRow(
                              column(6, img(src = "logo.png")),
                              column(6,  "2026 Internal Draft Integrated Report Data Download",style = "font-family: 'Arial'; font-si16pt; vertical-align: 'bottom'")),
                            windowTitle = "2026 Internal Draft Integrated Report Data"
                          ),
                          sidebarLayout(
                            sidebarPanel(

                              # Show a plot of the generated distribution
                              downloadButton('downloadallData', label = "Download All Assessment Data"),
                              bsTooltip(id = "downloadallData",
                                        title = "Clicking this button will download all data used in 2026 Assessments"),
                              downloadButton('downloadData', label = "Download Assessment Data by Unit"),
                              bsTooltip(id = "downloadData",
                                        title = "Clicking this button will download assessment data from the AU_IDs in the filter box below"),
                              selectizeInput("Data_AUs",
                                             "Select one or more Assessment Units",
                                             choices = NULL,
                                             multiple = TRUE,
                                             options = list(maxOptions = 7000))

                            ),



                            mainPanel(
                              tabsetPanel(type = "tabs",
                                          id = "Tabset",
                                          tabPanel("Instructions",
                                                   value = "InstructionTab",
                                                   h2(strong("Download numeric data used in the 2026 Draft Integrated Report"), style = "font-family: 'Arial'"),
                                                   p("DEQ recommends using the current version of Google Chrome or Mozilla Firefox for this application.", style = "font-family: 'times'"),
                                                   p("This application provides the numeric data used in new assessments for the 2026 Internal Draft Integrated Report. Clicking on the", strong('Download All Assessment Data'), "will
                               download all numeric data used in new 2026 assessments. Entering one or more Assessment Units in the search box and pressing",strong('Download All Assessment Data'),
                                                     "will download select data. Data will be downloaded bundled into a zip file" ,
                                                     style = "font-family: 'times'"),
                                                   p(strong("Due to the size of the file, downloading All Assessment Data may take a few minutes"), style = "font-family: 'times'"),
                                                   p("A dictionary describing column headers is included in the zip file", style = "font-family: 'times'"),
                                                   p("A complete mapping and dataset, including water quality standards information can be found on the ",
                                                     a("Interactive web map.", href="https://geo.maps.arcgis.com/apps/instant/sidebar/index.html?appid=7d13b19e01a44f1dbfd12903576e6d29", target="_blank")
                                                     , style = "font-family: 'times'"),
                                                   p(
                                                     a("The 2026 Internal Draft Assessment Methodology can be found here.", href="https://www.oregon.gov/deq/wq/Pages/Integrated-Report-Improvements.aspx", target="_blank"), style = "font-family: 'times'"),
                                                   p(
                                                     a("The DEQ 2026 IR webpage page can be found here.", href="https://www.oregon.gov/deq/wq/Pages/proposedIR.aspx", target="_blank"), style = "font-family: 'times'")
                                          ))



                            )#mainpanel

                          ))


                 # data panel end------------------------------------------------------------------------------------------------------
                 
                 
                 
                 # ,add_busy_spinner(spin = "fading-circle")
                 # ,
                 #
                 #
                 #
                 # # bootstrapPage('',
                 # #
                 # #               tags$style(type = 'text/css', ".navbar { background-color: #71bcb4;}",
                 # #                        ".navbar-default .navbar-nav > .active > a",
                 # #                        ".navbar-default .navbar-nav > .active > a:focus",
                 # #                        ".navbar-default .navbar-nav > .active > a:hover {color: pink;background-color: purple;}",
                 # #                        ".navbar-default .navbar-nav > li > a:hover {color: black;background-color:yellow;text-decoration:underline;}",
                 # #                        ".navbar-default .navbar-nav > li > a[data-value='t1'] {color: red;background-color: pink;}",
                 # #                        ".navbar-default .navbar-nav > li > a[data-value='t2'] {color: blue;background-color: lightblue;}",
                 # #                        ".navbar-default .navbar-nav > li > a[data-value='t3'] {color: green;background-color: lightgreen;"
                 # #
                 # #               )
                 # #
                 # # tags$style(type = 'text/css',
                 # #            HTML('.navbar { background-color: #71bcb4;}
                 # #                           .navbar-default .navbar-brand{color: black;}
                 # #                           .tab-panel{ background-color: red; color: black}
                 # #                           .navbar-default .navbar-nav > .active > a,
                 # #                            .navbar-default .navbar-nav > .active > a:focus,
                 # #                            .navbar-default .navbar-nav > .active > a:hover {
                 # #                                 color: black;
                 # #                                 background-color: #00907e;
                 # #                             }')
                 # #
                 #
                 # )
                 
)

# Define server logic ----
server <- function(input, output, session) {
  
  # Loading Screen server componant ---------------------------------------------------------------------------------
  # Build loading screen
  w <- waiter::Waiter$new(
    html = shiny::tagList(
      "Querying Data...",
      waiter::spin_ball()
    )
  )
  
  observeEvent(input$go, {
    updateTabsetPanel(session, "Tabset",
                      selected = 'Datatab'
    )
  })
  
  
  # END Loading Screen server componant ---------------------------------------------------------------------------------
  
  
  # Update selectize inputs -----------------------------------------------------------------------------------------
  updateSelectizeInput(session, 'AUs', choices = AU_s, server = TRUE)
  updateSelectizeInput(session, 'Data_AUs', choices = AU_s, server = TRUE)
  updateSelectizeInput(session, 'Select_AUName', choices = AU_Names, server = TRUE)
  
  
  
  # END  Update selectize inputs -----------------------------------------------------------------------------------------
  
  
  
  # Build assessment display table ----------------------------------------------------------------------------------
  
  
  
  
  ## Filter AU data --------------------------------------------------------------------------------------------------
  AU_data <- eventReactive(input$go,{
    
    con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb", read_only = TRUE)
    
    t <-tbl(con, "AU_decisions")
    
    if(input$permitcheckbox){
      t <- t%>%
        filter(permittee)

    }
    
    if (!is.null(input$AUs)){
      
      AU_select <- input$AUs
      
      t <- t %>%
        filter(AU_ID %in% AU_select)
    }
    
    if (!is.null(input$Select_AUName)){
      
      AU_name <- input$Select_AUName
      
      t <- t %>%
        filter(AU_Name %in% AU_name)
    }
    
    if (!is.null(input$pollutant_selector)){
      
      pollutant <- input$pollutant_selector
      
      t <- t %>%
        filter(Char_Name %in% pollutant)
    }
    
    if (!is.null(input$category_selector)){
      
      category <- input$category_selector
      
      t <- t %>%
        filter(final_AU_cat %in% category)
    }
    
    if (!is.null(input$status_selector)){
      
      status <- input$status_selector
      
      t <- t %>%
        mutate(param_status = case_when(grepl('5', final_AU_cat) | grepl('4', final_AU_cat) ~ "Impaired",
                                        grepl('3', final_AU_cat) ~ "Insufficient",
                                        grepl('2',final_AU_cat) ~ 'Attains',
                                        TRUE ~ 'Unassessed')) %>%
        filter(param_status %in% status) %>%
        select(-param_status)
    }
    
    if (!is.null(input$status_change_selector)){
      
      stat_change <- input$status_change_selector
      
      t <- t %>%
        filter(status_change %in% stat_change)
    }
    
    if (!is.null(input$huc4_selector)){
      
      huc4 <- input$huc4_selector
      
      t <- t %>%
        filter(HUC4_NAME %in% huc4)
    }
    
    if (!is.null(input$huc6_selector)){
      
      huc6 <- input$huc6_selector
      
      t <- t %>%
        filter(HUC6_NAME %in% huc6)
    }
    
    if (!is.null(input$huc8_selector)){
      
      huc8 <- input$huc8_selector
      
      t <- t %>%
        filter(HUC8_NAME %in% huc8)
    }
    
    if (!is.null(input$huc10_selector)){
      
      huc10 <- input$huc10_selector
      
      t <- t %>%
        filter(HUC10_NAME %in% huc10)
    }
    
    if (!is.null(input$OWRD_selector)){
      
      OWRD <- input$OWRD_selector
      
      t <- t %>%
        filter(OWRD_Basin %in% OWRD)
    }
    
    
    
    
    
    
    
    
    t <- t %>%
      select(-HUC12_NAME, -HUC10,-HUC10_NAME,
             -HUC8, -HUC8_NAME, -HUC6, -HUC6_NAME, -HUC4,
             -HUC4_NAME)%>%
      collect()
    
    dbDisconnect(con, shutdown=TRUE)
    
    t
    
  })
  
  ## END Filter AU data --------------------------------------------------------------------------------------------------
  
  ## Filter GNIS data --------------------------------------------------------------------------------------------------
  GNIS_data <- eventReactive(input$go,{
    
    con <- dbConnect(duckdb(), dbdir = "data/decisions.duckdb", read_only = TRUE)
    
    gnis_AUs <- AU_data()$AU_ID
    gnis_Pollu_ID <- AU_data()$Pollu_ID
    gnis_wqstd_code <- AU_data()$wqstd_code
    
    
    g <- tbl(con, "GNIS_decisions") %>%
      filter(AU_ID %in% gnis_AUs,
             Pollu_ID %in% gnis_Pollu_ID,
             wqstd_code %in% gnis_wqstd_code) %>%
      collect()
    
    
    dbDisconnect(con, shutdown=TRUE)
    
    g
    
  })
  ## END Filter GNIS data -------------------------------------------------------------------------------------------------
  
  
  # Combine data ----------------------------------------------------------------------------------------------------
  combined_data <- eventReactive(input$go,{
    w$show()
    
    data <- AU_data()
    
    
    Dat <-data %>%
      left_join(nest_data, relationship = "many-to-many") %>%
      mutate(" " = case_when(lengths(`_details`) ==0 ~ "",
                             TRUE ~"&#11208;")) %>%
      relocate(" ")
    
    
    w$hide()
    return(Dat)
  })
  
  
  # Create table ----------------------------------------------------------------------------------------------------
  
  Dat <- reactive({combined_data()
  })
  rowNames <- FALSE
  colIdx <- as.integer(rowNames)
  
  
  ## make the callback
  parentRows <- 1
  callback = JS(
    sprintf("var parentRows = [%s];", toString(parentRows-1)),
    sprintf("var j0 = %d;", colIdx),
    "var nrows = table.rows().count();",
    "for(var i=0; i < nrows; ++i){",
    "  if(parentRows.indexOf(i) > -1){",
    "    table.cell(i,j0).nodes().to$().css({cursor: 'pointer'});",
    "  }else{",
    "    table.cell(i,j0).nodes().to$().removeClass('details-control');",
    "  }",
    "}",
    "",
    "// make the table header of the nested table",
    "var format = function(d, childId){",
    "  if(d != null){",
    "    var html = ",
    "      '<table class=\"display compact hover\" ' + ",
    "      'style=\"padding-left: 30px;\" id=\"' + childId + '\"><thead><tr>';",
    "    for(var key in d[d.length-1][0]){",
    "      html += '<th>' + key + '</th>';",
    "    }",
    "    html += '</tr></thead></table>'",
    "    return html;",
    "  } else {",
    "    return '';",
    "  }",
    "};",
    "",
    "// row callback to style the rows of the child tables",
    "var rowCallback = function(row, dat, displayNum, index){",
    "  if($(row).hasClass('odd')){",
    "    $(row).css('background-color', '#C0DDE1FF');",
    "    $(row).hover(function(){",
    "      $(this).css('background-color', '#C0DDE1FF');",
    "    }, function() {",
    "      $(this).css('background-color', '#C0DDE1FF');",
    "    });",
    "  } else {",
    "    $(row).css('background-color', '#C0DDE1FF');",
    "    $(row).hover(function(){",
    "      $(this).css('background-color', '#C0DDE1FF');",
    "    }, function() {",
    "      $(this).css('background-color', '#C0DDE1FF');",
    "    });",
    "  }",
    "};",
    "",
    "// header callback to style the header of the child tables",
    "var headerCallback = function(thead, data, start, end, display){",
    "  $('th', thead).css({",
    "    'border-top': '3px solid indigo',",
    "    'color': 'indigo',",
    "    'background-color': '#0E84B4FF'",
    "  });",
    "};",
    "",
    "// make the datatable",
    "var format_datatable = function(d, childId){",
    "  var dataset = [];",
    "  var n = d.length - 1;",
    "  for(var i = 0; i < d[n].length; i++){",
    "    var datarow = $.map(d[n][i], function (value, index) {",
    "      return [value];",
    "    });",
    "    dataset.push(datarow);",
    "  }",
    "  var id = 'table#' + childId;",
    "  if (Object.keys(d[n][0]).indexOf('_details') === -1) {",
    "    var subtable = $(id).DataTable({",
    "                 'data': dataset,",
    "                 'autoWidth': true,",
    "                 'deferRender': true,",
    "                 'info': false,",
    "                 'lengthChange': false,",
    "                 'ordering': d[n].length > 1,",
    "                 'order': [],",
    "                 'paging': false,",
    "                 'scrollX': false,",
    "                 'scrollY': false,",
    "                 'searching': false,",
    "                 'sortClasses': false,",
    "                 'rowCallback': rowCallback,",
    "                 'headerCallback': headerCallback,",
    "                 'columnDefs': [{targets: '_all', className: 'dt-left'}]",
    "               });",
    "  } else {",
    "    var subtable = $(id).DataTable({",
    "            'data': dataset,",
    "            'autoWidth': true,",
    "            'deferRender': true,",
    "            'info': false,",
    "            'lengthChange': false,",
    "            'ordering': d[n].length > 1,",
    "            'order': [],",
    "            'paging': false,",
    "            'scrollX': false,",
    "            'scrollY': false,",
    "            'searching': false,",
    "            'sortClasses': false,",
    "            'rowCallback': rowCallback,",
    "            'headerCallback': headerCallback,",
    "            'columnDefs': [",
    "              {targets: -1, visible: false},",
    "              {targets: 0, orderable: false, className: 'details-control'},",
    "              {targets: '_all', className: 'dt-left'}",
    "             ]",
    "          }).column(0).nodes().to$().css({cursor: 'pointer'});",
    "  }",
    "};",
    "",
    "// display the child table on click",
    "table.on('click', 'td.details-control', function(){",
    "  var tbl = $(this).closest('table'),",
    "      tblId = tbl.attr('id'),",
    "      td = $(this),",
    "      row = $(tbl).DataTable().row(td.closest('tr')),",
    "      rowIdx = row.index();",
    "  if(row.child.isShown()){",
    "    row.child.hide();",
    "    td.html('&#11208;');",
    "  } else {",
    "    var childId = tblId + '-child-' + rowIdx;",
    "    row.child(format(row.data(), childId)).show();",
    "    td.html('&#11206;');",
    "    format_datatable(row.data(), childId);",
    "  }",
    "});")
  
  output$table <- DT::renderDataTable({
    
    
    
    
    ## the datatable
    datatable(
      combined_data(),
      #extensions = 'Buttons',
      
      callback = callback, rownames = rowNames, escape = -colIdx-1,
      #filter = "top",
      selection = 'none',
      #next line adds grid lines
      class = 'cell-border stripe',
      options = list(
        autoWidth = TRUE,
        pageLength = 100,
        columnDefs = list(
          list(visible = FALSE,
               targets = '_details'),
          list(orderable = FALSE, className = 'details-control', targets = colIdx),
          list(className = "dt-left", targets = "_all")
        ),
        dom = 'Bfrtip'#,
        # buttons = c('copy', 'csv', 'excel')
      )
    )
  })
  
  output$dl <- downloadHandler(
    filename = function() { "Oregon 2024 IR- filtered.xlsx"},
    content = function(filenm) {write.xlsx(list('AU Decisions' = AU_data(), 'GNIS Decisions' = GNIS_data()), file = filenm)}
  )
  
  
  
  
  
  # END  Build assessment display table ----------------------------------------------------------------------------------
  
  
  # Raw data download -----------------------------------------------------------------------------------------------
  
  # Put together filtered data files -----------------------------------------
  
  filtered_data <-  reactive({
    
    inputAU <- input$Data_AUs
    
    return(inputAU)
    
  })
  
  
  
  output$downloadData <- downloadHandler(
    filename = '2022_IR_select_data_download.zip',
    content = function(fname) {
      
      con <- dbConnect(duckdb(), dbdir = 'data/decisions.duckdb')
      
      
      AquaticTrash_data <- tbl(con, 'AquaticTrash_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      Chl_a_Raw_Data <- tbl(con, 'Chl_a_Raw_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      Chl_a_WS_Data <- tbl(con, 'Chl_a_WS_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      Chl_a_other_Data <- tbl(con, 'Chl_a_other_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      DO_Data_Cont_spawn <- tbl(con, 'DO_Data_Cont_spawn') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      DO_Data_Cont_yearround <- tbl(con, 'DO_Data_Cont_yearround') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      
      DO_Data_Inst_spawn <- tbl(con, 'DO_Data_Inst_spawn') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      DO_Data_Inst_yearround <- tbl(con, 'DO_Data_Inst_yearround') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      HH_Tox_Data <- tbl(con, 'HH_Tox_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      MarineDO_Background_data <- tbl(con, 'MarineDO_Background_data') |>
        collect()
      
      MarineDO_benchmark_data <- tbl(con, 'MarineDO_benchmark_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      OceanAcidification_data <- tbl(con, 'OceanAcidification_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      RecreationsHabs_data <- tbl(con, 'RecreationsHabs_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      Temperature_Data <- tbl(con, 'Temperature_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_coast_Coast_Contact_Raw_Data <- tbl(con, 'bact_coast_Coast_Contact_Raw_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_coast_Coast_Contact_WS_Data <- tbl(con, 'bact_coast_Coast_Contact_WS_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      bact_coast_Coast_Contact_other_Data <- tbl(con, 'bact_coast_Coast_Contact_other_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_fresh_Fresh_Bacteria_Data_WS <- tbl(con, 'bact_fresh_Fresh_Bacteria_Data_WS') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_fresh_Fresh_Bacteria_Data_other <- tbl(con, 'bact_fresh_Fresh_Bacteria_Data_other') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_fresh_Fresh_Entero_Bact_Data_WS <- tbl(con, 'bact_fresh_Fresh_Entero_Bact_Data_WS') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      bact_fresh_Fresh_Entero_Bact_Data_other <- tbl(con, 'bact_fresh_Fresh_Entero_Bact_Data_other') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      biocriteria_data <- tbl(con, 'biocriteria_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      pH_WS_Data <- tbl(con, 'pH_WS_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      pH_other_Data <- tbl(con, 'pH_other_Data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      tox_AL_Aluminum_data <- tbl(con, 'tox_AL_Aluminum_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      tox_AL_Ammonia_data <- tbl(con, 'tox_AL_Ammonia_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      tox_AL_Copper_data <- tbl(con, 'tox_AL_Copper_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      tox_AL_data <- tbl(con, 'tox_AL_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      
      tox_AL_hard_data <- tbl(con, 'tox_AL_hard_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      tox_AL_penta_data <- tbl(con, 'tox_AL_penta_data') |>
        filter(AU_ID %in% !!filtered_data()) |>
        collect()
      
      
      
      
      
      
      dbDisconnect(con)
      
      original_wd <- getwd()
      tmpdir <- tempdir()
      setwd(tempdir())
      print(tempdir())
      
      
      
      
      fs <- c("Bacteria.xlsx",
              "chl-a.xlsx",
              "Dissolved_Oxygen.xlsx",
              "pH.xlsx",
              "Temperature.xlsx",
              "Aquatic Life Toxics.xlsx",
              "Human Health Toxics.xlsx" ,
              "Biocriteria.xlsx",
              "Recreational HABS.xlsx",
              "Ocean Acidification.xlsx",
              "Marine Dissolved Oxygen.xlsx",
              "Aquatic Trash.xlsx"        )
      
      
      
      ## workbooks -------------------------------------------------------------------------------------------------------
      bacteria_workbooks <- list('Coast_Contact_Raw_Data'       = bact_coast_Coast_Contact_Raw_Data       ,
                                 'Coast_Contact_WS_Data'        = bact_coast_Coast_Contact_WS_Data,
                                 'Coast_Contact_other_Data'     = bact_coast_Coast_Contact_other_Data,
                                 'Fresh_Bacteria_Data_WS'       = bact_fresh_Fresh_Bacteria_Data_WS       ,
                                 'Fresh_Bacteria_Data_other'    = bact_fresh_Fresh_Bacteria_Data_other    ,
                                 'Fresh_Entero_Bact_Data_other' = bact_fresh_Fresh_Entero_Bact_Data_other ,
                                 'Fresh_Entero_Bact_Data_WS'    = bact_fresh_Fresh_Entero_Bact_Data_WS    )
      chl_workbook <- list('Chl_a_Raw_Data' =Chl_a_Raw_Data,
                           'Chl_a_WS_Data' =  Chl_a_WS_Data,
                           'Chl_a_other_Data'= Chl_a_other_Data)
      
      DO_workbook <- list('DO_Data_Inst_yearround' =DO_Data_Inst_yearround,
                          'DO_Data_Cont_yearround' =DO_Data_Cont_yearround,
                          'DO_Data_Inst_spawn' = DO_Data_Inst_spawn,
                          'DO_Data_Cont_spawn' = DO_Data_Cont_spawn)
      
      pH_Workbook <- list('pH_WS_Data' =pH_WS_Data,
                          'pH_other_Data' =pH_other_Data)
      
      temp_Workbook <- list('Temperature_Data' =Temperature_Data)
      
      toxal_workbook <- list('tox_AL_data' =tox_AL_data,
                             'tox_AL_hard_data' =tox_AL_hard_data,
                             'tox_AL_penta_data' =tox_AL_penta_data,
                             'tox_AL_Ammonia_data' =tox_AL_Ammonia_data,
                             'tox_AL_Aluminum_data' =tox_AL_Aluminum_data,
                             'tox_AL_Copper_data' =tox_AL_Copper_data
      )
      
      toxhh_workbook <- list('HH_Tox_Data' =HH_Tox_Data)
      
      biocriteria_workbook <- list('biocriteria_data' =biocriteria_data)
      
      
      RecreationsHabs_workbook <- list('RecreationsHabs_data' =RecreationsHabs_data)
      
      OceanAcidification_data_workbook <- list('OceanAcidification_data' =OceanAcidification_data)
      
      marine_DO_workbook <- list('MarineDO_benchmark_data' =MarineDO_benchmark_data,
                                 'MarineDO_Background_data' =MarineDO_Background_data)
      
      AquaticTrash_data_workbook <- list('AquaticTrash_data' = AquaticTrash_data)
      
      
      
      write.xlsx(bacteria_workbooks, file =               "Bacteria.xlsx"               , overwrite = TRUE   )
      write.xlsx(chl_workbook, file =                     "chl-a.xlsx"                  , overwrite = TRUE   )
      write.xlsx(DO_workbook, file =                      "Dissolved_Oxygen.xlsx"       , overwrite = TRUE   )
      write.xlsx(pH_Workbook, file =                      "pH.xlsx"                     , overwrite = TRUE   )
      write.xlsx(temp_Workbook, file =                    "Temperature.xlsx"            , overwrite = TRUE   )
      write.xlsx(toxal_workbook, file =                   "Aquatic Life Toxics.xlsx"    , overwrite = TRUE   )
      write.xlsx(toxhh_workbook, file =                   "Human Health Toxics.xlsx"    , overwrite = TRUE   )
      write.xlsx(biocriteria_workbook, file=              "Biocriteria.xlsx"            , overwrite = TRUE   )
      write.xlsx(RecreationsHabs_workbook, file =         "Recreational HABS.xlsx"      , overwrite = TRUE   )
      write.xlsx(OceanAcidification_data_workbook, file = "Ocean Acidification.xlsx"    , overwrite = TRUE   )
      write.xlsx(marine_DO_workbook, file =               "Marine Dissolved Oxygen.xlsx", overwrite = TRUE   )
      write.xlsx(AquaticTrash_data_workbook, file =       "Aquatic Trash.xlsx"          , overwrite = TRUE   )
      
      
      
      zip(zipfile=fname, files=fs)
      
      setwd(original_wd)
    },
    contentType = "application/zip"
  )
  
  
  # All data download -----------------------------------------------------------------------------------------------
  
  output$downloadallData <-  downloadHandler(
    filename <- function() {
      paste("2022_IR_all_data_download", "zip", sep=".")
    },
    
    content <- function(file) {
      file.copy("data/Oregon 2024 Internal Draft IR data.zip", file)
    },
    contentType = "application/zip"
  )
  
}

# Run the application
shinyApp(ui = ui, server = server)
