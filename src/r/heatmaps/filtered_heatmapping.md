filtered\_heatmapping
================
yurkovkirill
05 01 2021

``` r
# setup

#install.packages("RSQLite")
#devtools::install_github("r-dbi/RSQLite")
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
#install.packages("tidyverse")
#install.packages("stringr")
#library(tidyverse) # for tibble and others
#library(stringr)

setwd("D:/MyFilesDesktop/Student/7SEM/DataScience/DS_Project")
con <- dbConnect(RSQLite::SQLite(), ":memory:")
dbListTables(con)
```

    ## character(0)

``` r
options(max.print=10000)

# init database
dbWriteTable(con, "games", read.csv("data/games.csv"))
dbWriteTable(con, "plays", read.csv("data/plays.csv"))
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
dbListTables(con)
```

    ## [1] "allWeeks" "games"    "plays"

``` r
#dbRemoveTable(con, "games")
#dbRemoveTable(con, "plays")
#dbRemoveTable(con, "allWeeks")


# USE IT
# 1) Берем координаты мяча в момент ball_snap (и считаем относительно него, ориентируясь по playDirection)
# 2) Пересчет их координат относительно


# нужно отобрать всех игроков в моменте, посмотрим не пропадают ли

testTeam <- dbGetQuery(con, "SELECT DISTINCT w.nflId, w.team FROM plays as p JOIN allWeeks as w ON p.gameId = w.gameId
                                      AND p.playId = w.playId WHERE w.gameId = 2018090600
                                      ORDER BY w.nflId")#w.event = 'ball_snap'")
head(testTeam,12)
```

    ##      nflId     team
    ## 1       NA football
    ## 2      310     away
    ## 3    79848     home
    ## 4  2495454     away
    ## 5  2495613     home
    ## 6  2506467     home
    ## 7  2507763     home
    ## 8  2507828     away
    ## 9  2532842     home
    ## 10 2533040     away
    ## 11 2534832     home
    ## 12 2539291     home

``` r
# этот запрос дал нам понять, что команда у игрока во время игры не меняется, но мы знаем что меняется сторона
# поэтому сделаем для всех игроков относительно мяча и playDirection, и получим в одном случае защиту справа
# а в другом защиту слева. Потом отобрать по o = orientation? Больше никак вроде #Pending


testFrames <- head(dbGetQuery(con, "SELECT w.frameId, w.playId, COUNT(w.nflId), COUNT(w.displayName) FROM plays as p JOIN allWeeks as w ON p.gameId = w.gameId
                                      AND p.playId = w.playId WHERE w.gameId = 2018090600
                                      GROUP BY w.frameId, w.playId ORDER BY w.playId"),60)#w.event = 'ball_snap'")
options(max.print=10000)
testFrames
```

    ##    frameId playId COUNT(w.nflId) COUNT(w.displayName)
    ## 1        1     75             13                   14
    ## 2        2     75             13                   14
    ## 3        3     75             13                   14
    ## 4        4     75             13                   14
    ## 5        5     75             13                   14
    ## 6        6     75             13                   14
    ## 7        7     75             13                   14
    ## 8        8     75             13                   14
    ## 9        9     75             13                   14
    ## 10      10     75             13                   14
    ## 11      11     75             13                   14
    ## 12      12     75             13                   14
    ## 13      13     75             13                   14
    ## 14      14     75             13                   14
    ## 15      15     75             13                   14
    ## 16      16     75             13                   14
    ## 17      17     75             13                   14
    ## 18      18     75             13                   14
    ## 19      19     75             13                   14
    ## 20      20     75             13                   14
    ## 21      21     75             13                   14
    ## 22      22     75             13                   14
    ## 23      23     75             13                   14
    ## 24      24     75             13                   14
    ## 25      25     75             13                   14
    ## 26      26     75             13                   14
    ## 27      27     75             13                   14
    ## 28      28     75             13                   14
    ## 29      29     75             13                   14
    ## 30      30     75             13                   14
    ## 31      31     75             13                   14
    ## 32      32     75             13                   14
    ## 33      33     75             13                   14
    ## 34      34     75             13                   14
    ## 35      35     75             13                   14
    ## 36      36     75             13                   14
    ## 37      37     75             13                   14
    ## 38      38     75             13                   14
    ## 39      39     75             13                   14
    ## 40      40     75             13                   14
    ## 41      41     75             13                   14
    ## 42      42     75             13                   14
    ## 43      43     75             13                   14
    ## 44      44     75             13                   14
    ## 45      45     75             13                   14
    ## 46      46     75             13                   14
    ## 47      47     75             13                   14
    ## 48      48     75             13                   14
    ## 49      49     75             13                   14
    ## 50      50     75             13                   14
    ## 51      51     75             13                   14
    ## 52      52     75             13                   14
    ## 53      53     75             13                   14
    ## 54      54     75             13                   14
    ## 55      55     75             13                   14
    ## 56      56     75             13                   14
    ## 57      57     75             13                   14
    ## 58      58     75             13                   14
    ## 59      59     75             13                   14
    ## 60       1    146             13                   14

