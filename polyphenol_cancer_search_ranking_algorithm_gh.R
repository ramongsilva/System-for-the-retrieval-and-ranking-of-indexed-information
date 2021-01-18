##################################################################################################
# Ranking algorithm for recuperation of indexed information about polyphenol-cancer searches
# Author: Ramon Gustavo Teodoro Marques da Silva - ramongsilva@yahoo.com.br

#Import libraries
library(plyr) 
library(DBI)
library(RMySQL)
library(RCurl)
library(RSQLite)
library(stringr)
library(XML)
library(rJava)
library(qdap)
library(reshape)
library(reshape2)
library(tm)
library(data.table)
library(scales)


#Setting the folder with files 
setwd("project-folder/")
source("functions.R")


#############################################################################################
# Retrieving of data in SQLite database
# Retrieving the  textual corpus with pubmed abstracts classified about cancer activity
drv = dbDriver("SQLite")
con = dbConnect(drv,dbname="db_total_project.db")
sql_articles <- str_c("SELECT * FROM articles_ensemble",sep="")	
res_articles <- dbSendQuery(con, sql_articles)
df_articles_positives <- fetch(res_articles, n = -1)
dbDisconnect(con)
df_articles_positives$med2 = (df_articles_positives$SVM_PROB + df_articles_positives$FORESTS_PROB + df_articles_positives$MAXENTROPY_PROB) / 3
df_articles = df_articles_positives
newdata <- df_articles_positives[order(-df_articles_positives$med),] 
rownames(newdata) = c(1:nrow(newdata))
lista_articles = newdata[,1]

#############################################################################################
# Retrieving datafames with named entity and rules associations recognized in pubmed abstracts
# sentences on Information Extraction step
setwd("project-folder/entities-recognized/")
df_entities01_2000 = fread(file = 'df_entities01_2000.tsv')
df_entities2001_5000 = fread(file = 'df_entities2001_5000.tsv')
df_entities5001_8000 = fread(file = 'df_entities5001_8000.tsv')
df_entities8001_9000 = fread(file = 'df_entities8001_9000.tsv')
df_entities9001_10000 = fread(file = 'df_entities9001_10000.tsv')
df_entities10001_11000 = fread(file = 'df_entities10001_11000.tsv')
df_entities11001_14000 = fread(file = 'df_entities11001_14000.tsv')
df_entities14001_15000 = fread(file = 'df_entities14001_15000.tsv')
df_entities15001_16000 = fread(file = 'df_entities15001_16000.tsv')
df_entities16001_17000 = fread(file = 'df_entities16001_17000.tsv')
df_entities17001_18000 = fread(file = 'df_entities17001_18000.tsv')
df_entities18001_21000 = fread(file = 'df_entities18001_21000.tsv')
df_entities21001_23000 = fread(file = 'df_entities21001_23000.tsv')
df_entities23001_26000 = fread(file = 'df_entities23001_26000.tsv')
df_entities_n_encontradas = fread(file = 'df_entities_n_encontradas.tsv')
df_entities_total = rbind(df_entities01_2000,df_entities2001_5000,df_entities5001_8000,df_entities8001_9000,df_entities9001_10000,df_entities10001_11000,df_entities11001_14000,df_entities14001_15000,df_entities15001_16000,df_entities16001_17000,df_entities17001_18000,df_entities18001_21000,df_entities21001_23000,df_entities23001_26000,df_entities_n_encontradas)
setwd("project-folder/")
df_articles_rules = read.table(file = 'Rule_associations_recognized.tsv', stringsAsFactors = FALSE, sep = '\t', fill = TRUE)

################################################################################
# Processing in start_pos attribute of df_entities_total dataframe
c = 0
for(i in 1:nrow(df_entities_total)){
  if(df_entities_total$start_pos[i] == 0){
    df_entities_total$start_pos[i] = 1
    c = c + 1
    cat('\n PMID = ',df_entities_total$entity_pmid[i])
  }
}



