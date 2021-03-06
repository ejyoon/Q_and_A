library(boot)
library(memoise)

equivocalFarLeftAnswers <- c("wooden chair", "burger", "dalmatian", "sunny beach")
equivocalNearLeftAnswers <- c("metal chair", "tomatos", "betta fish", "snowy forest")
equivocalNearRightAnswers <- c("metal stool", "carrot", "goldfish", "snowy mountain")
equivocalFarRightAnswers <- c("iron skillet", "sunflower", "angler fish", "ice hotel room")
branchingFarLeftAnswers <- c("mansion", "dalmatian", "carrot", "couch")
branchingNearLeftAnswers <- c("cottage", "poodle", "tomatos", "chair")
branchingNearRightAnswers <- c("office", "siamese cat", "sunflower", "table")
branchingFarRightAnswers <- c("park", "whale", "dead flower", "lawnmower")
overlappingFarLeftAnswers <- c("golden retriever", "dive bar", "oak", "wooden chair")
overlappingNearLeftAnswers <- c("house cat", "hotel lobby", "lettuce", "metal chair")
overlappingNearRightAnswers <- c("lion", "diner", "carrots", "iron skillet")
overlappingFarRightAnswers <- c("whale", "park", "flower", "wooden ruler")

mapAnswer <- function(type, answer) {
  if(type == "equivocal") {
    if(answer %in% equivocalFarLeftAnswers)
      return("A1")
    else if(answer %in% equivocalNearLeftAnswers)
      return("A2")
    else if(answer %in% equivocalNearRightAnswers)
      return("A3")
    else if(answer %in% equivocalFarRightAnswers)
      return("A4")
    else 
      stop(cat("Unrecognized answer in equivocal:", answer))
  } else if(type == "branching") {
    if(answer %in% branchingFarLeftAnswers)
      return("A1")
    else if(answer %in% branchingNearLeftAnswers)
      return("A2")
    else if(answer %in% branchingNearRightAnswers)
      return("A3")
    else if(answer %in% branchingFarRightAnswers)
      return("A4")
    else 
      stop(cat("Unrecognized answer in branching:", answer))
  } else if(type == "overlapping") {
    if(answer %in% overlappingFarLeftAnswers)
      return("A1")
    else if(answer %in% overlappingNearLeftAnswers)
      return("A2")
    else if(answer %in% overlappingNearRightAnswers)
      return("A3")
    else if(answer %in% overlappingFarRightAnswers)
      return("A4")
    else 
      stop(cat("Unrecognized answer in overlapping: ", answer))
  } else {
    stop(cat("Unrecognized type", type))
  }
}

equivocalLeftQuestions <- c("seat", "food", "pet", "outdoor place")
equivocalRightQuestions <- c("metal thing", "plant", "fish", "cold place")
branchingLowestLevelQuestions <- c("mansion", "dalmatian", "carrot", "couch")
branchingNextLowestLevelQuestions <- c("house", "dog", "food", "seat")
branchingNextHighestLevelQuestions <- c("building", "pet", "living plant", "furniture")
branchingHighestLevelQuestions <- c("place", "animal", "plant", "thing")
overlappingLowestLevelQuestions <- c("diner", "lion", "carrots", "skillet")
overlappingDominatedQuestions <- c("restaurant", "cat", "food", "metal thing")
overlappingNonDominatedQuestions <- c("bar", "pet", "leaves", "seat")
overlappingHighestLevelQuestions <- c("place", "animal", "plant", "thing")

mapQuestion <- function(type, question) {
  if(type == "equivocal") {
    if(question %in% equivocalLeftQuestions) {
      return("Q1")
    } else if(question %in% equivocalRightQuestions)
      return("Q2")
    else 
      stop(cat("Unrecognized question in equivocal:", question))
  } else if(type == "branching") {
    if(question %in% branchingLowestLevelQuestions)
      return("Q1")
    else if(question %in% branchingNextLowestLevelQuestions)
      return("Q2")
    else if(question %in% branchingNextHighestLevelQuestions)
      return("Q3")
    else if(question %in% branchingHighestLevelQuestions)
      return("Q4")
    else 
      stop(cat("Unrecognized question in branching:", question))
  } else if(type == "overlapping") {
    if(question %in% overlappingLowestLevelQuestions)
      return("Q1")
    else if(question %in% overlappingDominatedQuestions)
      return("Q2")
    else if(question %in% overlappingNonDominatedQuestions)
      return("Q3")
    else if(question %in% overlappingHighestLevelQuestions)
      return("Q4")
    else 
      stop(cat("Unrecognized question in overlapping: ", question))
  } else {
    stop(cat("Unrecognized type", type))
  }
}

