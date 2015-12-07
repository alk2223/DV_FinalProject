require("jsonlite")
require("RCurl")


df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from BATTING where AB > 50"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_alk2223', PASS='orcl_alk2223', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

ndf <- df %>% select(PLAYERID, YEARID, TEAMID, H) %>% arrange(H) %>% filter(TEAMID %in% c("TEX")) %>% filter(YEARID == 2014)


qplot(ndf$H,
      geom="histogram",
      binwidth = 25,  
      main = "Histogram for Hits", 
      xlab = "Hits",  
      fill=I("blue"), 
      col=I("red"), 
      alpha=I(.2),
      xlim=c(1,200))