#1. wczytanie plików
getwd()
df <- read.csv("autaSmall.csv")
head(df,5)


#2 Pobranie danych z REST API

install.packages("jsonline")
install.packages("httr")


library(jsonlite)
require(httr)

endpoint <- "https://api.openweathermap.org/data/2.5/weather?q=Warszawa&appid=1765994b51ed366c506d5dc0d0b07b77"

response <- GET(endpoint)

weather <- as.data.frame(fromJSON(endpoint))

View(weather)

#3 Funkcja zapisujaca porcjami danych csv do tabeli SQLite


?read.table

install.packages("DBI")
install.packages("RSQLite")

library(DBI)
library(RSQLite)

?file


readToBase<-function(filepath,dbConn,tablename,size,sep=",",header=TRUE,delete=TRUE, encoding="UTF-8"){
  ap=!delete
  ov=delete

fileCon <- file(description = filepath, open = "r",encoding = encoding)

df1 <- read.table(fileCon,header=TRUE,sep=",", fill=TRUE,
                  fileEncoding =  'UTF-8', nrows = size)

myColNames <- names(df1)
dbWriteTable(con,tablename,df1,append=ap,overwrite=ov)

i <- 10
repeat {
if(nrow(df1)==0) {
  break;
  close(fileCon)
  dbDisconnect(con)
  }
df1 <- read.table(fileCon,col.names = myColNames,sep=",",
                  fileEncoding = encoding, nrows = 90)
dbWriteTable(con,"tabela",df1,append=TRUE,overwrite=FALSE)
print(i)
i<- i +90
}
}
# i <- 1
# repeat{
#   if(i>5) {
#     break}
#   print(i)
# i<- i +1
#   }


View(df1)


con <- dbConnect(SQLite(),"auta.sqlite")

readToBase("autaSmall.csv",com,"auta2",1000)
dbDisconnect(con)
close(fileCon)

