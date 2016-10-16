# This script gets data that has already been downloaded, merges the multiple
# files together into one dataset, keeps only the columns with mean and 
# standard deviation, and then finds the mean for those columns among Subject
# and activity.

library(dplyr)

#Get test data
X_test<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/test/X_test.txt")
Y_test<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/test/subject_test.txt")

#Get train data
X_train<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/train/X_train.txt")
Y_train<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/train/subject_train.txt")

# Get & Set vairable names
features<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/features.txt")
names(X_test)<-features[,2]
names(X_train)<-features[,2]

# Set the names of the rest of the data
names(Y_test)<-"Y"
names(subject_test)<-"subject"
names(Y_train)<-"Y"
names(subject_train)<-"subject"

# Combine all data into two data frames (for test & train)
testdata<-data.frame(X_test,Y_test,subject_test)
traindata<-data.frame(X_train,Y_train,subject_train)

#Add columns to testdata and traindata to specify which dataset it is
testdata<-mutate(testdata,dataset="test")
traindata<-mutate(traindata,dataset="train")

#Merge the testdata and traindata sets into one data set
fulldataset<-rbind(testdata,traindata)

# Extracts only the measurements on the mean and standard deviation for
# each measurement. Identify which columns contain those names
namesofcolumns<-names(fulldataset)
columnstokeep<-grep("[Mm]ean|[Ss]td",namesofcolumns)

# Keep only the columns with mean or standard deviation
datasetMSTD<-fulldataset[,columnstokeep]

# Keep the three columns with y, subject, and test/train data
datasetMSTD<-data.frame(datasetMSTD,fulldataset$Y,fulldataset$subject,
                        fulldataset$dataset)

# Find the variable names and rename the y, subject, and test/train column
tempnames<-names(datasetMSTD)
tempnames[87:89]<-c("ActivityNum","Subject","TestORTrain")
names(datasetMSTD)<-tempnames

# Use descriptive activity names to name the activities in the data set. Get
# Get the labels from activity_labels file
activitylabels<-read.table("/Users/JessicaBohning/Documents/Data Science/Course 3- Getting and Cleaning Data/Week 4/UCI HAR Dataset/activity_labels.txt")
names(activitylabels)<- c("ActivityNum","ActivityWords")

# Use merge to merge the dataframe and the activity labels
datasetMSTD<-merge(datasetMSTD,activitylabels,by="ActivityNum")

#Note the ActivityNum moved to the first column and ActivityWords is the last

# Use datasetMSTD to create a second, independent tidy data set with the average
# of each variable for each activity and each subject. Create a dataset 
# (subject_activity) of Subject and Activity combined into on column with a "_" 
# separating them.

subject_activity<-data.frame(paste(datasetMSTD$Subject,datasetMSTD$ActivityWords,
                                   sep="_"))
names(subject_activity)<-"SubjectANDActivity"

# Add new column to original data set
datasetMSTDtemp<-data.frame(datasetMSTD,subject_activity)

# Find the mean for each grouping of Subject & Activity (for a total of 180 
# rows)
tidyMSTD<-aggregate(datasetMSTDtemp,by=list(datasetMSTDtemp$SubjectANDActivity),
                    mean)

# Because subject_activity is a column with two variables in it, it isn't tidy
# Split the data back up into two separate columns
ActivityWords<-gsub("[[:digit:]]+_","",tidyMSTD$Group.1)
Subject<-tidyMSTD$Subject
tidyMSTDFINAL<-data.frame(Subject,ActivityWords,tidyMSTD)

# Remove the unneccessary columns from tidyMSTDFINAL to create tidy data
tidyMSTDFINAL<-tidyMSTDFINAL[,c(1:2,5:90)]

# Export Data
write.table(tidyMSTDFINAL,row.name=FALSE)







