% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multipleFamilyCalculations.R
\name{get.psubset}
\alias{get.psubset}
\title{deprecated function}
\usage{
get.psubset(vec, not, pshare.data)
}
\arguments{
\item{vec}{a vector of names of all families where a variant is seen}

\item{not}{a vector of names of families where not all affected subjects
share the rare variant}

\item{pshare.data}{a data frame with at least two of the following columns:
pshare: vector of RV sharing probabilities
ped.tocompute.vec: vector of names of the families whose sharing 
probability is contained in pshare. The names in the arguments
vec and not must be found in ped.tocompute.vec}
}
\value{
P-value of the exact rare variant sharing test requiring
sharing by all affected subjects.
}
\description{
This function is deprecated with version >= 2.0
and should not be used, instead use multipleFamilyPValue
}
\examples{
data(samplePedigrees)
notSharedFams <- c(15159, 15053, 15157)
famids <- sapply(samplePedigrees, function(p) p$famid[1])
notShared <- famids \%in\% notSharedFams
probs <- sapply(samplePedigrees, RVsharing)
get.psubset(famids, notShared, data.frame(pshare=probs,
ped.tocompute.vec=famids))
}
