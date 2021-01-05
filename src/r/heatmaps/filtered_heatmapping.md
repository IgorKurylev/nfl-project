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
dbWriteTable(con, "week1", read.csv("data/week1.csv"))
dbListTables(con)
```

    ## [1] "games" "plays" "week1"

``` r
# USE IT
# 1) Берем координаты мяча в момент ball_snap (и считаем относительно него, ориентируясь по playDirection)
# 2) Пересчет их координат относительно


# нужно отобрать всех игроков в моменте, посмотрим не пропадают ли

testTeam <- dbGetQuery(con, "SELECT DISTINCT w1.nflId, w1.team FROM plays as p JOIN week1 as w1 ON p.gameId = w1.gameId
                                      AND p.playId = w1.playId WHERE w1.gameId = 2018090600
                                      ORDER BY w1.nflId")#w1.event = 'ball_snap'")
head(testTeam,60)
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
    ## 13 2539334     away
    ## 14 2539653     away
    ## 15 2540158     home
    ## 16 2543583     away
    ## 17 2543850     away
    ## 18 2552301     away
    ## 19 2552315     home
    ## 20 2552418     away
    ## 21 2552453     away
    ## 22 2552582     home
    ## 23 2552600     home
    ## 24 2552689     home
    ## 25 2553502     home
    ## 26 2555162     away
    ## 27 2555255     away
    ## 28 2555383     home
    ## 29 2555415     away
    ## 30 2555461     home
    ## 31 2555543     away
    ## 32 2556363     home
    ## 33 2556444     home
    ## 34 2556445     away
    ## 35 2557034     away
    ## 36 2557958     home
    ## 37 2557967     away
    ## 38 2558023     away
    ## 39 2558168     home
    ## 40 2558175     home
    ## 41 2558184     away
    ## 42 2558258     home
    ## 43 2559033     away
    ## 44 2559109     away
    ## 45 2559150     home
    ## 46 2560854     away
    ## 47 2560995     home
    ## 48 2561132     away

