##################################################################################################
# Auxiliar functions 
# Author: Ramon Gustavo Teodoro Marques da Silva - ramongsilva@yahoo.com.br

# Function to eliminate whitespaces
trim <- function(x) {
  gsub("(^[[:space:]]+|[[:space:]]+$)","",x)
}

# Function to cut whitespaces
countWhiteSpaces <- function(x) attr(gregexpr("(?<=[^ ])[ ]+(?=[^ ])", x, perl = TRUE)[[1]], "match.length")

# Clean pubmed abstracts
cleanFun <- function(htmlString) {

  htmlString = gsub("[&]", "", htmlString)
  htmlString = gsub("[;]", "", htmlString)
  htmlString = gsub("<.*?>", "", htmlString)
  htmlString = gsub("tumour","tumor", htmlString)
  htmlString = gsub("tumours","tumors", htmlString)
  return(htmlString)
}

######################################################################################
#Auxiliary functions for S1 AND S2 score calc in Ranking algorithm
######################################################################################
# Auxiliary function S1 score calc, for polyphenol-cancer sentences
s1_score_calc_PC <- function(lst_rules){
  peso = 0
  if(lst_rules[1] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[2] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[3] == 'sim'){
    peso = peso + 3
  }
  if(lst_rules[4] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[5] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[6] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[7] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[8] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[9] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[10] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[11] == 'sim'){
    peso = peso + 3
  }
  if(lst_rules[12] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[13] == 'sim'){
    peso = peso + 10
  }
  
  
  return(peso)
}

# Auxiliary function for S1 score calc, for polyphenol and cancer sentences
s1_score_calc_P <- function(lst_rules){
  peso = 0
  if(lst_rules[1] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[2] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[3] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[4] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[5] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[6] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[7] == 'sim'){
    peso = peso + 1  }
  if(lst_rules[8] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[9] == 'sim'){
    peso = peso + 3
  }
  if(lst_rules[10] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[11] == 'sim'){
    peso = peso + 2
  }
  if(lst_rules[12] == 'sim'){
    peso = peso + 7
  }
  return(peso)
}

# Auxiliary function for S2 score calc, for polyphenol-gene and gene sentences
s2_score_calc <- function(lst_rules){
  peso = 0
  if(lst_rules[1] == 'sim'){
    peso = peso + 1
  }
  if(lst_rules[2] == 'sim'){
    peso = peso + 2
  }
  return(peso)
}




