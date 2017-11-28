############################################
#Term 3 - Group 4 Group Project
#Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst
#
#Description: 
#
#Output:
############################################

#Check that necessary packages are installed
packages <- c("tidyverse", "tm", "RMySQL", "jsonlite", "lubridate", "RCurl", "gtools")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#Load Neccessary Packages
sapply(packages, require, character.only = TRUE)

#Options
options(stringsAsFactors = FALSE)

#Credentials for API keys and DB conenctions
source("credentials.R")

#Functions
nyt_keywords_func <- function(keywords_df) {
    if(nrow(keywords_df[[2]]) == 0) {return(NULL)}
    
    if("isMajor" %in% colnames(keywords_df[[2]])) {
        colnames(keywords_df[[2]])[colnames(keywords_df[[2]])=="isMajor"] <- "is_major"
    }
    id_key <- rep(keywords_df[[1]], nrow(keywords_df[[2]]))
    results <- cbind.data.frame(id_key, keywords_df[[2]])
}

#Pull NY Times Articles
#https://developer.nytimes.com/
nyt_url <- "https://api.nytimes.com/svc/archive/v1/2017/"
nyt_articles <- NULL
nyt_keywords <- NULL

#loop over months
for (i in 1:2){
        #Replace "7" with i to perform the loop for the desired months
        nyt_results <- fromJSON(paste0(nyt_url, i, ".json?&api-key=", nyt_key))
        nyt_df <- nyt_results$response$docs
        
        headlines <- as.data.frame(nyt_results[["response"]][["docs"]][["headline"]])
        
        #Keywords need to be a separate table since there are multiple keywords per article
        temp_df <- as.data.frame(cbind(nyt_results[["response"]][["docs"]][["_id"]],
                                       nyt_results[["response"]][["docs"]][["keywords"]]))
        keywords <- do.call("smartbind", apply(temp_df, 1, nyt_keywords_func))
        nyt_keywords <- rbind(nyt_keywords, keywords)
        
        #author <- nyt_results[["response"]][["docs"]][["byline"]][[1]][["original"]]
        
        nyt_df <- cbind(nyt_df, headlines)
        
        #Drop list columns and other unimportant columns
        nyt_df <- nyt_df[,-c(4:6,7:13,19,23)]
        
        #Bind the new articles with the prior set
        nyt_articles <- bind_rows(nyt_articles, nyt_df)
        
        #Remove variables to free space
        rm(temp_df)
        rm(keywords)
        rm(nyt_results)
        rm(nyt_df)
        rm(headlines)
}

#Pull Guardian Data
#https://bonobo.capi.gutools.co.uk/register/developer

#Create Corpus

#Write metadata of articles to database
#Database connection
mydb = dbConnect(MySQL(), user=db_user, password=db_password, dbname= db_name, host= db_host)

#Write information to table
dbWriteTable(mydb, "nytimes", df2, append = 'FALSE', row.names = FALSE)
dbWriteTable(mydb, "gaurdian", df2, append = 'FALSE', row.names = FALSE)

#Create Train, Test and Validation sets

#WordToVec - Andrew
#Lexical Diversity - Paul
#Naive Bayes - Jay
#SVM - Jay


#Test Model
#Validate Model

#Use DB for data organization - use it for document lookup or article URL?

#Classification
#Sentiment Analysis
#Naive Bayes Classification
#K-Folds Validation
#Latent Semantic Analysis (aka Latent Semantic Indexing)
#Binary classification on multiple sources
#Article filtering
#Optimization - penalty for misclassification
#
#
#
#Test the Access 
#