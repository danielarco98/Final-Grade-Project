library(ggplot2)
library(cowplot)
library(R.matlab)
library(MASS)
library(dplyr)
library(reshape2)
library("ggpubr")
library(nnet)
library(VGAM)
############################################################################
## Load the data

#IMPORTANT
#Before running the code set as working directory to source file location
dir <- dirname(getwd())

#Get the file list of all response matrices
file_list <- list.files(path=paste(c(dir,'/Stadistics/Results/'),  collapse = ''))

#initiate a blank data frame, each iteration of the loop will append the data from the given file to this variable
dataset <- data.frame()

#Build a dataset with all the responses
for (i in 1:length(file_list)){
   temp_data <- readMat(paste(c(dir,'/Stadistics/Results/',file_list[i]), collapse = ''))
   temp_data <- temp_data$respMat
   temp_data <- cbind(rep(i,40 ),temp_data)
   dataset <- rbind(dataset, temp_data) #for each iteration, bind the new data to the building dataset
}

#Store a boolean which indicates us if symmetry axis orientation has been perceived properly or not
dataset$V6 <- dataset$V5 == dataset$V6


#Assign a score of 0 to every image where the axis was not detected properly
realscore <- dataset$V4
realscore[dataset$V6==FALSE]<- 0
dataset$V4 <- realscore;


###########################################################################
## Reformat the data

#Add column names
colnames(dataset) <- c(
  "SubjectNum",
  "GlobalSymm",
  "LocalSymm",
  "Score", # 0 to 5. Categorical
  # 5 is perfect symmetry, 1 is not really symmetric
  #0 not symmetric
  
  "TrueSymmOri", 
  "DetectedSymm", 
  "Time"
)


#Normalize range of global and local symmetry from 0.5 and 1 to 0 and 1
dataset$GlobalSymm<- (dataset$GlobalSymm - min(dataset$GlobalSymm))/(max(dataset$GlobalSymm) - min(dataset$GlobalSymm)) 
dataset$LocalSymm<- (dataset$LocalSymm - min(dataset$LocalSymm))/(max(dataset$LocalSymm)-min(dataset$LocalSymm))

#Now add factors for variables that are factors
dataset$Score <- as.ordered(dataset$Score) #ordered factor
dataset<- na.omit(dataset)
dataset$SubjectNum <- as.factor(dataset$SubjectNum)
dataset$TrueSymmOri <- as.factor(dataset$TrueSymmOri)
dataset$DetectedSymm <- as.factor(dataset$DetectedSymm) 



################################################################################
#Test proportionality

#For choosing a model we have to test if the proportionality on odds is not violated on this data

#First we fit a model without ordinal information
cat("Multinomial logistic regression \n")
mod.multinom <-multinom(Score~GlobalSymm + LocalSymm + TrueSymmOri, data = dataset)
print(summary(mod.multinom, cor=F, Wald=T))
x1<-logLik(mod.multinom)
cat("Degrees of freedom Multinomial logistic regression \n")
print(df_of_multinom_model <- attributes(x1)$df)

#Then, the partial proportional odds model
cat("Proportional odds logistic regression\n")
mod.polr <- polr(Score~GlobalSymm + LocalSymm + TrueSymmOri, data=dataset)
print(summary(mod.polr))
x2<-logLik(mod.polr)
cat("Degrees of freedom Proportional Odds Logistic Regression \n")
print(df_of_polr_model <- attributes(x2)$df)

cat("Answering the question: Is proportional odds model assumption violated\n")
cat("P value for difference in AIC between POLR and Multinomial Logit model\n")

# abs since the values could be negative. That is negative difference of degrees of freedom would produce p=NaN
a= 1-pchisq(abs(mod.polr$deviance-mod.multinom$deviance),   abs(df_of_multinom_model-df_of_polr_model))
a

#As the p-value is almost 0, we can state that the residuals are statistically different
#So proportionality on odds can not be maintained


################################################################################
# CUMULATIVE LOGIT MODEL ASSUMED UNCONSTRAINED PARTIAL-PROPORTIONAL ODDS 

