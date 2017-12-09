
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
    packages <- c("tidyverse", "FSelector", "caret", "ROCR", "h2o")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)



#   ____________________________________________________________________________
#   Pre-processing                                                          ####


#   Utilize clean.corpus() function to clean corpus
 
    corp <- clean.corpus(combined_data$body, stemming = TRUE)

    inspect(corp[1:5])

#   Remove misspelled words make sure to specify lang as either "en_US" or "en_GB"
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
    tdm2 <- removeSparseTerms(tdm, sparse = 0.97) 
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

#   One hot encode target variable ==> "NY Times"= 1; "Guardian" = 0
    tdm2$article.source <- as.factor(ifelse(tdm2$article.source == "NY Times", 1, 0))
    weightedtdm$article.source <- as.factor(ifelse(weightedtdm$article.source == "NY Times", 1, 0))

#   Split into train/test     
    nobs <- nrow(tdm2) # number of observations 
    train_index <- sample(nrow(tdm2), 0.75*nobs) 
    test_index <- sample(setdiff(seq_len(nrow(tdm2)), train_index)) 
    
    
    tdm2_train <- tdm2[train_index,]
    tdm2_test <- tdm2[test_index,]
    

    
#   Remove objects that are no longer needed to conserve memory
    remove(tdm, combined_data, corp, final_data, nyt_final_data)
#   ____________________________________________________________________________
#   Feature Selection                                                       ####

#   Calculate the chi square statistics utilizing function from the Fselector package.
    feature_weights<- chi.squared(article.source ~ ., tdm2)
    
    
#   Print the results 
    print(feature_weights)
    
    
#   Select top # variables
    subset<- cutoff.k(feature_weights, 1500)
    
    
#   Print the final formula that can be used in classification
    func <- as.simple.formula(subset, "class")
    print(f)

    
#   ____________________________________________________________________________
#   SVM                                                                     ####

    library(parallelSVM) # <= this could speed up the process
    
    
    
#   set resampling scheme: 10-fold cross-validation, 3 times 
    ctrl <- trainControl(method="repeatedcv", number = 5, repeats = 1) 
    
#   fit a multiclass SVM using the weighted (td-idf) term document matrix
#   kernel: linear 
#   tuning parameters: C 
    set.seed(123)
    svm_mod  <- train(article.source ~ . , data = tdm2[train_index,], trControl = ctrl, method = "svmLinear")
    
#   fit another multiclass SVM using the weighted (td-idf) term document matrix
#   kernel: linear
#   tuning parameters: C 
    set.seed(123)
    svm_mod_weight  <- train(article.source ~ . , data = weightedtdm[train_index,], trControl = ctrl, method = "svmLinear")
    
#   predict on test data and print the result statistics
    svm_mod.pred <- predict(svm_mod, newdata = tdm2[test_index,-which(names(tdm2)=="article.source")] )
    print(confusionMatrix(svm_mod.pred, tdm2[test_index, which(names(tdm2)=="article.source")]) )
    
    svm_mod_weight.pred <- predict(svm_mod_weight, newdata = weightedtdm[test_index, -which(names(tdm2)=="article.source")])
    print(confusionMatrix(svm_mod_weight.pred, weightedtdm[test_index, which(names(tdm2)=="article.source")]) )
#   ____________________________________________________________________________
#   Naive Bayes with h2o package                                            ####

#    We will use *h2o package* which allows the user to run basic H2O commands using 
#    R commands. This will greatly help with the sheer size of the datasets because no 
#    actual data is stored in **R** workspace, and no actual work is carried out by R. 
#    R rather merely saves the named objects on the server. 
    
#    Here we'll initilalize h2o cluster we will also convert our datasets into **as.h2o** format.    
    
    h2o.shutdown() # shutdown existing instance
    h2o.init()
    
#   load the train and test datasets into h2o enviroment
    train_tdm2.h2o <- as.h2o(tdm2[train_index,],  destination_frame ="tdm2_train")
    test_tdm2.h2o <- as.h2o(tdm2[test_index,], destination_frame = "tdm2_test")
    
    train_weightedtdm.h2o <- as.h2o(weightedtdm[train_index,],  destination_frame ="weightedtdm_train")
    test_weightedtdm.h2o <- as.h2o(weightedtdm[test_index,], destination_frame = "weightedtdm_test")
    
    
   
    bayes_mod <- h2o.naiveBayes(x = colnames(train_tdm2.h2o)[-which(names(train_tdm2.h2o)=="article.source")], 
                                y = "article.source", 
                                training_frame = train_tdm2.h2o,
                                validation_frame = test_tdm2.h2o ,
                                laplace = 1)
   
   
    bayes_mod_weight <- h2o.naiveBayes(x = colnames(train_weightedtdm.h2o)[-which(names(train_weightedtdm.h2o)=="article.source")], 
                                y = "article.source", 
                                training_frame = train_weightedtdm.h2o,
                                validation_frame = test_weightedtdm.h2o,
                                laplace = 1)
    summary(bayes_mod)
    summary(bayes_mod_weight)
    
    plot(h2o.performance(bayes_mod, valid = TRUE), type='roc', col= "red")
    plot(h2o.performance(bayes_mod_weight, valid = TRUE), type='roc')
    
        
#   Calculate performance measures at threshold that maximizes precision
    bayes.pred = as.data.frame( h2o.predict(bayes_mod, newdata = test_tdm2.h2o, type = "Class" ))
    

#   ____________________________________________________________________________
#   GBM                                                                     ####

#   Since, the classes are somewhat skewed we will use h2o.gbm() function parameter 
#   **balance_classes = TRUE** to balance the classes.
    
    gbm_mod <- h2o.gbm(x = colnames(train_tdm2.h2o)[-which(names(train_tdm2.h2o)=="article.source")], 
                       y = "article.source", 
                       training_frame = train_tdm2.h2o,
                       validation_frame = test_tdm2.h2o ,
                       nfolds = 10,
                       balance_classes = TRUE,
                       distribution = "bernoulli",
                       nbins_cats = 2000,
                       seed = 123)
    summary(gbm_mod)   
    plot(h2o.performance(gbm_mod), type='roc', col = "red",lwd = 1 )
    
    
    gbm_mod_weight <- h2o.gbm(x = colnames(train_weightedtdm.h2o)[-which(names(train_weightedtdm.h2o)=="article.source")], 
                       y = "article.source", 
                       training_frame = train_weightedtdm.h2o,
                       validation_frame = test_weightedtdm.h2o,
                       nfolds = 10,
                       balance_classes = TRUE,
                       distribution = "bernoulli",
                       nbins_cats = 2000,
                       seed = 123)
    
    summary(gbm_mod_weight)   
   
#   Plot the ROC curve    
    plot(h2o.performance(gbm_mod_weight, valid = TRUE), type='roc', col = "red",lwd = 1 )
    
#   We can aslo look at the scoring history
    
    plot(gbm_mod_weight)
    
#   We can check the variable importance and select only ones that have scaled importance of >= 0.001
    gbm_mod_weight@model$variable_importances
    var_imp <- gbm_mod_weight@model$variable_importances[gbm_mod_weight@model$variable_importances$scaled_importance >= 0.001,]
    