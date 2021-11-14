library(RSQLite)
library(tm)
library(dplyr)
library(knitr)
library(lubridate)
library(ggplot2)
library(plotly)

#api endpoint
endpoint <- 'https://api.coronavirus.data.gov.uk/v1/data?filters=areaType=region;areaName=england&structure={"date":"date","newCases":"newCasesByPublishDate"}'

#api call according to structure above and including a timeout of 
httr::GET(
  url = endpoint,
  httr::timeout(10)
) -> response

#exception handling for unsuccessful api calls
if (response$status_code >= 400) {
  err_msg = httr::http_status(response)
  stop(err_msg)
}

#converting response from json to text
json_text <- httr::content(response, "text")

#converting to R DF
data  <- jsonlite::fromJSON(json_text)

#checking structure of data and data types
str(data)

#previewing data to ensure pulled through all metrics correctly
head(data)

#flattening out json structure to get data
data1 <- flatten(data$data)
print(data1)

#plotting historical data on line chart using plotly to analyse covid trends 
fig <- plot_ly(data1, x = data1$date, y = data1$newCases, type = 'scatter', mode = 'lines')
line = list(color = 'transparent')

#producing plot defined above
fig

#creating db instance
mydb <- dbConnect(RSQLite::SQLite(), "")

#writing to db
dbWriteTable(mydb, "england_covid_data", data1)

#querying sqlite database to ensure written to db effectively
res <- dbSendQuery(mydb, "SELECT * FROM england_covid_data")
dbFetch(res)







