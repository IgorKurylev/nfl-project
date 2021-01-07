filtered\_heatmapping
================
yurkovkirill
05 01 2021

\#Setup

``` r
library(DBI)
library(ggplot2)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(MASS)
```

    ## 
    ## Attaching package: 'MASS'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

``` r
library(raster)
```

    ## Loading required package: sp

    ## 
    ## Attaching package: 'raster'

    ## The following objects are masked from 'package:MASS':
    ## 
    ##     area, select

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     select

``` r
knitr::opts_knit$set(root.dir = "D:/MyFilesDesktop/Student/7SEM/DataScience/DS_Project")
```

\#Filling DataBase

``` r
con <- dbConnect(RSQLite::SQLite(), ":memory:")
#dbListTables(con)
#options(max.print=10000)

dbWriteTable(con, "games", read.csv("data/games.csv"))
dbWriteTable(con, "allWeeks", read.csv("data/week1.csv"))
dbListFields(con, "allWeeks")
```

    ##  [1] "time"          "x"             "y"             "s"            
    ##  [5] "a"             "dis"           "o"             "dir"          
    ##  [9] "event"         "nflId"         "displayName"   "jerseyNumber" 
    ## [13] "position"      "frameId"       "team"          "gameId"       
    ## [17] "playId"        "playDirection" "route"

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week2.csv"))
```

    ## [1] 1231793

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week3.csv"))
```

    ## [1] 1168345

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week4.csv"))
```

    ## [1] 1205527

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week5.csv"))
```

    ## [1] 1171908

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week6.csv"))
```

    ## [1] 1072563

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week7.csv"))
```

    ## [1] 982583

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week8.csv"))
```

    ## [1] 1001501

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week9.csv"))
```

    ## [1] 958464

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week10.csv"))
```

    ## [1] 964889

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week11.csv"))
```

    ## [1] 932240

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week12.csv"))
```

    ## [1] 1024868

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week13.csv"))
```

    ## [1] 1172517

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week14.csv"))
```

    ## [1] 1161644

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week15.csv"))
```

    ## [1] 1081222

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week16.csv"))
```

    ## [1] 1144037

``` r
dbAppendTable(con, "allWeeks", read.csv("data/week17.csv"))
```

    ## [1] 1049265

``` r
dbGetQuery(con, "SELECT COUNT(*) FROM allWeeks")
```

    ##   COUNT(*)
    ## 1 18309388

``` r
# Add additional column for statistic:
# - success
# - yardFromDefTouch
plays <- read.csv("data/plays.csv")
plays$success <- 0
plays$success[plays$playResult >= plays$yardsToGo] <- 1
plays$yardFromDefTouch <- 0
dbWriteTable(con, "plays", plays)
dbExecute(con, "UPDATE plays SET yardFromDefTouch = CASE 
                WHEN (possessionTeam = yardlineSide) THEN (100 - yardlineNumber) 
                ELSE yardlineNumber
                END")
```

    ## [1] 19239

``` r
dbListTables(con)
```

    ## [1] "allWeeks" "games"    "plays"

``` r
#dbRemoveTable(con, "games")
#dbRemoveTable(con, "plays")
#dbRemoveTable(con, "allWeeks")
```

# Modify play table team column

``` r
################################################################################################################
# Обработка данных
################################################################################################################
##### Нормальный отбор по команде нападения BEGIN
# QUERIES for teams ########################
dbExecute(con, "UPDATE plays as p SET possessionTeam = 'away'
                WHERE possessionTeam != (SELECT homeTeamAbbr FROM games as g WHERE p.gameId = g.gameId)")
```

    ## [1] 9621

``` r
dbExecute(con, "UPDATE plays as p SET possessionTeam = 'home'
                WHERE possessionTeam = (SELECT homeTeamAbbr FROM games as g WHERE p.gameId = g.gameId)")
```

    ## [1] 9618

Check it

``` r
testTeam1 <- dbGetQuery(con, "SELECT team, COUNT(DISTINCT(playId)) FROM allWeeks as w GROUP BY team")
testTeam1
```

    ##       team COUNT(DISTINCT(playId))
    ## 1     away                    4591
    ## 2 football                    4592
    ## 3     home                    4592

``` r
# проверка
testTeamPlay <- dbGetQuery(con, "SELECT possessionTeam, COUNT(DISTINCT(playId)) FROM plays GROUP BY possessionTeam")
testTeamPlay
```

    ##   possessionTeam COUNT(DISTINCT(playId))
    ## 1           away                    3973
    ## 2           home                    3992

# New ball snap table

``` r
#######################################################################################################################
# берем информацию по мячу ## MAIN QUERY for init point (ball)
#######################################################################################################################

#dbListFields(con, "plays")
dbWriteTable(con, "football_inSnap1", dbGetQuery(con, "SELECT p.epa, w.x as x_b, w.y as y_b, w.displayName, w.event, w.playId,
                                      w.gameId, p.offenseFormation, p.possessionTeam, p.yardFromDefTouch, p.success
                                      FROM plays as p JOIN allWeeks as w ON p.gameId = w.gameId
                                      AND p.playId = w.playId WHERE w.event = 'ball_snap' AND w.displayName = 'Football'"))
dbListFields(con, "football_inSnap1")
```

    ##  [1] "epa"              "x_b"              "y_b"              "displayName"     
    ##  [5] "event"            "playId"           "gameId"           "offenseFormation"
    ##  [9] "possessionTeam"   "yardFromDefTouch" "success"

``` r
#dbRemoveTable(con, "football_inSnap1")
```

# Filling DataBase End

``` r
######## FUNCTIONS #####################################################################################################
############################ PLOT FUNC DEF #####################
relGraphs <- function(df, strBest, strWin, strBestWin){
  summary(df)
  dfBest <- df[df$epa < summary(df$epa)[[2]],]
  dfWin <- df[df$success == 0,]
  dfBestWin <- df[df$epa < summary(df$epa)[[2]] & df$success == 0,]
  
  if(nrow(dfBest) > 1){
    dfBestPlot <- dfBest %>% 
      ggplot(aes(x = x_rel, y = y_rel)) +
      geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + 
      labs(title=strBest)
  } else {
    dfBestPlot <- list(dfBest[,c(2,3)], strBest) 
  }
  
  if(nrow(dfWin) > 1){
    dfWinPlot <- dfWin %>% 
      ggplot(aes(x = x_rel, y = y_rel)) +
      geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + 
      labs(title=strWin)
  } else {
    dfWinPlot <- list(dfWin[,c(2,3)], strWin)
  }
  
  #SBestWin <- summary(dfBestWin)
  #xline <- density(dfBestWin$x_rel)$x[which.max(density(dfBestWin$x_rel)$y)]
  #yline <- density(dfBestWin$y_rel)$x[which.max(density(dfBestWin$y_rel)$y)]
  if(nrow(dfBestWin) > 1){
    dfBestWinPlot <- dfBestWin %>% 
      ggplot(aes(x = x_rel, y = y_rel)) +
      geom_density2d_filled(aes(fill = ..level..),
                            contour_var = "ndensity",
                            breaks = seq(0.2, 1.0, length.out = 10)
                            ) + #очистка
      labs(title=strBestWin)
  } else {
    dfBestWinPlot <- list(dfBestWin[,c(2,3)], strBestWin)
  }

  return (list(dfBestPlot, dfWinPlot, dfBestWinPlot, dfBestWin))
}
# EXAMPLE: plots <- relGraphs(WR_def_pos, "WR_def_posBest", "WR_def_posWin","WR_def_posBestWin")
# plots
# or plots[[1]]


########### Функция извлечения лучших координат
extractMaxDensityXYrel <- function(dataframe){
  
  kde <- kde2d(dataframe$x_rel, dataframe$y_rel, n = 100)
  #contour(kde, xlab = "x_rel", ylab = "y_rel" )
  r <- raster(kde)
  dfKde <- as.data.frame(r, xy=T) #layer == density
  xyD <- aggregate(dfKde$layer, by = list(dfKde$x, dfKde$y), FUN = max)
  names(xyD)[names(xyD) == "x"] <- "density"
  names(xyD)[names(xyD) == "Group.1"] <- "x"
  names(xyD)[names(xyD) == "Group.2"] <- "y"
  rel_max <- xyD[xyD$density == max(xyD$density),]
  return(rel_max)
}
## EXAMPLE
# yardsHeat <- printYardsGraph(85, 100)
# rel_max <- extractMaxDensityXYrel(yardsHeat[[4]])
# x_rel_max <- rel_max$x
# y_rel_max <- rel_max$y
# yardsHeat[[3]] + geom_vline(xintercept = x_rel_max) + geom_hline(yintercept = y_rel_max)
```

# Общие heatmaps лучшего расположения против различных типов атак по их популярности

``` r
##### DIFFERENT TYPES OF OFFENSE #######################################################
### разные типы атак
attackTypes <- dbGetQuery(con, "SELECT offenseFormation, COUNT(DISTINCT(playId)) as popularity FROM plays
                                GROUP BY offenseFormation ORDER BY popularity DESC")
attackTypes
```

    ##   offenseFormation popularity
    ## 1          SHOTGUN       4320
    ## 2       SINGLEBACK       1949
    ## 3            EMPTY       1857
    ## 4           I_FORM        802
    ## 5           PISTOL        246
    ## 6                         138
    ## 7            JUMBO         51
    ## 8          WILDCAT         36

``` r
# I_FORM
def_ag_I_FORM <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'I_FORM'")
plots <- relGraphs(def_ag_I_FORM, "def_ag_I_FORM_Best", "def_ag_I_FORM_Win","def_ag_I_FORM_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-1.png)<!-- -->

``` r
# SINGLEBACK
def_ag_SINGLEBACK <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SINGLEBACK'")
plots <- relGraphs(def_ag_SINGLEBACK, "def_ag_SINGLEBACK_Best", "def_ag_SINGLEBACK_Win","def_ag_SINGLEBACK_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-2.png)<!-- -->

``` r
# SHOTGUN
def_ag_SHOTGUN <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SHOTGUN'")
plots <- relGraphs(def_ag_SHOTGUN, "def_ag_SHOTGUN_Best", "def_ag_SHOTGUN_Win","def_ag_SHOTGUN_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-3.png)<!-- -->

``` r
# PISTOL
def_ag_PISTOL <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'PISTOL'")
plots <- relGraphs(def_ag_PISTOL, "def_ag_PISTOL_Best", "def_ag_PISTOL_Win","def_ag_PISTOL_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-4.png)<!-- -->

``` r
# WILDCAT 
def_ag_WILDCAT <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'WILDCAT'")
plots <- relGraphs(def_ag_WILDCAT, "def_ag_WILDCAT_Best", "def_ag_WILDCAT_Win","def_ag_WILDCAT_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-5.png)<!-- -->

``` r
# JUMBO 
def_ag_JUMBO <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'JUMBO'")
plots <- relGraphs(def_ag_JUMBO, "def_ag_JUMBO_Best", "def_ag_JUMBO_Win","def_ag_JUMBO_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-6.png)<!-- -->

``` r
# EMPTY
def_ag_EMPTY <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection, fS.success FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'EMPTY'")
plots <- relGraphs(def_ag_EMPTY, "def_ag_EMPTY_Best", "def_ag_EMPTY_Win","def_ag_EMPTY_BestWin")
plots[[3]]
```

![](filtered_heatmapping_files/figure-gfm/data8-7.png)<!-- -->

# Общие heatmaps лучшего расположения защиты по ярдлиниям

``` r
########################################################################################
##### DIFFERENT TYPES OF YARDLINES #####################################################
### разные по ярдлиниям
###### AUTO YARDS GRAPH FUNC ########## 
printYardsGraph <- function(strYardsfrom, strYardsto){
    strYardsfrom <- toString(strYardsfrom)
    strYardsto <- toString(strYardsto)
    def_yft <- dbGetQuery(con, paste0("SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel,
                                  w.displayName, w.playId, w.gameId, w.team, w.playDirection, fS.success 
                                  FROM football_inSnap1 as fS
                                  JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap'
                                  AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardFromDefTouch > ", strYardsfrom, " AND fS.yardFromDefTouch <= ", strYardsto))
    plots <- relGraphs(def_yft, paste0("def_yft_", strYardsfrom, "_", strYardsto, "_Best"),
                       paste0("def_yft_", strYardsfrom, "_", strYardsto, "_Win"),
                       paste0("def_yft_", strYardsfrom, "_", strYardsto, "_BestWin"))
    print(plots[[3]]) # BestWin
    return(plots)
}  


# 0-10
yardsHeat <- printYardsGraph(0, 10)
```

![](filtered_heatmapping_files/figure-gfm/data9-1.png)<!-- -->

``` r
# 10-20
yardsHeat <- printYardsGraph(10, 20)
```

![](filtered_heatmapping_files/figure-gfm/data9-2.png)<!-- -->

``` r
# 30-40
yardsHeat <- printYardsGraph(30, 40)
```

![](filtered_heatmapping_files/figure-gfm/data9-3.png)<!-- -->

``` r
# 40-55
yardsHeat <- printYardsGraph(40, 55)
```

![](filtered_heatmapping_files/figure-gfm/data9-4.png)<!-- -->

``` r
# 55-70
yardsHeat <- printYardsGraph(55, 70)
```

![](filtered_heatmapping_files/figure-gfm/data9-5.png)<!-- -->

``` r
# 70-85
yardsHeat <- printYardsGraph(70, 85)
```

![](filtered_heatmapping_files/figure-gfm/data9-6.png)<!-- -->

``` r
# 85-100
yardsHeat <- printYardsGraph(85, 100)
```

![](filtered_heatmapping_files/figure-gfm/data9-7.png)<!-- -->

# Heatmaps лучшего расположения защиты по ролям защитников

  - функции

<!-- end list -->

``` r
####################################################################################
##### DIFFERENT TYPES OF ролям #####################################################
### разные по ролям ####### UNIVERSAL
roleTypes <- dbGetQuery(con, "SELECT position, COUNT(DISTINCT(playId)) as popularity FROM allWeeks
                                GROUP BY position ORDER BY popularity DESC")
roleTypes
```

    ##    position popularity
    ## 1        QB       4592
    ## 2                 4592
    ## 3        WR       4590
    ## 4        CB       4590
    ## 5        TE       4577
    ## 6        RB       4561
    ## 7       OLB       4444
    ## 8        FS       4371
    ## 9        SS       4271
    ## 10      ILB       3948
    ## 11       LB       3608
    ## 12      MLB       3309
    ## 13       DB       3058
    ## 14        S       1367
    ## 15       HB        590
    ## 16       FB        580
    ## 17       DE        137
    ## 18       DL         37
    ## 19       DT         23
    ## 20        P         16
    ## 21       LS         16
    ## 22       NT          5
    ## 23        K          5

``` r
####### GRAPHS BEGIN #################
############### Функция рисования графа относительно роли (типа) игрока ################################################
printPlayerTypeGraph <- function(strType){
  i_def_pos <- dbGetQuery(con, paste0("SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                      w.gameId, w.team, fS.success, w.position FROM football_inSnap1 as fS
                                      JOIN allWeeks as w ON fS.gameId = w.gameId AND fS.playId = w.playId
                                      WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                      AND w.position = '", strType, "'"))
  if (strType == ""){
    strType = "NO"
  }
  plots <- relGraphs(i_def_pos, paste0(strType, "_def_posBest"),
                     paste0(strType, "_def_posWin"), paste0(strType, "_def_posBestWin"))
  #print(plots[[3]])
  return(plots)
}

playerTypeGraphDraw <- function(strType){
  playerTypeGraph <- printPlayerTypeGraph(strType)
  
  if (strType == ""){
    strType = "NO"
  }
  
  nrowsdf <- nrow(playerTypeGraph[[4]])
  if(nrowsdf > 1){
    rel_max <- extractMaxDensityXYrel(playerTypeGraph[[4]])
    rel_max$type <- strType
    print(playerTypeGraph[[3]] + geom_vline(xintercept = rel_max$x) + geom_hline(yintercept = rel_max$y) +
            labs(subtitle = paste0("x_rel_best = ", rel_max$x, " y_rel_best = ", rel_max$y)))
  } else {
    if(nrowsdf == 1){
      rel_max <- data.frame(x = plots[[4]]$x_rel, y = plots[[4]]$y_rel, density = 1)
      rel_max$type <- strType
    } else {
      rel_max <- data.frame(x = 0, y = 0, density = 0)
      rel_max$type <- strType
    }
    
  }
  print(rel_max)
}
```

# Цикл по всем ролям

Координаты лучшего расположения - функции

``` r
####### ONLY X Y BEGIN #############
######################### выявление лучших позиций в виде текста для определенных ролей ###############################

### Возвращает или df с полями x y type density. Если пусто то density = 0, если 1 строка, то density = 1
printPlayerTypeBestPos <- function(strType){
  plots <- printPlayerTypeGraph(strType)
  #print(plots[[3]])
  if (strType == ""){
    strType = "NO"
  }
  
  nrowsdf <- nrow(plots[[4]])
  if(nrowsdf > 1){
    rel_max <- extractMaxDensityXYrel(plots[[4]])
    rel_max$type <- strType
  } else {
    if(nrowsdf == 1){
      rel_max <- data.frame(x = plots[[4]]$x_rel, y = plots[[4]]$y_rel, density = 1)
      rel_max$type <- strType
    } else {
      rel_max <- data.frame(x = 0, y = 0, density = 0)
      rel_max$type <- strType
    }
  }
  return(rel_max)
}
```

  - цикл использования

<!-- end list -->

    for (i in 1:(nrow(roleTypes))) {
      strType <- roleTypes[i,1]
      playerTypeGraph <- printPlayerTypeBestPos(strType)
      print(playerTypeGraph)
    }
    
    #### не выбирается QB потому что в защите его нет, proof:
    # playerTypeGraphDraw("QB")
    # i_def_pos <- dbGetQuery(con, paste0("SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
    #                                       w.gameId, w.team, fS.success, w.position FROM football_inSnap1 as fS
    #                                       JOIN allWeeks as w ON fS.gameId = w.gameId AND fS.playId = w.playId
    #                                       WHERE w.event = 'ball_snap'",# AND w.team NOT IN(fS.possessionTeam, 'football')
    #                                     "AND w.position = '", "QB", "'"))
    # head(i_def_pos, 10)
    ####### ONLY X Y END #############
    
    
    ####################################################################################

# Heatmaps лучшего расположения защиты по ролям и тактикам

  - функции

<!-- end list -->

``` r
##### DETECT POP TACTICS
attackTypes <- dbGetQuery(con, "SELECT offenseFormation, COUNT(DISTINCT(playId)) as popularity FROM plays
                                GROUP BY offenseFormation ORDER BY popularity DESC")
attackTypes
```

    ##   offenseFormation popularity
    ## 1          SHOTGUN       4320
    ## 2       SINGLEBACK       1949
    ## 3            EMPTY       1857
    ## 4           I_FORM        802
    ## 5           PISTOL        246
    ## 6                         138
    ## 7            JUMBO         51
    ## 8          WILDCAT         36

``` r
####################################################################################
##### DIFFERENT TYPES OF ROLES and offense tactics #################################
### разные по ролям ####### TACTIC Relative


####### GRAPHS BEGIN #################
#func
printPlayersTypeTactics <- function(strType, strAType){
  i_def_pos <- dbGetQuery(con, paste0("SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                        w.gameId, w.team, fS.success, w.position FROM football_inSnap1 as fS
                                        JOIN allWeeks as w ON fS.gameId = w.gameId AND fS.playId = w.playId
                                        WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                        AND w.position = '", strType, "'", "AND fS.offenseFormation = '", strAType, "'"))
  if (strType == ""){
    strType = "NO"
  }
  if (strAType == ""){
    strAType = "NO"
  }
  
  plots <- relGraphs(i_def_pos, paste0(strAType, "_", strType, "_def_posBest"),
                     paste0(strAType, "_", strType, "_def_posWin"), paste0(strAType, "_", strType, "_def_posBestWin"))
  return(plots)
} 

# func
playerTypeTacticsGraphDraw <- function(strType, strAType){
  playerTypeTacticsGraph <- printPlayersTypeTactics(strType, strAType)
  if (strType == ""){
    strType = "NO"
  }
  if (strAType == ""){
    strAType = "NO"
  }
  
  nrowsdf <- nrow(playerTypeTacticsGraph[[4]])
  if(nrowsdf > 1){
    rel_max <- extractMaxDensityXYrel(playerTypeTacticsGraph[[4]])
    print(playerTypeTacticsGraph[[3]] + geom_vline(xintercept = rel_max$x) + geom_hline(yintercept = rel_max$y) +
            labs(subtitle = paste0("x_rel_best = ", rel_max$x, " y_rel_best = ", rel_max$y)))
  } else {
    if(nrowsdf == 1){
      rel_max <- data.frame(x = plots[[4]]$x_rel, y = plots[[4]]$y_rel, density = 1)
    } else {
      rel_max <- data.frame(x = 0, y = 0, density = 0)
    }
    
  }
  rel_max$type <- strType
  rel_max$Atype <- strAType
  print(rel_max)
}
```

  - цикл по всем

<!-- end list -->

    #loop
    for (i in 1:(nrow(attackTypes))) {
      strAType <- attackTypes[i,1]
      for (j in 1:(nrow(roleTypes))) {
        strType <- roleTypes[j,1]
        playerTypeTacticsGraphDraw(strType, strAType)
      }
    }
    
    ### То что некоторые пустые это нормально, ролей много, некоторые тактики и роли непопулярны
    ####### GRAPHS END #################

Координаты по тактикам и ролям (для защиты) - функции

``` r
##### ONLY X Y BEGIN ###############
printPlayerTacticsTypeBestPos <- function(strType, strAType){
  
  plots <- printPlayersTypeTactics(strType, strAType)
  if (strType == ""){
    strType = "NO"
  }
  if (strAType == ""){
    strAType = "NO"
  }
  
  #print(plots[[3]])
  nrowsdf <- nrow(plots[[4]])
  if(nrowsdf > 1){
    rel_max <- extractMaxDensityXYrel(plots[[4]])
  } else {
    if(nrowsdf == 1){
      rel_max <- data.frame(x = plots[[4]]$x_rel, y = plots[[4]]$y_rel, density = 1)
    } else {
      rel_max <- data.frame(x = 0, y = 0, density = 0)
    }
  }
  rel_max$type <- strType
  rel_max$Atype <- strAType
  return(rel_max)
} 
```

Цикл использования по всем (осторожно)

    #loop
    for (i in 1:(nrow(attackTypes))) {
      strAType <- attackTypes[i,1]
      for (j in 1:(nrow(roleTypes))) {
        strType <- roleTypes[j,1]
        playerTypeGraph <- printPlayerTacticsTypeBestPos(strType, strAType)
        print(playerTypeGraph)
      }
    }
    
    ##### ONLY X Y END ###############

``` r
# сравнить Worst



# $$$$$$$$$$$$$$ #
# готовые решения:
# printPlayerTypeBestPos(strType) - возвращает лучшую позицию игрока по типу независимо от типа Атаки
# playerTypeGraphDraw(strType) - рисует графики и выводит, ничего не возвращае
# printPlayerTacticsTypeBestPos(strType, strAType) - возвращает лучшую позицию. strType - тип игрока, strAType - тип атаки
# playerTypeTacticsGraphDraw(strType, strAType) - рисует графики и выводит, ничего не возвращает

#Пример использования:
printPlayerTypeBestPos("OLB")
```

    ##             x         y    density type
    ## 4104 1.108485 -5.382929 0.04060916  OLB

``` r
playerTypeGraphDraw("OLB")
```

![](filtered_heatmapping_files/figure-gfm/data18-1.png)<!-- -->

    ##             x         y    density type
    ## 4104 1.108485 -5.382929 0.04060916  OLB

``` r
printPlayerTacticsTypeBestPos("OLB", "SHOTGUN")
```

    ##             x         y    density type   Atype
    ## 4606 1.185859 -5.408485 0.03988676  OLB SHOTGUN

``` r
playerTypeTacticsGraphDraw("OLB", "SHOTGUN")
```

![](filtered_heatmapping_files/figure-gfm/data18-2.png)<!-- -->

    ##             x         y    density type   Atype
    ## 4606 1.185859 -5.408485 0.03988676  OLB SHOTGUN

``` r
# end

dbDisconnect(con)
```
