
.onAttach <- function(libname, pkgname){
  ## Setup python connection
  py <- findpython::can_find_python_cmd(required_modules = "pattern.db")
  if(py){
    if(!PythonInR::pyIsConnected()){
      PythonInR::pyConnect(attributes(py)$python_cmd)
    }
    PythonInR::pyExec("from pattern.db import *")
    
    ## sentiment analysis
    PythonInR::pyExec("from pattern.nl import sentiment as sentiment_nl")
    PythonInR::pyExec("from pattern.en import sentiment as sentiment_en")
    PythonInR::pyExec("from pattern.fr import sentiment as sentiment_fr")  
    
    ## POS parsing
    PythonInR::pyExec("from pattern.text.tree import Text")
    PythonInR::pyExec("from pattern.nl import parse as parse_nl")
    PythonInR::pyExec("from pattern.en import parse as parse_en")
    PythonInR::pyExec("from pattern.fr import parse as parse_fr")
    PythonInR::pyExec("from pattern.de import parse as parse_de")
    
  }
  invisible()
}
