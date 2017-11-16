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

#Options
options(stringsAsFactors = FALSE)

#Credentials for API keys and DB conenctions
source("credentials.R")

#Pull NY Times Articles
#https://developer.nytimes.com/
nyt_url <- "https://api.nytimes.com/svc/archive/v1/2017/"
nyt_articles <- NULL

#loop over months
for (i in 1:2){
        #Replace "7" with i to perform the loop for the desired months
        nyt_results <- fromJSON(paste0(nyt_url, i, ".json?&api-key=", nyt_key))
        nyt_df <- nyt_results$response$docs
        
        #Can't rbind because of the lists in the data frame, need to figure out how to handle
        nyt_articles <- rbind(nyt_articles, nyt_df)
}

#Pull NY Times Articles
#https://developer.nytimes.com/

#Pull Guardian Data
#https://bonobo.capi.gutools.co.uk/register/developer

#Create Corpus

#Write metadata of articles to database
#Database connection
mydb = dbConnect(MySQL(), user=db_user, password=db_password, dbname= db_name, host= db_host)

#Write information to table
dbWriteTable(mydb, "nytimes", df2, append = 'FALSE', row.names = FALSE)
dbWriteTable(mydb, "articles", df2, append = 'FALSE', row.names = FALSE)

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