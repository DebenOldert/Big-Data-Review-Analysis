# ##########
# Written by: Deben Oldert
# 
# Keep in mind that it took me several days/weeks and beers to make this.
# So please give me some credit. Naiba and I won't bite.
# 
# This program is called Naiba.
# She can tell you and learn if movie ratings are positive or negative
# 
# #########

PROCESSES <- ifelse(!is.na(detectCores()), detectCores(), 1)

sentiment.test.threaded <- function(){
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
  
  cat("*Intensive thinking* Hmmmm... (No progressbar will be shown, be patient)\n")
  
  
  worker <- function(i){
    scr <- (sentiment.calc(set[i,]$review, progress = FALSE)==as.integer(set[i,]$sentiment))
    return(scr)
  }
  
  time.start <- Sys.time()
  
  score <- mcmapply(worker, MIN:MAX, mc.cores = PROCESSES)
  
  time.end <- Sys.time()
  
  cat("Phoee... Finally done. Hope I did well...\n")
  
  cat("It took me", format(time.end - time.start, format = "%H:%M:%S"), "\n")
  score <- unlist(score)
  
  score <- as.integer(mean(score) * 100)
  
  if(score > 70){
    cat(paste0("OMG! I got ", as.character(score), "% correct!\n"))
  }
  else{
    cat(paste0("Hmm. I'm not quite happy with a score of ", as.character(score), "%\n"))
  }
  
  return(score)
}

learn.teach.threaded <- function(){
  env <- .GlobalEnv
  
  if(console.confirm("Do you want to train me so I can be better?")){
    if(exists("positive.cmb") && exists("positive.cnt") && exists("negative.cmb") && exists("negative.cnt")){
      cat("Hmmm... I already know someting.\n")
      if(!console.confirm("Do you want me to continue to learn? (Append learning skillset)")){
        env$positive.cmb <- c()
        env$positive.cnt <- c()
        env$negative.cmb <- c()
        env$negative.cnt <- c()
      }
    }
    else{
      env$positive.cmb <- c()
      env$positive.cnt <- c()
      env$negative.cmb <- c()
      env$negative.cnt <- c()
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
    
    worker <- function(x){
      prt <- as.integer((MAX - MIN + 1) / PROCESSES)
      if(x < PROCESSES) prt <- (((x - 1) * prt) + 1):(x * prt)
      else prt <- (((x - 1) * prt) + 1):MAX
      
      pos.cmb <- c()
      pos.cnt <- c()
      neg.cmb <- c()
      neg.cnt <- c()
      
      for(i in prt){
        if(set[i,]$sentiment == 1){
          pos <- sentiment.train.threaded(set[i,]$review, pos.cmb, pos.cnt)
          pos.cmb <- pos$cmb
          pos.cnt <- pos$cnt
        }
        else{
          neg <- sentiment.train.threaded(set[i,]$review, neg.cmb, neg.cnt)
          neg.cmb <- neg$cmb
          neg.cnt <- neg$cnt
        }
      }
      pos <- data.frame(positive.cmb=pos.cmb, positive.cnt=pos.cnt)
      neg <- data.frame(negative.cmb=neg.cmb, negative.cnt=neg.cnt)
      return(c(pos, neg))
      #return(list(pos.cmb=pos.cmb, pos.cnt=pos.cnt, neg.cmb=neg.cmb, neg.cnt=neg.cnt))
    }
    
    cat("Getting smarter... (No progressbar will be shown, be patient)\n")

    env$answer <- mcmapply(worker, 1:PROCESSES)
    
    if(console.confirm("Let me catch some breath here. Do you want me to remeber this training?")) learn.save()
  }
  cat("Now that I know everything. There is one thing you should learn.\n")
  cat("If you want me to analyse a review just call:\n\n")
  cat("sentiment.calc(<any text>)\n\n")
  cat("Now let's get started!\n")
}

sentiment.train.threaded <- function(str, cmb, cnt){
  spl <- sentiment.split(toupper(str))
  
  if((length(spl)-SENSITIVITY+1) < 1) {
    cat("You have to train me with more text.\n")
    return(list(cmb=cmb, cnt=cnt))
  }
  
  for(i in 1:(length(spl)-SENSITIVITY+1)){
    grp <- paste(spl[i:(i+SENSITIVITY-1)], collapse = ' ')
    mtc <- match(grp, cmb)
    if(!is.na(mtc)){
      cnt[mtc] <- cnt[mtc] + 1
    }
    else{
      cmb <- c(cmb, grp)
      cnt <- c(cnt, 1)
    }
  }
  return(list(cmb=cmb, cnt=cnt))
}