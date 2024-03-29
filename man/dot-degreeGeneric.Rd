% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/centrality-utils.R
\name{.degreeGeneric}
\alias{.degreeGeneric}
\title{Generic function to calculate degree based on data}
\usage{
.degreeGeneric(
  fun = stats::cor,
  funPrefix = "operator",
  xdata,
  cutoff = 0,
  considerUnweighted = FALSE,
  chunks = 1000,
  forceRecalcDegree = FALSE,
  forceRecalcNetwork = FALSE,
  nCores = 1,
  ...
)
}
\arguments{
\item{fun}{function that will calculate the edge weight between 2 nodes}

\item{funPrefix}{used to store low-level information on network as it can
become to large to be stored in memory}

\item{xdata}{calculate correlation matrix on each column}

\item{cutoff}{positive value that determines a cutoff value}

\item{considerUnweighted}{consider all edges as 1 if they are greater than 0}

\item{chunks}{calculate function at batches of this value (default is 1000)}

\item{forceRecalcDegree}{force recalculation of penalty weights (but not
the network), instead of going to cache}

\item{forceRecalcNetwork}{force recalculation of network and penalty
weights, instead of going to cache}

\item{nCores}{number of cores to be used}

\item{...}{extra parameters for fun}
}
\value{
a vector of the degrees
}
\description{
The assumption to use this function is that the network represented by a
matrix is symetric and without
any connection the node and itself.
}
