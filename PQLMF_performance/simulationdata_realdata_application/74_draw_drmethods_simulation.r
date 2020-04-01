args<-commandArgs(T)
library(igraph)
library(Matrix)
library(adaptiveGPCA)
library(ggplot2)
library(phyloseq)
library(mvtnorm)
library(Rcpp)
library(doParallel)
library(foreach)
cell_type <- c(rep(1, 100),rep(2,300),rep(3,600))
k <- length(unique(cell_type))
figure_path="/net/mulan/home/qidif/scRNA_Method/Res_Summary/simulation_figures/"
marker_number <- args[1]
total_value <- c()
total_compare <- c()
total_method <- c()
total_time <- c()
res_path <- "~/scRNA_Method/Res_Summary/simulation_multimethods/"
source("~/scRNA_Method/Res_Summary/DRComparison-master/algorithms/ExtractW.R")
	tryCatch({
for (method_indx in seq (1,9)){
METHODS <- c("FA", "PCA", "ZINBWaVE", "NMF", "PoissonNMF", "MDS", "LLE", "LTSA", "PQLMF")
imethod <- METHODS[method_indx]
print(imethod)
irpt <- 1
num_pc <- 10
for (simu_time in seq(1,10)){
	idata <- paste0("time",simu_time,".m_sigmag_sq0.1.nm_sigmag_sq0.001.sigmae_sq0.1.marker_number",marker_number,".prop0.2.mu1.simu.rds")
	file <- paste0(res_path,"res.",idata,".nPC",num_pc,".rpt",irpt,".",imethod,".rds")
	if(file.exists(file)){
	res <- readRDS(file)
		W <- ExtractW(res, imethod)
		res_clust <- kmeans(W, k, nstart=10000, iter.max=100000000)
		total_value <- c(total_value, compare(as.numeric(as.factor(cell_type)), res_clust$cluster, method="nmi"))
		total_value <- c(total_value, compare(as.numeric(as.factor(cell_type)), res_clust$cluster, method="adjusted.rand"))
		total_compare <- c(total_compare, "nmi", "adjusted.rand")
		total_method <- c(total_method, imethod, imethod)
		total_time <- c(total_time, simu_time, simu_time)
	}
	}
	}
	}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
data <- data.frame(VALUE=as.numeric(total_value), COMPARE=total_compare, METHOD=total_method)
save(data, file=paste0(figure_path, "res.",idata,".nPC",num_pc,".rpt",irpt,".allDRmethods.RData"))
library(ggplot2)
pngfile=paste0(figure_path,"res.",idata,".nPC",num_pc,".rpt",irpt,".allDRmethods.png")

png(pngfile)
ggplot(data=data, aes(x=METHOD, y=VALUE, fill=COMPARE)) + geom_boxplot()+ theme(axis.text.x = element_text(angle = 90, hjust = 1)) + ylim(0, 1)

dev.off()

