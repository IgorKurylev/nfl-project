setwd("D:/DS/project")

library(caret)
library(plotly)

df <- read.csv("players_merged.csv")
df <- na.omit(df)

df["BMI"] <- (df$weight / (df$height)^2) * 703

plot(df$cnt, df$points)

# removing anomalies

df <- subset(df, df$cnt < 100)
df <- subset(df,  df$cnt != 59 & df$points != 19)

plot(df$cnt, df$points)

## Feature scaling

preproc <- preProcess(df[,c(8,9)], method=c("center", "scale"))
norm <- predict(preproc, df[,c(8,9)])

summary(norm)

plot(norm$cnt, norm$points)

scaled <- data.frame(norm$cnt, norm$points)

## Hierarchial

d <- dist(as.matrix(scaled))
hc <- hclust(d, method = "ward")
plot(hc, xlab='State')

rect.hclust(hc , k = 8)

ct <- cutree(hc, k = 8)
plot(scaled, col=ct)


## most interesting types - 2,7,6

fig <- plot_ly(data = df, x = ~cnt, y = ~points, text = ~ct)
add_markers(fig, color = ~ct)

df["points_cnt"] <- ct


## K-means (not used in this case)

set.seed(731)

wss <- numeric(15) 
for (i in 1:15) wss[i] <- (kmeans(scaled, centers=i)$tot.withinss)

plot(1:15, wss, type="b", 
     xlab="Number of Clusters",ylab="Within groups sum of squares",
     main = "WSS")

km <- kmeans(scaled, 8, nstart = 15)

plot(scaled, col=km$cluster)
points(km$centers, col=1:8, pch=8)

## BMI as feature

# removing anomalies

df <- subset(df, df$points != 447 & df$BMI != 35.9936)
df <- subset(df, df$points != 241 & df$BMI != 39.97166)

## Feature scaling

preproc <- preProcess(df[,c(8,10)], method=c("center", "scale"))
norm <- predict(preproc, df[,c(8,10)])

summary(norm)

plot(norm$BMI, norm$points)

scaled <- data.frame(norm$BMI, norm$points)
scaled <- na.omit(scaled)

## Hierarchial (not used in this case)

d <- dist(as.matrix(scaled))
hc <- hclust(d, method = "ward")
plot(hc, xlab='State')

rect.hclust(hc , k = 7)

ct <- cutree(hc, k = 7)
plot(scaled, col=ct)

## K-means

set.seed(731)

wss <- numeric(15) 
for (i in 1:15) wss[i] <- (kmeans(scaled, centers=i)$tot.withinss)

plot(1:15, wss, type="b", 
     xlab="Number of Clusters",ylab="Within groups sum of squares",
     main = "WSS")
chosen <- 8
abline(v = chosen, h = wss[chosen], col = 'red')

km <- kmeans(scaled, 8, nstart = 15)

plot(scaled, col=km$cluster)
points(km$centers, col=1:8, pch=8)

## most interesting types - 7,6,5,3

fig <- plot_ly(data = df, x = ~BMI, y = ~points, text = ~km$cluster)
add_markers(fig, color = ~km$cluster)

df["points_bmi"] <- km$cluster

write.csv(x = df, file = "clustering.csv")


## EPA ~ yardsToGo

df <- read.csv("nfl-big-data-bowl-2021/plays.csv")
df <- na.omit(df)

summary(df$epa)
summary(df$yardsToGo)

plot(df$yardsToGo, df$epa)

fig <- plot_ly(data = df, x = ~yardsToGo, y = ~epa)
fig

# removing anomalies

df <- subset(df, df$epa != -0.3228326 & df$yardsToGo != 41)
df <- subset(df, df$epa !=  -2.437345 & df$yardsToGo != 38)

## Feature scaling

preproc <- preProcess(df[,c(which(colnames(df)=="yardsToGo"),which(colnames(df)=="epa"))], method=c("center", "scale"))
norm <- predict(preproc, df[,c(which(colnames(df)=="yardsToGo"),which(colnames(df)=="epa"))])