``` r
# этот запрос дал нам понять, что команда у игрока во время игры не меняется, но мы знаем что меняется сторона
# поэтому сделаем для всех игроков относительно мяча и playDirection, и получим в одном случае защиту справа
# а в другом защиту слева. Потом отобрать по o = orientation? Больше никак вроде #Pending


testFrames <- dbGetQuery(con, "SELECT w1.frameId, w1.playId, COUNT(w1.nflId), COUNT(w1.displayName) FROM plays as p JOIN week1 as w1 ON p.gameId = w1.gameId
                                      AND p.playId = w1.playId WHERE w1.gameId = 2018090600
                                      GROUP BY w1.frameId, w1.playId ORDER BY w1.playId")#w1.event = 'ball_snap'")
options(max.print=10000)
head(testFrames,60)
```

    ##    frameId playId COUNT(w1.nflId) COUNT(w1.displayName)
    ## 1        1     75              13                    14
    ## 2        2     75              13                    14
    ## 3        3     75              13                    14
    ## 4        4     75              13                    14
    ## 5        5     75              13                    14
    ## 6        6     75              13                    14
    ## 7        7     75              13                    14
    ## 8        8     75              13                    14
    ## 9        9     75              13                    14
    ## 10      10     75              13                    14
    ## 11      11     75              13                    14
    ## 12      12     75              13                    14
    ## 13      13     75              13                    14
    ## 14      14     75              13                    14
    ## 15      15     75              13                    14
    ## 16      16     75              13                    14
    ## 17      17     75              13                    14
    ## 18      18     75              13                    14
    ## 19      19     75              13                    14
    ## 20      20     75              13                    14
    ## 21      21     75              13                    14
    ## 22      22     75              13                    14
    ## 23      23     75              13                    14
    ## 24      24     75              13                    14
    ## 25      25     75              13                    14
    ## 26      26     75              13                    14
    ## 27      27     75              13                    14
    ## 28      28     75              13                    14
    ## 29      29     75              13                    14
    ## 30      30     75              13                    14
    ## 31      31     75              13                    14
    ## 32      32     75              13                    14
    ## 33      33     75              13                    14
    ## 34      34     75              13                    14
    ## 35      35     75              13                    14
    ## 36      36     75              13                    14
    ## 37      37     75              13                    14
    ## 38      38     75              13                    14
    ## 39      39     75              13                    14
    ## 40      40     75              13                    14
    ## 41      41     75              13                    14
    ## 42      42     75              13                    14
    ## 43      43     75              13                    14
    ## 44      44     75              13                    14
    ## 45      45     75              13                    14
    ## 46      46     75              13                    14
    ## 47      47     75              13                    14
    ## 48      48     75              13                    14
    ## 49      49     75              13                    14
    ## 50      50     75              13                    14
    ## 51      51     75              13                    14
    ## 52      52     75              13                    14
    ## 53      53     75              13                    14
    ## 54      54     75              13                    14
    ## 55      55     75              13                    14
    ## 56      56     75              13                    14
    ## 57      57     75              13                    14
    ## 58      58     75              13                    14
    ## 59      59     75              13                    14
    ## 60       1    146              13                    14

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
testTeam1 <- dbGetQuery(con, "SELECT team, COUNT(DISTINCT(nflId)) FROM week1 as w1 GROUP BY team")
testTeam1
```

    ##       team COUNT(DISTINCT(nflId))
    ## 1     away                    303
    ## 2 football                      0
    ## 3     home                    299

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
football_inSnap1 <- dbGetQuery(con, "SELECT p.epa, w1.x as x_b, w1.y as y_b, w1.displayName, w1.event, w1.playId,
                                      w1.gameId, p.offenseFormation, p.possessionTeam, p.yardlineNumber
                                      FROM plays as p JOIN week1 as w1 ON p.gameId = w1.gameId
                                      AND p.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName = 'Football'")
dbWriteTable(con, "football_inSnap1", football_inSnap1)
dbListFields(con, "football_inSnap1")
```

    ##  [1] "epa"              "x_b"              "y_b"              "displayName"     
    ##  [5] "event"            "playId"           "gameId"           "offenseFormation"
    ##  [9] "possessionTeam"   "yardlineNumber"

``` r
#dbRemoveTable(con, "football_inSnap1")


#### теперь пробуем соединить по команде (home / away) ####
# Красота
DefPlayers_inSnap <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                      w1.gameId, w1.team, w1.playDirection FROM football_inSnap1 as fS
                                      JOIN week1 as w1 ON fS.gameId = w1.gameId AND fS.playId = w1.playId
                                      WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')")
summary(DefPlayers_inSnap)
```

    ##       epa              x_rel            y_rel           displayName       
    ##  Min.   :-9.3259   Min.   : 0.010   Min.   :-23.44000   Length:8004       
    ##  1st Qu.:-0.8652   1st Qu.: 2.490   1st Qu.: -6.62000   Class :character  
    ##  Median :-0.2413   Median : 4.965   Median : -0.13000   Mode  :character  
    ##  Mean   :-0.1215   Mean   : 6.248   Mean   : -0.01468                     
    ##  3rd Qu.: 0.8474   3rd Qu.: 8.260   3rd Qu.:  6.63000                     
    ##  Max.   : 6.4780   Max.   :59.050   Max.   : 23.42000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  58   Min.   :2.018e+09   Length:8004        Length:8004       
    ##  1st Qu.:1186   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2288   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2260   Mean   :2.018e+09                                        
    ##  3rd Qu.:3306   3rd Qu.:2.018e+09                                        
    ##  Max.   :5511   Max.   :2.018e+09

