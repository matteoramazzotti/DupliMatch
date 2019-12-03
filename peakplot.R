args = commandArgs(trailingOnly=TRUE)
if (length(args) == 0) {
	cat("\nUSAGE: Rscript pleakPlot.R file.peaks\n")
	cat("       Rscript pleakPlot.R file.cov contig_name start stop outfile.pdf\n\n")
	quit("no")
}
if (length(args) == 1) {
	#args = "1018_SAUR.peaks"
	#outfile name is infile name with the pdf extension
	covfile<-gsub(".peaks",".cov",args[1])
	cat("Loading coverage file\n")
	cov<-read.delim(file=covfile,sep="\t",header=F)
	#grand mean of the whole genome coverage
	gmean<-mean(cov[,3])
	#while reading peak files the "#" containing lines are skipped
	peaks<-read.table(pipe(paste("grep -v '#' ",args[1])),sep="\t")
	#a single pdf is created for each genome
	pdf(file=paste(args[1],".pdf",sep=""),width=10,height=5)
	#loop through peaks
	for (i in 1:dim(peaks)[1]) {
		#select by contig name
		cursel<-as.character(peaks[i,1])
		sel<-ifelse(!is.na(match(cov[,1],cursel)),T,F)
		#a is a portion of cov
		a<-cov[sel,]
		#with mean smean
		smean<-mean(a[,3])
		#tol is a 5% peak size to be plotted on left and right of the peak
		tol<-(peaks[i,3]-peaks[i,2]+1)*0.05
		st<-round(peaks[i,2]-tol,0)
		en<-round(peaks[i,3]+tol,0)
		title<-paste("Plotting contig ",cursel,", peak ",peaks[i,2],"-",peaks[i,3],sep="") 
		cat(title,"\n")
		plot(st:en,a[st:en,3],ylim=c(0,max(a[,3])),type="l",main=title,xlab="Position", ylab="Coverage")
		abline(v=peaks[i,c(2,3)],col="black")
		abline(h=gmean,lty=2,col="blue")
		abline(h=smean,lty=2,col="red")
		abline(h=smean*2,lty=2,col="green")
	}
	dev.off()
}
if (length(args)==5) {
	cov<-read.delim(file=args[1],sep="\t",header=F)
	gmean<-mean(cov[,3])
	cursel<-as.character(args[2])
	sel<-ifelse(!is.na(match(cov[,1],cursel)),T,F)
	#a is a portion of cov
	a<-cov[sel,]
	smean<-mean(a[,3])
	st<-args[3]
	en<-args[4]
	title<-paste("Plotting contig ",cursel,", from ",st," to ",en,sep="") 
	pdf(file=args[5],width=10,height=5)
	plot(st:en,a[st:en,3],ylim=c(0,max(a[,3])),type="l",main=title,xlab="Position", ylab="Coverage")
	abline(h=gmean,lty=2,col="blue")
	abline(h=smean,lty=2,col="red")
	abline(h=smean*2,lty=2,col="green")
	dev.off()
}
if (length(args)!=5 && length(args)!=1) {
	cat("invalid number of parameters\n")
} 
