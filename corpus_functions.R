
#   ============================================================================
#                       Term 3 - Group 4 Group Project            
#   ============================================================================
#   Purpose: This script contains functions that will aid in the process of creating
#            a clean and usable corpus for modeling.
#   ============================================================================
#   Created: 11/29/2017
#   Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst 
#            Bellarmine University
#   ----------------------------------------------------------------------------


#   ____________________________________________________________________________
#   Load Required Packages and Files  

#   Check that necessary packages are installed
    packages <- c("SnowballC","tm", "hunspell")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)


#   Function to perform creating and cleaning a corpos from a vector of text
#   Inputs: 
#   x is a vector of text
#   add_stopwords is a vector of additional stopwords to remove from text
#   stemming is a boolean to know if stemming should be performed
#   Outputs:
#   cleaned corpus of the orginal text

    clean.corpus <- function(x, add_stopwords = NULL, stemming = FALSE) {
    

#       Creating corpus from vector
        corpus <- Corpus(VectorSource(x))
        corpus <- tm_map(corpus,  removePunctuation)
        corpus <- tm_map(corpus,  stripWhitespace)
        corpus <- tm_map(corpus,  removeNumbers)
        corpus <- tm_map(corpus, function(x) gsub("[^a-zA-Z0-9 ]","",x))
        corpus <- tm_map(corpus, tolower)
#       Remove standard stopwords
        if(is.null(add_stopwords)){
            corpus <- tm_map(corpus, removeWords, stopwords('english'))
        } else {
#       Remove standard plus additional words if submitted
            corpus <- tm_map(corpus, removeWords, c(add_stopwords, stopwords('english')))
        }
        
        if(stemming){
            corpus <- tm_map(corpus, stemDocument)
        }

                            
#       Ensures that the corpus is returned in a plain text, otherwise, depending on the version of 
#       "tm" package it can cause issues with the creation of Document-Term Matrix.  
        corpus <- tm_map(corpus, PlainTextDocument)
        return(corpus)
    }

#       Removes misspelled (non-English) words lang = "en_GB" or "en_US" 
        remove_spelling <- function(corpus, lang = "en_US"){
            corpus <- tm_map(corpus, 
                             removeWords,
                             sort(unique(unlist(hunspell_find(as.character(corpus), 
                                                              dict = dictionary(lang ))
                                                )
                                         )
                                  )
                            )
            return(corpus)
        }

