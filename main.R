library(readr)
library(dplyr)
library(stringr)
library(parallel)
source("threaded.R")
SENSITIVITY <- 4

#MAX <- nrow(DATA1)
MAX <- 500

LEARNED.POSITIVE <- paste(getwd(), "learned_positive.csv", sep = "/")
LEARNED.NEGATIVE <- paste(getwd(), "learned_negative.csv", sep = "/")

cat("Hey there! My name is Naiba. Nice to meet you.\n")
cat("Thanks to the magic of multi-threading I have", PROCESSES, "brains (CPU). But this only works under a UNIX environment (e.g. MacOS).\n")
cat("Don't you even dare to call the *.threaded functions in a windwows environment.\n")
cat("If you have any question about me, just go to:\n")
cat("https://github.com/DebenOldert/Big-Data-Review-Analysis/blob/master/README.md\n")
cat("But that's enough trashtalk. Let's do this!")

sentiment.train <- function(str, sen){
  env <- .GlobalEnv
  spl <- sentiment.split(toupper(str))
  
  if((length(spl)-SENSITIVITY+1) < 1) {
    cat("You have to train me with more text.\n")
    return()
  }
  
  for(i in 1:(length(spl)-SENSITIVITY+1)){
    grp <- paste(spl[i:(i+SENSITIVITY-1)], collapse = ' ')
    if(sen == 1){
      mtc <- match(grp, env$positive.cmb)
      if(!is.na(mtc)){
        env$positive.cnt[mtc] <- env$positive.cnt[mtc] + 1
      }
      else{
        env$positive.cmb <- c(env$positive.cmb, grp)
        env$positive.cnt <- c(env$positive.cnt, 1)
      }
    }
    else{
      mtc <- match(grp, env$negative.cmb)
      if(!is.na(mtc)){
        env$negative.cnt[mtc] <- env$negative.cnt[mtc] + 1
      }
      else{
        env$negative.cmb <- c(env$negative.cmb, grp)
        env$negative.cnt <- c(env$negative.cnt, 1)
      }
    }
  }
}
sentiment.test <- function(){
  env <- .GlobalEnv
  
  cat("Ohh so you want to test me?\n")
  cat("Well come on then. Let's do this!\n\n")
  cat("First of all. Can you give me the test(set)?\n")
  
  set <- file.choose()
  set <- env$set.import(set)
  
  MAX <- nrow(set)
  MIN <- 1
  
  if(!console.confirm(paste("Do you want me to test all of the", as.character(nrow(set)), "records?"))){
    cat("Well thanks that might just saved me a huge headache.\n")
    repeat{
      MIN <- console.ask("So where do you want me to start?", type = "integer")
      if(MIN > 0 && MIN <= MAX) break
      else cat("Please enter a number bigger than 0 and smaller or equal than the records in this set.\n")
    }
    repeat{
     MAX <- console.ask("And where do you want me to stop?", type = "integer")
     if(MAX >= MIN && MAX <= nrow(set)) break
     else cat(paste("Please enter a number bigger or equal then", as.character(MIN), "and smaller or equal then", as.character(nrow(set))))
    }
  }
  score <- c()
  
  time.start <- Sys.time()
  cat("*Intensive thinking* Hmmmm...\n")
  
  progress <- txtProgressBar(min = (MIN - 1), max = MAX, style = 3)
  setTxtProgressBar(progress, (MIN - 1))
  
  for(i in MIN:MAX){
    test <- sentiment.calc(set[i,]$review, progress = FALSE)
    score <- c(score, (test==as.integer(set[i,]$sentiment)))
    setTxtProgressBar(progress, i)
  }
  
  time.end <- Sys.time()
  
  close(progress)
  
  cat("Phoee... Finally done. Hope I did well...\n")
  
  cat("It took me", format(time.end - time.start, format = "%H:%M:%S"), "\n")
  
  score <- as.integer(mean(score)*100)

  if(score > 80){
    cat(paste0("OMG! I got ", as.character(score), "% correct!\n"))
  }
  else{
    cat(paste0("Hmm. I'm not quite happy with a score of ", as.character(score), "%\n"))
  }
  
  return(score)
}
sentiment.calc <- function(str, progress=TRUE) {
  env <- .GlobalEnv
  spl <- sentiment.split(toupper(str))
  pos <- 0
  neg <- 0
  data <- data.frame(grp=character())
  
  if((length(spl)-SENSITIVITY+1) < 1){
    stop("I really need some more text to figure this one out.\n")
  }
  
  if(progress){
    time.start <- Sys.time()
    cat("Let me think...\n")
    prog <- txtProgressBar(0, (length(spl)-SENSITIVITY+1), style = 3)
  }
  for(i in 1:(length(spl)-SENSITIVITY+1)){
    grp <- paste(spl[i:(i+SENSITIVITY-1)], collapse = ' ')
    
    mtc <- match(grp, env$positive.cmb)
    if(!is.na(mtc)){
      pos <- pos + env$positive.cnt[mtc]
    }
    mtc <- match(grp, env$negative.cmb)
    if(!is.na(mtc)){
      neg <- neg + env$negative.cnt[mtc]
    }
    
    # if(nrow(env$positive[env$positive==grp,]) == 1){
    #   pos <- pos + env$positive[env$positive==grp,]$cnt
    # }
    # if(nrow(env$negative[env$negative==grp,]) == 1){
    #   neg <- neg + env$negative[env$negative==grp,]$cnt
    # }
    if(progress) setTxtProgressBar(prog, i)
  }
  
  if(progress){
    close(prog)
    time.end <- Sys.time()
    cat("It took me", format(time.end - time.start, format = "%H:%M:%S"), "\n")
  
    if(pos >= neg){
      cat("This must be a POSITIVE review\n")
    }
    else{
      cat("This must be a NEGATIVE review\n")
    }
  }
  print(pos)
  print(neg)
  return(pos >= neg)
}