``` r
DefPlayers_inSnapBest <- DefPlayers_inSnap[DefPlayers_inSnap$epa < -0.86,]
DefPlayers_inSnapWorst <- DefPlayers_inSnap[DefPlayers_inSnap$epa > 0.84,]
DefPlayers_inSnapBest %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
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
def_ag_I_FORM_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'I_FORM'")
summary(def_ag_I_FORM_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-2.90680   Min.   : 0.360   Min.   :-20.0000   Length:314        
    ##  1st Qu.:-0.48274   1st Qu.: 2.315   1st Qu.: -5.2900   Class :character  
    ##  Median :-0.01289   Median : 4.320   Median : -0.5450   Mode  :character  
    ##  Mean   : 0.24762   Mean   : 5.314   Mean   : -0.1991                     
    ##  3rd Qu.: 1.13023   3rd Qu.: 6.702   3rd Qu.:  5.2575                     
    ##  Max.   : 2.94565   Max.   :18.550   Max.   : 20.4000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  75   Min.   :2.018e+09   Length:314         Length:314        
    ##  1st Qu.: 653   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1583   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1731   Mean   :2.018e+09                                        
    ##  3rd Qu.:2868   3rd Qu.:2.018e+09                                        
    ##  Max.   :3716   Max.   :2.018e+09

``` r
def_ag_I_FORM_1_Best <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa < -0.48,]
def_ag_I_FORM_1_Worst <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa > 1.13,]

def_ag_I_FORM_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_I_FORM_1_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-2.png)<!-- -->

``` r
# SINGLEBACK
def_ag_SINGLEBACK_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SINGLEBACK'")
summary(def_ag_SINGLEBACK_1)
```

    ##       epa              x_rel            y_rel         displayName       
    ##  Min.   :-8.0115   Min.   : 0.070   Min.   :-20.930   Length:1103       
    ##  1st Qu.:-0.5532   1st Qu.: 2.460   1st Qu.: -5.760   Class :character  
    ##  Median :-0.2283   Median : 4.320   Median : -0.430   Mode  :character  
    ##  Mean   : 0.1144   Mean   : 5.358   Mean   : -0.151                     
    ##  3rd Qu.: 1.0263   3rd Qu.: 6.940   3rd Qu.:  5.740                     
    ##  Max.   : 5.7593   Max.   :20.490   Max.   : 20.760                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  60   Min.   :2.018e+09   Length:1103        Length:1103       
    ##  1st Qu.: 837   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1682   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1862   Mean   :2.018e+09                                        
    ##  3rd Qu.:2758   3rd Qu.:2.018e+09                                        
    ##  Max.   :4896   Max.   :2.018e+09

``` r
def_ag_SINGLEBACK_1_Best <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa < -0.55,]
def_ag_SINGLEBACK_1_Worst <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa > 1.02,]

def_ag_SINGLEBACK_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SINGLEBACK_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-3.png)<!-- -->

``` r
# SHOTGUN
def_ag_SHOTGUN_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'SHOTGUN'")
summary(def_ag_SHOTGUN_1)
```

    ##       epa              x_rel            y_rel           displayName       
    ##  Min.   :-9.3259   Min.   : 0.010   Min.   :-23.23000   Length:5349       
    ##  1st Qu.:-0.9116   1st Qu.: 2.400   1st Qu.: -6.70000   Class :character  
    ##  Median :-0.2559   Median : 5.070   Median : -0.06000   Mode  :character  
    ##  Mean   :-0.1997   Mean   : 6.388   Mean   : -0.04723                     
    ##  3rd Qu.: 0.7705   3rd Qu.: 8.510   3rd Qu.:  6.57000                     
    ##  Max.   : 6.4780   Max.   :59.050   Max.   : 22.78000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  58   Min.   :2.018e+09   Length:5349        Length:5349       
    ##  1st Qu.:1344   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2417   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2389   Mean   :2.018e+09                                        
    ##  3rd Qu.:3481   3rd Qu.:2.018e+09                                        
    ##  Max.   :5511   Max.   :2.018e+09

``` r
def_ag_SHOTGUN_1_Best <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa < -0.91,]
def_ag_SHOTGUN_1_Worst <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa > 0.77,]
def_ag_SHOTGUN_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SHOTGUN_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-4.png)<!-- -->

