setwd("~/to website/r project (rlcs)")

data <- read.csv("matches_by_teams.csv")

#need to remove rows with NA values

data <- na.omit(data)

#first need to turn columns color, team_name, and team_region, winner into numbers

#color
data$color <- replace(data$color,data$color == "blue" ,0)
data$color <- replace(data$color,data$color == "orange" ,1)
data$color <- as.numeric(data$color)

#team_name

data$team_name <- as.numeric(as.factor(data$team_name))

#team_region

data$team_region <- as.numeric(as.factor(data$team_region))

#winner 

data$winner <- replace(data$winner, data$winner == "True", 1)
data$winner <- replace(data$winner, data$winner == "False", 0)
data$winner <- as.numeric(data$winner)


#need to remove score column since this almost always shows who wins (in bo5)
#can also remove match_id, team_id, and team_slug columns

data$match_id <- NULL
data$team_id <- NULL
data$team_slug <- NULL
data$score <- NULL

#can start now
set.seed(1)
N <- nrow(data)
trainInd <- sample(1:N, round(N*0.8), replace=F)
trainSet <- data[trainInd,]
validSet <- data[-trainInd,]


full <- lm(winner ~ ., data = data)
empty <- lm(winner ~ 1, data = data)
library(MASS)
m1 <- stepAIC(object = empty, scope = list(upper = full, lower = empty), direction = "both", k = log(nrow(trainSet)))

pred1 <- predict(m1, newdata = validSet)
sqrt(mean((validSet$winner- pred1)^2)) # RMSE on validation  
sqrt(mean(m1$residuals^2)) # RMSE on train

#this step is to find the optimal k value
K <- 5
validSetSplits <- sample((1:N)%%K + 1)
RMSE1 <- c()
RMSE2 <- c()
RMSE3 <- c()
RMSE4 <- c()
RMSE5 <- c()
for (k in 1:K) {
  validSet <- data[validSetSplits==k,]
  trainSet <- data[validSetSplits!=k,]  
  
  full <- lm(winner ~ ., data = data)
  empty <- lm(winner ~ 1, data = data)
  
  m1 <- stepAIC(object = empty, scope = list(upper = full, lower = empty),
                direction = "both", k = log(nrow(trainSet)) ^ 2)
  pred1 <- predict(m1, newdata = validSet)
  RMSE1[k] <- sqrt(mean((validSet$winner - pred1)^2))  
  
  m2 <- stepAIC(object = empty, scope = list(upper = full, lower = empty),
                direction = "both", k =  2 * (log(nrow(trainSet))))
  pred2 <- predict(m2, newdata = validSet)
  RMSE2[k] <- sqrt(mean((validSet$winner - pred2)^2))  
  
  m3 <- stepAIC(object = empty, scope = list(upper = full, lower = empty),
                direction = "both", k =  (log(nrow(trainSet))))
  pred3 <- predict(m3, newdata = validSet)
  RMSE3[k] <- sqrt(mean((validSet$winner - pred3)^2)) 
  
  m4 <- stepAIC(object = empty, scope = list(upper = full, lower = empty),
                direction = "both", k = log(nrow(trainSet)) ^ 3)
  pred4 <- predict(m4, newdata = validSet)
  RMSE4[k] <- sqrt(mean((validSet$winner - pred4)^2))  
  
  m5 <- stepAIC(object = empty, scope = list(upper = full, lower = empty),
                direction = "both", k = 1/2 * log(nrow(trainSet)))
  pred5 <- predict(m4, newdata = validSet)
  RMSE5[k] <- sqrt(mean((validSet$winner - pred5)^2))  
  
}
RMSE1 
RMSE2
RMSE3 
RMSE4
RMSE5 

mean(RMSE1)
mean(RMSE2)
mean(RMSE3)
mean(RMSE4)
mean(RMSE5)

#3 has the lowest rmse, so use that k value for final model

full <- lm(winner ~ ., data = data)
empty <- lm(winner ~ 1, data = data)

mfinal <- stepAIC(object = empty, scope = list(upper = full, lower = empty), direction = "both", k = log(nrow(trainSet)))
library(car)
vif(mfinal)

#need to remove those with high vif (>10) manually


#removed core_goals, positioning_time_in_front_ball, movement_total_distance, boost_time_75_100, positioning_time_behind_ball
#movement_time_slow_speed, boost_bpm, boost_bcpm, boost_time_25_50, positioning_time_neutral_third

mfinal <- lm(formula = winner ~ 
                boost_amount_stolen + 
               movement_time_supersonic_speed + 
               core_shooting_percentage + 
               color + boost_time_boost_50_75 + boost_time_boost_0_25 + 
                boost_time_full_boost +  
               core_shots, data = data)

vif(mfinal)

#need to find out what this stuff does

predf <- predict(mfinal, newdata = data)
RMSEfinal <- sqrt(mean((data$winner - predf)^2)) 
RMSEfinal

plot (mfinal$fitted.values, mfinal$residuals, xlab= "Fitted Values", ylab = "Residuals", main="Residuals vs. Fitted Values")
#makes sense, lines represent if the original data was 0(left line) or 1(right line)

plot (1:nrow(data), mfinal$residuals, xlab= "Index", ylab = "Residuals", main="Residuals vs. Index")
#this shows no relationship of index and residualsfor (i in 1:n){


rounded_predictions <- round(predf , digits=0)
min(rounded_predictions)
max(rounded_predictions)

rounded_predictions <- replace(rounded_predictions, rounded_predictions == -1, 0)
rounded_predictions <- replace(rounded_predictions, rounded_predictions == 2, 1)

min(rounded_predictions)
max(rounded_predictions)

compare <- (rounded_predictions == data$winner)
sum(compare)

sum(compare) / length(compare)

