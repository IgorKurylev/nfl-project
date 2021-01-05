setwd("D:/DS/project")

## TODO: models tuning
##       try a classification task
##       change dependent variable to epa
##       try to exclude epa
##       add teams personnel
##       transform model to risk predictor

calc_rmse = function(actual, predicted) {
  sqrt(mean((actual - predicted) ^ 2))
}

################################### Random forest ######################################

#install.packages("randomForest")
#install.packages("party")

library(randomForest)
library(party)


df <- read.csv("nfl-big-data-bowl-2021/plays.csv")
df <- na.omit(df)

df <- transform(df,
                offenseFormation  = as.factor(offenseFormation),
                typeDropback = as.factor(typeDropback),
                passResult = as.factor(passResult))

summary(df)
sapply(df, class)

colSums(is.na(df))

## 80% of the sample size
smp_size <- floor(0.8 * nrow(df))

set.seed(123)
train_ind <- sample(seq_len(nrow(df)), size = smp_size)

train <- df[train_ind, ]
test <- df[-train_ind, ]
model <- randomForest(playResult ~ yardsToGo + offenseFormation + defendersInTheBox + numberOfPassRushers + typeDropback + preSnapHomeScore + preSnapVisitorScore + passResult + epa,
                      data = train, mtry = 3,
                      importance = TRUE, ntrees = 500)

model

importance(model, type = 1)

varImpPlot(model, type = 1)

summary(model)

predicted = predict(model, newdata = test)
plot(predicted, test$playResult,
     xlab = "Predicted", ylab = "Actual",
     main = "Random forest: Predicted vs Actual",
     col = "dodgerblue", pch = 20)
grid()
abline(0, 1, col = "darkorange", lwd = 2)

(tst_rmse = calc_rmse(predicted, test$playResult))


################################### Bagging ######################################

bagging_model <- randomForest(playResult ~ yardsToGo + offenseFormation + defendersInTheBox + numberOfPassRushers + typeDropback + preSnapHomeScore + preSnapVisitorScore + passResult + epa,
                      data = train, mtry = 9,
                      importance = TRUE, ntrees = 500)

bagging_model

importance(bagging_model, type = 1)

varImpPlot(bagging_model, type = 1)

summary(bagging_model)

predicted = predict(bagging_model, newdata = test)
plot(predicted, test$playResult,
     xlab = "Predicted", ylab = "Actual",
     main = "Bagging: Predicted vs Actual",
     col = "dodgerblue", pch = 20)
grid()
abline(0, 1, col = "darkorange", lwd = 2)

(tst_rmse = calc_rmse(predicted, test$playResult))


################################### Boosted model ######################################

boosted_model <- gbm(playResult ~ yardsToGo + offenseFormation + defendersInTheBox + numberOfPassRushers + typeDropback + preSnapHomeScore + preSnapVisitorScore + passResult + epa,
                     data = train, distribution = "gaussian", 
                    n.trees = 5000, interaction.depth = 4, shrinkage = 0.01)
boosted_model

tibble::as_tibble(summary(boosted_model))

## Marginal effects
## https://www.statisticshowto.com/marginal-effects/

plot(boosted_model, i = "epa", col = "dodgerblue", lwd = 2)
plot(boosted_model, i = "yardsToGo", col = "dodgerblue", lwd = 2)

boosted_prediction = predict(boosted_model, newdata = test, n.trees = 5000)
(boosted_tst_rmse = calc_rmse(boosted_prediction, test$playResult))

plot(boosted_prediction, test$playResult,
     xlab = "Predicted", ylab = "Actual", 
     main = "Predicted vs Actual: Boosted Model, Test Data",
     col = "dodgerblue", pch = 20)
grid()
abline(0, 1, col = "darkorange", lwd = 2)

################################### Visualization attempt ######################################

plot(getTree(model, 3, labelVar=TRUE))

cf <- cforest(playResult ~ yardsToGo + offenseFormation + defendersInTheBox + numberOfPassRushers + typeDropback + preSnapHomeScore + preSnapVisitorScore + passResult + epa,
              data = train)

plot(getTree(cf, 3, labelVar=TRUE))

pt <- prettytree(cf@ensemble[[3]], names(cf@data@get("input")))

nt <- new("BinaryTree")
nt@tree <- pt
nt@data <- cf@data
nt@responses <- cf@responses
nt@weights <- cf@weights[[3]]

plot(nt, type="simple")


npt <- new("BinaryTree")
npt@tree <- pt
plot(npt, type="simple")


prettytree(cf, names(cf@data@get("input")))


################################### Simple Tree (Classification) ######################################

library(rpart)
library(rpart.plot)
library(caret)

df <- read.csv("nfl-big-data-bowl-2021/plays.csv")
df <- na.omit(df)

quantile(df$playResult, na.rm = TRUE)

df["result_categorical"] <- df["playResult"]
df["result_categorical"] <- apply(df["result_categorical"], 2, function(x) ifelse(x < 0, -1, x))
df["result_categorical"] <- apply(df["result_categorical"], 2, function(x) ifelse(x > 0 & x < 5, 0, x))
df["result_categorical"] <- apply(df["result_categorical"], 2, function(x) ifelse(x > 4 & x < 11, 1, x))
df["result_categorical"] <- apply(df["result_categorical"], 2, function(x) ifelse(x > 10, 2, x))

df <- transform(df,
                offenseFormation  = as.factor(offenseFormation),
                typeDropback = as.factor(typeDropback),
                passResult = as.factor(passResult),
                result_categorical = as.factor(result_categorical))

smp_size <- floor(0.8 * nrow(df))

set.seed(123)
train_ind <- sample(seq_len(nrow(df)), size = smp_size)

train <- df[train_ind, ]
test <- df[-train_ind, ]

rpart_model <- rpart( result_categorical ~ yardsToGo + offenseFormation + defendersInTheBox + numberOfPassRushers + typeDropback + preSnapHomeScore + preSnapVisitorScore + passResult + epa,
                data = train,
                method = "class",
                control = rpart.control(xval=4),
                parms = list(split="information") )

printcp(rpart_model)

rpart.plot(rpart_model, type = 4, extra = 3)

predicted_testing <- predict(rpart_model, newdata = test, type = "class")
test["predicted"] <- predicted_testing

## ROC AUC (Only for 0 predictions)

library(ROCR)

predicted = predict(rpart_model, newdata = test, type="class")
predicted[predicted != 0] <- 1

test["for_0"] <- test["result_categorical"] 
test["for_0"] <- apply(test["for_0"], 2, function(x) ifelse(x != 0, 1, x))


predObj = prediction(as.numeric(predicted), test$for_0)

rocObj = performance(predObj, measure="tpr", x.measure="fpr")  # creates ROC curve 
aucObj = performance(predObj, measure="auc")  # auc object

auc = aucObj@y.values[[1]]

plot(rocObj, main = paste("Area under the curve:", auc))
