
#   ============================================================================
#                       Term 3 - Group 4 Group Project            
#   ============================================================================
#   Purpose: This script contains functions that will aid in the process of pulling 
#            Guardian articles and converting them into a data frame for modeling purposes. 
#   ============================================================================
#   Created: 11/29/2017
#   Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst 
#            Bellarmine University
#   ----------------------------------------------------------------------------


#   ____________________________________________________________________________
#   Load Required Packages and Files  

#   Check that necessary packages are installed
packages <- c("tidyverse", "jsonlite", "lubridate", "RCurl", "gtools", "XML")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
sapply(packages, require, character.only = TRUE)

#   ____________________________________________________________________________
#   Create Functions                                                        ####

nyt_keywords_func <- function(keywords_df) {
    if(nrow(keywords_df[[2]]) == 0) {return(NULL)}
    
    #API changes the name of this column from month to month
    if("isMajor" %in% colnames(keywords_df[[2]])) {
        colnames(keywords_df[[2]])[colnames(keywords_df[[2]])=="isMajor"] <- "is_major"
    }
    if("major" %in% colnames(keywords_df[[2]])) {
        colnames(keywords_df[[2]])[colnames(keywords_df[[2]])=="major"] <- "is_major"
    }
    id_key <- rep(keywords_df[[1]], nrow(keywords_df[[2]]))
    results <- cbind.data.frame(id_key, keywords_df[[2]])
}

nyt_author_func <- function(author) {
    #Class of the byline changes from list to vector, using 
    if(class(author) == "list") x <- author$original
    else x <- author
    if(length(x) == 0) return("NA")
    x <- gsub("^By ","",x)
}

#   Pull NY Times Articles
#   https://developer.nytimes.com/
#
#   Currently hard coding to just 2017 articles. Year below can be changed for more or an
#   additional loop can be created to gather more than the current year.

get_nyt_data <- function() {
    nyt_url <- "https://api.nytimes.com/svc/archive/v1/2017/"
    nyt_articles <<- NULL
    nyt_keywords <<- NULL
    
    #   Loop over months
    for (i in 1:11){
        
        nyt_results <- fromJSON(paste0(nyt_url, i, ".json?&api-key=", nyt_key))
        nyt_df <- nyt_results$response$docs
        
        headlines <- as.data.frame(nyt_results[["response"]][["docs"]][["headline"]])
        
        #Keywords need to be a separate table since there are multiple keywords per article
        temp_df <- as.data.frame(cbind(nyt_results[["response"]][["docs"]][["_id"]],
                                       nyt_results[["response"]][["docs"]][["keywords"]]))
        keywords <- do.call("smartbind", apply(temp_df, 1, nyt_keywords_func))
        nyt_keywords <<- rbind(nyt_keywords, keywords)
        
        #Extract Author's name from the "byline"
        temp_df <- nyt_results[["response"]][["docs"]][["byline"]]
        author <- sapply(temp_df, nyt_author_func)
        
        #Bind the columns of the original data frame with the new headlines and author data frames
        nyt_df <- cbind(nyt_df, headlines, author)
        
        #Drop list columns and other unimportant columns
        drop_cols <- c("abstract","print_page","blog","multimedia","headline",
                       "keywords","byline","seo","sub")
        nyt_df <- nyt_df[,!names(nyt_df) %in% drop_cols]
        
        #Word count column changes format from character to integer causing issues
        nyt_df$word_count <- as.character(nyt_df$word_count)
        
        #Bind the new articles with the prior set
        nyt_articles <- bind_rows(nyt_articles, nyt_df)
        
        #Filter out non-articles from the resutls
        nyt_articles <<- filter(nyt_articles, nyt_articles$document_type == 'article')
        
        #Remove variables to free space
        rm(temp_df)
        rm(keywords)
        rm(nyt_results)
        rm(nyt_df)
        rm(headlines)
        rm(author)
    }
}

#   Function to extract body from the NYT articles
get_nyt_body <- function(url){
    
    source <-  getURL(url,encoding="UTF-8") # Specify encoding when dealing with non-latin characters
    
    parsed <- htmlParse(source)
    
    paste(unlist(xpathSApply(parsed, "//p[@ class='story-body-text story-content']", xmlValue)),collapse = "")
    
}