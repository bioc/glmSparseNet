% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/network_options.R
\name{orphanHeuristic}
\alias{orphanHeuristic}
\title{Heuristic function to penalize nodes with high degree}
\usage{
orphanHeuristic(x)
}
\arguments{
\item{x}{single value of vector}
}
\value{
transformed
}
\description{
Heuristic function to penalize nodes with high degree
}
\examples{
orphanHeuristic(rnorm(1:10))
}
