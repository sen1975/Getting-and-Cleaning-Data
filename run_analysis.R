packages <- c("reshape2")
 sapply(packages, require, character.only=TRUE, quietly=TRUE)
# URL of the .Zip file to be loaded
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
path<-getwd()
  download.file(url, file.path(path, "dataFiles.zip"))

# unzip the downloaded file
 unzip(zipfile = "dataFiles.zip")

 #activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activitiyNamee"))

 # read activity and features text file
   activityLabels <- data.table::fread(file.path(path,"UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))

  features <- data.table::fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
 # to get the position of mean and SD in the file
   featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
  measurements <- features[featuresWanted, featureNames]
  measurements <- gsub('[()]', '', measurements)

# Loading the train dataset and ...

     train <- data.table::fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
#data.table::setnames(train, colnames(train), measurements)
 trainActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
                         
 trainSubjects <- data.table::fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
                       
 train <- cbind(trainSubjects, trainActivities, train)

# Load test datasets

   test <- data.table::fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]

  testActivities <- data.table::fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt") , col.names = c("Activity"))
                       
 testSubjects <- data.table::fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
                      
  test <- cbind(testSubjects, testActivities, test)

# merge datasets
 combined <- rbind(train, test)

# Convert classLabels to activityName.More explicit. 
 
  combined[["Activity"]] <- factor(combined[, Activity]
                          , levels = activityLabels[["classLabels"]]
                           , labels = activityLabels[["activityName"]])

  combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
  combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
  combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

 data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
