glmSparseNet
================

- [Overview](#overview)
- [Citation](#citation)
- [Instalation](#instalation)
- [Details](#details)
  - [Function definition](#function-definition)
- [Example for survival analysis using RNA-seq
  data](#example-for-survival-analysis-using-rna-seq-data)
- [Visualization and Analytical
  tools](#visualization-and-analytical-tools)
  - [Survival curves with
    `separate2groupsCox`](#survival-curves-with-separate2groupscox)

<!-- README.md and README.html are generated from README.Rmd. Please edit that file -->

> Elastic-Net models with additional regularization based on network
> centrality metrics

[![R-CMD-check](https://github.com/sysbiomed/glmSparseNet/actions/workflows/check.yml/badge.svg)](https://github.com/sysbiomed/glmSparseNet/actions/workflows/check.yml)
[![codecov](https://codecov.io/github/sysbiomed/glmSparseNet/graph/badge.svg?token=spsEKgAbyi)](https://codecov.io/github/sysbiomed/glmSparseNet)

## Overview

`glmSparseNet` is a R package that generalizes sparse regression models
when the features *(e.g. genes)* have a graph structure
*(e.g. protein-protein interactions)*, by including network-based
regularizers. `glmSparseNet` uses the `glmnet` R-package, by including
centrality measures of the network as penalty weights in the
regularization. The current version implements regularization based on
node degree, i.e. the strength and/or number of its associated edges,
either by promoting hubs in the solution or orphan genes in the
solution. All the `glmnet` distribution families are supported, namely
*“gaussian”*, *“poisson”*, *“binomial”*, *“multinomial”*, *“cox”*, and
*“mgaussian”*.

It adds two new main functions called `glmSparseNet` and
`cv.glmSparseNet` that extend both model inference and model selection
via cross-validation with network-based regularization. These functions
are very flexible and allow to transform the penalty weights after the
centrality metric is calculated, thus allowing to change how it affects
the regularization. To facilitate users, we made available a function
that will penalize low connected nodes in the network - `glmHub` or
`glmDegree` - and another that will penalize hubs - `glmOrphan`.

<span style="display:block;text-align:center">![Overview of the
R-Package pipeline](inst/images/overview.png)</span>

Below, we provide one example for survival analysis using transcriptomic
data from the TCGA Adrenocortical Carcinoma project. More information
and Rmd files are available in the vignettes folder where more extensive
and complete examples are provided for logistic regresson and Cox’s
regression for different types of cancer data.

## Citation

Veríssimo, A., Carrasquinha E., Lopes, M.B., Oliveira, A.L., Sagot,
M.-F. & Vinga, S. (2018), Sparse network-based regularization for the
analysis of patientomics high-dimensional survival data. bioRxiv 403402;
doi: <https://doi.org/10.1101/403402>

Veríssimo, A., Oliveira, A.L., Sagot, M.-F., & Vinga, S. (2016).
DegreeCox – a network-based regularization method for survival analysis.
BMC Bioinformatics. 17(16): 449.
<https://doi.org/10.1186/s12859-016-1310-4>

This package was developed by André Veríssimo, Eunice Carrasquinha,
Marta B. Lopes and Susana Vinga under the project SOUND, funded from the
European Union Horizon 2020 research and innovation program under grant
agreement No. 633974.

## Instalation

Bioconductor is necessary for the installation of this package.

``` r
if (!require("BiocManager")) {
  install.packages("BiocManager")
}
BiocManager::install("glmSparseNet")
```

## Details

This package extends the `glmnet` r-package with network-based
regularization based on features relations. This network can be
calculated from the data itself or using external networks to enrich the
model.

There are 2 methods available to use data-dependant methods to generate
the network:

1.  Correlation matrix with cutoff;
2.  Covariance matrix with cutoff;

Alternatively, the network can be passed as an adjancency matrix or an
already calculate metric for each node.

### Function definition

The main functions from this packages are the `glmSparseNet` and
`cv.glmSparseNet` and the arguments for the functions are defined as:

- `xdata`: A MultiAssayExperiment object or an input matrix of dimension
  `Observations x Features`
- `ydata`: Response object that can take different forms depending on
  the model family that is used
- `family`: Model type that can take: *“gaussian”*, *“poisson”*,
  *“binomial”*, *“multinomial”*, *“cox”*, and *“mgaussian”*
- `network`: Network to use in penalization, it can take as input:
  “correlation”, “covariance”, a matrix object with p.vars x p.vars
  representing the network, a weighted vector of penalties
- `experiment.name`: Optional parameter used with a
  “MultiAssayExperiment” object as input
- `network.options`: Optional parameter defining the options to process
  the network, such as:
  - `cutoff`: A real number to use to remove edges from the network
  - `minDegree`: Minimum value that the weight should have, this is
    useful as when the weight is 0, there is no regularization on that
    feature, which may lead to convergence problems
  - `transFun`: Transformation function to the vector of penalty weights
    after these are calculated from the network

*note:* These functions can take any additional arguments that `glmnet`
or `cv.glmnet` accept (e.g. number of folds in cross validation)

``` r
cv.glmSparseNet(
  xdata,
  ydata,
  family = "cox",
  network = "correlation",
  options = networkOptions(
    cutoff = .6,
    minDegree = 0.2
  )
)
```

## Example for survival analysis using RNA-seq data

This example uses an adrenal cancer dataset using the correlation to
calculate the network and cross-validation to find the optimal model.
The network itself if filtered using a cutoff value of 0.6, i.e. all
edges that have a correlation between the two features *(genes)* below
the cutoff value are discarded.

The data was retrieved from TCGA database and the Adrenocortical
Carcinoma project with 92 patients and a reduced RNASeq data. See
Bioconductor package `MultiAssayExperiment` for more information on the
`miniACC` dataset.

To run the following examples, the next libraries are also needed:

``` r
library(futile.logger)
library(dplyr)
library(ggplot2)
library(reshape2)
library(MultiAssayExperiment)
library(survival)
library(glmnet)
library(glmSparseNet)
```

There is some pre-processing needed to remove patients with invalid
follow-up date or death date:

``` r
# load data
data("miniACC", package = "MultiAssayExperiment")
xdata <- miniACC

# build valid data with days of last follow up or to event
eventIx <- which(!is.na(xdata$days_to_death))
censIx <- which(!is.na(xdata$days_to_last_followup))
survEventTime <- array(NA, nrow(colData(xdata)))
survEventTime[eventIx] <- xdata$days_to_death[eventIx]
survEventTime[censIx] <- xdata$days_to_last_followup[censIx]

# Keep only valid individuals
#
# they are valid if they have:
#  - either a follow_up time or event time
#  - a valid vital_status (i.e. not missing)
#  - folloup_time or event_time > 0
validIx <- as.vector(!is.na(survEventTime) & !is.na(xdata$vital_status) & survEventTime > 0)
ydata <- data.frame(
  time = survEventTime[validIx],
  status = xdata$vital_status[validIx],
  row.names = xdata$patientID[validIx]
)
```

The function `cv.glmSparseNet` fits the survival data using 10-fold
cross validation and using a cutoff value of 0.6 to reduce the size of
the network.

``` r
# build response object for glmnet
fit3 <- cv.glmSparseNet(
  xdata, 
  ydata,
  family = "cox",
  network = "correlation",
  experiment = "RNASeq2GeneNorm",
  alpha = .7,
  nlambda = 1000,
  options = networkOptions(
    cutoff = .6,
    minDegree = 0.2,
    transFun = hubHeuristic
  )
)
```

    ## Warning: 'experiments' dropped; see 'drops()'

    ## harmonizing input:
    ##   removing 306 sampleMap rows not in names(experiments)
    ##   removing 13 colData rownames not in sampleMap 'primary'

``` r
plot(fit3)
```

![](README_files/figure-gfm/fit.surv-1.png)<!-- -->

*Cross validation plot, showing all 1000 lambdas tested and the error
for each, vertical lines show best model and another with fewer
variables selected within one standard error of the best.*

## Visualization and Analytical tools

### Survival curves with `separate2groupsCox`

This function generates Kaplan-Meier survival model based on the
estimated coefficients of the Cox model. It creates two groups based on
the relative risk and displays both survival curves *(high vs. low-risk
patients, as defined by the median)* and the corresponding results of
log-rank tests.

``` r
# Data to use in draw.kaplan function
#  * it takes the input data, response and coefficients
#  * calculates the relative risk
#  * separates individuals based on relative risk into High/Low risk groups
xdataReduced <- as(xdata[, , "RNASeq2GeneNorm"], "MatchedAssayExperiment")
```

    ## Warning: 'experiments' dropped; see 'drops()'

    ## harmonizing input:
    ##   removing 306 sampleMap rows not in names(experiments)
    ##   removing 13 colData rownames not in sampleMap 'primary'

``` r
ydataKM <- ydata[rownames(colData(xdataReduced)), ]
bestModelCoef <- coef(fit3, s = "lambda.min")[, 1]
```

Kaplan-Meier plot

``` r
separate2GroupsCox(
  bestModelCoef, t(assay(xdata[["RNASeq2GeneNorm"]])), ydataKM, ylim = c(0, 1)
)
```

    ## Coordinate system already present. Adding new coordinate system, which will
    ## replace the existing one.

    ## $pvalue
    ## [1] 2.728306e-07
    ## 
    ## $plot

![](README_files/figure-gfm/call.kaplan-1.png)<!-- -->

    ## 
    ## $km
    ## Call: survfit(formula = survival::Surv(time, status) ~ group, data = prognosticIndexDf)
    ## 
    ##                n events median 0.95LCL 0.95UCL
    ## Low risk - 1  40      5     NA      NA      NA
    ## High risk - 1 39     23   1105     579      NA
