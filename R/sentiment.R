

#' @title Sentiment analysis using the python pattern package.
#' @description Sentiment analysis using the python pattern package. See http://www.clips.ua.ac.be/pattern.
#' Only dutch/french/english
#' @param x a character string
#' @param language a character string with possible values 'dutch', 'french' or 'english'
#' @param id an identifier - to use later on to link
#' @param digest logical indicating to digest::digest the message
#' @return a data.frame with elements polarity, subjectivity and id, indicating
#' the sentiment, subjectivity score and the id
#' @export
#' @examples 
#' pattern_sentiment("i really really hate iphones", language = "english")
#' pattern_sentiment("We waren bijna bij de kooien toen er van boven 
#'  een hoeragejuich losbrak alsof Rudi Vuller door Koeman 
#'  in z'n kloten was geschopt.", language = "dutch")
#' pattern_sentiment("j'aime Paris, c'est super", language = "french")
pattern_sentiment <- function(x, language, id=x, digest=FALSE){
  stopifnot(language %in% c("dutch", "french", "english"))
  pyobj <- "message"
  if(digest){
    pyobj <- sprintf("message_%s", digest::digest(x))  
  }
  FUN <- switch(language, 
                dutch = "sentiment_nl", 
                french = "sentiment_fr", 
                english = "sentiment_en")
  pySet(key=pyobj, value = x)
  pyExec(sprintf("senti = %s(%s)", FUN, pyobj))
  score <- list(polarity = pyGet0(key = "senti[0]"), 
                subjectivity = pyGet0(key = "senti[1]"),
                id = id)
  # limit subjectivity to 0-1 range
  score$subjectivity <- ifelse(score$subjectivity > 1, 1, 
                               ifelse(score$subjectivity < 0, 0, score$subjectivity))
  score <- data.table::setDF(score)
  score
}