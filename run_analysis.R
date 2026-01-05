url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "dataset.zip"
if(!file.exists(zipfile)) download.file(url, zipfile, mode="wb")
if(!dir.exists("UCI HAR Dataset")) unzip(zipfile)

library(dplyr)

features <- read.table("UCI HAR Dataset/features.txt")
activities <- read.table("UCI HAR Dataset/activity_labels.txt",
                         col.names=c("ActivityID","Activity"))

load_data <- function(type) {
  x <- read.table(paste0("UCI HAR Dataset/",type,"/X_",type,".txt"))
  y <- read.table(paste0("UCI HAR Dataset/",type,"/y_",type,".txt"),
                  col.names="ActivityID")
  s <- read.table(paste0("UCI HAR Dataset/",type,"/subject_",type,".txt"),
                  col.names="Subject")
  colnames(x) <- features$V2
  cbind(s,y,x)
}

train <- load_data("train")
test  <- load_data("test")
data  <- rbind(train,test)

data <- data %>%
  select(Subject, ActivityID, contains("mean()"), contains("std()")) %>%
  merge(activities, by="ActivityID")

names(data) <- gsub("\\(\\)|-","",names(data))
names(data) <- gsub("^t","Time",names(data))
names(data) <- gsub("^f","Frequency",names(data))
names(data) <- gsub("Acc","Accelerometer",names(data))
names(data) <- gsub("Gyro","Gyroscope",names(data))
names(data) <- gsub("Mag","Magnitude",names(data))
names(data) <- gsub("BodyBody","Body",names(data))

tidy <- data %>%
  group_by(Subject, Activity) %>%
  summarise(across(everything(), mean))

write.table(tidy, "tidy_data.txt", row.names = FALSE)


