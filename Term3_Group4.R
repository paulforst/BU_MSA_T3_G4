############################################
#Term 3 - Group 4 Group Project
#Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst
#
#Description: 
#
#Output:
############################################

#Check that necessary packages are installed
packages <- c("tidyverse", "tm", "RMySQL", "jsonlite", "lubridate", "RCurl")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#Load Neccessary Packages
sapply(packages, require, character.only = TRUE)

<<<<<<< HEAD
#Options
options(stringsAsFactors = FALSE)

#Credentials for API keys and DB conenctions
source("credentials.R")

#Pull NY Times Articles
#https://developer.nytimes.com/
nyt_url <- "https://api.nytimes.com/svc/archive/v1/2017/"

#loop over months
for (i in 1:3){
        #Replace "7" with i to perform the loop for the desired months
        nyt_results <- fromJSON(paste0(nyt_url, 7, ".json?&api-key=", nyt_key))
}
=======
#Pull NY Times Articles
#https://developer.nytimes.com/
>>>>>>> d7f58b3167bff1cd0a7afb873d76401a598cbd9e

#Pull Guardian Data
#https://bonobo.capi.gutools.co.uk/register/developer

#Create Corpus

#Write metadata of articles to database
<<<<<<< HEAD
=======
#DB connection information
db_host <- "bu-iaa-db.cjoepp1m87gp.us-east-2.rds.amazonaws.com"
db_user <- 
db_password <- 
db_name <- "pforst"

>>>>>>> d7f58b3167bff1cd0a7afb873d76401a598cbd9e
#Database connection
mydb = dbConnect(MySQL(), user=db_user, password=db_password, dbname= db_name, host= db_host)

#Write information to table
<<<<<<< HEAD
dbWriteTable(mydb, "nytimes", df2, append = 'FALSE', row.names = FALSE)
=======
dbWriteTable(mydb, "articles", df2, append = 'FALSE', row.names = FALSE)
>>>>>>> d7f58b3167bff1cd0a7afb873d76401a598cbd9e

#Create Train, Test and Validation sets

#Create model on classification
#Create model on Lexicial Diversity


#Test Model
#Validate Model

#Use DB for data organization - use it for document lookup or article URL?

#Classification
#Lexical Diversity/Reading Level
#Sentiment Analysis
#Naive Bayes Classification
#K-Folds Validation
#Latent Semantic Analysis (aka Latent Semantic Indexing)
#Binary classification on multiple sources
#Article filtering
#Optimization - penalty for misclassification