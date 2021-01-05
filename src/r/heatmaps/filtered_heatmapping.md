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
head(testTeam, 12)
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


# берем информацию по мячу
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
                                      w1.gameId, p.offenseFormation, p.possessionTeam FROM plays as p JOIN week1 as w1 ON p.gameId = w1.gameId
                                      AND p.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName = 'Football'")
dbWriteTable(con, "football_inSnap1", football_inSnap1)
dbListFields(con, "football_inSnap1")
```

    ## [1] "epa"              "x_b"              "y_b"              "displayName"     
    ## [5] "event"            "playId"           "gameId"           "offenseFormation"
    ## [9] "possessionTeam"

``` r
#dbRemoveTable(con, "football_inSnap1")


# информация о защитниках с относительными координатами

### MAIN QUERY of defenders (by team!)
DefPlayers_inSnapleftOffense <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'left' AND  x_rel <= 0")

# Отбор по epa
summary(DefPlayers_inSnapleftOffense)
```

    ##       epa              x_rel             y_rel           displayName       
    ##  Min.   :-8.8164   Min.   :-25.880   Min.   :-23.92000   Length:4562       
    ##  1st Qu.:-0.8424   1st Qu.: -7.897   1st Qu.: -7.22000   Class :character  
    ##  Median :-0.2506   Median : -4.680   Median :  0.13500   Mode  :character  
    ##  Mean   :-0.1650   Mean   : -5.748   Mean   :  0.04305                     
    ##  3rd Qu.: 0.7438   3rd Qu.: -1.830   3rd Qu.:  7.15000                     
    ##  Max.   : 5.5859   Max.   :  0.000   Max.   : 24.53000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  58   Min.   :2.018e+09   Length:4562        Length:4562       
    ##  1st Qu.:1182   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2305   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2260   Mean   :2.018e+09                                        
    ##  3rd Qu.:3332   3rd Qu.:2.018e+09                                        
    ##  Max.   :5511   Max.   :2.018e+09

``` r
# 1rd quater of epa is -0.8424
# 3rd Qu.: 0.74
players_inSnapBestEPA <- DefPlayers_inSnapleftOffense[DefPlayers_inSnapleftOffense$epa < -0.85,]
players_inSnapWorstEPA <- DefPlayers_inSnapleftOffense[DefPlayers_inSnapleftOffense$epa > 0.74,]
#players_inSnapBestBestEPA <- DefPlayers_inSnapleftOffense[DefPlayers_inSnapleftOffense$epa < -2,]
#summary(players_inSnapBestEPA)
#summary(players_inSnapWorstEPA)
#summary(players_inSnapBestBestEPA)



#players_inSnapBestBestEPA %>%
#  ggplot(aes(x = x_rel, y = y_rel)) +
#  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.1, 1.0, length.out = 10))
players_inSnapBestEPA %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) # очистка
```

![](filtered_heatmapping_files/figure-gfm/all-1.png)<!-- -->

``` r
players_inSnapWorstEPA %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10))
```

![](filtered_heatmapping_files/figure-gfm/all-2.png)<!-- -->

``` r
### теперь для правой атаки (соеденить по модулю x_rel #Pending)
### MAIN QUERY of defenders (by team!)
DefPlayers_inSnaprightOffense <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0")

summary(DefPlayers_inSnaprightOffense)
```

    ##       epa               x_rel            y_rel           displayName       
    ##  Min.   :-9.32588   Min.   : 0.000   Min.   :-22.95000   Length:4206       
    ##  1st Qu.:-0.88154   1st Qu.: 1.930   1st Qu.: -6.90000   Class :character  
    ##  Median :-0.23486   Median : 4.530   Median : -0.38000   Mode  :character  
    ##  Mean   :-0.08282   Mean   : 5.732   Mean   : -0.04933                     
    ##  3rd Qu.: 0.91539   3rd Qu.: 7.670   3rd Qu.:  7.02500                     
    ##  Max.   : 6.47797   Max.   :59.050   Max.   : 23.57000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  71   Min.   :2.018e+09   Length:4206        Length:4206       
    ##  1st Qu.:1218   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2297   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2274   Mean   :2.018e+09                                        
    ##  3rd Qu.:3321   3rd Qu.:2.018e+09                                        
    ##  Max.   :5449   Max.   :2.018e+09

``` r
# 1rd quater of epa is -0.88
# 3rd Qu.: 0.91
players_inSnapBestEPAr <- DefPlayers_inSnaprightOffense[DefPlayers_inSnaprightOffense$epa < -0.88,]
players_inSnapWorstEPAr <- DefPlayers_inSnaprightOffense[DefPlayers_inSnaprightOffense$epa > 0.91,]
#players_inSnapBestBestEPAr <- DefPlayers_inSnaprightOffense[DefPlayers_inSnaprightOffense$epa < -2,]


