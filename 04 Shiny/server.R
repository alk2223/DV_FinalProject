require("jsonlite")
require("RCurl")
require("ggplot2")
require("dplyr")
require("shiny")
library("DT")
library("shiny")

shinyServer(function(input, output) {

  
    bat <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="SELECT * from BATTING;"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cca628', PASS='orcl_cca628', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
  
    award <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="SELECT * from AWARDSPLAYERS;"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_alk2223', PASS='orcl_alk2223', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
    
    play <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="SELECT * from PlayerNames;"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cca628', PASS='orcl_cca628', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
    
    awarddf <- award %>%  filter(AWARDID == "Most Valuable Player") %>%  tbl_df 

    playname <- dplyr::right_join(play, bat, by = "PLAYERID")
    
    mvp <- dplyr::semi_join(playname, awarddf, by =c("PLAYERID","YEARID"))
    
    output$mvp_table <- renderDataTable({
      datatable(mvp, filter="top",options = list(lengthChange = FALSE))
    })
    
    pitch <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="SELECT * from Pitching;"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cca628', PASS='orcl_cca628', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
    
    cyAwardDf <- award %>%  filter(AWARDID == "Cy Young Award") %>%  tbl_df 
    
    playname <- dplyr::right_join(play, pitch, by = "PLAYERID")
    
    cy <- dplyr::semi_join(playname, cyAwardDf, by =c("PLAYERID","YEARID"))
    
    output$cy_table <- renderDataTable({
      datatable(cy, filter="top",options = list(lengthChange = FALSE))
    })
    
    output$scatplot <- renderPlot({
      Beg_Year <- reactive({input$mindate})
      End_Year <- reactive({input$maxdate})
      
      playname <- dplyr::right_join(play, bat, by = "PLAYERID")
      
      ndf <- playname %>% select(PLAYERID, YEARID, NAMELAST,HR) %>% filter(PLAYERID %in% c("mcgwima01", "sosasa01", "bondsba01"))%>% filter(YEARID < End_Year(), YEARID > Beg_Year())%>% tbl_df 
      
      plot <- ggplot() + 
        coord_cartesian() + 
        scale_x_continuous() +
        scale_y_continuous() +
        
        labs(title='') +
        labs(x=paste("Year"), y=paste("HR")) +
        layer(data=ndf, 
              mapping=aes(x=as.numeric(as.character(YEARID)), y=as.numeric(as.character(HR)), color=NAMELAST), 
              stat="identity", 
              stat_params=list(), 
              geom="line",
              geom_params=list(), 
              position=position_jitter(width=0.3, height=0)
        )
      

      return(plot)
    })
    
    
    
    team_name <- eventReactive(input$clicks,{input$teams})
    year_input <- eventReactive(input$clicks, {input$years})
    
    
    output$hist <- renderPlot({
      
      df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from BATTING where AB > 50"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_alk2223', PASS='orcl_alk2223', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
      
      ndf <- df %>% select(PLAYERID, YEARID, TEAMID, H) %>% arrange(H) %>% filter(TEAMID %in% team_name()) %>% filter(YEARID %in% as.numeric(year_input()))
          
      
      qplot(ndf$H,
          geom="histogram",
          binwidth = 25,  
          main = "Histogram for Hits", 
          xlab = "Hits",  
          fill=I("blue"), 
          col=I("red"), 
          alpha=I(.2),
          xlim=c(1,200))
    
  })
    team_choice <- eventReactive(input$clicks,{input$choices})
    
    output$barplot <- renderPlot({
      df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from BATTING where AB is not NULL"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_cca628', PASS='orcl_cca628', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
      
      ndf <- df %>% filter(TEAMID %in% team_choice()) %>% group_by(TEAMID)%>% summarize(absum = sum(AB), hrsum = sum(HR), value = absum/hrsum)
      
      ndf1 <- ndf %>% ungroup %>% summarize(trend=mean(value))
      plot_bar <- ggplot() + 
        coord_cartesian() + 
        scale_x_discrete() +
        scale_y_continuous() +
        labs(title='Power Hitting by Team') +
        labs(x=paste("TeamID"), y=paste("At bats per homerun")) +
        layer(data=ndf, 
              mapping=aes(x=TEAMID, y=value), 
              stat="identity", 
              stat_params=list(), 
              geom="bar",
              geom_params=list(colour="blue"), 
              position=position_identity()
        ) +
        layer(data=ndf1, 
              mapping=aes(yintercept = trend), 
              geom="hline",
              geom_params=list(colour="red")
        ) 
      
      return(plot_bar)
    })
})
