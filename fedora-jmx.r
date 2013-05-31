library(ggplot2);
library(gridExtra);
library(tcltk);
library(RColorBrewer);
library(plyr);

options <- commandArgs(trailingOnly = TRUE);
path <- tk_choose.dir(default = getwd(), caption = "Select data directory")
if(interactive()) {
  dir.path <- path;
} else {
  dir.path <- options[1];
}

files <- list.files(path=dir.path, pattern=".csv", all.files=F, full.names=T);

time.breaks<-c(1, 3.16, 10, 31.62, 100, 316.22, 1000, 3162.28, 10000, 31622.7, 100000);
time.labels<-c("1ms", "3.16ms", "10ms", "31.62ms", "100ms", "316.22ms", "1s", "3.1s", "10s", "31.62s", "100s");

size.breaks<-c(10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000);
size.labels<-c("10B", "100B", "1kB", "10kB", "100kB", "1MB", "10MB", "100MB", "1GB");

#crudNumber.breaks<-c(0, 100, 10000, 1000000, 100000000, 10000000000, 1000000000000, 100000000000000);
#crudNumber.labels<-c("0", "100", "10k", "1M", "100M", "10Bil", "1Tri", "100Tri");

crudNumber.breaks<-c(0, 3.16, 10, 31.62, 100, 316.22, 1000, 3162.28, 10000, 31622.7, 100000, 316227.7, 1000000, 3162277.6, 10000000);
crudNumber.labels<-c("0", "3", "10", "31", "100", "316", "1k", "3.16k", "10k", "31.6k", "0.1M", "0.3M", "1M", "3.16M", "10M");

yaxis.rates.breaks <- c(0.00001, 0.0001, 0.001, 0.01, 0.1)
yaxis.rates.labels <- c("10ns/B", "100ns/B", "1us/B", "10us/B", "100us/B")

colour.scale=c("#008500", "#00cc00", "#FF7C00", "#FDB462", "#EB3A1E", "#FFAA00", "#377EB8", "#87B5DC", "#BEBADA", "#382F85", "#999999", "#984EA3", "#F781BF", "#A65628")

data.defined <- FALSE;

#Get the different thread counts;
count <- 0;
for (file in files) {
  file.parts<-strsplit(file, "-");
  thread.count<-sub('threads.csv', '', file.parts[[1]][5]);
  if (count == 0) {
    thread.counts <- c(thread.count) ;
  } else {
    thread.counts <- c(thread.counts, thread.count) ;
  }  
  count <- count + 1;
}
thread.counts <- unique(thread.counts);
thread.counts <- as.numeric(thread.counts);
print(thread.counts)

#get the files for each thread count
count <- 0
for (thread.count in thread.counts) {
  thread.files <- list.files(path=dir.path, pattern=sprintf("%sthreads.csv",thread.count), all.files=F, full.names=T);
  for (file in thread.files) {
    print (file);
    print (thread.count);
    add.create<-FALSE;

    # Pull out parts from the file name
    file.parts<-strsplit(file, "-");
    label<-file.parts[[1]][2];
    mean<-as.numeric(sub('mean', '', file.parts[[1]][3]));
    stddev<-sub('stddev', '', file.parts[[1]][4]);
    title <- tail(strsplit(file, "/")[[1]], 1);
    bin.width<-as.numeric(stddev) * 6/50;

    # Read in the csv file
    data <- read.csv(file);

    #Converting old style jmx label to the new style
    data[['label']] <- sub("Fedora Read Binary Resource Request", "Read Binary Resource", data[['label']]);
    data[['label']] <- sub("Fedora Create Binary Resource Request", "Create Binary Resource", data[['label']]);

    #data[['operation']] <- data[['label']]

    # Adding the thread count as a column to the data
    threadCount <- c('threadCount', rep(thread.count, nrow(data)-1));
    data$threadCount <- threadCount;

    # Adding the file size as a column to the data
    fileSize <- c('fileSize', rep(mean, nrow(data)-1));
    data$fileSize <- fileSize;

    #Cleaning threadname column
    data[['threadName']] <- sub("Threadgroup 1-", "", data[['threadName']]);
  
    count <- count + 1;
    if (count == 1) {
      data.all <- rbind(data);
    } else {
      data.all <- rbind(data.all, data);
    }

    # Set bytes and elapsed as numeric so log scales in plotting wouldn't fail over
    data$bytes <- as.numeric(data$bytes);
    data$elapsed <- as.numeric(data$elapsed);
  
    # Filter data - interested in read and create binary resource
    binReadData <- data[data[,'label'] == "Read Binary Resource",];
    binCreateData <- data[data[,'label'] == "Create Binary Resource",];

    # Modify the lable for binary data to include thread count
    binReadData[['label']] <- sprintf("%s - %s threads", binReadData[['label']], thread.count );
    binCreateData[['label']] <- sprintf("%s - %s threads", binCreateData[['label']], thread.count );

    # Match read bytes sizes to create, rather than use the response size in create
    if ( length(binReadData[['bytes']]) == length(binCreateData[['bytes']]) ) {
      binCreateData[['bytes']] <- binReadData[['bytes']];
      add.create<-TRUE;
    }

    # Bind the create data, so we can plot them
    if (length(binCreateData) > 0 & add.create == TRUE) {
      if (data.defined == TRUE) { 
        data.bin<-rbind(data.bin,binCreateData);
      } else {
        data.bin<-rbind(binCreateData);
        data.defined <- TRUE;
      }
    }

    # Bind the read data, so we can plot them
    if (length(binReadData) > 0 ) {
      if (data.defined == TRUE) { 
        data.bin<-rbind(data.bin,binReadData);
      } else {
        data.bin<-rbind(binReadData);
        data.defined <- TRUE;
      }	
    }

  }
}