``` r
# этот запрос показал, что количество игроков каждом фрейме одного момента одинаковое, поэтому смело можно брать
# ball_snap кадр и мы получим данные о всех зафиксированных игроках в моменте

################################################################################################################
# информация о защитниках с относительными координатами
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

``` r
testTeam1 <- dbGetQuery(con, "SELECT team, COUNT(DISTINCT(nflId)) FROM allWeeks as w GROUP BY team")
testTeam1
```

    ##       team COUNT(DISTINCT(nflId))
    ## 1     away                   1198
    ## 2 football                      0
    ## 3     home                   1201

``` r
# проверка
testTeamPlay <- dbGetQuery(con, "SELECT possessionTeam, COUNT(DISTINCT(playId)) FROM plays GROUP BY possessionTeam")
testTeamPlay
```

    ##   possessionTeam COUNT(DISTINCT(playId))
    ## 1           away                    3973
    ## 2           home                    3992

``` r
# берем информацию по мячу ## MAIN QUERY for init point (ball)
dbListFields(con, "plays")
```

    ##  [1] "gameId"                 "playId"                 "playDescription"       
    ##  [4] "quarter"                "down"                   "yardsToGo"             
    ##  [7] "possessionTeam"         "playType"               "yardlineSide"          
    ## [10] "yardlineNumber"         "offenseFormation"       "personnelO"            
    ## [13] "defendersInTheBox"      "numberOfPassRushers"    "personnelD"            
    ## [16] "typeDropback"           "preSnapVisitorScore"    "preSnapHomeScore"      
    ## [19] "gameClock"              "absoluteYardlineNumber" "penaltyCodes"          
    ## [22] "penaltyJerseyNumbers"   "passResult"             "offensePlayResult"     
    ## [25] "playResult"             "epa"                    "isDefensivePI"

``` r
# football_inSnap1 <- dbGetQuery(con, "SELECT p.epa, w.x as x_b, w.y as y_b, w.displayName, w.event, w.playId,
#                                       w.gameId, p.offenseFormation, p.possessionTeam, p.yardlineNumber
#                                       FROM plays as p JOIN allWeeks as w ON p.gameId = w.gameId
#                                       AND p.playId = w.playId WHERE w.event = 'ball_snap' AND w.displayName = 'Football'")
dbWriteTable(con, "football_inSnap1", dbGetQuery(con, "SELECT p.epa, w.x as x_b, w.y as y_b, w.displayName, w.event, w.playId,
                                      w.gameId, p.offenseFormation, p.possessionTeam, p.yardlineNumber
                                      FROM plays as p JOIN allWeeks as w ON p.gameId = w.gameId
                                      AND p.playId = w.playId WHERE w.event = 'ball_snap' AND w.displayName = 'Football'"))
dbListFields(con, "football_inSnap1")
```

    ##  [1] "epa"              "x_b"              "y_b"              "displayName"     
    ##  [5] "event"            "playId"           "gameId"           "offenseFormation"
    ##  [9] "possessionTeam"   "yardlineNumber"

``` r
#dbRemoveTable(con, "football_inSnap1")


#### теперь пробуем соединить по команде (home / away) ####
# Красота
DefPlayers_inSnap <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                      w.gameId, w.team, w.playDirection FROM football_inSnap1 as fS
                                      JOIN allWeeks as w ON fS.gameId = w.gameId AND fS.playId = w.playId
                                      WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')")
summary(DefPlayers_inSnap)
```

    ##       epa                x_rel            y_rel          displayName       
    ##  Min.   :-11.93595   Min.   : 0.000   Min.   :-49.7900   Length:148274     
    ##  1st Qu.: -0.76341   1st Qu.: 2.450   1st Qu.: -6.5000   Class :character  
    ##  Median : -0.19567   Median : 4.870   Median :  0.0200   Mode  :character  
    ##  Mean   :  0.01333   Mean   : 6.233   Mean   :  0.0305                     
    ##  3rd Qu.:  0.97432   3rd Qu.: 8.140   3rd Qu.:  6.5300                     
    ##  Max.   :  8.62932   Max.   :66.030   Max.   : 47.1200                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  50   Min.   :2.018e+09   Length:148274      Length:148274     
    ##  1st Qu.:1133   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2176   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2184   Mean   :2.018e+09                                        
    ##  3rd Qu.:3213   3rd Qu.:2.018e+09                                        
    ##  Max.   :5661   Max.   :2.018e+09

``` r
DefPlayers_inSnapBest <- DefPlayers_inSnap[DefPlayers_inSnap$epa < -0.76,]
#DefPlayers_inSnapWorst <- DefPlayers_inSnap[DefPlayers_inSnap$epa > 0.97,]
DefPlayers_inSnapBest %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 15)) + #очистка
  labs(title="DefPlayers_inSnapBest NEW")
