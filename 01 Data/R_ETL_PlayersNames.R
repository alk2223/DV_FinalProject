require(tidyr)
require(dplyr)
require(ggplot2)

setwd("C:/Users/chase_000/Desktop/College/Fall 2015/Data Visualization/DV_FinalProject/01 Data/lahman-csv_2015-01-24")

file_path <- "PlayerNames.csv"

playdf <- read.csv(file_path, stringsAsFactors = FALSE)


library(lubridate)
dimensions <- names(playdf)


write.csv(playdf, paste(gsub(".csv", "", file_path), ".reformatted.csv", sep=""), row.names=FALSE, na = "")

Bats <- gsub(" +", "_", gsub("[^A-z, 0-9, ]", "", gsub(".csv", "", file_path)))
sql <- paste("CREATE TABLE", Bats, "(") 

  for(d in dimensions) {
    if(d != tail(dimensions, n=1)) sql <- paste(sql, paste(d, "varchar2(4000),\n"))
    else sql <- paste(sql, paste(d, "varchar2(4000)\n"))
  }


sql <- paste(sql, ");")
cat(sql)