#players_inSnapBestBestEPAr %>%
#  ggplot(aes(x = x_rel, y = y_rel)) +
#  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.1, 1.0, length.out = 10))
players_inSnapBestEPAr %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) #очистка
```

![](filtered_heatmapping_files/figure-gfm/all-3.png)<!-- -->

``` r
players_inSnapWorstEPAr %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10))
```

![](filtered_heatmapping_files/figure-gfm/all-4.png)<!-- -->

``` r
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
def_ag_I_FORM_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0
                                  AND fS.offenseFormation = 'I_FORM'")
summary(def_ag_I_FORM_1)
```

    ##       epa              x_rel            y_rel          displayName       
    ##  Min.   :-2.9068   Min.   : 0.030   Min.   :-19.1400   Length:134        
    ##  1st Qu.:-0.4545   1st Qu.: 2.837   1st Qu.: -6.0050   Class :character  
    ##  Median :-0.1538   Median : 4.420   Median : -0.8350   Mode  :character  
    ##  Mean   : 0.2747   Mean   : 5.512   Mean   : -0.9491                     
    ##  3rd Qu.: 1.1374   3rd Qu.: 6.853   3rd Qu.:  4.8025                     
    ##  Max.   : 2.9456   Max.   :17.140   Max.   : 19.7000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   : 210   Min.   :2.018e+09   Length:134         Length:134        
    ##  1st Qu.: 451   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2204   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1902   Mean   :2.018e+09                                        
    ##  3rd Qu.:2895   3rd Qu.:2.018e+09                                        
    ##  Max.   :3716   Max.   :2.018e+09

``` r
def_ag_I_FORM_1_Best <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa < -0.46,]
def_ag_I_FORM_1_Worst <- def_ag_I_FORM_1[def_ag_I_FORM_1$epa > 1.13,]

def_ag_I_FORM_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_I_FORM_1_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-5.png)<!-- -->

``` r
# SINGLEBACK
def_ag_SINGLEBACK_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0
                                  AND fS.offenseFormation = 'SINGLEBACK'")
summary(def_ag_SINGLEBACK_1)
```

    ##       epa               x_rel            y_rel          displayName       
    ##  Min.   :-3.75961   Min.   : 0.000   Min.   :-20.9300   Length:617        
    ##  1st Qu.:-0.55316   1st Qu.: 2.470   1st Qu.: -5.9400   Class :character  
    ##  Median :-0.04321   Median : 4.350   Median : -0.7700   Mode  :character  
    ##  Mean   : 0.38134   Mean   : 5.375   Mean   : -0.2116                     
    ##  3rd Qu.: 1.23018   3rd Qu.: 6.950   3rd Qu.:  5.7100                     
    ##  Max.   : 5.75931   Max.   :20.240   Max.   : 20.5900                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  71   Min.   :2.018e+09   Length:617         Length:617        
    ##  1st Qu.: 963   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1610   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :1942   Mean   :2.018e+09                                        
    ##  3rd Qu.:3167   3rd Qu.:2.018e+09                                        
    ##  Max.   :4896   Max.   :2.018e+09

``` r
def_ag_SINGLEBACK_1_Best <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa < -0.56,]
def_ag_SINGLEBACK_1_Worst <- def_ag_SINGLEBACK_1[def_ag_SINGLEBACK_1$epa > 1.23,]

def_ag_SINGLEBACK_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SINGLEBACK_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-6.png)<!-- -->

``` r
# SHOTGUN
def_ag_SHOTGUN_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0
                                  AND fS.offenseFormation = 'SHOTGUN'")
