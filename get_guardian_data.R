
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
#   Load Required Packages and Files                                        ####

    # Verify that required packages are installed
    packages <- c("httr", "rjson", "lubridate", "plyr", "data.table")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)
    
    # Load required packages
    sapply(packages, require, character.only = TRUE)
    
    sections <- c("sport", "world", "politics", "travel")
    
    # Create url for each section
    urls <- lapply(sections, function(x) {
        paste0("http://content.guardianapis.com/search?section=", 
               x, paste0("&order-by=newest&show-fields=body&page-size=50&api-key=", 
                         guardian_key))
    })
    
#   ____________________________________________________________________________
#   Create Functions                                                        ####

    # Write a function to get results
    get_results <- function(url, pageNum) {
        # If pagenum is > 1, then add
        if(pageNum > 1) {
            url <- paste0(url, "&page=", pageNum)
        }
        # Query results
        results <- content(GET(url), "parsed")
        # Error control
        if(length(results) == 0) {
            warning("Empty results. No results will be returned. Please make sure that the URL is correct along with your API key.")
            return(NULL)
        }
        # Pull out the results from the list
        results <- results[["response"]]$results
        # Return
        return(results)
    }
    
    # Main function
    main_call <- function(url, pages = 30) {
        # master
        master <- vector("list", pages)
        # Loop through the pages
        for(page in 1:pages) {
            temp <- get_results(url, page)
            master[[page]] <- temp
        }
        # Return
        return(master)
    }
    
    # For each url, call main_call() function
    data <- lapply(urls, function(x) {
        
        print(paste0("Section ", x))
        # Set limits for number of articles 
        upper_limit <- 1500
        limit_pp <- 50 
        # Number of calls needed
        calls <- upper_limit / (limit_pp)
        # Run main
        main <- main_call(x, calls)
        # Get name
        name <- gsub("http://content.guardianapis.com/search?section=",
                     "", unlist(strsplit(x, "&order", fixed = TRUE))[1],fixed = TRUE)
        # Write to project directory
        save(main, file = paste0(name,"_guardian.Rdata"))
    })
    
    # Get the file names with .Rdata extension
    files <- list.files(path=getwd(), pattern="guardian.Rdata$", full.names = FALSE, recursive = FALSE)
    
    # Create a vector of files
    master <- vector("list", length(files))
    
    # Loop through the files
    for(x in 1:length(files)){
        load(file=files[x])
        master[[x]] <- main
    }
    
    # To data frame function
    to_df <- function(list) {
        # return in df format
        results <- lapply(list, function(x){
           
            results <- lapply(x, function(b) {
                
                tmp <- lapply(b, function(y) {
                    striphtml <- function(htmlString) {
                        return(gsub("<.*?>", "", htmlString))
                    }
                    # Return fields
                    y$fields <- striphtml(y$fields$body)
                    temp <- lapply(y, Filter, f = Negate(is.null))
                    temp <- list("url" = ifelse(length(temp$webUrl) > 0, temp$webUrl, NA),
                                 "headline" = ifelse(length(temp$webTitle) > 0, temp$webTitle, NA),
                                 "body" = ifelse(length(temp$fields) > 0, temp$fields, NA),
                                 "section" = ifelse(length(temp$sectionName) > 0, temp$sectionName, NA),
                                 "publication_date" = ifelse(length(temp$webPublicationDate) > 0, temp$webPublicationDate, NA))
                    # Convert body to ASCII
                    temp$body <- iconv(temp$body, "latin1", "ASCII", sub="")
                    # Return
                    return(temp)
                })
                # Bind the results
                return(rbindlist(tmp, fill = TRUE))
            })
            return(rbindlist(results, fill = TRUE))
        })
        return(rbindlist(results, fill = TRUE))
    }
       
#   ____________________________________________________________________________
#   Output                                                                  ####

    # Convert results to the data frame
    final_data <<- to_df(master)
    
    
    # Convert section variable to factor
    final_data$section <- as.factor(final_data$section)
    
    final_data$source <- "Guardian"
    
    
    # Remove unnecessary variables 
    rm(data, main, master)
    
    
    # Save as Rdata
    save(final_data, file = "guardian_final.Rdata")
