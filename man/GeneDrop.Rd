% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/monteCarloMethods.R
\name{GeneDrop}
\alias{GeneDrop}
\alias{GeneDropSim.allsubsets.fn}
\alias{GeneDropSim.fn}
\alias{GeneDropSimExcessSharing.fn}
\title{deprecated function}
\usage{
GeneDrop(...)

GeneDropSim.allsubsets.fn(...)

GeneDropSim.fn(...)

GeneDropSimExcessSharing.fn(...)
}
\arguments{
\item{...}{arguments to the old function}
}
\value{
none
}
\description{
This function is deprecated with version >= 2.0
and should not be used, instead use RVsharing with nSim option
}
\examples{
tryCatch(GeneDrop(), error = function(e) message(e))
}
