############################################################################################################################
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
############################################################################################################################

############################################################################################################################
# 01) Merges the training and the test sets to create one data set.
############################################################################################################################
# Rationale:
# - this is simply the concatenation of 2 files
############################################################################################################################

# Test

y_test        <- read.table("test/y_test.txt", colClasses = "character")
X_test        <- read.table("test/X_test.txt", colClasses = "character")
subject_test  <- read.table("test/subject_test.txt", colClasses = "character")

# Training

y_train        <- read.table("train/y_train.txt", colClasses = "character")
X_train        <- read.table("train/X_train.txt", colClasses = "character")
subject_train  <- read.table("train/subject_train.txt", colClasses = "character")

# Merged sets

y_merged       <- rbind(y_train,y_test)
X_merged       <- rbind(X_train,X_test)
subject_merged <- rbind(subject_train,subject_test)

# Write merged sets

install.packages("gdata") # required for write.fwf
library(gdata)

write.table(y_merged,file="01_y_merged.txt",quote=FALSE,row.names=FALSE,col.names=FALSE)
write.fwf(X_merged,file="01_X_merged.txt",width=15,quote=FALSE,rownames=FALSE,colnames=FALSE,justify="right")
write.table(subject_merged,file="01_subject_merged.txt",quote=FALSE,row.names=FALSE,col.names=FALSE)


############################################################################################################################
# 02) Extracts only the measurements on the mean and standard deviation for each measurement. 
############################################################################################################################
# The purpose of of this section is to substract a subset of columns
# Based on the requirements, it is to substract ONLY the columns with means and STD
# The name of the columns is defined in the file features.txt, which contains the names of each of the columns
# Although not mentioned explictely, it is assumed that feature # 1 is the name of column # 1, and so on .... 
############################################################################################################################
#
# How to do this ?
# First, a fact: If you run colnames(), the name of the columns will be V1, V2, ..., V561 (uppercase V)
# Second, what is the simplest way to get the 'good columns' (as opposed to 561) ?
# I would suggest to use sqldf, which is part of the package "sqldf"
# It provides the ability to manipulate frames ... using SQL !!!
# After that, to subselect columns ... the only thing required is to put them in the select
############################################################################################################################
install.packages("sqldf")
library(sqldf)
############################################################################################################################
# for simplicity purpose, I will use a subset of the columns, as opposed to all the mean / std columns
############################################################################################################################
# The resulting frame will still keep the good name for the columns, eventhough they are now less
############################################################################################################################
# IMPORTANT, the ONLY place where the original columns and the columns are bound is in the code, UNLESS Headers are enabled
############################################################################################################################

X_merged_subset_features <- sqldf("select V1,V2,V3,V4,V5,V6,V41,V42,V43,V44,V45,V46 from X_merged")
write.fwf(X_merged_subset_features,file="02_X_merged_subset_features.txt",width=15,quote=FALSE,rownames=FALSE,colnames=TRUE,justify="right")

############################################################################################################################
# 03) Uses descriptive activity names to name the activities in the data set
############################################################################################################################
# It is time to start getting 'pretty' labels inside the tables
# The first step is to get the activity labels
# We will load both activity labels and teatures, and will put them in lists
############################################################################################################################

activity_labels           <- read.table("activity_labels.txt", colClasses = "character")
colnames(activity_labels) <- c("ALabelID","ALabel")

features                  <- read.table("features.txt", colClasses = "character")
colnames(features)        <- c("FLabelID","FLabel")

############################################################################################################################
# Next, we need to 'bind' the activity labels with the observations
# to use this, we need to do a couple of things: 'cbind' the 2 columns, and a look-up to change the id to the string
############################################################################################################################

tmp              <- cbind(y_merged$V1,X_merged_subset_features)
colnames(tmp)[1] <- "ActivityLabelID" # need to rename column ; sql parser does not like special characters !!!!!!!!!!!!!!!!
tmp2             <- sqldf("select activity_labels.ALabel, tmp.* from tmp,activity_labels where ALabelID = ActivityLabelID")

# got my (03) table, and will flush it into a file

write.fwf(tmp2,file="03_X_merged_subset_features_with_activity_labels.txt",width=18,quote=FALSE,rownames=FALSE,colnames=TRUE,justify="right")