# Transforming the data
data.all$fileSize <- as.numeric(data.all$fileSize);
data.all$threadCount <- as.numeric(data.all$threadCount);

data.all <- transform(data.all, label = factor(label, levels=c("Delete Object", "Create Object", "Read Object", "Create Datastream", "Update Datastream", "Read Datastream"), labels=c("Delete object", "Create object", "Read object", "Create data", "Update data", "Read data")))

data.all <- transform(data.all, responseCode = factor(responseCode))

# Creating a bar chart of response codes
#p <- ggplot(data=data.all, aes(x=label, fill=responseCode)) + geom_bar() + facet_grid(threadCount ~ ., scales="free_y") + scale_y_log10(breaks=crudNumber.breaks, #labels=crudNumber.labels, name="Request response count (log scale)") + scale_fill_manual(values = colour.scale);

p <- ggplot(data=data.all, aes(x=label, fill=responseCode)) + geom_bar(position="dodge") + facet_grid(threadCount ~ ., scales="free_y") + scale_y_log10() + scale_y_log10(breaks=crudNumber.breaks, labels=crudNumber.labels, name="Request response count (log scale)") + scale_fill_manual(values = colour.scale);

p + opts(title = "Status of request response, arranged by number of concurrent calls (thread count)", axis.text.x=theme_text(angle=0)) + labs(x="Operation");

ggsave( filename="StatusOfResponse.png", height=14.4, width=14.4);

# Creating a box plot of Number of concurrent calls by Jmeter (thread count) vs time taken (grouped for each response)
p <- ggplot(data=data.all, aes(factor(as.character(data.all$threadCount)), data.all$elapsed, fill=data.all$label)) + geom_boxplot() + 
scale_y_log10(breaks=time.breaks, labels=time.labels, name="Elapsed time (ms)") +
xlim(as.character(sort(thread.counts))) + xlab("Threads");

p + labs(x="Number of concurrent calls by Jmeter - thread count", y="Elapsed time (ms)") + scale_fill_discrete(name="Opearion") + 
opts(title = "Number of concurrent calls by Jmeter (thread count) vs Time taken (grouped for each response)", legend.position ="right");
ggsave( filename="ThreadCountVsElapsedTimebyOperation.png", height=7.2, width=14.4);

# Creating a box plot of Number of concurrent calls by Jmeter (thread count) vs time taken
elapsed.median <- ddply(data.all, .(threadCount), summarise, val = median(elapsed))
elapsed.mean <- ddply(data.all, .(threadCount), summarise, val = mean(elapsed))
elapsed.min <- ddply(data.all, .(threadCount), summarise, val = min(elapsed))
elapsed.max <- ddply(data.all, .(threadCount), summarise, val = max(elapsed))

p <- ggplot(data=data.all, aes(factor(as.character(data.all$threadCount)), data.all$elapsed)) + geom_boxplot() + 
geom_text(data = elapsed.median, aes(x = as.character(threadCount), y = val, label = sprintf("%g ms", val)), size = 3, vjust = -0.25) +
geom_text(data = elapsed.min, aes(x = as.character(threadCount), y = val, label = sprintf("%g ms", val)), size = 3, hjust = -1.0, vjust=-0.4) +
geom_text(data = elapsed.max, aes(x = as.character(threadCount), y = val, label = sprintf("%g ms", val)), size = 3, vjust = -0.7) +
scale_y_log10(breaks=time.breaks, labels=time.labels, name="Elapsed time (ms)") + xlab("Threads") + 
xlim(as.character(sort(thread.counts))) + xlab("Threads");

p + labs(x="Number of concurrent calls by Jmeter - thread count", y="Elapsed time (ms)") +
opts(title = "Number of concurrent calls by Jmeter (thread count) vs Time taken", legend.position ="right");

ggsave( filename="ThreadCountVsElapsedTime.png", height=7.2, width=14.4);

# Write the summary data
out<-capture.output(summary(data.bin))
cat(out,file="summary-combined.txt",sep="\n",append=TRUE)

