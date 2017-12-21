set.seed(12345)
loan_data <- read.csv("/Users/niniliu/Documents/EECS6893/Project/EECS 6893 Project/integrated_data.csv", header=TRUE, sep=",")

#set up categorical variables
loan_data$FIRST_TIME_HOME_BUYER_FLAG.f <- factor(loan_data$FIRST_TIME_HOME_BUYER_FLAG)
loan_data$OCCUPANCY_STATUS.f <- factor(loan_data$OCCUPANCY_STATUS)
loan_data$CHANNEL.f <- factor(loan_data$CHANNEL)
loan_data$LOAN_PURPOSE.f <- factor(loan_data$LOAN_PURPOSE)
loan_data$SUPER_CONFORMING_FLAG.f <- factor(loan_data$SUPER_CONFORMING_FLAG)

#interpret HPI index
#loan_data['HPI_var'] <- (loan_data$HPI_MAX-loan_data$HPI_MIN)/loan_data$HPI_ORIG
loan_data['HPI_inc'] <- loan_data$HPI_MAX/loan_data$HPI_ORIG
loan_data['HPI_dec'] <- loan_data$HPI_ORIG/loan_data$HPI_MIN

#normalize variables
loan_select <- subset(loan_data,select=c(2,5,6,9:11,16,18,28,29))
scale_loan <- scale(loan_select)
loan_model <- cbind(scale_loan,subset(loan_data,select=c(23:27)),loan_data$IND_DEFAULT_2)
colnames(loan_model)[16] <- "DEFAULT_IND" #rename column

#PCA using Covariance matrix
pcCov <- prcomp(loan_model[,1:12])
print(pcCov)
biplot(pcCov)
screeplot(pcCov)

#fit glm model
sample_size <- floor(0.8*nrow(loan_data))
train_index <- sample(seq_len(nrow(loan_data)), size = sample_size)
train <- loan_model[train_index,]
test <- loan_model[-train_index,]
glm_model <- glm(DEFAULT_IND ~.,family=binomial(link='logit'),data=train)
print(summary(glm_model))
#test prediction accuracy
fitted.results <- predict(glm_model,newdata=test[,1:ncol(test)-1],type='response')
#fitted.results <- ifelse(fitted.results > 0.5,1,0)
misClasificError <- mean(fitted.results != test$DEFAULT_IND)
print(paste('Accuracy',1-misClasificError)) #no default is identified

#glmnet model
library(glmnet)
x = model.matrix(DEFAULT_IND ~ . -1, data = loan_model)
y = loan_model$DEFAULT_IND
glmnet.tr <- glmnet(x[train_index,],y[train_index],family="binomial",alpha=0)
plot(glmnet.tr, xvar = "lambda", label = TRUE)
pred_net <- predict(glmnet.tr, x[-train_index, ])
#pred <- ifelse(pred > 0.5,1,0)
rmse = sqrt(apply((y[-train_index] - pred_net)^2, 2, mean))
plot(log(glmnet.tr$lambda), rmse, type = "b", xlab = "Log(lambda)")
lam.best = glmnet.tr$lambda[order(rmse)[1]]
coef(glmnet.tr, s = lam.best)
pred.best <- predict(glmnet.tr,x[-train_index,],s = lam.best,type='response')
#print(pred.best)
#pred.best <- ifelse(pred.best > 0.05,1,0)

#cross-validation
glmnet.cv <- cv.glmnet(x[train_index,],y[train_index],family="binomial",type.measure="auc")
plot(glmnet.cv)
pred.cv <- predict(glmnet.cv, x[-train_index, ])
coef(glmnet.cv,glmnet.cv$lambda.min)
#rmsecv = sqrt(apply((y[-train_index] - pred.cv)^2, 2, mean))
#plot(log(glmnet.cv$lambda), rmsecv, type = "b", xlab = "Log(lambda)")
pred.cvbest <- predict(glmnet.cv,x[-train_index,],s = "lambda.min",type="response")

#cross validation type "response"
glmnet.cv2 <- cv.glmnet(x[train_index,],y[train_index],family="binomial")
pred.cv2best <- predict(glmnet.cv2,x[-train_index,],s = "lambda.min")

#ROC Curve of glm model
library(ROCR)
pred <- prediction(fitted.results,test$DEFAULT_IND)
perf <- performance(pred,"tpr","fpr")
par(mar=c(5,5,2,2),xaxs = "i",yaxs = "i",cex.axis=1.3,cex.lab=1.4)
plot(perf,col="red",lty=1,lwd=2,main="ROC Curve")
abline(0,1)
auc <- performance(pred,"auc")
auc <- unlist(slot(auc, "y.values"))
print(auc)

#ROC Curve of glmnet
pred2 <- prediction(pred.best,test$DEFAULT_IND)
perf2 <- performance(pred2,"tpr","fpr")
plot(perf2,col="red",lty=1,lwd=2,main="ROC Curve of GLMNET Models")
abline(0,1)
auc2 <- performance(pred2,"auc")
auc2 <- unlist(slot(auc2, "y.values"))
print(auc2)

#cross validation
pred3 <- prediction(pred.cvbest,test$DEFAULT_IND)
perf3 <- performance(pred3,"tpr","fpr")
lines(perf3@x.values[[1]],perf3@y.values[[1]],col="green",lty=1,lwd=2)
auc3 <- performance(pred3,"auc")
auc3 <- unlist(slot(auc3, "y.values"))
print(auc3)

legend(0.55,0.15, legend=c("General GLMNET Model", "Cross Validation GLMNET Model"),col=c("red", "green"), lty=1:1)
output <- cbind(pred3@predictions[[1]],test$DEFAULT_IND)
write.csv(output, file = "glmnet.csv",row.names = FALSE)