############################################################################################################################
# 04) Appropriately labels the data set with descriptive variable names. 
############################################################################################################################
# Now it is time to label the metrics (the columns)
# And this is a challenge ; if we could like to do this automatically, we need to parse the names, do the look-ups, etc
# one complication is that the names are a mess, and contain tons of 'special characters'
# Due to the fact that the column ORIGINAL names were kept, we can simply 'index' the numbers to the proper names in the
# list of features
############################################################################################################################
# from the header of file (03), we get V1 V2 V3 V4 V5 V6 V41 V42 V43 V44 V45 V46
# these numbers represent the 'index' or lookup-id to the table features
# To make it simple, I will 'hardcode' the new column names, as opposed to use regex to eliminate the special characters
# Also, we will use the previously created tmp2 data.frame
############################################################################################################################

colnames(tmp2)[3]   <- "tBodyAccMeanX"     # V1
colnames(tmp2)[4]   <- "tBodyAccMeanY"     # V2                        
colnames(tmp2)[5]   <- "tBodyAccMeanZ"     # V3

colnames(tmp2)[6]   <- "tBodyAccSTDX"      # V4
colnames(tmp2)[7]   <- "tBodyAccSTDY"      # V5
colnames(tmp2)[8]   <- "tBodyAccSTDZ"      # V6

colnames(tmp2)[9]   <- "tGravityAccMeanX"  # V41
colnames(tmp2)[10]  <- "tGravityAccMeanY"  # V42
colnames(tmp2)[11]  <- "tGravityAccMeanZ"  # V43

colnames(tmp2)[12]  <- "tGravityAccSTDX"   # V44
colnames(tmp2)[13]  <- "tGravityAccSTDY"   # V45
colnames(tmp2)[14]  <- "tGravityAccSTDZ"   # V46

# got my (04) table, and will flush it into a file

write.fwf(tmp2,file="04_X_merged_subset_features_with_activity_labels.txt",width=18,quote=FALSE,rownames=FALSE,colnames=TRUE,justify="right")

############################################################################################################################
# 05) Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
############################################################################################################################
# Now, for the last table / file.
# We need now to pull subject (in the subject file), and aggregate metrics
# We can still use tmp2
############################################################################################################################

tmp3              <- cbind(subject_merged,tmp2)
colnames(tmp3)[1] <- "Subject"

############################################################################################################################
# now tmp3 contains my table 'ready to go'
# need only to 'group by' ... in an elegant manner ...
############################################################################################################################
# here is where I found an issue !!!!!!
# first, all my metrics are strings !!!
# quick solution .... drop first 3 columns, convert everything to number, calculate the averages, cbind ... and done 
############################################################################################################################

tmp4 <- subset(tmp3,select=-c(1:3)) # remove the first 3 columns
tmp5 <- data.matrix(tmp4)           # convert the data frame to a matrix (in order to change its context is numbers)
tmp6 <- cbind(tmp3[c(1,2,3)],tmp5)

tmp7 <- sqldf("select Subject,ALabel, 
              avg(tBodyAccMeanX)     'AVGtBodyAccMeanX',
              avg(tBodyAccMeanY)     'AVGtBodyAccMeanY',
              avg(tBodyAccMeanZ)     'AVGtBodyAccMeanZ',
              avg(tBodyAccSTDX)      'AVGtBodyAccSTDX',
              avg(tBodyAccSTDY)      'AVGtBodyAccSTDY',
              avg(tBodyAccSTDZ)      'AVGtBodyAccSTDZ',
              avg(tGravityAccMeanX)  'AVGtGravityAccMeanX',
              avg(tGravityAccMeanY)  'AVGtGravityAccMeanY',
              avg(tGravityAccMeanZ)  'AVGtGravityAccMeanZ',
              avg(tGravityAccSTDX)   'AVGtGravityAccSTDX',
              avg(tGravityAccSTDY)   'AVGtGravityAccSTDY',
              avg(tGravityAccSTDZ)   'AVGtGravityAccSTDZ'
          from tmp6
          group by Subject, ALabel")

# got my (05) table, and will flush it into a file

write.fwf(tmp7,file="05_tiny_tidy_output_file.txt",width=18,quote=FALSE,rownames=FALSE,colnames=TRUE,justify="right")

