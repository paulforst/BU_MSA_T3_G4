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

#Create DB of locations of articles?

#Pull NY Times Articles

#Pull BBC Articles

#Pull Guardian Data

#Create Corpus

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