```

![](filtered_heatmapping_files/figure-gfm/all-1.png)<!-- -->

``` r
##### У нас получилось учесть всех защитников для обоих команд


##### DIFFERENT TYPES OF OFFENSE #######################################################
### разные типы атак
attackTypes <- dbGetQuery(con, "SELECT offenseFormation, COUNT(playId) FROM plays GROUP BY offenseFormation")
attackTypes
```

    ##   offenseFormation COUNT(playId)
    ## 1                            141
    ## 2            EMPTY          2428
    ## 3           I_FORM           915
    ## 4            JUMBO            51
    ## 5           PISTOL           251
    ## 6          SHOTGUN         12627
    ## 7       SINGLEBACK          2790
    ## 8          WILDCAT            36

``` r
# I_FORM
def_ag_I_FORM_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'I_FORM'")
summary(def_ag_I_FORM_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-6.15907   Min.   : 0.090   Min.   :-46.5400   Length:6662       
    ##  1st Qu.:-0.51937   1st Qu.: 2.450   1st Qu.: -5.3275   Class :character  
    ##  Median :-0.04667   Median : 4.430   Median :  0.0200   Mode  :character  
    ##  Mean   : 0.25764   Mean   : 5.579   Mean   : -0.0232                     
    ##  3rd Qu.: 1.13023   3rd Qu.: 6.800   3rd Qu.:  5.4100                     
    ##  Max.   : 7.07367   Max.   :22.930   Max.   : 23.7900                     
    ##      playId           gameId              team           playDirection     
    ##  Min.   :  51.0   Min.   :2.018e+09   Length:6662        Length:6662       
    ##  1st Qu.: 782.5   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1680.0   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1838.4   Mean   :2.018e+09                                        
    ##  3rd Qu.:2819.0   3rd Qu.:2.018e+09                                        
    ##  Max.   :4721.0   Max.   :2.018e+09

``` r
def_ag_I_FORM_1_Best <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa < -0.51,]
#def_ag_I_FORM_1_Worst <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa > 1.13,]

def_ag_I_FORM_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_I_FORM_1_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-2.png)<!-- -->

``` r
# SINGLEBACK
def_ag_SINGLEBACK_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SINGLEBACK'")
summary(def_ag_SINGLEBACK_1)
```

    ##       epa              x_rel            y_rel           displayName       
    ##  Min.   :-8.5402   Min.   : 0.030   Min.   :-46.74000   Length:20855      
    ##  1st Qu.:-0.5304   1st Qu.: 2.460   1st Qu.: -5.77000   Class :character  
    ##  Median :-0.1113   Median : 4.400   Median : -0.15000   Mode  :character  
    ##  Mean   : 0.2014   Mean   : 5.521   Mean   : -0.02823                     
    ##  3rd Qu.: 1.1000   3rd Qu.: 6.880   3rd Qu.:  5.71000                     
    ##  Max.   : 8.2073   Max.   :24.520   Max.   : 45.18000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  51   Min.   :2.018e+09   Length:20855       Length:20855      
    ##  1st Qu.: 833   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1646   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1835   Mean   :2.018e+09                                        
    ##  3rd Qu.:2793   3rd Qu.:2.018e+09                                        
    ##  Max.   :5385   Max.   :2.018e+09

``` r
def_ag_SINGLEBACK_1_Best <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa < -0.53,]
#def_ag_SINGLEBACK_1_Worst <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa > 1.10,]

