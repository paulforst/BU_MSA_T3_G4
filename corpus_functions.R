
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
packages <- c("SnowballC","tm")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
sapply(packages, require, character.only = TRUE)


#Function to perform creating and cleaning a corpos from a vector of text
#Inputs: 
#       x is a vector of text
#       add_stopwords is a vector of additional stopwords to remove from text
#       stemming is a boolean to know if stemming should be performed
#Outputs:
#       cleaned corpus of the orginal text
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)


clean.corpus <- function(x, add_stopwords = NULL, stemming = FALSE) {

    #Creating corpus from vector
    corpus <- Corpus(VectorSource(x))
   
    corpus <- tm_map(corpus,  removePunctuation)
    corpus <- tm_map(corpus,  stripWhitespace)
    corpus <- tm_map(corpus,  removeNumbers)

    corpus <- tm_map(corpus, removeSpecialChars)
    corpus <- tm_map(corpus, tolower)
    #Remove standard stopwords
    if(is.null(add_stopwords)){
        corpus <- tm_map(corpus, removeWords, stopwords('english'))
    } else {
        #Remove standard plus additional words if submitted
        corpus <- tm_map(corpus, removeWords, c(add_stopwords, stopwords('english')))
    }
    
    if(stemming){
        corpus <- tm_map(corpus, stemDocument)
    }
    corpus <- tm_map(corpus, PlainTextDocument)
    return(corpus)
}