summary(norm)

plot(norm$yardsToGo, norm$epa)

library(ggplot2)

p <- ggplot(df, aes(yardsToGo, playResult))
p + geom_point(position = "jitter", alpha = 0.1)

scaled <- data.frame(norm$yardsToGo, norm$epa)

## Hierarchial (not used in this case)

d <- dist(as.matrix(scaled))
hc <- hclust(d, method = "ward")

rect.hclust(hc , k = 8)

ct <- cutree(hc, k = 8)

opts <- options()  # save old options

options(ggplot2.continuous.colour="viridis")
options(ggplot2.continuous.fill = "viridis")

p <- ggplot(scaled, aes(norm.yardsToGo, norm.epa, colour = ct))
p + geom_point(position = "jitter", alpha=0.2)

options(opts)

plot(scaled, col=ct)

## K-means

set.seed(731)

wss <- numeric(15) 
for (i in 1:15) wss[i] <- (kmeans(scaled, centers=i)$tot.withinss)

plot(1:15, wss, type="b", 
     xlab="Number of Clusters",ylab="Within groups sum of squares",
     main = "WSS")
chosen <- 8
abline(v = chosen, h = wss[chosen], col = 'red')

km <- kmeans(scaled, 8, nstart = 20)

plot(scaled, col=km$cluster)
points(km$centers, col=1:8, pch=8)

p <- ggplot(scaled, aes(norm.yardsToGo, norm.epa, colour = km$cluster))
p + geom_point(position = "jitter", alpha=0.2)

fig <- plot_ly(data = df, x = ~yardsToGo, y = ~epa, color = ~km$cluster, text = ~km$cluster)
fig

df["epa_yardstogo"] <- km$cluster

write.csv(x = df, file = "plays_clustering.csv")

## most risk in 4,5
## less risk in 3
## most successful plays in 6


###### Conclusions

library(plyr)
library(dplyr)

clust <- read.csv('clustering.csv', header = TRUE, sep=',') 
clust$counts <- 1

groupColumns = c("nflId ","position", "points_bmi", "points_cnt")
dataCol = c("counts")

res <- ddply(clust, groupColumns, function(x) colSums(x[dataCol]))
#res <- subset(res, counts > 37) # ????????????????????????


single_bmi <- aggregate(res$counts, by=list(points_bmi=res$points_bmi), FUN=sum)
single_cnt <- aggregate(res$counts, by=list(points_cnt=res$points_cnt), FUN=sum)
pos_bmi <- aggregate(res$counts, by=list(position=res$position, points_bmi=res$points_bmi), FUN=sum)
pos_cnt <- aggregate(res$counts, by=list(position=res$position, points_cnt=res$points_cnt), FUN=sum)
all_grp <- aggregate(res$counts, by=list(nflId=res$nflId, 
                                         position=res$position, 
                                         points_bmi=res$points_bmi, 
                                         points_cnt=res$points_cnt), 
                     FUN=sum)

res <- res %>% rowwise %>% do({
        result = as_data_frame(.)
        
        result$bmi_count = single_bmi[single_bmi$points_bmi == result$points_bmi, 2]
        result$cnt_count = single_cnt[single_cnt$points_cnt == result$points_cnt, 2]
        result$count_bmi_pos = pos_bmi[pos_bmi$points_bmi   == result$points_bmi & 
                                               pos_bmi$position   == result$position, 3]
        result$count_bmi_pos = pos_cnt[pos_cnt$points_cnt   == result$points_cnt & 
                                               pos_cnt$position   == result$position, 3]
        
        
        result$totalAll = all_grp[  all_grp$points_bmi == result$points_bmi & 
                                            all_grp$points_cnt == result$points_cnt &
                                            all_grp$position   == result$position & 
                                            all_grp$nflId      == result$nflId, 5]
        
        result
})



xtabs(~position + points_bmi , data = res)

xtabs(~position + points_cnt , data = res)


