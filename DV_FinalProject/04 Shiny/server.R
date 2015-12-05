# server.R
require("jsonlite")
require("RCurl")
require("ggplot2")
require("dplyr")
require("shiny")
require("shinydashboard")
require("leaflet")
require("DT")

shinyServer(function(input, output) {
  
  KPI_Low_Max_value <- reactive({input$KPI1})     
  KPI_Medium_Max_value <- reactive({input$KPI2})
  rv <- reactiveValues(alpha = 0.50)
  observeEvent(input$light, { rv$alpha <- 0.50 })
  observeEvent(input$dark, { rv$alpha <- 0.75 })
  
  df1 <- eventReactive(input$clicks1, {data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from BATTING where AB is not NULL"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cca628', PASS='orcl_cca628', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
  })
  
  # Begin code for First Tab:
  output$table <- renderDataTable({DT::datatable(df1(), rownames = FALSE,
                                                 extensions = list(
                                                   # THe following statement is commented out because it doesn't seem to work properly.
                                                   # AutoFill = list(columnDefs = list(list(enable = FALSE, targets = c(0, 1, -1, -2)), list(increment = TRUE, targets = c(3, 4)))),
                                                   Responsive = TRUE,
                                                   FixedHeader = TRUE,
                                                   # To get the functionality in the following 3 statements, uncomment the statement and the corresponding options statement below, 
                                                   # also comment the TableTools = TRUE statement and the last options statement.
                                                   # ColReorder = TRUE  
                                                   # ColVis = TRUE       
                                                   # FixedColumns = TRUE 
                                                   TableTools = TRUE
                                                 ), 
                                                 # options = list(order = list(list(1, 'asc'), list(3, 'desc')), dom='Rlfrtip')
                                                 # options = list(order = list(list(1, 'asc'), list(3, 'desc')), dom='C<"clear">lfrtip')
                                                 # options = list(dom = 't', scrollX = TRUE, scrollCollapse = TRUE)
                                                 options = list(dom = 'T<"clear">lfrtip', tableTools = list(sSwfPath = copySWF('www', pdf = TRUE)))
  )
  })
})
