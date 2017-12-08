Bellarmine MSA Program Term III Project
Group 4 Members:
•	Tammy Hang
•	Paul Forst
•	Andrew Brill
•	Jay Bektasevic

INTRODUCTION

JPAT Times is a consulting firm that works with the print media to reduce the burden of manually reviewing the mountain of articles that are submitted to their publication. Through a review of a publications historical documents, we provide recommendations on which articles most closely fit their style. By using our proprietary filtering algorithms, we cannot only reduce the number of articles but also increase the overall quality of the material.

We also work with freelance writers and journalists to help them succeed in getting their material published to the most reputable sources in the United States. By providing a view into the type of content that sources typically publish, we can assist writers in gearing material to a specific publication.

JPAT Times has been hired by some of the most desirable sources in newspaper media to analyze articles for them. This project will result in the development of text mining strategies and statistical methods to deal with topics that abide by journalistic standards regarding the style and language of reporting.

THE DATA

New York Times Articles

We begin by registering for API (Application Processing Interface) access through the New York Times Developer Network. Through the use of the API and key, we can programmatically access the New York Times data. Currently, the API allows users to pull all items published within a given month and year. For our analysis, we initially focused on all the information for the first eleven months of this year. The data returned from the API includes numerous fields such as the website URL, document ID, headline, section, document type, keywords and other valuable information. While analyzing our data, we reduced our set only to documents that were

identified as “Articles” as well as focusing on a concentration in Politics, Travel, World News, and Sports sections.

The one crucial piece that was not contained in the returned information was the full document body. To gather that information, we use the provided URLs and utilize web scraping to pull the necessary text. Also, since each article potentially contains multiple associated keywords, the keywords were extracted from a secondary table linked through the article id number. While these keywords were not used currently, they are stored for potential use in future projects.

Guardian Articles

Once again, access to the Guardian data was accomplished through an API interface. However, the Guardian API returns the full body text which eliminated the need to scrape the information of each article after gathering the initial metadata. Overall, the data was relatively clean especially compared to the results returned from the NY Times. We reviewed the results and focused on articles from sections that could be compared to the Times. After reducing both data frames to a smaller set of key fields, the Guardian and New York Times tables were joined together to form the primary data source for our work.

PRE-PROCESSING

Data is almost never ready for analysis especially text data. We begin by creating a corpus (large and structured collection of documents) and utilize several common text pre-processing tasks such as:

    o remove punctuation
    o remove digits
    o remove extra white space
    o remove stop words (e.g. the, and, is, for)
    o conversion to lower case
    o remove numbers and special characters
    o stemming

The tm_map() function applies these cleaning tasks to the entire corpus. The other major pre-processing component is creating the document term matrix (DTM) which contains the frequency of terms in each document. That is, rows of the DTM represent documents and columns represent a unique term in the corpus. So, the (i,j)th entry of the DTM contains the number of times “term j” appeared in “document i”. By representing the corpus this way, we open the door for machine learning techniques to be used. In particular, algorithms such as Naive Bayes and SVM require that data is represented in the data-frame format.

It is also a good idea to produce a weighted version of the DTM by term frequency-inverse document frequency (tf-idf). This weighted version takes into account how often a term is used in the entire corpus as well as in a single document. The reasoning is that if a term is used in the entire corpus frequently, it is probably not as important when differentiating documents. On the other hand, if a word appears rarely in the corpus, it may be an important distinction even if it only occurs a few times in a document. In this analysis, both the unweighted and tf-idf weighted DTM’s are computed. The performances of various supervised learning methods using both
versions of the DTM are compared. Common terms can also be found (those which appear in at least a specified number of documents) with findFreqTerms() function.

Dimensionality Reduction

Oftentimes the document term matrix is highly dimensional and sparse. It often creates issues for machine learning algorithms during the training phase. For that reason, it is vital to reduce the dimensionality of the dataset by either feature selection or other dimensionality reduction methods. The feature selection selects important features from the original feature set while; the dimensionality reduction methods produce new features from the original set in some other dimension. We will apply Chi-Square as feature selection method.
In essence, the Chi-Square test is used to test the independence of two events. More precisely in feature selection, it is used to test whether the existence of a specific term and the existence of a specific class are independent. We will utilize chi.squared() function from the Fselector package.

Last but not least, the DTM’s were converted into data frames for modeling purposes. We also appended the document source as the last column (article.source) to be used as a target variable in supervised methods.

TEXT MINING APPROACHES

