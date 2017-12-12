#                           Term 3 - Group 4 Group Project            
#   ============================================================================
#   Purpose: Topic Modeling 

    packages <- c("tidyverse", "dplyr", "tm", "topicmodels", "tidytext", "ggplot2")
    new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)

#   Load Neccessary Packages
    sapply(packages, require, character.only = TRUE)


#   ____________________________________________________________________________
#   Document Term Matrix was transformed to dataframe                       ####

    #Topic Model for Combined Data
    
#   renaming tdm 
    dtm <- tdm
    dtm

#   LDA function from topic model package k set to 4 for 4- topic LDA model 
    all_lda <- LDA(dtm, k = 4, control = list(seed = 1234))
    all_lda

#   word topic probabilities 
    all_topics <- tidy(all_lda, matrix = "beta")
    all_topics

#   Visualization of 4 topics that were extracted 
    all_top_terms <- all_topics %>%
                  group_by(topic) %>%
                  top_n(10, beta) %>%
                  ungroup() %>%
                  arrange(topic, -beta)

    all_top_terms %>%
                  mutate(term = reorder(term, beta)) %>%
                  ggplot(aes(term, beta, fill = factor(topic))) +
                  geom_col(show.legend = FALSE) +
                  facet_wrap(~ topic, scales = "free") +
                  coord_flip() + ggtitle('Top terms in each LDA topic')

   
    
    #------------------------------------------------------
    #Topic Model for New York Times
    #   renaming tdm 
    dtm <- dtm_nyt
    dtm
    
    #   LDA function from topic model package k set to 4 for 4- topic LDA model 
    nytimes_lda <- LDA(dtm, k = 4, control = list(seed = 1234))
    nytimes_lda
    
    #   word topic probabilities 
    nytimes_topics <- tidy(nytimes_lda, matrix = "beta")
    nytimes_topics
    
    #   Visualization of 4 topics that were extracted 
    nytimes_top_terms <- nytimes_topics %>%
        group_by(topic) %>%
        top_n(10, beta) %>%
        ungroup() %>%
        arrange(topic, -beta)
    
    nytimes_top_terms %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip() + ggtitle('NYT Top terms in each LDA topic')
    
#------------------------------------------------------    
    #Topic Model for Guardian
    #   renaming tdm 
    dtm <- dtm_guardian
    dtm
    
    #   LDA function from topic model package k set to 4 for 4- topic LDA model 
    guardian_lda <- LDA(dtm, k = 4, control = list(seed = 1234))
    guardian_lda
    
    #   word topic probabilities 
    guardian_topics <- tidy(guardian_lda, matrix = "beta")
    guardian_topics
    
    #   Visualization of 4 topics that were extracted 
    guardian_top_terms <- guardian_topics %>%
        group_by(topic) %>%
        top_n(10, beta) %>%
        ungroup() %>%
        arrange(topic, -beta)
    
    guardian_top_terms %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip() + ggtitle('Guardian Top terms in each LDA topic')
    
    
     
    
    corp_guardian <- clean.corpus(combined_data[combined_data$source == "Guardian"]$body, stemming = TRUE)
    
    corp_nyt <- clean.corpus(combined_data[!combined_data$source == "Guardian"]$body, stemming = TRUE)

    dtm_guardian <- DocumentTermMatrix(corp_guardian)
        
    dtm_nyt <- DocumentTermMatrix(corp_nyt)

    save(dtm_guardian, file = "dtm_guardian.Rdata")    
    save(dtm_nyt, file = "dtm_nyt.Rdata")    
    