def_ag_SINGLEBACK_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SINGLEBACK_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-3.png)<!-- -->

``` r
# SHOTGUN
def_ag_SHOTGUN_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SHOTGUN'")
summary(def_ag_SHOTGUN_1)
```

    ##       epa                x_rel            y_rel           displayName       
    ##  Min.   :-11.93595   Min.   : 0.000   Min.   :-48.56000   Length:98452      
    ##  1st Qu.: -0.84981   1st Qu.: 2.400   1st Qu.: -6.61000   Class :character  
    ##  Median : -0.21685   Median : 4.980   Median :  0.05000   Mode  :character  
    ##  Mean   : -0.04194   Mean   : 6.377   Mean   :  0.02659                     
    ##  3rd Qu.:  0.90331   3rd Qu.: 8.460   3rd Qu.:  6.62000                     
    ##  Max.   :  8.62932   Max.   :66.030   Max.   : 47.12000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  50   Min.   :2.018e+09   Length:98452       Length:98452      
    ##  1st Qu.:1286   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2280   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2303   Mean   :2.018e+09                                        
    ##  3rd Qu.:3365   3rd Qu.:2.018e+09                                        
    ##  Max.   :5602   Max.   :2.018e+09

``` r
def_ag_SHOTGUN_1_Best <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa < -0.84,]
#def_ag_SHOTGUN_1_Worst <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa > 0.90,]
def_ag_SHOTGUN_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SHOTGUN_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-4.png)<!-- -->

``` r
# PISTOL
def_ag_PISTOL_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'PISTOL'")
summary(def_ag_PISTOL_1)
```

    ##       epa              x_rel            y_rel        displayName       
    ##  Min.   :-6.6393   Min.   : 0.120   Min.   :-21.78   Length:1865       
    ##  1st Qu.:-0.5976   1st Qu.: 2.620   1st Qu.: -5.91   Class :character  
    ##  Median :-0.1110   Median : 4.770   Median :  0.01   Mode  :character  
    ##  Mean   : 0.1721   Mean   : 5.938   Mean   :  0.11                     
    ##  3rd Qu.: 1.2633   3rd Qu.: 7.410   3rd Qu.:  6.23                     
    ##  Max.   : 6.6493   Max.   :29.320   Max.   : 22.26                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  54   Min.   :2.018e+09   Length:1865        Length:1865       
    ##  1st Qu.: 742   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1982   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1925   Mean   :2.018e+09                                        
    ##  3rd Qu.:2982   3rd Qu.:2.018e+09                                        
    ##  Max.   :4799   Max.   :2.018e+09

``` r
def_ag_PISTOL_1_Best <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa < -0.59,]
#def_ag_PISTOL_1_Worst <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa > 1.26,]
def_ag_PISTOL_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_PISTOL_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-5.png)<!-- -->