``` r
# PISTOL
def_ag_PISTOL_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'PISTOL'")
summary(def_ag_PISTOL_1)
```

    ##       epa               x_rel            y_rel         displayName       
    ##  Min.   :-5.06208   Min.   : 0.590   Min.   :-20.590   Length:75         
    ##  1st Qu.:-0.18700   1st Qu.: 3.180   1st Qu.: -5.965   Class :character  
    ##  Median : 0.17406   Median : 5.210   Median :  0.090   Mode  :character  
    ##  Mean   :-0.02633   Mean   : 6.343   Mean   :  0.582                     
    ##  3rd Qu.: 0.84738   3rd Qu.: 7.690   3rd Qu.:  6.270                     
    ##  Max.   : 1.38130   Max.   :19.220   Max.   : 20.440                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  95   Min.   :2.018e+09   Length:75          Length:75         
    ##  1st Qu.:1546   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2282   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2510   Mean   :2.018e+09                                        
    ##  3rd Qu.:3871   3rd Qu.:2.018e+09                                        
    ##  Max.   :4438   Max.   :2.018e+09

``` r
def_ag_PISTOL_1_Best <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa < -0.18,]
def_ag_PISTOL_1_Worst <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa > 0.84,]
def_ag_PISTOL_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_PISTOL_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-5.png)<!-- -->

``` r
# WILDCAT #more weeks # lowPending 3.1
def_ag_WILDCAT_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'WILDCAT'")
summary(def_ag_WILDCAT_1)
```

    ##       epa              x_rel            y_rel         displayName       
    ##  Min.   :-0.4577   Min.   : 1.330   Min.   :-10.830   Length:9          
    ##  1st Qu.:-0.4577   1st Qu.: 1.960   1st Qu.: -4.290   Class :character  
    ##  Median :-0.4577   Median : 3.630   Median :  3.470   Mode  :character  
    ##  Mean   :-0.4577   Mean   : 5.012   Mean   :  1.716                     
    ##  3rd Qu.:-0.4577   3rd Qu.: 4.940   3rd Qu.:  5.330                     
    ##  Max.   :-0.4577   Max.   :17.220   Max.   : 17.190                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :2841   Min.   :2.018e+09   Length:9           Length:9          
    ##  1st Qu.:2841   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2841   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2841   Mean   :2.018e+09                                        
    ##  3rd Qu.:2841   3rd Qu.:2.018e+09                                        
    ##  Max.   :2841   Max.   :2.018e+09

``` r
def_ag_WILDCAT_1_Best <- def_ag_WILDCAT_1[def_ag_WILDCAT_1$epa < -0.56,] # lowPending 3.1
def_ag_WILDCAT_1_Worst <- def_ag_WILDCAT_1[def_ag_WILDCAT_1$epa > 1.23,] # lowPending 3.1
def_ag_WILDCAT_1 %>% # lowPending 3.1
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_WILDCAT_1")
```

![](filtered_heatmapping_files/figure-gfm/all-6.png)<!-- -->

``` r
# JUMBO #Pending 3.1
def_ag_JUMBO_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'JUMBO'")
summary(def_ag_JUMBO_1)
```

    ##       epa            x_rel           y_rel         displayName       
    ##  Min.   :1.353   Min.   :1.400   Min.   :-6.3400   Length:6          
    ##  1st Qu.:1.353   1st Qu.:1.635   1st Qu.:-3.3950   Class :character  
    ##  Median :1.353   Median :2.790   Median : 0.1150   Mode  :character  
    ##  Mean   :1.353   Mean   :2.803   Mean   : 0.2817                     
    ##  3rd Qu.:1.353   3rd Qu.:3.803   3rd Qu.: 3.6775                     
    ##  Max.   :1.353   Max.   :4.450   Max.   : 7.5000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :1465   Min.   :2.018e+09   Length:6           Length:6          
    ##  1st Qu.:1465   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1465   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1465   Mean   :2.018e+09                                        
    ##  3rd Qu.:1465   3rd Qu.:2.018e+09                                        
    ##  Max.   :1465   Max.   :2.018e+09

``` r
def_ag_JUMBO_1_Best <- def_ag_JUMBO_1[def_ag_JUMBO_1$epa < -0.56,] # lowPending 3.1
def_ag_JUMBO_1_Worst <- def_ag_JUMBO_1[def_ag_JUMBO_1$epa > 1.23,] # lowPending 3.1
def_ag_JUMBO_1 %>% # lowPending 3.1
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_JUMBO_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-7.png)<!-- -->

