#### Install packages if needed ####
install.packages("Seurat")
install.packages("tidyverse")
install.packages("hdf5r")
library(Seurat)
library(tidyverse)

#### Create gene expression matrix ####
nsclc.sparse.m <- Read10X_h5(filename = 'path/to/file')
str(nsclc.sparse.m)
cts <- nsclc.sparse.m$'Gene Expression'
cts[1:10,1:10]

#### Load Seurat object ####
nsclc.seurat.obj <- CreateSeuratObject(counts = cts, project = "NSCLC", min.cells = 3, min.features = 200)
str(nsclc.seurat.obj)
nsclc.seurat.obj

#### Quality control ####

# Measure & Visualise MT reads
nsclc.seurat.obj[["percent.mt"]] <- PercentageFeatureSet(nsclc.seurat.obj, pattern = "^MT-")
View(nsclc.seurat.obj@meta.data)

VlnPlot(nsclc.seurat.obj, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol=3)
FeatureScatter(nsclc.seurat.obj, feature1="nCount_RNA", feature2="nFeature_RNA") + geom_smooth(method = 'lm')

# Filter out unwanted reads
nsclc.seurat.obj <- subset(nsclc.seurat.obj, subset= nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

# Normalise
nsclc.seurat.obj <- NormalizeData(nsclc.seurat.obj)

# Identify highly variable features
nsclc.seurat.obj <- FindVariableFeatures(nsclc.seurat.obj, selection.method = "vst", nfeatures = 2000)

# Identify top 10 most highly variable genes
top10 <- head(VariableFeatures(nsclc.seurat.obj), 10)

# Plot variable features
plot1 <- VariableFeaturePlot(nsclc.seurat.obj)
LabelPoints(plot=plot1, points = top10, repel = TRUE)

# Scaling
all.genes<- rownames(nsclc.seurat.obj)
nsclc.seurat.obj <- ScaleData(nsclc.seurat.obj, features=all.genes)

# Linear dimensionality reduction
nsclc.seurat.obj<- RunPCA(nsclc.seurat.obj, features =  VariableFeatures(object = nsclc.seurat.obj))

# PCA
print(nsclc.seurat.obj[["pca"]], dims=1:5, nfeatures=5)
DimHeatmap(nsclc.seurat.obj, dims=1, cells=500, balanced= TRUE)

# Elbow plot
ElbowPlot(nsclc.seurat.obj)
