% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/string_db.R
\name{buildStringNetwork}
\alias{buildStringNetwork}
\title{Build gene network from peptide ids}
\usage{
buildStringNetwork(
  stringTbl,
  useNames = c("protein", "ensembl", "external"),
  string.tbl = deprecated(),
  use.names = deprecated()
)
}
\arguments{
\item{stringTbl}{\code{data.frame} or \code{tibble} with colnames and rownames as
ensembl peptide id \emph{(same order)}.}

\item{useNames}{\code{character(1)} that defaults to use protein names
_('protein'), other options are 'ensembl' for ensembl gene id or 'external'
for external gene names.}

\item{string.tbl}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}}

\item{use.names}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}}
}
\value{
a new matrix with gene ids instead of peptide ids. The size of matrix
can be different as
there may not be a mapping or a peptide mapping can have multiple genes.
}
\description{
This can reduce the dimension of the original network, as there may not be a
mapping
between peptide and gene id
}
\examples{
\donttest{
interactions <- stringDBhomoSapiens(scoreThreshold = 100)
string_network <- buildStringNetwork(interactions)

# number of edges
sum(string_network != 0)
}
}
\seealso{
\code{\link[=stringDBhomoSapiens]{stringDBhomoSapiens()}}
}
