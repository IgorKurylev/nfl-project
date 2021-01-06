setwd("D:/DS/project")

## TODO: identify anomalies

library(caret)

df <- read.csv("players_merged.csv")
df <- na.omit(df)

df["BMI"] <- (df$weight / (df$height)^2) * 703

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
#plot(hc, xlab='State')

rect.hclust(hc , k = 10)

ct <- cutree(hc, k = 10)
plot(scaled, col=ct)

## K-means

set.seed(731)

wss <- numeric(15) 
for (i in 1:15) wss[i] <- (kmeans(scaled, centers=i)$tot.withinss)

plot(1:15, wss, type="b", 
     xlab="Number of Clusters",ylab="Within groups sum of squares",
     main = "WSS")
#chosen <- 4
#abline(v = chosen, h = wss[chosen], col = 'red')

km <- kmeans(scaled, 6, nstart = 15)

plot(scaled, col=km$cluster)
points(km$centers, col=1:6, pch=8)

## BMI as feature

## Feature scaling

preproc <- preProcess(df[,c(8,10)], method=c("center", "scale"))
norm <- predict(preproc, df[,c(8,10)])

summary(norm)

plot(norm$BMI, norm$points)

scaled <- data.frame(norm$BMI, norm$points)
scaled <- na.omit(scaled)

## Hierarchial

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
#chosen <- 4
#abline(v = chosen, h = wss[chosen], col = 'red')

km <- kmeans(scaled, 6, nstart = 15)

plot(scaled, col=km$cluster)
points(km$centers, col=1:6, pch=8)


## EPA ~ yardsToGo

df <- read.csv("nfl-big-data-bowl-2021/plays.csv")
df <- na.omit(df)

summary(df$epa)
summary(df$yardsToGo)

plot(df$yardsToGo, df$epa)

## Feature scaling

preproc <- preProcess(df[,c(which(colnames(df)=="yardsToGo"),which(colnames(df)=="playResult"))], method=c("center", "scale"))
norm <- predict(preproc, df[,c(which(colnames(df)=="yardsToGo"),which(colnames(df)=="playResult"))])

summary(norm)

plot(norm$yardsToGo, norm$playResult)

library(ggplot2)

p <- ggplot(df, aes(yardsToGo, playResult))
p + geom_point(position = "jitter", alpha = 0.1)

scaled <- data.frame(norm$yardsToGo, norm$playResult)

## Hierarchial

d <- dist(as.matrix(scaled))
hc <- hclust(d, method = "ward")
plot(hc, xlab='State')

rect.hclust(hc , k = 8)

ct <- cutree(hc, k = 8)

opts <- options()  # save old options

options(ggplot2.continuous.colour="viridis")
options(ggplot2.continuous.fill = "viridis")

p <- ggplot(scaled, aes(norm.yardsToGo, norm.playResult, colour = ct))
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
#chosen <- 4
#abline(v = chosen, h = wss[chosen], col = 'red')

km <- kmeans(scaled, 10, nstart = 20)

plot(scaled, col=km$cluster)
points(km$centers, col=1:10, pch=8)