``` r
# WILDCAT #more weeks # lowPending 3.1
def_ag_WILDCAT_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'WILDCAT'")
summary(def_ag_WILDCAT_1)
```

    ##       epa              x_rel            y_rel           displayName       
    ##  Min.   :-5.0202   Min.   : 0.500   Min.   :-22.85000   Length:263        
    ##  1st Qu.:-0.8078   1st Qu.: 2.520   1st Qu.: -6.51500   Class :character  
    ##  Median :-0.3447   Median : 4.600   Median :  0.12000   Mode  :character  
    ##  Mean   :-0.2177   Mean   : 5.701   Mean   :  0.02255                     
    ##  3rd Qu.: 0.5062   3rd Qu.: 7.690   3rd Qu.:  7.28500                     
    ##  Max.   : 3.1279   Max.   :17.220   Max.   : 21.89000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   : 192   Min.   :2.018e+09   Length:263         Length:263        
    ##  1st Qu.:1649   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2177   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2341   Mean   :2.018e+09                                        
    ##  3rd Qu.:3266   3rd Qu.:2.018e+09                                        
    ##  Max.   :4228   Max.   :2.018e+09

``` r
def_ag_WILDCAT_1_Best <- def_ag_WILDCAT_1[def_ag_WILDCAT_1$epa < -0.80,] # lowPending 3.1
#def_ag_WILDCAT_1_Worst <- def_ag_WILDCAT_1[def_ag_WILDCAT_1$epa > 0.50,] # lowPending 3.1
def_ag_WILDCAT_1_Best %>% # lowPending 3.1
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_WILDCAT_1")
```

![](filtered_heatmapping_files/figure-gfm/all-6.png)<!-- -->

``` r
# JUMBO #Pending 3.1
def_ag_JUMBO_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'JUMBO'")
summary(def_ag_JUMBO_1)
```

    ##       epa              x_rel            y_rel        displayName       
    ##  Min.   :-4.4665   Min.   : 0.280   Min.   :-9.910   Length:297        
    ##  1st Qu.:-0.3106   1st Qu.: 1.570   1st Qu.:-4.030   Class :character  
    ##  Median :-0.1230   Median : 3.380   Median : 0.170   Mode  :character  
    ##  Mean   : 0.4670   Mean   : 3.406   Mean   : 1.148                     
    ##  3rd Qu.: 1.3858   3rd Qu.: 4.740   3rd Qu.: 4.930                     
    ##  Max.   : 7.3358   Max.   :14.390   Max.   :37.740                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   : 187   Min.   :2.018e+09   Length:297         Length:297        
    ##  1st Qu.: 889   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1789   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1902   Mean   :2.018e+09                                        
    ##  3rd Qu.:2792   3rd Qu.:2.018e+09                                        
    ##  Max.   :4590   Max.   :2.018e+09

