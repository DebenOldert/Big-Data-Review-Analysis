sentiment.test.threaded <- function(){
  env <- .GlobalEnv
  this <- new.env(parent = env)
  
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
  
  cat("*Intensive thinking* Hmmmm...\n")
  
  
  worker <- function(i, env, prog){
    scr <- sentiment.calc(set[i,]$review, progress = FALSE)
    env$setTxtProgressBar(prog, i)
    return(scr)
  }
  
  prog <- txtProgressBar(min = (MIN-1), max = MAX, style = 3)
  setTxtProgressBar(prog, (MIN-1))
  
  score <- unlist(mcmapply(worker, MIN:MAX, MoreArgs = list(env, prog), mc.cores = 4))
  
  close(prog)
  cat("Phoee... Finally done. Hope I did well...\n")
  
  score <- as.integer(mean(score)*100)
  
  if(score > 80){
    cat(paste0("OMG! I got ", as.character(score), "% correct!\n"))
  }
  else{
    cat(paste0("Hmm. I'm not happy with a score of ", as.character(score), "%\n"))
  }
  
  return(score)
}