mapGoal <- function(type, goal) {
  if(type == "equivocal") {
    if(goal %in% equivocalFarLeftAnswers)
      return("G1")
    else if(goal %in% equivocalNearLeftAnswers)
      return("G2")
    else if(goal %in% equivocalNearRightAnswers)
      return("G3")
    else if(goal %in% equivocalFarRightAnswers)
      return("G4")
    else 
      stop(cat("Unrecognized answer in equivocal:", goal))
  } else if(type == "branching") {
    if(goal %in% branchingFarLeftAnswers)
      return("G1")
    else if(goal %in% branchingNearLeftAnswers)
      return("G2")
    else if(goal %in% branchingNearRightAnswers)
      return("G3")
    else if(goal %in% branchingFarRightAnswers)
      return("G4")
    else 
      stop(cat("Unrecognized answer in branching:", goal))
  } else if(type == "overlapping") {
    if(goal %in% overlappingFarLeftAnswers)
      return("G1")
    else if(goal %in% overlappingNearLeftAnswers)
      return("G2")
    else if(goal %in% overlappingNearRightAnswers)
      return("G3")
    else if(goal %in% overlappingFarRightAnswers)
      return("G4")
    else 
      stop(cat("Unrecognized answer in overlapping: ", goal))
  } else {
    stop(cat("Unrecognized type", type))
  }
}

vectorizedMapAnswer <- Vectorize(mapAnswer);
vectorizedMapQuestion <- Vectorize(mapQuestion);
vectorizedMapGoal <- Vectorize(mapGoal);

mapWordsToNodes <- function(d) {
  answerNodes = c()
  questionNodes = c()
  goalNodes = c()
  for(i in 1:length(d$gameID)) {
    answerNodes <- append(answerNodes, mapAnswer(d[i,]$type, d[i,]$answer))
    questionNodes <- append(questionNodes, 
                            mapQuestion(d[i,]$type, d[i,]$question))
    goalNodes <- append(goalNodes, mapGoal(d[i,]$type, d[i,]$goal))
  }
  d$goalNodes = factor(goalNodes)
  d$answerNodes = factor(answerNodes)
  d$questionNodes = factor(questionNodes)
  return(d)
}

## This function takes a raw questioner data set ('q') or an answerer dataset ('a')
## and estimates the emperical probability of each response
##
## Note that this currently does not collapse over any aspect of the experiment.
## Below, the function getProbsAndCIs does so.
getProbs <- function(data, QorA, R) {
  if(QorA == "q") {
    tempData <- data %>% group_by(domain, type, goal, response) %>% 
      summarize(count = n()) %>%
      complete(response, type, domain, goal)
  } else if(QorA == "a") {
    tempData <- data %>% group_by(domain, type, utterance, response) %>% 
      summarize(count = n()) %>%
      complete(response, type, domain, utterance)
  } else {
    stop(cat("Did not specify Q or A:", QorA))
  }
  
  outputData <- tempData %>% 
    do(mutate(., count = ifelse(is.na(count), 0, count),
              empProb = count / sum(count),
              groupSize = sum(count))) %>%
    ungroup() %>%
    mutate(type = factor(type),
           domain = factor(domain)); 
  return(outputData)
}

emptyAnswerGrid <- function(d, collapseDomain) {
  if(collapseDomain) {
    g <- expand.grid(response = levels(d$response),
                     type = levels(factor(d$type)),
                     utterance = levels(factor(d$utterance)));
  } else {
    g <- expand.grid(response = levels(d$response),
                     domain = levels(factor(d$domain)),
                     type = levels(factor(d$type)),
                     utterance = levels(factor(d$utterance)))
  }
  return(g)
};

emptyQuestionGrid <- function(d, collapseDomain) {
  if(collapseDomain) {
    g <- expand.grid(response = levels(d$response),
                     type = levels(factor(d$type)),
                     goal = levels(factor(d$goal)));
  } else {
    g <- expand.grid(response = levels(d$response),
                     domain = levels(factor(d$domain)),
                     type = levels(factor(d$type)),
                     goal = levels(factor(d$goal)))
  }
  return(g)
};