``` r
def_ag_JUMBO_1_Best <- def_ag_JUMBO_1[def_ag_JUMBO_1$epa < -0.31,] # lowPending 3.1
#def_ag_JUMBO_1_Worst <- def_ag_JUMBO_1[def_ag_JUMBO_1$epa > 1.38,] # lowPending 3.1
def_ag_JUMBO_1_Best %>% # lowPending 3.1
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_JUMBO_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-7.png)<!-- -->

``` r
# EMPTY
def_ag_EMPTY_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap' AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'EMPTY'")
summary(def_ag_EMPTY_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-9.59810   Min.   : 0.010   Min.   :-49.7900   Length:18767      
    ##  1st Qu.:-0.85601   1st Qu.: 2.750   1st Qu.: -7.8400   Class :character  
    ##  Median :-0.22596   Median : 5.420   Median :  0.0800   Mode  :character  
    ##  Mean   :-0.02454   Mean   : 6.547   Mean   :  0.1021                     
    ##  3rd Qu.: 1.04434   3rd Qu.: 8.400   3rd Qu.:  7.9900                     
    ##  Max.   : 7.77519   Max.   :48.900   Max.   : 46.3500                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  51   Min.   :2.018e+09   Length:18767       Length:18767      
    ##  1st Qu.: 978   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2028   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2068   Mean   :2.018e+09                                        
    ##  3rd Qu.:3110   3rd Qu.:2.018e+09                                        
    ##  Max.   :5637   Max.   :2.018e+09

``` r
def_ag_EMPTY_1_Best <- def_ag_EMPTY_1[def_ag_EMPTY_1$epa < -0.85,]
#def_ag_EMPTY_1_Worst <- def_ag_EMPTY_1[def_ag_EMPTY_1$epa > 1.04,]
def_ag_EMPTY_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_EMPTY_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-8.png)<!-- -->

``` r
######################################################################################################################
### разные по ярдлиниям 
# 0-10
def_yl_0_10_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS
                                  JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap'
                                  AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 0 AND fS.yardlineNumber <= 10")
summary(def_yl_0_10_1)
```

    ##       epa               x_rel            y_rel           displayName       
    ##  Min.   :-11.9360   Min.   : 0.000   Min.   :-25.32000   Length:12465      
    ##  1st Qu.: -0.5562   1st Qu.: 2.300   1st Qu.: -6.35000   Class :character  
    ##  Median : -0.1528   Median : 4.230   Median :  0.07000   Mode  :character  
    ##  Mean   :  0.1582   Mean   : 5.008   Mean   :  0.06645                     
    ##  3rd Qu.:  1.4571   3rd Qu.: 6.380   3rd Qu.:  6.39000                     
    ##  Max.   :  8.2073   Max.   :36.060   Max.   : 46.24000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  69   Min.   :2.018e+09   Length:12465       Length:12465      
    ##  1st Qu.:1258   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2256   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2273   Mean   :2.018e+09                                        
    ##  3rd Qu.:3330   3rd Qu.:2.018e+09                                        
    ##  Max.   :4922   Max.   :2.018e+09

``` r
def_yl_0_10_1_Best <- def_yl_0_10_1[def_yl_0_10_1$epa < -0.55,]
#def_yl_0_10_1_Worst <- def_yl_0_10_1[def_yl_0_10_1$epa > 1.45,]
def_yl_0_10_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 0-10")
```

![](filtered_heatmapping_files/figure-gfm/all-9.png)<!-- -->

``` r
# 10-20
def_yl_10_20_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS
                                  JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap'
                                  AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 10 AND fS.yardlineNumber <= 20")
summary(def_yl_10_20_1)
```

    ##       epa               x_rel            y_rel           displayName       
    ##  Min.   :-7.46543   Min.   : 0.010   Min.   :-48.56000   Length:21732      
    ##  1st Qu.:-0.72015   1st Qu.: 2.550   1st Qu.: -6.57000   Class :character  
    ##  Median :-0.16828   Median : 4.990   Median : -0.05000   Mode  :character  
    ##  Mean   : 0.09273   Mean   : 6.203   Mean   : -0.02888                     
    ##  3rd Qu.: 0.99142   3rd Qu.: 8.240   3rd Qu.:  6.60000                     
    ##  Max.   : 8.62932   Max.   :48.900   Max.   : 47.12000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  58   Min.   :2.018e+09   Length:21732       Length:21732      
    ##  1st Qu.:1114   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2172   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2192   Mean   :2.018e+09                                        
    ##  3rd Qu.:3198   3rd Qu.:2.018e+09                                        
    ##  Max.   :5661   Max.   :2.018e+09

``` r
def_yl_10_20_1_Best <- def_yl_10_20_1[def_yl_10_20_1$epa < -0.72,]
#def_yl_10_20_1_Worst <- def_yl_10_20_1[def_yl_10_20_1$epa > 0.99,]
def_yl_10_20_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 10-20")
```

![](filtered_heatmapping_files/figure-gfm/all-10.png)<!-- -->

``` r
# 20-35

def_yl_20_35_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS
                                  JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap'
                                  AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 20 AND fS.yardlineNumber <= 35")
summary(def_yl_20_35_1)
```

    ##       epa                 x_rel            y_rel           displayName       
    ##  Min.   :-10.951801   Min.   : 0.000   Min.   :-49.79000   Length:58442      
    ##  1st Qu.: -0.776415   1st Qu.: 2.470   1st Qu.: -6.52750   Class :character  
    ##  Median : -0.216429   Median : 4.920   Median : -0.03000   Mode  :character  
    ##  Mean   : -0.000178   Mean   : 6.298   Mean   :  0.01265                     
    ##  3rd Qu.:  0.943866   3rd Qu.: 8.280   3rd Qu.:  6.50000                     
    ##  Max.   :  8.397043   Max.   :66.030   Max.   : 47.04000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  50   Min.   :2.018e+09   Length:58442       Length:58442      
    ##  1st Qu.:1107   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2156   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2154   Mean   :2.018e+09                                        
    ##  3rd Qu.:3174   3rd Qu.:2.018e+09                                        
    ##  Max.   :5577   Max.   :2.018e+09

``` r
def_yl_20_35_1_Best <- def_yl_20_35_1[def_yl_20_35_1$epa < -0.77,]
#def_yl_20_35_1_Worst <- def_yl_20_35_1[def_yl_20_35_1$epa > 0.94,]
def_yl_20_35_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 20-35")
```

![](filtered_heatmapping_files/figure-gfm/all-11.png)<!-- -->

``` r
# 35-50
def_yl_35_50_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w.x - x_b) as x_rel, (w.y - y_b) as y_rel, w.displayName, w.playId,
                                  w.gameId, w.team, w.playDirection  FROM football_inSnap1 as fS
                                  JOIN allWeeks as w ON fS.gameId = w.gameId
                                  AND fS.playId = w.playId WHERE w.event = 'ball_snap'
                                  AND w.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 35 AND fS.yardlineNumber <= 50")