``` r
# EMPTY
def_ag_EMPTY_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.offenseFormation = 'EMPTY'")
summary(def_ag_EMPTY_1)
```

    ##       epa              x_rel            y_rel          displayName       
    ##  Min.   :-4.1975   Min.   : 0.290   Min.   :-23.4400   Length:1109       
    ##  1st Qu.:-0.9079   1st Qu.: 3.150   1st Qu.: -7.7700   Class :character  
    ##  Median :-0.2775   Median : 5.670   Median : -0.0700   Mode  :character  
    ##  Mean   :-0.1089   Mean   : 6.816   Mean   :  0.2373                     
    ##  3rd Qu.: 0.6062   3rd Qu.: 8.710   3rd Qu.:  8.4400                     
    ##  Max.   : 3.4600   Max.   :25.880   Max.   : 23.4200                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  93   Min.   :2.018e+09   Length:1109        Length:1109       
    ##  1st Qu.: 868   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2303   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2161   Mean   :2.018e+09                                        
    ##  3rd Qu.:3143   3rd Qu.:2.018e+09                                        
    ##  Max.   :5323   Max.   :2.018e+09

``` r
def_ag_EMPTY_1_Best <- def_ag_EMPTY_1[def_ag_EMPTY_1$epa < -0.90,]
def_ag_EMPTY_1_Worst <- def_ag_EMPTY_1[def_ag_EMPTY_1$epa > 0.60,]
def_ag_EMPTY_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_EMPTY_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-8.png)<!-- -->

``` r
### разные по ярдлиниям 
# 0-10
def_yl_0_10_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS
                                  JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap'
                                  AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 0 AND fS.yardlineNumber <= 10")
summary(def_yl_0_10_1)
```

    ##       epa              x_rel            y_rel          displayName       
    ##  Min.   :-6.9678   Min.   : 0.070   Min.   :-21.8700   Length:704        
    ##  1st Qu.:-0.7858   1st Qu.: 2.817   1st Qu.: -6.2125   Class :character  
    ##  Median :-0.2345   Median : 4.665   Median :  0.2100   Mode  :character  
    ##  Mean   :-0.1997   Mean   : 5.326   Mean   :  0.3805                     
    ##  3rd Qu.: 0.4873   3rd Qu.: 6.872   3rd Qu.:  6.9125                     
    ##  Max.   : 3.4601   Max.   :21.930   Max.   : 23.4200                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   : 256   Min.   :2.018e+09   Length:704         Length:704        
    ##  1st Qu.: 925   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1982   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2203   Mean   :2.018e+09                                        
    ##  3rd Qu.:3442   3rd Qu.:2.018e+09                                        
    ##  Max.   :4472   Max.   :2.018e+09

``` r
def_yl_0_10_1_Best <- def_yl_0_10_1[def_yl_0_10_1$epa < -0.78,]
def_yl_0_10_1_Worst <- def_yl_0_10_1[def_yl_0_10_1$epa > 0.48,]
def_yl_0_10_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 0-10")
```

![](filtered_heatmapping_files/figure-gfm/all-9.png)<!-- -->

``` r
# 10-20
def_yl_10_20_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS
                                  JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap'
                                  AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 10 AND fS.yardlineNumber <= 20")
