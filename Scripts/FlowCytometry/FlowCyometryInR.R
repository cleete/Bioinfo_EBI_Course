#Load BiocManger first
install.packages('BiocManager')
library('BiocManager')
BiocManager::install('flowCore')  #install flowcore
library('flowCore')

#load exampledata
filenames <- list.files("~/course_dir/data_dir/Christopher_Hall/EBI_2024", pattern = ".fcs", full.names = TRUE)  #load only FCS files only and get the full name 

#load into flowframe(ff)
ff <- read.FCS(filenames[1], truncate_max_range = F)  #argument for truncate_max_range: because in Aurora has a higher max value
ff

#Check for markers
markernames(ff)

#Check metadata
keyword(ff)
t<-keyword(ff)

#Access Expression data
ff@exprs

#Create a flowSet(fs) // FCS from different experiments can be imported as long as it has the same markers
fs <- read.flowSet(filenames, truncate_max_range = F)   #dont forget to use truncate_max_range to avoid upper threshold
fs[[1]]    #to check for different files in the flowset

markernames(fs)

# Use this function to check data across all files
fsApply(fs, each_col, max)
fsApply(fs, summary)

#ggcyto is a tool to visualize FACS plots
BiocManager::install('ggcyto')
library('ggcyto')
fsApply(fs, function(x)autoplot(x))

#Compensation and Transform the data  (since data is stored as linear data in the fcs files)
compensate(ff,spillover(ff)) #best to use the spillover/compensation from your flow cytometer

#for Aurora data, the data will be already saved as an unmixed data and have no spillover information
?estimateLogicle
colnames(ff)
trans <- estimateLogicle(ff, channels=colnames(ff[,7:42]))
ff_trans <- transform(ff, trans)

autoplot(ff_trans)

#now apply it to all the files
fs_trans <- transform(fs, trans)
fsApply(fs_trans, function(x)autoplot(x))

#install flowAI and run to clean up data to keep parts with good flow run time
BiocManager::install('flowAI')
library('flowAI')
fs_clean <- flow_auto_qc(fs_trans, remove_from = "FR_FS")    #flowAI can be extremely harsh in terms of removing cells from the analysis; better to remove dynamic range check

#all in one set of commands (from loading-transforming-cleaning)
filenames <- list.files("~/course_dir/data_dir/Christopher_Hall/EBI_2024", pattern = ".fcs", full.names = TRUE)  #load only FCS files only and get the full name 
fs <- read.flowSet(filenames, truncate_max_range = F)   #dont forget to use truncate_max_range to avoid upper threshold
trans <- estimateLogicle(ff, channels=colnames(ff[,7:42]))
fs_trans <- transform(fs, trans)
fs_clean <- flow_auto_qc(fs_trans, remove_from = "FR_FS")    #flowAI can be extremely harsh in terms of removing cells from the analysis; better to remove dynamic range check

#Using ggplot package to visualize flow cytometry data
autoplot(fs_clean, x='CD3', y='CD8', bins=256)

#Basic Gating Steps
BiocManager::install('openCyto')
library("openCyto")       #
library("flowWorkspace")  #gives you a control panel to perform you gating hierarchy