# called a bunch of times on questioner data set to bootstrap CI
Qprobs <- function(collapseDomains, data, indices) {
  d <- data[indices,] # allows boot to select sample 
  pseudocount <- 0#runif(1, max = .25)
  emptyGrid <- emptyQuestionGrid(d, collapseDomains)
  c <- d %>% 
    group_by(response) %>% 
    summarize(count = n()) %>%
    right_join(emptyGrid, by = "response") %>% 
    do(mutate(., countp1 = ifelse(is.na(count), 
                                  pseudocount, count + pseudocount),
              count = ifelse(is.na(count), 0, count),
              empProb = countp1 / sum(countp1)))
  return(c$empProb)
}

# called a bunch of times on answerer data set to bootstrap CI
Aprobs <- function(collapseDomains, data, indices) {
  d <- data[indices,] # allows boot to select sample 
  pseudocount <- 0#runif(1, max = .25)
  emptyGrid <- emptyAnswerGrid(d, collapseDomains)
  c <- d %>%
    group_by(response) %>%
    summarize(count = n()) %>%
    right_join(emptyGrid, by = "response") %>%
    do(mutate(., countp1 = ifelse(is.na(count), pseudocount, count + pseudocount),
              count = ifelse(is.na(count), 0, count),
              empProb = countp1 / sum(countp1)))  
  return(c$empProb)
} 

## This function takes a raw questioner data set ('q') or an answerer dataset ('a')
## and estimates the emperical probability of each response, along with 
## bootstrapped confidence intervals
##
## Note that this currently does not collapse over any aspect of the experiment.
## If we want to do that in the future, will just group by fewer things before 
## summarizing
getProbsAndCIs <- function(data, QorA, R = 1000, collapseDomains) {
  if(QorA == "a") {
    emptyGrid = emptyAnswerGrid(data, collapseDomains)
  } else {
    emptyGrid = emptyQuestionGrid(data, collapseDomains)
  };
  outputData <- data %>% 
    group_by(response) %>%
    summarize(count = n()) %>%
    right_join(emptyGrid, by = "response") %>%
    do(mutate(., count = ifelse(is.na(count), 0, count),
              empProb = count / sum(count),
              groupSize = sum(count)))
  # Get confidence intervals
  if(QorA == "q") {
    bootObj <-  boot(data = data,statistic = Qprobs,R=R, collapseDomains=collapseDomains)
  } else {
    bootObj <-  boot(data = data,statistic = Aprobs,R=R, collapseDomains=collapseDomains)
  }
  upper_ci <- c()
  lower_ci <- c()
  for(i in 1:4) {
    lower = boot.ci(bootObj, index = i, type = "perc")$percent[4]
    upper = boot.ci(bootObj, index = i, type = "perc")$percent[5]
    if(is.null(lower) | is.null(upper)) {
      lower = outputData$empProb[i]
      upper = outputData$empProb[i]
    }
    lower_ci = append(lower_ci, lower)
    upper_ci = append(upper_ci, upper)
  }
  
  outputData$lower_ci = lower_ci
  outputData$upper_ci = upper_ci
  
  return(outputData)
}

# Expect two columns that end with _prob (i.e. emp_prob and model_prob)
optimalFit <- function(data, equal = FALSE) {
  prob_correlation <- data %>%
    group_by(modelLevel, rationality) %>%
    filter(rationality > 1) %>%
    summarise(correlation = cor(modelProb, empProb, method = 'pearson')) %>%
    mutate(m = max(correlation)) %>%
    ungroup() %>%
    filter(m == correlation) %>%
    mutate(maximizingR = rationality) %>%
    group_by(modelLevel, correlation) %>%
    summarize(maximizingR = min(maximizingR)) %>%
    select(modelLevel, maximizingR, correlation) %>%
    ungroup() 
  
  # add literal back in w/ correlation = NA
  if(!any(prob_correlation$modelLevel == "literal")) {
    prob_correlation <- rbind(prob_correlation, c('literal', 1.0, NA))
  }

  return(data %>% inner_join(prob_correlation) %>% 
           filter(rationality == maximizingR))
}