summary(def_yl_10_20_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-4.03653   Min.   : 0.170   Min.   :-23.3800   Length:1386       
    ##  1st Qu.:-0.86717   1st Qu.: 2.442   1st Qu.: -6.4625   Class :character  
    ##  Median :-0.18823   Median : 4.925   Median :  0.3200   Mode  :character  
    ##  Mean   : 0.03288   Mean   : 6.278   Mean   :  0.2099                     
    ##  3rd Qu.: 0.93870   3rd Qu.: 8.455   3rd Qu.:  7.0475                     
    ##  Max.   : 4.30964   Max.   :28.110   Max.   : 22.5400                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  71   Min.   :2.018e+09   Length:1386        Length:1386       
    ##  1st Qu.:1182   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2119   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2196   Mean   :2.018e+09                                        
    ##  3rd Qu.:3169   3rd Qu.:2.018e+09                                        
    ##  Max.   :4924   Max.   :2.018e+09

``` r
def_yl_10_20_1_Best <- def_yl_10_20_1[def_yl_10_20_1$epa < -0.86,]
def_yl_10_20_1_Worst <- def_yl_10_20_1[def_yl_10_20_1$epa > 0.93,]
def_yl_10_20_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 10-20")
```

![](filtered_heatmapping_files/figure-gfm/all-10.png)<!-- -->

``` r
# 20-35

def_yl_20_35_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS
                                  JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap'
                                  AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 20 AND fS.yardlineNumber <= 35")
summary(def_yl_20_35_1)
```

    ##       epa              x_rel            y_rel          displayName       
    ##  Min.   :-9.3259   Min.   : 0.040   Min.   :-23.4400   Length:3072       
    ##  1st Qu.:-0.9235   1st Qu.: 2.440   1st Qu.: -6.7625   Class :character  
    ##  Median :-0.2881   Median : 4.980   Median : -0.4650   Mode  :character  
    ##  Mean   :-0.2023   Mean   : 6.214   Mean   : -0.2091                     
    ##  3rd Qu.: 0.7010   3rd Qu.: 8.293   3rd Qu.:  6.3125                     
    ##  Max.   : 6.4780   Max.   :25.880   Max.   : 22.6300                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  58   Min.   :2.018e+09   Length:3072        Length:3072       
    ##  1st Qu.:1177   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2324   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2247   Mean   :2.018e+09                                        
    ##  3rd Qu.:3267   3rd Qu.:2.018e+09                                        
    ##  Max.   :5511   Max.   :2.018e+09

``` r
def_yl_20_35_1_Best <- def_yl_20_35_1[def_yl_20_35_1$epa < -0.92,]
def_yl_20_35_1_Worst <- def_yl_20_35_1[def_yl_20_35_1$epa > 0.70,]
def_yl_20_35_1_Best %>% 
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="Best right def on yardline 20-35")
```

![](filtered_heatmapping_files/figure-gfm/all-11.png)<!-- -->

``` r
# 35-50
def_yl_35_50_1 <- dbGetQuery(con, "SELECT fS.epa, abs(w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS
                                  JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap'
                                  AND w1.team NOT IN(fS.possessionTeam, 'football')
                                  AND fS.yardlineNumber > 35 AND fS.yardlineNumber <= 50")
summary(def_yl_35_50_1)
```

    ##       epa               x_rel            y_rel           displayName       
    ##  Min.   :-8.81636   Min.   : 0.010   Min.   :-23.23000   Length:2842       
    ##  1st Qu.:-0.78222   1st Qu.: 2.502   1st Qu.: -6.65750   Class :character  
    ##  Median :-0.23486   Median : 5.040   Median : -0.07000   Mode  :character  
    ##  Mean   :-0.09012   Mean   : 6.497   Mean   : -0.01202                     
    ##  3rd Qu.: 0.95071   3rd Qu.: 8.508   3rd Qu.:  6.63750                     
    ##  Max.   : 5.58587   Max.   :59.050   Max.   : 22.80000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  79   Min.   :2.018e+09   Length:2842        Length:2842       
    ##  1st Qu.:1235   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2357   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2320   Mean   :2.018e+09                                        
    ##  3rd Qu.:3335   3rd Qu.:2.018e+09                                        
    ##  Max.   :5369   Max.   :2.018e+09

``` r
def_yl_35_50_1_Best <- def_yl_35_50_1[def_yl_35_50_1$epa < -0.78,]
def_yl_35_50_1_Worst <- def_yl_35_50_1[def_yl_35_50_1$epa > 0.95,]
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
# То есть w1.playDirection = 'right' AND  x_rel >= 0 заменится на w1.замененный team из homeTeamAbbr != p.possessionTeam

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