#For fitting the data, we choose an ordinal model but without the proportinality on oddas assumption
nonpropfit<-vglm(Score~ GlobalSymm, data = dataset, family = cumulative(parallel = F ~ GlobalSymm + LocalSymm))
summary(nonpropfit)

 #Create the predicted probabilities for each scoring in function of Global Symmetry
 newdat <- data.frame(
 GlobalSymm= seq(from = 0, to = 1, length.out = 1000))
 
 newdat <- cbind(newdat, predict(nonpropfit, newdat, type = "response"))
 lnewdat <- melt(newdat, id.vars = c("GlobalSymm"),
                 variable.name = "Score", value.name="Probability")
 
 #Plot the predicted probabilities
 predplot<-ggplot() +
   geom_line(data=lnewdat, aes(x = GlobalSymm, y = Probability, colour = Score))+
   theme(legend.position=c(1,1),
         legend.direction="horizontal",
         legend.justification=c(1, 0), 
         legend.key.width=unit(1, "lines"), 
         legend.key.height=unit(1, "lines"), 
         plot.margin = unit(c(5, 1, 0.5, 0.5), "lines"))+
 xlab("% of Global Symmetry Signal")+
    ylab("Probability")+ ylim(0,1)
 
 
 #Compare the predicted probabilities with the actual experimental histogram of Scores
 
 #Plot for score = 1
 hist1<- ggplot(dataset[dataset$Score==1,])+
   geom_histogram(aes(x= GlobalSymm*100,  y=..count../sum(..count..)),binwidth = 5)+
   geom_line(data=lnewdat[lnewdat$Score==1,], aes(x = GlobalSymm*100, y = Probability))+
   ggtitle("Distribution of probabilities of Score = 1")+
   xlab("% of Global Symmetry Signal")+
   ylab("Probability")+ ylim(0,1)
 
 #Plot for score = 2
 hist2<- ggplot(dataset[dataset$Score==2,])+
   geom_histogram(aes(x= GlobalSymm*100,  y=..count../sum(..count..)),binwidth = 5)+
   geom_line(data=lnewdat[lnewdat$Score==2,], aes(x = GlobalSymm*100, y = Probability))+
   ggtitle("Distribution of probabilities of Score = 2")+
   xlab("% of Global Symmetry Signal")+
   ylab("Probability")+ ylim(0,1)
 
 #Plot for score = 3
 hist3<- ggplot(dataset[dataset$Score==3,])+
   geom_histogram(aes(x= GlobalSymm*100,  y=..count../sum(..count..)),binwidth = 5)+
   geom_line(data=lnewdat[lnewdat$Score==3,], aes(x = GlobalSymm*100, y = Probability))+
   ggtitle("Distribution of probabilities of Score = 3")+
   xlab("% of Global Symmetry Signal")+
   ylab("Probability")+ ylim(0,1)
 
 #Plot for score = 4
 hist4 <- ggplot(dataset[dataset$Score==4,])+
   geom_histogram(aes(x= GlobalSymm*100,  y=..count../sum(..count..)),binwidth = 5)+
   geom_line(data=lnewdat[lnewdat$Score==4,], aes(x = GlobalSymm*100, y = Probability))+
   ggtitle("Distribution of probabilities of Score = 4")+
   xlab("% of Global Symmetry Signal")+
   ylab("Probability")+ ylim(0,1)
 
 #Plot for score = 5
 hist5 <- ggplot(dataset[dataset$Score==5,])+
   geom_histogram(aes(x= GlobalSymm*100,  y=..count../sum(..count..)),binwidth = 5)+
   geom_line(data=lnewdat[lnewdat$Score==5,], aes(x = GlobalSymm*100, y = Probability))+
   ggtitle("Distribution of probabilities of Score = 5")+
   xlab("% of Global Symmetry Signal")+
   ylab("Probability")+ ylim(0,1)
 
 #Merge all the plots on a single figure
 histcomboplot <- ggarrange(hist1, hist2,hist3,hist4,hist5,
                            labels = c("A", "B","C","D",'E'),
                            ncol = 2, nrow = 3)

 predplot
 histcomboplot
 