
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
    packages <- c("tidyverse", "tm", "RMySQL", "jsonlite", "lubridate", "RCurl", "gtools", "XML", "koRpus")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)

#   Options
    options(stringsAsFactors = FALSE)
    set.seed(2017)

#   Load source files    
#   Credentials for API keys and DB conenctions
    source("credentials.R")
#   Corpus functions
    source("corpus_functions.R")
#   NY Times functions
    source("get_nyt_data.R")

#   ____________________________________________________________________________
#   NY Times Data                                                           ####
    #Call general function to generate the data from the NYT API
    #Creates the global variables byt_articles and nyt_keywords
    get_nyt_data()
    
#   Initialize body_container 
    body_container <- NULL
    
#   Randomly select 5,000 articles to use for modeling
    nyt_sample <- nyt_articles[sample(1:nrow(nyt_articles), 5000, replace=FALSE),]
    
    for (i in 1:length(nyt_sample[[1]])) {
        body_container[[i]] <- tryCatch(get_nyt_body(nyt_sample[[1]][i]), error = function(e) NULL) 
        # tryCatch() will ignore error and continue on with the loop
        print(paste0("Scraping article # ", i)) # print the index of an article being scraped
    }
    
    # Save as Rdata
    save(body_container, file = "nyt_body.Rdata")

    
    
    nyt_sample_with_body <- cbind(nyt_sample, body_container)
    
    features <- c("web_url", "main",  "body_container", "section_name", "pub_date")
    
    nyt_final_data <- nyt_sample_with_body[features]
    colnames(nyt_final_data)[] <- colnames(final_data)
#   ____________________________________________________________________________
#   Guardian Data                                                           ####

#   ----------------------> See get_guardian_data.R <---------------------------

#   In order to avoid the script from burgeoning in size, we will merge the two 
#   scripts at a later phase of the project. 

#   ____________________________________________________________________________
#   Create Corpus                                                           ####

    nytCorpus <- clean.corpus(body_container)


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