summary(def_ag_SHOTGUN_1)
```

    ##       epa              x_rel            y_rel            displayName       
    ##  Min.   :-9.3259   Min.   : 0.000   Min.   :-22.950000   Length:2903       
    ##  1st Qu.:-0.9116   1st Qu.: 1.840   1st Qu.: -7.140000   Class :character  
    ##  Median :-0.2399   Median : 4.560   Median : -0.140000   Mode  :character  
    ##  Mean   :-0.1646   Mean   : 5.816   Mean   : -0.007337                     
    ##  3rd Qu.: 0.8846   3rd Qu.: 7.855   3rd Qu.:  7.200000                     
    ##  Max.   : 6.4780   Max.   :59.050   Max.   : 22.780000                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  72   Min.   :2.018e+09   Length:2903        Length:2903       
    ##  1st Qu.:1350   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :2594   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2431   Mean   :2.018e+09                                        
    ##  3rd Qu.:3475   3rd Qu.:2.018e+09                                        
    ##  Max.   :5276   Max.   :2.018e+09

``` r
def_ag_SHOTGUN_1_Best <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa < -0.91,]
def_ag_SHOTGUN_1_Worst <- def_ag_SHOTGUN_1[def_ag_SHOTGUN_1$epa > 0.88,]
def_ag_SHOTGUN_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_SHOTGUN_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-7.png)<!-- -->

``` r
# PISTOL
def_ag_PISTOL_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0
                                  AND fS.offenseFormation = 'PISTOL'")
summary(def_ag_PISTOL_1)
```

    ##       epa              x_rel            y_rel         displayName       
    ##  Min.   :-5.0621   Min.   : 0.310   Min.   :-20.590   Length:56         
    ##  1st Qu.:-0.4325   1st Qu.: 2.505   1st Qu.: -6.298   Class :character  
    ##  Median : 0.1741   Median : 5.070   Median :  1.615   Mode  :character  
    ##  Mean   :-0.4893   Mean   : 6.017   Mean   :  1.294                     
    ##  3rd Qu.: 0.7052   3rd Qu.: 6.685   3rd Qu.:  8.080                     
    ##  Max.   : 1.3813   Max.   :19.220   Max.   : 20.440                     
    ##      playId         gameId              team           playDirection     
    ##  Min.   :  95   Min.   :2.018e+09   Length:56          Length:56         
    ##  1st Qu.: 641   1st Qu.:2.018e+09   Class :character   Class :character  
    ##  Median :1865   Median :2.018e+09   Mode  :character   Mode  :character  
    ##  Mean   :2045   Mean   :2.018e+09                                        
    ##  3rd Qu.:2982   3rd Qu.:2.018e+09                                        
    ##  Max.   :4438   Max.   :2.018e+09

``` r
def_ag_PISTOL_1_Best <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa < -0.43,]
def_ag_PISTOL_1_Worst <- def_ag_PISTOL_1[def_ag_PISTOL_1$epa > 0.70,]
def_ag_PISTOL_1_Best %>%
  ggplot(aes(x = x_rel, y = y_rel)) +
  geom_density2d_filled(contour_var = "ndensity", breaks = seq(0.2, 1.0, length.out = 10)) + #очистка
  labs(title="def_ag_PISTOL_Best")
```

![](filtered_heatmapping_files/figure-gfm/all-8.png)<!-- -->

``` r
# WILDCAT for left #Pending 3.1
def_ag_WILDCAT_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'left' AND  x_rel <= 0
                                  AND fS.offenseFormation = 'WILDCAT'")
summary(def_ag_WILDCAT_1)
```

    ##       epa              x_rel             y_rel         displayName       
    ##  Min.   :-0.4577   Min.   :-17.220   Min.   :-10.830   Length:9          
    ##  1st Qu.:-0.4577   1st Qu.: -4.940   1st Qu.: -4.290   Class :character  
    ##  Median :-0.4577   Median : -3.630   Median :  3.470   Mode  :character  
    ##  Mean   :-0.4577   Mean   : -5.012   Mean   :  1.716                     
    ##  3rd Qu.:-0.4577   3rd Qu.: -1.960   3rd Qu.:  5.330                     
    ##  Max.   :-0.4577   Max.   : -1.330   Max.   : 17.190                     
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

![](filtered_heatmapping_files/figure-gfm/all-9.png)<!-- -->

``` r
# JUMBO #Pending 3.1
def_ag_JUMBO_1 <- dbGetQuery(con, "SELECT fS.epa, (w1.x - x_b) as x_rel, (w1.y - y_b) as y_rel, w1.displayName, w1.playId,
                                  w1.gameId, w1.team, w1.playDirection  FROM football_inSnap1 as fS JOIN week1 as w1 ON fS.gameId = w1.gameId
                                  AND fS.playId = w1.playId WHERE w1.event = 'ball_snap' AND w1.displayName != 'Football'
                                  AND w1.playDirection = 'right' AND  x_rel >= 0
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

![](filtered_heatmapping_files/figure-gfm/all-10.png)<!-- -->

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
```
