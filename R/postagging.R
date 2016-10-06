#' @title POS tagging using the python pattern package including relations.
#' @description POS tagging using the python pattern package including relations. See http://www.clips.ua.ac.be/pattern.
#' Only dutch/french/english/german
#' @param x a character string in UTF-8
#' @param language a character string with possible values 'dutch', 'french', 'english' or 'german'
#' @param digest logical indicating to digest::digest the message
#' @param as_html logical indicating to return only the xml (for debugging)
#' @return a data.frame with at least the elements sentence.id, sentence.language, chunk.id, chunk.type, chunk.pnp, chunk.relation, 
#' word.id, word, word.type, word.lemma or an xml object if as_xml is set to TRUE.
#' @export
#' @examples 
#' x <- "Mevrouw wenst zich aan te sluiten bij onze dienst, kan dat wel zomaar?"
#' pattern_pos(x = x, language = 'dutch')
#' 
#' x <- "Il pleure dans mon coeur comme il pleut sur la ville.
#'  Quelle est cette langueur qui penetre mon coeur?"
#' pattern_pos(x = x, language = 'french')
#' 
#' x <- "BNOSAC provides consultancy in open source analytical intelligence. 
#'  We gather dedicated open source software engineers with a focus on data mining, 
#'  business intelligence, statistical engineering and advanced artificial intelligence."
#' pattern_pos(x = x, language = 'english')
#' 
#' x <- "Der Turmer, der schaut zu Mitten der Nacht. 	
#'  Hinab auf die Graber in Lage
#'  Der Mond, der hat alles ins Helle gebracht.
#'  Der Kirchhof, er liegt wie am Tage.
#'  Da regt sich ein Grab und ein anderes dann."
#' pattern_pos(x = x, language = 'german')
pattern_pos <- function(x, language, digest=FALSE, as_html = FALSE){
  stopifnot(language %in% c("dutch", "french", "english", "german"))
  pyobj <- "messagepos"
  if(digest){
    pyobj <- sprintf("messagepos_%s", digest::digest(x))  
  }
  FUN <- switch(language, 
                dutch = "parse_nl", 
                french = "parse_fr", 
                english = "parse_en",
                german = "parse_de")
  
  pySet(key=pyobj, value = x)
  f <- file.path(tempdir(), "postagged.xml")
  pySet(key="outputfile", value = f)
  pyExec(sprintf("s = Text(%s(%s, tokenize = True, tags = True, chunks = True, lemmata = True, encoding = 'utf-8', relations = True)).xml", FUN, pyobj))
  pyExec(sprintf("f = open(outputfile, 'w')"))
  pyExec(sprintf("f.write(s)"))
  pyExec(sprintf("f.close()"))
  
  
  wordsinfo <- function(x){
    x <- lapply(x, wordinfo)
    rbindlist(x, fill = TRUE)
  }
  wordinfo <- function(x){
    list(word = xml2::xml_text(x),
         word.type = xml2::xml_attr(x, "type"),
         word.lemma = xml2::xml_attr(x, "lemma")
    )
  }
  chunkinfo <- function(x, level = 0L){
    info <- list()
    #info$chunk <-  setDT(as.list(xml2::xml_attrs(x)))
    info$chunk <-  setDT(list(type = xml2::xml_attr(x, "type"),
                              relation = xml2::xml_attr(x, "relation")))
    if(nrow(info$chunk) > 0){
      if(level == 0){
        setnames(info$chunk, old = colnames(info$chunk), new = sprintf("chunk.%s", colnames(info$chunk)))
      }else{
        setnames(info$chunk, old = colnames(info$chunk), new = sprintf("chunk.level%s.%s", level, colnames(info$chunk)))
      }  
    }
    
    
    children <- xml_children(x)
    if(all(xml_name(children) %in% "word")){
      info$children <- wordsinfo(children)
      class(info$children) <- c("word", "data.frame")
    }else{
      level <- level+1L
      info$children <- list()
      for(idx in seq_along(children)){
        child <- children[[idx]]
        childtype <- xml_name(child)
        if(childtype %in% c("chunk", "chink")){
          info$children[[idx]] <- chunkinfo(child, level = level) ## go one deeper
          if(nrow(info$children[[idx]]$chunk) == 0){
            lst <- list()
            lst[[sprintf("chunkid.level%s", level)]] <- idx
            info$children[[idx]]$chunk <- as.data.table(lst)
          }else{
            info$children[[idx]]$chunk[[sprintf("chunkid.level%s", level)]] <- idx
          }
        }else if(childtype %in% c("word")){
          info$children[[idx]] <- wordinfo(child)
          class(info$children[[idx]]) <- c("word", "data.frame")
        }else{
          print(child)
          stop('unexpected child type')
        }
      }
    }
    class(info) <- "chunk"
    info
  }
  rcombine <- function(x){
    if(inherits(x, "word")){
      return(x)
    }else if(inherits(x, "chunk")){
      if(inherits(x$children, "word")){
        return(cbind(x$chunk, x$children))
      }else{ # its a chunk
        x$children <- rcombine(x$children)
        return(cbind(x$chunk, x$children))
      }
    }else if(inherits(x, "list")){
      x <- lapply(x, rcombine)
      x <- rbindlist(x, fill = TRUE)
      return(x)
    }else{
      stop("rcombine - unexpected input")
    }
  }
  
  if(as_html){
    posxml <- xml2::read_html(f, encoding = "UTF-8")
    return(posxml)
  }
  posxml <- xml2::read_html(f, encoding = "UTF-8")
  sentences <- xml2::xml_find_all(posxml, "//sentence")
  sentences <- lapply(sentences, FUN=function(sentence){
    out <- list()
    out$sentence <- setDT(list(sentence.id = xml2::xml_attr(sentence, "id"),
                         sentence.language = xml2::xml_attr(sentence, "language")))
    chunks <- xml2::xml_find_all(sentence, "chunk|chink")
    out$chunks <- lapply(chunks, FUN=function(chunk){
      info <- chunkinfo(chunk)
      rcombine(info)
      # if(!is.data.frame(info$children)){
      #   
      #   info <- rcombine(info)
      #   info$children <- lapply(info$children, FUN=function(x) rcombine(x))
      #   info$children <- rbindlist(info$children, fill = TRUE)
      # }
      # if(nrow(info$chunk) > 0){
      #   info <- cbind(info$chunk, info$children)  
      # }else{
      #   info <- info$children
      # }
      # 
      # info
    })
    out$chunks <- Map(f = function(chunk, chunk.id){
      if(nrow(chunk) > 0){
        chunk$chunk.id <- chunk.id  
      }else{
        chunk <- data.table(chunk.id = chunk.id)
      }
      setcolorder(chunk, c("chunk.id", setdiff(colnames(chunk), "chunk.id")))
      chunk
    }, chunk = out$chunks, chunk.id = seq_along(out$chunks))
    out$chunks <- rbindlist(out$chunks, fill = TRUE)
    if(nrow(out$chunks) == 0){
      return(out$sentence)
    }
    out <- cbind(out$sentence, out$chunks)
  })
  tags <- rbindlist(sentences, fill = TRUE)
  tags <- tags[!is.na(tags$word), ] ## only a sentence/chunk, no word - not needed
  tags$word.id <- seq_len(nrow(tags))
  #tags$ends <- cumsum(nchar(tags$word))
  #tags$starts <- cumsum(c(1, nchar(tags$word)))[-(nrow(tags)+1)]
  #tags$test <- substr(rep(gsub(" ", "", x), nrow(tags)), tags$start, tags$end)
  #gregexpr(" ", x)
  #tags <- tags[, c("id", "type", "starts", "ends", "word", "lemma"), with = FALSE]
  tags$chunk.pnp <- NA_character_
  if("chunk.type" %in% colnames(tags)){
    idx <- which(tags$chunk.type %in% "PNP")
    tags$chunk.pnp[idx] <- tags$chunk.type[idx]
    ## keep the lowest type in case of PNP
    previdx <- idx
    for(column in grep("chunk.level.+.type", colnames(tags), value=TRUE)){
      levelidx <- which(tags[[column]]  %in% "PNP")
      levelidx <- intersect(previdx, levelidx)
      tags$chunk.type[levelidx] <- tags[[column]][levelidx]
      previdx <- levelidx
    }
  }
  colorder <- c("sentence.id", "sentence.language", 
                "chunk.id", "chunk.type", "chunk.pnp", "chunk.relation", 
                "word.id", "word", "word.type", "word.lemma")
  colorder <- c(colorder, setdiff(colnames(tags), colorder))
  tags <- tags[, colorder, with = FALSE]
  tags <- data.table::setDF(tags)
  tags
}
