library(ggplot2)
library(cowplot)
library(R.matlab)
library(MASS)
library(dplyr)
library(reshape2)


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


#Transform the range of global and local symmetry from 0.5-1 to 0-1
dataset$GlobalSymm<- (dataset$GlobalSymm - min(dataset$GlobalSymm))/(max(dataset$GlobalSymm)-min(dataset$GlobalSymm)) 
dataset$LocalSymm<- (dataset$LocalSymm - min(dataset$LocalSymm))/(max(dataset$LocalSymm)-min(dataset$LocalSymm))


#Now add factors for variables that are factors
dataset<- na.omit(dataset)
dataset$SubjectNum <- as.factor(dataset$SubjectNum)
dataset$TrueSymmOri <- as.factor(dataset$TrueSymmOri)
dataset$DetectedSymm <- as.factor(dataset$DetectedSymm) 
dataset$Score <- as.ordered(dataset$Score)

#Exclude the figures with no global symmetry which introduces noise
excludelocal<- dataset$DetectedSymm
excludelocal[dataset$GlobalSymm == 0] <- FALSE;
dataset<-cbind(dataset,excludelocal)


############################################################################
## Logistic regression

logistic <- glm(DetectedSymm ~ GlobalSymm + LocalSymm + TrueSymmOri, data=dataset, family="binomial")
summary(logistic)

#Model only taking into account Global Symmetry as independent variable
simple_logistic <- glm(excludelocal ~ GlobalSymm, data=dataset, family="binomial")
summary(simple_logistic)

#Predict maximum likelihood probabilities
GlobalSymm_range <- seq(from=min(dataset$GlobalSymm), to=max(dataset$GlobalSymm), by=.01)
GlobalSymm_slope <- simple_logistic$coefficients[2] #b1 term of logistic regression formula
b0 <- simple_logistic$coefficients[1] #Intercept term
logits<- b0 + GlobalSymm_slope* GlobalSymm_range 
probs <- exp(logits)/(1+exp(logits)) #Maximum likelihood probabilities

#Compute the experimental probabilities as the mean detection for each percentage of
#global symmetric points
means_tot=dataset %>%
  group_by(GlobalSymm) %>%
  summarize(
    means_tot = mean(as.logical(DetectedSymm))
  )

#Store the mean detection of each subject for every value of global symmetry
#Used for calculating the SD for error bars
means_subjects=dataset %>%
  group_by(SubjectNum,GlobalSymm) %>%
  summarize(
    means_subjects = mean(as.logical(DetectedSymm))
  )


#Calculate the sd for every subject on each value of global symmetry
sd_tot= rep(0, 10)
for (i in 1:10) {
  for (a in 1:length(means_subjects$GlobalSymm)){
  if (means_tot$GlobalSymm[i] == means_subjects$GlobalSymm[a]) {
    sd_tot[i] <- sd_tot[i] + (means_tot$means_tot[i] - means_subjects$means_subjects[a])**2 #Sum of Squares
    }
  }
  sd_tot[i]= sqrt(sd_tot[i]/(length(means_subjects$GlobalSymm)-1)) #SD formula
  
  }

#Plot of the probability of detection vs global symmetry
ggplot() +
  geom_line(aes(x=GlobalSymm_range, y=probs))+ #Maximum likelihood fit
  geom_point(aes(x=means_tot$GlobalSymm, y= means_tot$means_tot), size=2) + #Experimental data
  geom_errorbar(aes(x=means_tot$GlobalSymm, y= means_tot$means_tot, ymin=means_tot$means_tot-sd_tot, ymax=means_tot$means_tot+sd_tot), width=.002,
                position=position_dodge(.9)) + #Error bars for experimental data
  xlab("% Global Symmetry") +
  ylab("Probability of detecting the axis of symmetry")