sentiment.split <- function(str){
  return(na.omit(unlist(strsplit(unlist(str), "[^a-zA-Z]+"))))
}

learn.save <- function(){
  env <- .GlobalEnv
  
  if(!file.exists(LEARNED.POSITIVE) || console.confirm("Positive learned file already exists. Overwrite?")){
    pos <- data.frame(cmb=env$positive.cmb, cnt=env$positive.cnt)
    write_csv(pos, LEARNED.POSITIVE)
  }
  if(!file.exists(LEARNED.NEGATIVE) || console.confirm("Negative learned file already exists. Overwrite?")){
    neg <- data.frame(cmb=env$negative.cmb, cnt=env$negative.cnt)
    write_csv(neg, LEARNED.NEGATIVE)
  }
  
}

learn.load <- function(){
  env <- .GlobalEnv
  
  if(file.exists(LEARNED.POSITIVE) && file.exists(LEARNED.NEGATIVE)){
    if(console.confirm("I found out that I already learned something a while ago. Do you want to use that data?")){
      pos <- read_csv(LEARNED.POSITIVE)
      neg <- read_csv(LEARNED.NEGATIVE)
      
      env$positive.cmb <- pos$cmb
      env$positive.cnt <- pos$cnt
      env$negative.cmb <- neg$cmb
      env$negative.cnt <- neg$cnt
      
      return(TRUE)
    }
  }
  return(FALSE)
}

console.confirm <- function(str){
   repeat{
     ans <- readline(prompt = paste(str, "[Y|N]: "))
     if(ans == "Y") return(TRUE)
     if(ans == "N") return(FALSE)
     
     cat("Enter Y or N. Let's try it again.\n")
   }
}
console.ask <- function(str, type="string"){
  repeat{
    ans <- readline(prompt = paste0(str, " [", type, "]: "))
    if(type == "string"){
      return(ans)
    }
    if(type == "integer"){
      if(grepl("^[0-9]+$", ans)){
        return(as.integer(ans))
      }
    }
    
    cat(paste(type, "only please!", "\n"))
  }
}

set.import <- function(fullPath){
  suppressMessages(suppressWarnings(
  if(endsWith(fullPath, ".tsv")) return(read_delim(fullPath, "\t", escape_backslash = TRUE, escape_double = FALSE, trim_ws = TRUE))
  else if(endsWith(fullPath, ".csv")) return(read_csv(fullPath, trim_ws = TRUE))
  ))
}

learn.teach <- function(){
  if(console.confirm("Do you want to train me so I can be better?")){
    if(exists("positive.cmb") && exists("positive.cnt") && exists("negative.cmb") && exists("negative.cnt")){
      cat("Hmmm... I already know someting.\n")
      if(!console.confirm("Do you want me to continue to learn? (Append learning skillset)")){
        positive.cmb <- c()
        positive.cnt <- c()
        negative.cmb <- c()
        negative.cnt <- c()
      }
    }
    else{
      positive.cmb <- c()
      positive.cnt <- c()
      negative.cmb <- c()
      negative.cnt <- c()
    }
    
    set <- file.choose()
    
    set <- set.import(set)
    
    MAX <- nrow(set)
    MIN <- 1
    
    if(!console.confirm(paste("Do you want me to learn all of the", as.character(nrow(set)), "records?"))){
      cat("Well thanks that might just saved me a huge headache.\n")
      repeat{
        MIN <- console.ask("So where do you want me to start?", type = "integer")
        if(MIN > 0 && MIN <= MAX) break
        else cat("Please enter a number bigger than 0 and smaller or equal than ", as.character(MAX), "\n")
      }
      repeat{
        MAX <- console.ask("And where do you want me to stop?", type = "integer")
        if(MAX >= MIN && MAX <= nrow(set)) break
        else cat(paste("Please enter a number bigger or equal then", as.character(MIN), "and smaller or equal then", as.character(nrow(set))))
      }
    }
    
    
    cat("Getting smarter...\n")
    
    progress <- txtProgressBar((MIN-1), MAX, style = 3)
    setTxtProgressBar(progress, (MIN-1))
    
    for(i in MIN:MAX){
      sentiment.train(set[i,]$review, as.integer(set[i,]$sentiment))
      setTxtProgressBar(progress, i)
    }
    close(progress)
    
    if(console.confirm("Let me catch some breath here. Do you want me to remeber this training?")) learn.save()
  }
  cat("Now that I know everything. There is one thing you should learn.\n")
  cat("If you want me to analyse a review just call:\n\n")
  cat("sentiment.calc(<any text>)\n\n")
  cat("Now let's get started!\n")
}