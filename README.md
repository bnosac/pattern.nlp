# pattern.nlp
R package to perform sentiment analysis for Dutch/French/English and Parts of Speech tagging for Dutch/French/English/German/Spanish/Italian

The  **pattern.nlp** package allows to do the following text mining tasks based on the pattern library

- POS tagging: Parts of Speech tagging for Dutch, French, English, German, Spanish, Italian
- Sentiment analysis: Sentiment + subjectivity scoring for Dutch, French, English

![](inst/img/pattern-nlp-logo.png)

## Examples

The following shows how to use the package

### Sentiment analysis

```
library(pattern.nlp)

## Sentiment analysis
x <- pattern_sentiment("i really really hate iphones", language = "english")
y <- pattern_sentiment("We waren bijna bij de kooien toen er van boven 
  een hoeragejuich losbrak alsof Rudi Vuller door Koeman in z'n kloten was geschopt.", language = "dutch")
z <- pattern_sentiment("j'aime Paris, c'est super", language = "french")
rbind(x, y, z)

polarity subjectivity                                               id
   -0.80         0.90                     i really really hate iphones
    0.70         1.00                 We waren bijna bij de kooien ...
    0.65         0.75                        j'aime Paris, c'est super
```

### Parts of Speech tagging

```
x <- "Dus godvermehoeren met pus in alle puisten, zei die schele van Van Bukburg en hij had nog gelijk ook.
 Er was toen dat liedje van tietenkonttieten kot tieten kontkontkont, maar dat hoefden we geenseens niet te zingen"
pattern_pos(x = x, language = 'dutch')

x <- "Il pleure dans mon coeur comme il pleut sur la ville. Quelle est cette langueur qui penetre mon coeur?"
pattern_pos(x = x, language = 'french')

x <- "BNOSAC provides consultancy in open source analytical intelligence. 
 We gather dedicated open source software engineers with a focus on data mining, 
 business intelligence, statistical engineering and advanced artificial intelligence."
pattern_pos(x = x, language = 'english')

x <- "Der Turmer, der schaut zu Mitten der Nacht. 	
 Hinab auf die Graber in Lage
 Der Mond, der hat alles ins Helle gebracht.
 Der Kirchhof, er liegt wie am Tage.
 Da regt sich ein Grab und ein anderes dann."
pattern_pos(x = x, language = 'german')

x <- "Pasaron cuatro jinetes, sobre jacas andaluzas
 con trajes de azul y verde, con largas capas oscuras."
pattern_pos(x = x, language = 'spanish')

x <- "Avevamo vegliato tutta la notte - i miei amici ed io sotto lampade 
  di moschea dalle cupole di ottone traforato, stellate come le nostre anime, 
  perché come queste irradiate dal chiuso fulgòre di un cuore elettrico."
pattern_pos(x = x, language = 'italian')
```

The output of the POS tagging shows at least the following elements:
```
sentence.id sentence.language chunk.id chunk.type chunk.pnp chunk.relation word.id     word word.type word.lemma
          9                fr        1         NP      <NA>            SBJ       1       Il       PRP         il
          9                fr        2         VP      <NA>           <NA>       2   pleure        VB    pleurer
          9                fr        3        PNP       PNP           <NA>       3     dans        IN       dans
          9                fr        3        PNP       PNP           <NA>       4      mon      PRP$        mon
          9                fr        3        PNP       PNP           <NA>       5    coeur        NN      coeur
          9                fr        4        PNP       PNP           <NA>       6    comme        IN      comme
          9                fr        4        PNP       PNP           <NA>       7       il       PRP         il
          9                fr        5         VP      <NA>           <NA>       8    pleut        VB   pleuvoir
          9                fr        6        PNP       PNP           <NA>       9      sur        IN        sur
          9                fr        6        PNP       PNP           <NA>      10       la        DT         la
          9                fr        6        PNP       PNP           <NA>      11    ville        NN      ville
          9                fr        7       <NA>      <NA>           <NA>      12        .         .          .
         10                fr        1         NP      <NA>            SBJ      13   Quelle       PRP     quelle
         10                fr        2         VP      <NA>           <NA>      14      est        VB       être
         10                fr        3         NP      <NA>            OBJ      15    cette       PRP      cette
         10                fr        3         NP      <NA>            OBJ      16 langueur        NN   langueur
         10                fr        4       <NA>      <NA>           <NA>      17      qui        WP        qui
         10                fr        5         VP      <NA>           <NA>      18  penetre        VB    penetre
         10                fr        6         NP      <NA>            OBJ      19      mon      PRP$        mon
         10                fr        6         NP      <NA>            OBJ      20    coeur        NN      coeur
         10                fr        7       <NA>      <NA>           <NA>      21        ?         .          ?
```

More information about these tags can be found at http://www.clips.ua.ac.be/pages/mbsp-tags
## Installation

First install Python version 2.5+ (not version 3) and the pattern package (https://github.com/clips/pattern). Mark that the pattern package is released under the BSD license. 

```
pip install pattern
```

Make sure the location of Python is into the PATH and proceed by installing the R package pattern.nlp as follows:

```
devtools::install_github("bnosac/pattern.nlp", args = "--no-multiarch")
```

Make sure your when you run the R version (64/32 bit) it is the same as the Python version you installed (64/32 bit).
Advise: don't use RStudio, but just plain R when executing the code. 
Mark that the pattern.nlp package is released under the AGPL-3 license.

## Support in text mining

Need support in text mining. 
Contact BNOSAC: http://www.bnosac.be
