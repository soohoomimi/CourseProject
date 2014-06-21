# Run_analysis.R README 

## Preliminary notes and mentionings

Run_analysis.R takes data from UCI's "Human Activity Recognition Using Smartphones Data Set", and produces a tidy dataset for downstream analysis. More information about the source of the data can be found at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. 

The script performs the following tasks as outlined by the Coursera "Getting and Cleaning Data" Course Project requirements:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

It does so slightly out of order in order to minimize the number of merges required to produce the final output dataset. With that being said, the script is meant to be run in the sequence laid out in the script (from top to bottom). The steps have been numbered only to reflect which of the 5 tasks above the script is addressing.

## Script Assumptions

The script assumes that: 

* The data were obtained from and downloaded by clicking the .zip file linked on the Course Project website: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
* The data were unzipped onto the user's local drive.
* The unzipped files and the file structure have not been altered by the user.
* The home folder created by unzipping the files is set as the working directory. This is referred to as "C:/UCI HAR Dataset" in the script.
* The user has the data.table package installed. 

## Data files used 

The following data files are called by run_analysis.R:

* x_test.txt
* x_train.txt 
* y_test.txt
* y_train.txt
* subject_test.txt
* subject_train.txt
* features.txt
* activity_labels.txt

## General processing workflow

The script begins by reading in the training and test files (561 measurements in all), and binds these results with associated files containing information on subject ID's and the activity performed while the measurements were collected. The script does this for each of the training and test datasets in isolation. 

Before merging these wider training and test dataframes together, the script walks through replacing the generic "V1, V2, V3..." column names in dataframe with more descriptive variable names. It does so by reading in the variable descriptions from the "features.txt" file, creating a vector of new column names, then assigning them to each of the training and test dataframes. The script then merges the training and test files together using rbind (rbind was used in place of merge() because the column names are identical). 

Working off of the merged dataset, the script replaces the activity labels (provided in the data as 1-6's) with more fleshed out activity descriptions. It does this by reading in the "activity_labels.txt" file, which provides us with a key for the numeric activity labels in the dataset. The script runs a for loop that replaces each numeric label with the corresponding activity description. The script then includes a quick data verification step to ensure that the labels were properly replaced. 

Once we've confirmed that the activity descriptions were successfully inserted, the script continues by cleaning up the column names by removing special characters. Specifically, it uses the sub() and gsub() functions to get rid of the commas, dashes, and empty parentheses, replacing them with periods and backspaces. Because the merged dataset will be summarized in order to produce the final tidy dataset, this cleanup helps ensure that calculations will be able to run without issue. 

With cleaned up column names in tow, the script then subsets out a new dataframe that includes only the measurements that contain a mean or standard deviation. It does this by using the grepl() function, which indexes each column name including the strings "std" or "mean". Subsetting by this index produces a smaller dataset of 81 columns: 79 mean/standard deviation measures and our 2 grouping variables of subject ID and activity. 

This smaller dataset is then used to produce our final tidy dataset. The final commands in the script use plyr operations afforded by the data.table package to summarize the measures by our grouping variables. Specifically, the script uses lapply() and by= to take the mean of each of the 79 measurement variables, grouping them by subject ID and activity. The script runs through editing the column names to reflect that each column is an averaged value (e.g. an average of the average or standard deviation values given in the original dataset). 

The resulting tidy dataset includes 180 rows and 81 columns. Each row contains a subject ID, activity description, and corresponding averaged values for each measure. 

###Thanks for reading!
