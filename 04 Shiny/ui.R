library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  tabsetPanel(
    tabPanel("Batting Statistics for Most Valuable Players",dataTableOutput("mvp_table")), 
    tabPanel("Pitching Statistics for Cy Young Award Winners", dataTableOutput("cy_table")), 
    tabPanel(title = "Home Run Hitters Scatterplot",pageWithSidebar(headerPanel("Home Run Hitters Scatterplot"),
      sidebarPanel(sliderInput("mindate",                                                              "Beginning Year:", 
                   min = 1985,
                   max = 2006,
                   value = 1985, sep = ''), 
                   
                   sliderInput("maxdate",
                   "Ending Year:",
                   min = 1986,
                   max = 2007,
                   value = 2007, sep = '')),actionButton(inputId = "clicks", label = "Run")), mainPanel(plotOutput("scatplot"))))
    ))