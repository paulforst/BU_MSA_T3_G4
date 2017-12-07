
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
    packages <- c("tidyverse", "FSelector", "caret")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)



#   ____________________________________________________________________________
#   Pre-processing                                                          ####


#   Utilize clean.corpus() function to clean corpus
 
    corp <- clean.corpus(combined_data$body, stemming = TRUE)

    inspect(corp[1:5])

#   Remove misspelled words
    system.time(  
    corp <- remove_spelling(corp, lang = "en_GB")
    )
#   create Document-Term Matrix (tdm)
    tdm <- DocumentTermMatrix(corp)
    
    dim(tdm)
    inspect(tdm)
#   sample of columns (words)    
    colnames(tdm)[20:30] 
    
#   The interpretation of this is to say if sparse is equal to .99, then we are removing 
#   terms that only appear in at most 1% of the data.
    tdm2 <- removeSparseTerms(tdm, sparse = 0.99) 
    inspect(tdm2)
#   Inspect a portion of the tdm2
    as.matrix(tdm2)[10:20,20:30]
    #tdm <- TermDocumentMatrix(corp)
 
#   find frequent terms: terms that appear in at least 3000 of docs-which is 25% of docs. 
    freq.term <- findFreqTerms(tdm2, 3000)   
    
    freq.term[1:5]
        
#   create tf-idf weighted version of term document matrix
    weightedtdm <- weightTfIdf(tdm2)
#   inspect the same portion of the weighted tdm
    as.matrix(weightedtdm)[10:20,20:30]  
    
#   Convert tdm's into data frames 
    tdm2 <- as.data.frame(inspect(tdm2))
    weightedtdm <- as.data.frame(inspect(weightedtdm))
#   append document source to tdm to be used as a target  
    tdm2$article.source <- combined_data$source
    weightedtdm$article.source <- combined_data$source      

#   Split into train/test     
    
    
#   Remove objects that are no longer needed to conserve memory
    remove(tdm, tdm2, weightedtdm)
#   ____________________________________________________________________________
#   Feature Selection                                                       ####

#   Calculate the chi square statistics utilizing function from the Fselector package.
    feature_weights<- chi.squared(article_class ~ ., tdm)
    
    
#   Print the results 
    print(feature_weights)
    
    
#   Select top # variables
    subset<- cutoff.k(feature_weights, 500)
    
    
#   Print the final formula that can be used in classification
    f<- as.simple.formula(subset, "class")
    print(f)

    
#   ____________________________________________________________________________
#   SVM                                                                     ####

#   set resampling scheme: 10-fold cross-validation, 3 times 
    ctrl <- trainControl(method="repeatedcv", number = 10, repeats = 3) 
    
#   fit a multiclass SVM using the weighted (td-idf) term document matrix
#   kernel: linear 
#   tuning parameters: C 
    set.seed(123)
    svm.tfidf.linear  <- train(article.source ~ . , data = weightedtdm, trControl = ctrl, method = "svmLinear")
    
#   fit another multiclass SVM using the weighted (td-idf) term document matrix
#   kernel: radial basis function
#   tuning parameters: sigma, C 
    set.seed(123)
    svm.tfidf.radial  <- train(article.source ~ . , data = weightedtdm, trControl = ctrl, method = "svmRadial")
    
#   predict on test data
    svm.tfidf.linear.predict <- predict(svm.tfidf.linear, newdata = weightedtdm_test)
    svm.tfidf.radial.predict <- predict(svm.tfidf.radial, newdata = weightedtdm_test)
    
    

    
#   fit a multiclass SVM using the unweighted TDM
#   kernel: linear 
#   tuning parameters: C 
    set.seed(100)
    svm.linear  <- train(article.source ~ . , data = weightedtdm, trControl = ctrl, method = "svmLinear")
    
#   fit another multiclass SVM using the unweighted TDM
#   kernel: radial basis function
#   tuning parameters: sigma, C 
    set.seed(100)
    svm.radial  <- train(article.source ~ . , data = weightedtdm, trControl = ctrl, method = "svmRadial")
    
#   predict on test data
    svm.linear.predict <- predict(svm.linear, newdata = weightedtdm_test)
    svm.radial.predict <- predict(svm.radial, newdata = weightedtdm_test)    
    
    
    
    