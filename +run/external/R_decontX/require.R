if (!requireNamespace("celda", quietly = TRUE)){
if (!requireNamespace("BiocManager", quietly = TRUE)){
    install.packages("BiocManager", repo="http://cran.rstudio.com/")
}
BiocManager::install("celda")
}


if (!requireNamespace("rhdf5", quietly = TRUE)){
if (!requireNamespace("BiocManager", quietly = TRUE)){
    install.packages("BiocManager", repo="http://cran.rstudio.com/")
}
BiocManager::install("rhdf5")
}

#if (!requireNamespace("scater", quietly = TRUE)){
#if (!requireNamespace("BiocManager", quietly = TRUE)){
#    install.packages("BiocManager", repo="http://cran.rstudio.com/")
#}
#BiocManager::install("scater")
#}

#if (!requireNamespace("decontX", quietly = TRUE)){
#if (!requireNamespace("BiocManager", quietly = TRUE)){
#    install.packages("BiocManager", repo="http://cran.rstudio.com/")
#}
#BiocManager::install("decontX")
#}


