#1. wczytanie plików
getwd()
df <- read.csv("autaSmall.csv")
head(df,5)
#2 Pobranie danych z REST API

install.packages("jsonline")
install.packages("httr")
library(jsonlite)
library(httr)

endpoint <- "https://api.openweathermap.org/data/2.5/weather?q=Warszawa&appid=1765994b51ed366c506d5dc0d0b07b77"
response <- GET(endpoint)
weather <- as.data.frame(fromJSON(endpoint))
View(weather)


#3 Funkcja zapisujaca porcjami danych csv do tabeli SQLite
install.packages("DBI")
install.packages("RSQLite")

library(DBI)
library(RSQLite)

readToBase<-function(filepath,dbConn,tablename,size,sep=",",header=TRUE,delete=TRUE){
  ap<- !delete
  ov<- delete
  fileConnection<-file(description = filepath,open="r")
  df<- read.table(fileConnection,nrows = size,header = header,fill=TRUE,sep=sep) 
  dbWriteTable(con, tablename, df,append=ap,overwrite=ov)
  myColNames<- names(df)
  repeat{
    if( nrow(df)==0){
      dbDisconnect(con)
      close(fileConnection)
      break 
    }
    df<- read.table(fileConnection,nrows = size,col.names = myColNames,fill=TRUE,sep=sep)
    dbWriteTable(con,tablename, df,append=TRUE,overwrite=FALSE)
  }
} 
con <- dbConnect(SQLite(),"auta.sqlite")
readToBase("autaSmall.csv",con,"auta",1000)
dbDisconnect(con)
close(fileCon)

#4.Napisz funkcję znajdującą tydzień obserwacji z największą średnią ceną ofert korzystając z zapytania SQL.
con <- dbConnect(SQLite(),"auta.sqlite")
res<-dbSendQuery(con,"SELECT tydzien from auta GROUP by tydzien ORDER by avg(cena) DESC limit 1")
zBazy<-dbFetch(res)
dbClearResult(res)
dbDisconnect(con)

#5. Podobnie jak w poprzednim zadaniu napisz funkcję znajdującą tydzień obserwacji z największą 
#średnią ceną ofert  tym razem wykorzystując REST api.

readtoBaseAPI <- function(api,con,tablename) {
  i<-1
  week<-fromJSON(paste(api,i,sep=""))
  dbWriteTable(con,tablename, week,append=FALSE,overwrite=TRUE)
  
  for (i in 2:nweeks$`MAX(tydzien)`) {
    print(i)
    week<-fromJSON(paste(api,i,sep=""))
    dbWriteTable(con,tablename, week,append=TRUE,overwrite=FALSE)  
  }
}
nweeks<-fromJSON("http://54.37.136.190:8000/nweek")
con <- dbConnect(SQLite(),"auta.sqlite")
readtoBaseAPI("http://54.37.136.190:8000/week?t=",con,"auta_API")
res<-dbSendQuery(con,"SELECT tydzien from auta_API GROUP by tydzien ORDER by avg(cena) DESC limit 1")
zBazyAPI<-dbFetch(res)
dbClearResult(res)
dbDisconnect(con)