JPAT Times is responsible for deploying four different text mining and statistical methods. After careful and deliberate consideration, our team decided to focus on the following techniques:

· Unsupervised Classification Method

      o Topic Modeling is utilized for discovering the underlying topics that are presented in this unstructured collection of themes or         topics. Latent Dirichlet Allocation assumes that each document corpus contains a mix of topics that are found throughout the             entire corpus. The main strategies are that every word in each document is assigned a topic, the proportion of each unique               topic is estimated for every document, and for every corpus, the topic is distributed and is explored. The topic can then be             assumed to be a probability distribution across the multitude of words. We calculate the probability weights for words and               create topics based on those weights.

      o Word2Vec or Text2Vec: Created by a team of researchers led by Tomas Mikolov at Google, Word2Vec is a group of related models             that are used to produce word embeddings(WEMs) These models are shallow, two-layer neural networks that are trained to                   reconstruct linguistic contexts of words. Word2Vec takes as its input a large corpus of text and produces a vector space,               typically among hundred dimensions, with each unique word in the corpus being assigned a corresponding vector in the space.             Essentially, Word2Vec asks, “what if we could model all relationship between words as spatial ones” or “how can we reduce words         into a field where they are purely defined by their relations? Word2Vec try to reflect similarities in usage between words to           distances in space.

      o Lexical Diversity is used to determine the complexity of the language of each article. There are numerous methods for                   calculating the diversity but we decided to focus on the Measure of Lexical Diversity (MTLD) and the Flesch-Kincaid age level           calculation when analyzing the article text. MTLD was chosen because it’s fairly accepted as a good baseline and is also not             impacted by the document’s length like several other algorithms. The Flesch-Kincaid formula for reading and age level has become         very popular for use in many settings especially education. It generates a score based on how difficult a document is to read           and comprehend which can then be translated into a grade level and age.

· Supervised Classification Methods:

  We will use two classification algorithms to categorize news articles.

      o Support Vector Machine (SVM) with linear and radial kernels

        An SVM model is a representation of the examples as points in space, mapped so that the examples of the separate categories are         divided by a clear gap that is as wide as possible. New examples are then mapped into that same space and predicted to belong to         a category based on which side of the gap they fall on. In addition to performing linear classification, SVMs can efficiently           perform a non-linear classification using what is called the kernel trick, implicitly mapping their inputs into high-dimensional         feature spaces.

        The main task of an SVM is finding the optimal hyperplane with a maximum distance from the nearest training patterns which are           the support vectors. Only the support vectors are used for prediction/categorization which makes it computationally efficient.

      o Naïve Bayes

        Naive Bayes is often used for high-dimensional datasets. This makes Naive Bayes applicable for a wide variety of problems, such         as spam filter and in our case article classification.

        Naive Bayes is called ‘naive’ because it treats each of its inputs as an independent. In the case of text data, this is an               erroneous assumption, as textual features are often tied to one another in various ways. Nonetheless, the Naive Bayes classifier         generally achieves very good results on text data.

        The Naive Bayes model uses the priors which are defined as the number of observations in each class and the number of                   observations for each term over all classes. The likelihood is defined as the number of times a word occurs in each class.

For evaluation/comparison purposes we will use repeated 10-fold cross-validation. That is the training data is split into 10 subsets which are called folds. The algorithms are run 10 times each time using a different fold as the training dataset. In order to reduce the overfitting, this is repeated three times and the average error across all trials is computed.

Weighted average precision, recall, and f-score will be calculated that can be used for final model selection.

CONSTRAINTS

This typically leads to various linguistic and computational challenges for text mining analyses of news.

· Indexing, categorization/classification

      o Articles are segmented by time and by sources.
      o Multisource corpus, many articles published around the same time
      o Same classification/ popular topics (politics, business, world, etc.,)

§ May have arbitrary topics

§ Context and content meaning (followers, followees, retweet, web vs. social web)

· Language and meaning

      o Articles are written in object and structured language
      o American and British English

§ Vocabulary – (vacation vs. holiday, apartments vs. flats, cookies vs. biscuits)

§ Collective Nouns and Auxiliary Verbs

§ Spelling

· Interpretation of model parameters

RESOURCES

APIs 1. https://developer.nytimes.com/ 2. https://www.theguardian.com/uk

, Voa. “Six Differences Between British and American English.” VOA, VOA, 6 Sept. 2017, learningenglish.voanews.com/a/six-difference-between-britsh-and-american-english/3063743.html.
