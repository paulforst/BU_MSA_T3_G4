
#   ============================================================================
#                       Term 3 - Group 4 Group Project            
#   ============================================================================
#   Purpose: Data cleaning and feature selection
#   ============================================================================
#   Created: 12/04/2017
#   Members: Tammy Hang, Jay Bektasevic, Andrew Brill, Paul Forst 
#            Bellarmine University
#   ----------------------------------------------------------------------------


#   ____________________________________________________________________________
#   Load Required Packages and Files  

#   Check that necessary packages are installed
packages <- c("tidyverse", "FSelector")
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
sapply(packages, require, character.only = TRUE)



#   ____________________________________________________________________________
#   Pre-processing                                                          ####


#   Utilize clean.corpus() function to clean corpus

    corpus_clean <- clean.corpus(source_data)


#   create term document matrix (tdm)
    tdm <- DocumentTermMatrix(corpus)

#   inspecting the tdm
    dim(tdm) 

#   sample of columns (words)    
    colnames(tdm)[20:30]     

#   find frequent terms: terms that appear in at least # of documents. 
    findFreqTerms(tdm, 30)    
        
#   create tf-idf weighted version of term document matrix
    weightedtdm <- weightTfIdf(tdm)
#   inspect same portion of the weighted tdm
    as.matrix(weightedtdm)[10:20,20:30] 
    
    articles$article_class <- # needs to be determined
#   ____________________________________________________________________________
#   Feature Selection                                                       ####

#   Calculate the chi square statistics utilizing function from the Fselector package.
    weights<- chi.squared(article_class ~ ., tdm)
    
    
#   Print the results 
    print(weights)
    
    
#   Select top five variables
    subset<- cutoff.k(weights, 5)
    
    
#   Print the final formula that can be used in classification
    f<- as.simple.formula(subset, "class")
    print(f)

    
#   ____________________________________________________________________________
#   SVM                                                                     ####

############################ working ###########################################
    
    # set resampling scheme: 10-fold cross-validation, 3 times
    ctrl <- trainControl(method="repeatedcv", number = 10, repeats = 3) 
    
    # fit a multiclass SVM using the weighted (td-idf) term document matrix
    # kernel: linear 
    # tuning parameters: C 
    set.seed(123)
    svm.tfidf.linear  <- train(doc.class ~ . , data=weightedTDMtrain, trControl = ctrl, method = "svmLinear")
    
    # fit another multiclass SVM using the weighted (td-idf) term document matrix
    # kernel: radial basis function
    # tuning parameters: sigma, C 
    set.seed(123)
    svm.tfidf.radial  <- train(doc.class ~ . , data=weightedTDMtrain, trControl = ctrl, method = "svmRadial")
    
    # predict on test data
    svm.tfidf.linear.predict <- predict(svm.tfidf.linear,newdata = weightedTDMtest)
    svm.tfidf.radial.predict <- predict(svm.tfidf.radial,newdata = weightedTDMtest)
    
    

    
    # fit a multiclass SVM using the unweighted TDM
    # kernel: linear 
    # tuning parameters: C 
    set.seed(100)
    svm.linear  <- train(doc.class ~ . , data=tdmTrain, trControl = ctrl, method = "svmLinear")
    
    # fit another multiclass SVM using the unweighted TDM
    # kernel: radial basis function
    # tuning parameters: sigma, C 
    set.seed(100)
    svm.radial  <- train(doc.class ~ . , data=tdmTrain, trControl = ctrl, method = "svmRadial")
    
    # predict on test data
    svm.linear.predict <- predict(svm.linear,newdata = tdmTest)
    svm.radial.predict <- predict(svm.radial,newdata = tdmTest)    
    
    
    
    