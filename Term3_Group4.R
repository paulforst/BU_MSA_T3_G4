
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
    packages <- c("tidyverse", "tm", "RMySQL", "jsonlite", "lubridate", "RCurl", "gtools", "XML", "koRpus", 
                  "tidytext", "ngram", "stringr")
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
        print(paste0("Scraping article # ", i, " of ", length(nyt_sample[[1]]))) # print the index of an article being scraped
    }
    
    # Save as Rdata
    save(body_container, file = "nyt_body.Rdata")

#   bind the article body with the rest of meta data    
    nyt_sample_with_body <- cbind(nyt_sample, body_container)
    
#   select features
    features <- c("web_url", "main",  "body_container", "section_name", "pub_date")
    
    nyt_final_data <- nyt_sample_with_body[features]
    
#   match the column names of both datasets

    colnames(nyt_final_data)[] <- colnames(final_data)
    
#   Remove records with no body text
    nyt_final_data <- nyt_final_data[!(is.na(nyt_final_data$body) | nyt_final_data$body==""), ]
    
#   Add a column to label the source
    nyt_final_data$source <- "NY Times"

#   Combine the datasets    
    combined_data <- rbind(final_data, nyt_final_data)
#   Initilize the word_count attribute
    combined_data$word_count <- NULL
    
#   Loop to get the word count of each article
    
    for (i in 1:nrow(combined_data[,1])) {
        
        # print(paste0("Row index ", i, " Count of words:  ", wordcount(combined_data$body[i])))
        
        combined_data$word_count[i] <- wordcount(combined_data$body[i])
    }
    
#   Plot the density 
    hist(combined_data$word_count, prob=TRUE, col="grey")
    lines(density(combined_data$word_count), col="blue", lwd=2)
    
#   Remove articles with <200 and >5,000 words    
    combined_data <- combined_data[combined_data$word_count >= 200 & combined_data$word_count <= 2000]
    
    hist(combined_data$word_count, prob = TRUE, col="grey")
    lines(density(combined_data$word_count), col="blue", lwd=2)
    
    table(combined_data$section)
    
    table(combined_data$source)

#   Fixed the world news section        
    combined_data$section <- str_replace(combined_data$section, "World news", "World")
   
    table(combined_data$section)
    
    save(combined_data, file = "combined_final_data.Rdata")
    
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

#   Initialize lexical diversity variable     
    nyt_lexdiv <- NULL
    
#   Loop through each NYT Article body to general lexical diversity    
    for (i in 1:length(body_container)) {
        nytToken <- tokenize(body_container[i], format = "obj", lang = "en")
        #lexdiv <- lex.div(nytToken, quiet = TRUE)
        lexdiv <- koRpus::MTLD(nytToken)
        nyt_lexdiv[i] <- lexdiv@MTLD[[1]]
    }
    
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