#ui.R 

require(shiny)
require(DT)

navbarPage(
  title = "Baseball Visualization",
  tabPanel(title = "Hitting",
           sidebarPanel(
             actionButton(inputId = "light", label = "Light"),
             actionButton(inputId = "dark", label = "Dark"),
             sliderInput("min_obp", "OBP_Low_Max_value:", 
                         min = 0, max = .250,  value = 0),
             sliderInput("max_obp", "OBP_Medium_Max_value:", 
                         min = .250, max = 1,  value = .250),
             textInput(inputId = "title", 
                       label = "Crosstab Title",
                       value = "Diamonds Crosstab\nSUM_PRICE, SUM_CARAT, SUM_PRICE / SUM_CARAT"),
             actionButton(inputId = "clicks1",  label = "Click me")
           ),
           
           mainPanel(dataTableOutput("table")
           )
  )
)
