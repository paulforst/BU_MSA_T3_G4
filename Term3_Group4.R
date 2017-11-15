############################################
#Term 3 - Group 4 Group Project
#Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst
#
#Description: 
#
#Output:
############################################

#Check that necessary packages are installed
packages <- c("tidyverse", "tm", "RMySQL")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#Load Neccessary Packages
sapply(packages, require, character.only = TRUE)

#Pull NY Times Articles
#https://developer.nytimes.com/

#Pull Guardian Data
#https://bonobo.capi.gutools.co.uk/register/developer

#Create Corpus

#Write metadata of articles to database
#DB connection information
db_host <- "bu-iaa-db.cjoepp1m87gp.us-east-2.rds.amazonaws.com"
db_user <- 
db_password <- 
db_name <- "pforst"

#Database connection
mydb = dbConnect(MySQL(), user=db_user, password=db_password, dbname= db_name, host= db_host)

#Write information to table
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
#Naive Bayes
#K-Folds
#Latent Semantic Analysis (aka Latent Semantic Indexing)
#Binary classification on multiple sources
#Article filtering
#Optimization - penalty for misclassification