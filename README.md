The purpose of this README file is to describe the requirements & approach of the program run_analysis.R

########################################################################################################################
#
# Requirements:
#
# You should create one R script called run_analysis.R that does the following. 
# 01) Merges the training and the test sets to create one data set.
# 02) Extracts only the measurements on the mean and standard deviation for each measurement. 
# 03) Uses descriptive activity names to name the activities in the data set
# 04) Appropriately labels the data set with descriptive variable names. 
# 05) Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
# 
########################################################################################################################

Implementation:
- for each step (1 to 5) the program will create and spool (to files) intermediate result sets
- the last file will be the file requested (as 'tiny tidy')

########################################################################################################################
Task # 1: Objective ->>> Merges the training and the test sets to create one data set.
########################################################################################################################
Design:
- each category (test and training) contains 3 datasets
- the output is to obtain only one set (of 3 files) concatenating in the correct order the correct files
- R Code for merge
  - y_merged       <- rbind(y_train,y_test)
  - X_merged       <- rbind(X_train,X_test)
  - subject_merged <- rbind(subject_train,subject_test)
Implementation note:
- to write fixed width files, the function write.fwf (from gdata package) was used
Output files:
- 01_y_merged.txt 
- 01_X_merged.txt 
- 01_subject_merged.txt 

########################################################################################################################


########################################################################################################################
Task # 2: Objective ->>> Extracts only the measurements on the mean and standard deviation for each measurement. 
########################################################################################################################
Design:
- select a subset of the 561 features (columns that have std and avg)
- the name of the columns is defined in the file features.txt, which contains the names of each of the columns
Implementation:
- Note: If you run colnames(), the name of the columns will be V1, V2, ..., V561 (uppercase V)
- sqldf was used as part of the implementation
- Columns used for this exercise are "select V1,V2,V3,V4,V5,V6,V41,V42,V43,V44,V45,V46 from X_merged"
Output file:
- 02_X_merged_subset_features.txt 
 
#######################################################################################################################

########################################################################################################################
Task # 3: Objective ->>> Uses descriptive activity names to name the activities in the data set
########################################################################################################################
Design:
- load 'helper' files, with labels for activities and features (metrics)
- rename columns (to improve readibility of code + SQL)
- add column with activity labels
Implementation:
- use sqldf to join and look-up for activity labels
Output file:
- 03_X_merged_subset_features_with_activity_labels.txt

########################################################################################################################


########################################################################################################################
Task # 4 Objective ->>> Uses descriptive activity names to name the activities in the data set
########################################################################################################################
Design:
- rename columns that contain features, so the name is acceptable by both R and sqldf
Implementation:
- due to time constraints, this section was 'hardcoded'
- based on SQL that selected subset of columns
- Names were modified to remove special characters
Output file:
- 04_X_merged_subset_features_with_activity_labels.txt

########################################################################################################################

########################################################################################################################
Task # 5 Objective ->>> Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
########################################################################################################################
Design:
- this is the final result set
- requires to avg metrics, by subject, by activity
Implementation:
- when manipulation was required for the calculation of averages, I realized the metrics where 'chars'
- had to manipulate the data in order to change types (from char to double)
- using sqldf, the group by were done
Output file:
- 05_tiny_tidy_output_file.txt

########################################################################################################################

