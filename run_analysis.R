# The following script performs the following functions as outlined by the Coursera "Getting and 
# Cleaning Data" Course Project requirements:

#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# Before beginning, load packages needed to carry out script:
library(data.table)

#1a. Read text files from both training and testing file into R. 
setwd("C:/UCI HAR Dataset/train")
subject_train<-read.table("subject_train.txt")
x_train<-read.table("X_train.txt")
y_train<-read.table("y_train.txt")

setwd("C:/UCI HAR Dataset/test")
subject_test<-read.table("subject_test.txt")
x_test<-read.table("X_test.txt")
y_test<-read.table("y_test.txt")

#1b. Merge training files together using cbind. Each file in itself consists of 1 column with 7352 obs. 
# Merging the files by columns creates a record that includes the test subject ID (1-30), activity label (1-6), and 
# accelerometer results.Repeat this merge via cbind with the testing files. 
training<-cbind(subject_train,y_train,x_train)
testing<-cbind(subject_test, y_test, x_test)

# This completes almost all of Part 1. We will complete Part 1 (merging the files together) after we add in descriptive 
# variable names for each column.

#4a. Read in column headers from features.txt, then create a vector with all column names to assign to training and testing 
# datasets.Because we merged the results files so that the test subject ID is in Column 1, activity label in Column 2,
# and the experiment results in the proceeding 561 columns, we will concatenate column names for columns 1 and 2
# to the beginning of the feature.names vector that we create. We will then assign this vector of 563 column headers to
# both the training and testing datasets.
setwd("C:/UCI HAR Dataset")
features.names<-read.table("features.txt")

#4b. Reading in the feature names as a table creates a table with 2 columns, we will only pull from the column with
# the variable descriptions.
features<-features.names[,2]

#4c. R automatically converts the text in feature.names to factors; we will convert these names into characters so 
# we can read them as column headers.
features<-as.character(features)
all.cols<-c("SubjectID", "Activity", features)

#4d. Now we'll assign the column header vector to each of the training and testing datasets.
names(testing)<-all.cols
names(training)<-all.cols

#1c. We can use rbind to merge the training and testing datasets because all columns follow the same order as eachother.
merged.dat<-rbind(training,testing)

# This completes Part 1 and Part 4 of the assignment.

#3a. Before tackling Part 2, we'll create a new column that explains each of the activity labels (1-6), using the 
# activity_labels.txt file that's given to us.First, we'll read in the activity_labels.txt file.
act_labels<-read.table("activity_labels.txt")

# Next, we'll make a copy of merged.dat. We'll alter the labels in the copy, and leave merged.dat unchanged.
merged.dat2<-merged.dat

#3b. Identify the activity column that currently has 1-6's representing different activities. We'll
# then use a for loop to loop through each row in this column, replacing each number with its corresponding activity
# description. 
activities<-c("Activity")

for(old.lab in activities) {
  new.lab<-as.character(merged.dat2[,old.lab])  #Make a copy of the current variable. We will alter the copy.
  #Now use the replace() function to change all labels following activity_labels.txt.
  new.lab<-replace(x=new.lab,list=(new.lab=="1"),values='WALKING')
  new.lab<-replace(x=new.lab,list=(new.lab=="2"),values='WALKING_UPSTAIRS')
  new.lab<-replace(x=new.lab,list=(new.lab=="3"),values='WALKING_DOWNSTAIRS')
  new.lab<-replace(x=new.lab,list=(new.lab=="4"),values='SITTING')
  new.lab<-replace(x=new.lab,list=(new.lab=="5"),values='STANDING')
  new.lab<-replace(x=new.lab,list=(new.lab=="6"),values='LAYING')
  merged.dat2[,old.lab]<-factor(new.lab); #Replace the current variable in the data set with the altered copy.
}

# Quick check to make sure the loop worked:
table(merged.dat$Activity) #This is the original column with 1-6's.
table(merged.dat2$Activity) #This is the new column with descriptions replacing the 1-6's. 
# Identical table results indicate that the loop worked.

#3c. Next, we'll create a copy of merged.dat2 for column header cleanup.
merged.dat3<-merged.dat2

#Let's clean up the header names a little bit before we build our second tidy dataset.
tidy.cols<-sub("\\(\\)","",names(merged.dat2),) #gets rid of ()'s
tidy.cols<-gsub("-",".",tidy.cols,) #replaces -'s with .'s
tidy.cols<-sub(",","by",tidy.cols,) #replaces ,'s with the word "by"
names(merged.dat3)<-tidy.cols

# Relabeling is done. This completes Part 3.

#2a. Now let's begin building our second tidy dataset by extracting only measurements of the mean or standard 
# deviation of a measure.
mean.std<-grepl("mean|std",tidy.cols) #logical vector that indicates whether "std" or "mean" are in the column names
mean.std.dat<-subset(merged.dat3, select= c("SubjectID", "Activity", tidy.cols[mean.std=="TRUE"])) #subsets dataframe 
# to only measures that contain a mean or std measurement, in addition to SubjectID and activity

#Let's do a quick check for missing values in our extracted dataset.
any(is.na(mean.std.dat[,3:79])) #No missing values, so we can move on to calculating the averages of each of our measures

#This completes Part 2. Now we can move on to Part 5, the final step.

#5. We'll average each measure by activity, for each subject, using plyr operations.
mean.std.dt<-data.table(mean.std.dat) #converts our data frame to a data table so we can use plyr for summarizing
tidy.dat<-mean.std.dt[,lapply(.SD,mean), by= list(SubjectID=mean.std.dt$SubjectID, Activity=mean.std.dt$Activity)] 
# takes the mean of all measures, grouping by subjectID and activity
tidy.dat<-tidy.dat[order(tidy.dat$SubjectID),] #orders data table so that Subject ID is in ascending order

#5b. Our last step will rename the column headers for our newly averaged values, such that each column name indicates 
# an averaged value.
edit.cols<-names(tidy.dat)[3:81]
N<-length(edit.cols)

#The for loop takes each column header and adds "Avg." before the measurement description.
for(i in 1:N) { 
  new.col<-paste("Avg", edit.cols[i])
  new.col<-sub(" ",".",new.col)
  edit.cols[i]<-new.col
}

#5c. Let's apply this new vector of edited labels to the dataframe.
names(tidy.dat)<-c("SubjectID", "Activity", edit.cols)

#Part 5 is complete; tidy dataset is ready. 

tidy.dat.export<-write.table(tidy.dat,"TidyData.txt",sep="\t", row.names=FALSE)
