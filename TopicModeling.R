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

#   renaming tdm 
    dtm <- tdm
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
                  top_n(20, beta) %>%
                  ungroup() %>%
                  arrange(topic, -beta)

    nytimes_top_terms %>%
                  mutate(term = reorder(term, beta)) %>%
                  ggplot(aes(term, beta, fill = factor(topic))) +
                  geom_col(show.legend = FALSE) +
                  facet_wrap(~ topic, scales = "free") +
                  coord_flip() + ggtitle('Top terms in each LDA topic')

    
    
    corp_guardian <- clean.corpus(combined_data[combined_data$source == "Guardian"]$body, stemming = TRUE)
    
    corp_nyt <- clean.corpus(combined_data[!combined_data$source == "Guardian"]$body, stemming = TRUE)

    dtm_guardian <- DocumentTermMatrix(corp_guardian)
        
    dtm_nyt <- DocumentTermMatrix(corp_nyt)

    save(dtm_guardian, file = "dtm_guardian.Rdata")    
    save(dtm_nyt, file = "dtm_nyt.Rdata")    
    