summary(def_yl_35_50_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-9.48768   Min.   : 0.000   Min.   :-46.7400   Length:55635      
    ##  1st Qu.:-0.79665   1st Qu.: 2.440   1st Qu.: -6.4600   Class :character  
    ##  Median :-0.23533   Median : 4.940   Median :  0.0800   Mode  :character  
    ##  Mean   :-0.03597   Mean   : 6.451   Mean   :  0.0644                     
    ##  3rd Qu.: 0.94936   3rd Qu.: 8.430   3rd Qu.:  6.5700                     
    ##  Max.   : 7.33575   Max.   :62.770   Max.   : 46.3500                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  60   Min.   :2.018e+09   Length:55635       Length:55635      
    ##  1st Qu.:1138   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2183   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2193   Mean   :2.018e+09                                        
    ##  3rd Qu.:3236   3rd Qu.:2.018e+09                                        
    ##  Max.   :5637   Max.   :2.018e+09

``` r
def_yl_35_50_1_Best <- def_yl_35_50_1[def_yl_35_50_1$epa < -0.79,]
#def_yl_35_50_1_Worst <- def_yl_35_50_1[def_yl_35_50_1$epa > 0.94,]
def_yl_35_50_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 35-50")
```

![](filtered_heatmapping_files/figure-gfm/all-12.png)<!-- -->

``` r
# Учесть под разные типы расположения! Какой лучше выбрать и как лучше делать под определенное расположение
# например WILDCAT #Pending1

# Pending2 для разных типов игроков

# Pending3 в games есть homeTeamAbbr, выделять команду можно по нему
# То есть w.playDirection = 'right' AND  x_rel >= 0 заменится на w.замененный team из homeTeamAbbr != p.possessionTeam

#Pending4 сделать для всех week



###HEATMAP + поле 
# playsWeek1 %>%
#   ggplot(aes(x = x_cor, y = y_cor)) +
#   geom_density2d_filled() +
#   theme(legend.position = "none") + add_field()
# Pending


# end

dbDisconnect(con)
```
