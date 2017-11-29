
#   ============================================================================
#                       Term 3 - Group 4 Group Project            
#   ============================================================================
#   Purpose: This script contains functions that will aid in the process of pulling 
#            NY Times articles and converting them into a data frame for modeling purposes. 
#   ============================================================================
#   Created: 11/29/2017
#   Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst 
#            Bellarmine University
#   ----------------------------------------------------------------------------


#   ____________________________________________________________________________
#   Load Required Packages and Files                                        ####


#   Check that necessary packages are installed
    packages <- c("tidyverse", "tm", "RMySQL", "jsonlite", "lubridate", "RCurl", "gtools", "GuardianR", "XML")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)

#   Options
    options(stringsAsFactors = FALSE)

#   Credentials for API keys and DB conenctions
    source("credentials.R")

#   ____________________________________________________________________________
#   Create Functions                                                        ####

    nyt_keywords_func <- function(keywords_df) {
        if(nrow(keywords_df[[2]]) == 0) {return(NULL)}
        
        if("isMajor" %in% colnames(keywords_df[[2]])) {
            colnames(keywords_df[[2]])[colnames(keywords_df[[2]])=="isMajor"] <- "is_major"
        }
        id_key <- rep(keywords_df[[1]], nrow(keywords_df[[2]]))
        results <- cbind.data.frame(id_key, keywords_df[[2]])
    }

    nyt_author_func <- function(author) {
        x <- author$original
        if(length(x) == 0) return("NA")
        x <- gsub("^By ","",x)
    }

#   Pull NY Times Articles
#   https://developer.nytimes.com/
    nyt_url <- "https://api.nytimes.com/svc/archive/v1/2017/"
    nyt_articles <- NULL
    nyt_keywords <- NULL

#   Loop over months
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
            
            temp_df <- nyt_results[["response"]][["docs"]][["byline"]]
            author <- sapply(temp_df, nyt_author_func)
            
            nyt_df <- cbind(nyt_df, headlines, author)
            
            #Drop list columns and other unimportant columns
            drop_cols <- c("abstract","print_page","blog","multimedia","headline","keywords","byline")
            nyt_df <- nyt_df[,!names(nyt_df) %in% drop_cols]
    
            #Bind the new articles with the prior set
            nyt_articles <- bind_rows(nyt_articles, nyt_df)
            
            #Remove variables to free space
            rm(temp_df)
            rm(keywords)
            rm(nyt_results)
            rm(nyt_df)
            rm(headlines)
            rm(author)
    }

#   Function to extract body from the NYT articles
    get_body <- function(url){
        
        source <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
        
        parsed <- htmlParse(source)
        
        paste(unlist(xpathSApply(parsed, "//p[@ class='story-body-text story-content']", xmlValue)),collapse = "")
        
    }
#   Initialize body_container 
    body_container <- NULL
    
    for (i in 1:length(nyt_articles[[1]])) {
        body_container[[i]] <- get_body(nyt_articles[[1]][i])
    }
    

#   ____________________________________________________________________________
#   Guardian Data                                                           ####

#   ----------------------> See get_guardian_data.R <---------------------------

#   In order to avoid the script from burgeoning in size, we will merge the two 
#   scripts at a later phase of the project. 

#   https://bonobo.capi.gutools.co.uk/register/developer
#   guardian_url <- "https://api.nytimes.com/svc/archive/v1/2017/"
#   guardian_articles <- NULL



#   ____________________________________________________________________________
#   Create Corpus                                                           ####






#   ____________________________________________________________________________
#   Database Connection                                                     ####

#   Write metadata of articles to database
    mydb = dbConnect(MySQL(), user=db_user, password=db_password, dbname= db_name, host= db_host)

#   Write information to table
    dbWriteTable(mydb, "nyt_articles", nyt_articles, append = 'FALSE', row.names = FALSE)
    dbWriteTable(mydb, "nyt_keywords", nyt_keywords, append = 'FALSE', row.names = FALSE)
    dbWriteTable(mydb, "guardian_articles", guardian_articles, append = 'FALSE', row.names = FALSE)

#   Create Train, Test and Validation sets

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