####################################################################################
# Ranking algorithm for search of polyphenol-cancer
#####################################################################################
# Select 1 to 3 examples

#genistein
id_polifenol = '127'
#colorectal cancer
id_cancer = '15585' 
#122

#luteolin
id_polifenol = '117'
#colorectal cancer
id_cancer = '15585'
#55

#Flavonoid
id_polifenol = '104'
#colorectal cancer
id_cancer = '15585'

#####################################################################################
# Start of algorithm processing

# Retrieving datafames with indexing of polyphenol-cancer associations
setwd("project-folder/information-indexed")
df_cross_index_polyphenol_cancer = read.table(file = 'df_cross_indexation_polyphenol_cancer_association.tsv', stringsAsFactors = FALSE, sep = '\t', fill = TRUE)
# Selecting indexed pubmed abstracts with the polyphenol and cancer searched
articles_intersect = unlist(strsplit(df_cross_index_polyphenol_cancer[(df_cross_index_polyphenol_cancer$id_polifenol == id_polifenol & df_cross_index_polyphenol_cancer$id_cancer == id_cancer),]$pmids,','))

c = 0
lst_pmids = list()
lst_pesos =list()
lst_pesos_entities = list()
lst_pesos_genes = list()
lst_genes = list()
lst_genes_freq = list()
lst_score = list()
for(i in 1:length(articles_intersect)){
  #For each PMID, selecting sentences with rules and searched entities recognized
  rule_sentences = df_articles_rules[df_articles_rules$pmid == articles_intersect[i],]
  rule_sentences$end_pos = as.numeric(rule_sentences$end_pos)
  entity_sentences = df_entities_total[df_entities_total$entity_pmid == articles_intersect[i],]
  #Calc of S3 score (number of entities occurrence)
  total_s3_score = 0
  peso_entities_other_cancers = entity_sentences[(entity_sentences$term_id == '10007' & entity_sentences$entity_pmid == articles_intersect[i] & (entity_sentences$entity_type == "cancer_type_entity_p" | entity_sentences$entity_type == "cancer_type_entity_e" | entity_sentences$entity_type == "cancer_type_entity_cell")),]
  peso_entities_cancer = entity_sentences[(entity_sentences$term_id == id_cancer & entity_sentences$entity_pmid == articles_intersect[i] & (entity_sentences$entity_type == "cancer_type_entity_p" | entity_sentences$entity_type == "cancer_type_entity_e" | entity_sentences$entity_type == "cancer_type_entity_cell")),]
  peso_entities_polifenol = entity_sentences[(entity_sentences$term_id == id_polifenol & entity_sentences$entity_pmid == articles_intersect[i] & (entity_sentences$entity_type == "chemical_entity_e" | entity_sentences$entity_type == "chemical_entity_p")),]
  peso_entities_genes = entity_sentences[(entity_sentences$entity_pmid == articles_intersect[i] & (entity_sentences$entity_type == "gene_hgnc_entity" | entity_sentences$entity_type == "gene_entity")),]
  total_s3_score = nrow(peso_entities_genes) + nrow(peso_entities_polifenol) + nrow(peso_entities_cancer) + nrow(peso_entities_other_cancers)
  #S1 and S2 scores for each pubmed abstract
  total_s1_score = 0
  total_s2_score = 0
  genes_total = ''
  chave = ''
  ##########################################################################################
  #Only articles containing at least one recognized rule are considered
  if(nrow(rule_sentences) > 0){
    entity_sentences = df_entities_total[df_entities_total$entity_pmid == articles_intersect[i],]
    #For each sentence of pubmed abstract, is calculated S1 and S2 scores
    for(j in 1:nrow(rule_sentences)){
      #S1 Score for sentence
      s1_score = 0
      #S2 score for sentence
      s2_score = 0
      genes = ''
      #Checks for the occurrence of generic "cancer 10007" entities within the sentence with recognized rule, starting from the START and END positions
      entity_sentence_other_cancers = entity_sentences[(entity_sentences$term_id == '10007' & entity_sentences$entity_pmid == rule_sentences$pmid[j] & entity_sentences$start_pos >= rule_sentences$start_pos[j] & entity_sentences$end_pos <= rule_sentences$end_pos[j] & (entity_sentences$entity_type == "cancer_type_entity_p" | entity_sentences$entity_type == "cancer_type_entity_e" | entity_sentences$entity_type == "cancer_type_entity_cell")),]
      #Checks the occurrence of entities from the id_cancer searched within the sentence with recognized rule, starting from the START and END positions
      entity_sentence_cancer = entity_sentences[(entity_sentences$term_id == id_cancer & entity_sentences$entity_pmid == rule_sentences$pmid[j] & entity_sentences$start_pos >= rule_sentences$start_pos[j] & entity_sentences$end_pos <= rule_sentences$end_pos[j] & (entity_sentences$entity_type == "cancer_type_entity_p" | entity_sentences$entity_type == "cancer_type_entity_e" | entity_sentences$entity_type == "cancer_type_entity_cell")),]
      #Checks the occurrence of entities of the id_polifenol searched within the sentence with associated rule, starting from the START and END positions
      entity_sentence_polifenol = entity_sentences[(entity_sentences$term_id == id_polifenol & entity_sentences$entity_pmid == rule_sentences$pmid[j] & entity_sentences$start_pos >= rule_sentences$start_pos[j] & entity_sentences$end_pos <= rule_sentences$end_pos[j] & (entity_sentences$entity_type == "chemical_entity_e" | entity_sentences$entity_type == "chemical_entity_p")),]
      #Checks for the occurrence of gene entities in general within the recognized rule sentence, from the START and END positions
      entity_sentence_genes = entity_sentences[(entity_sentences$entity_pmid == rule_sentences$pmid[j] & entity_sentences$start_pos >= rule_sentences$start_pos[j] & entity_sentences$end_pos <= rule_sentences$end_pos[j] & (entity_sentences$entity_type == "gene_hgnc_entity" | entity_sentences$entity_type == "gene_entity")),]
      #Get the gene names related to sentence
      if(nrow(entity_sentence_genes) > 0){
         genes = paste(entity_sentence_genes$db_term, collapse = ',')
      }else{
        genes = ''
      }
      
      #Here are used 3 functions for S1 and S2 scores calculation:
      # - calc_peso_polifenol_cancer: for polyphenol-cancer sentences
      # - calc_peso_polifenol_gene: for all sentences
      # - calc_peso_polifenol: for polyphenol and cancer sentences
      ################### POLYPHENOL-CANCER SENTENCE ###################
      if((nrow(entity_sentence_polifenol) > 0) & (nrow(entity_sentence_cancer) > 0)) {
        rules_s1_score = as.character(rule_sentences[j,c(4:13,17,19,29)])
        s1_score = calc_peso_polifenol_cancer(rules_s1_score)
        rules_s2_score = as.character(rule_sentences[j,c(14,15)])
        s2_score = calc_peso_polifenol_gene(rules_s2_score)
      }else{
        ################### POLYPHENOL- SENTENCE ###################
          if(nrow(entity_sentence_polifenol) > 0) {
            rules_s1_score = as.character(rule_sentences[j,c(5:9,11:13,17:19,29)])
            s1_score = calc_peso_polifenol(rules_s1_score) 
            rules_s2_score = as.character(rule_sentences[j,c(14,15)])
            s2_score = calc_peso_polifenol_gene(rules_s2_score)
          }else{
            ################### CANCER- SENTENCE ###################
            if((nrow(entity_sentence_cancer) > 0) | (nrow(entity_sentence_other_cancers) > 0)) {
              rules_s1_score = as.character(rule_sentences[j,c(5:9,11:13,17:19,29)])
              s1_score = calc_peso_polifenol(rules_s1_score) 
              s2_score = 0
              }else{
                ################### GENE- SENTENCE or POLYPHENOL-GENE SENTENCE ###################
                if(nrow(entity_sentence_genes) > 0) {
                  rules_s2_score = as.character(rule_sentences[j,c(14,15)])
                  s2_score = calc_peso_polifenol_gene(rules_s2_score)
                  s1_score = 0
                }
              }
            }
        }
      
      #Final calc of S1 and S2 scorefor each sentence
      cat('\n S1 + S2 score = ',s1_score + s2_score)
      
      #Calc the final S1 and S2 score
      #S1 Score
      total_s1_score = total_s1_score + s1_score
      #S2 Score
      total_s2_score = total_s2_score + s2_score
      
      #Selecting gene names of pubmed abstract
      if((nchar(genes_total) == 0) & (nchar(genes) == 0)){
        genes_total = ''
      }else{
        if((nchar(genes_total) == 0) & (nchar(genes) > 0)){
          genes_total = genes
        }else{
          if((nchar(genes_total) > 1) & (nchar(genes) > 0)){
            genes_total = str_c(genes_total,',',genes)
          }else{
            genes_total = genes_total
          }
        }
      }

    }
    #####################################################################################
    # Final calc of pubmed abstract S1 and S2 score 
    
    #Formart genes extracted from pubmed abstracts 
    if(nchar(genes_total) > 2){
        genes_total = strsplit(genes_total,',')
        genes_total = unlist(genes_total)
        genes_total = stripWhitespace(genes_total)
        cat('\n genes_total 3 = ',genes_total)
        genes_total = data.frame(table(genes_total))
        genes_total[,1] =  paste(genes_total[,1], collapse = ',')
        genes_total[,2] = paste(genes_total[,2], collapse = ',')
        chave = 'sim'
    }else{
      chave = 'nao'
    }
    #Format row for dataframe
    c = c + 1
    cat('\n\n pmid = ',rule_sentences$pmid[j])
    cat('\n Peso = ',total_s1_score)
    lst_pmids[c] = rule_sentences$pmid[j]
    lst_pesos[c] = total_s1_score
    lst_pesos_entities[c] = total_s3_score
    lst_pesos_genes[c] = total_s2_score
    if(chave == 'sim'){
      lst_genes[c] = genes_total$genes_total
      lst_genes_freq[c] = genes_total$Freq
    }else{
      lst_genes[c] = ''
      lst_genes_freq[c] = ''
    }
    #S5 score from text classification step
    scores = newdata[newdata$pmid == rule_sentences$pmid[j],]
    lst_score[c] = scores$med2[1]
    
  }
}
#####################################################################################
# Final of processing
# Creating a final dataframe with ranking of pubmed abstracts about the polyphenol and cancer searched
df_ranking = data.frame(pmid = unlist(lst_pmids), s1_score = unlist(lst_pesos), s2_score = unlist(lst_pesos_genes), s3_score = unlist(lst_pesos_entities), genes = unlist(lst_genes), genes_freq = unlist(lst_genes_freq), s5_score = unlist(lst_score), stringsAsFactors = FALSE)
# Normalization of S1, S2 e S3 scores 
df_ranking$s1 = rescale(df_ranking$s1_score)
df_ranking$s3 = rescale(df_ranking$s2_score)
df_ranking$s2 = rescale(df_ranking$s3_score)
# Creating of s4 score 
df_ranking$s4 = (((df_ranking$s1 * 5) + (df_ranking$s3 * 3) + (df_ranking$s2 * 2)) / 10)
# Order by the dataframe for descendent s4 score 
df_ranking = df_ranking[order(-df_ranking$s4),]
rownames(df_ranking) = c(1:nrow(df_ranking))
df_ranking = df_ranking[,c(1,8,10,9,11,7,2,3,4,5,6)]

####################################################################################################
#Result of Ranking algorithm for search of polyphenol-cancer
####################################################################################################
# Dataframe with results (output) of algorithm execution
View(df_ranking)




