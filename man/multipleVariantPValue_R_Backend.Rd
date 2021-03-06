% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multipleFamilyCalculationsBackend.R
\name{multipleVariantPValue_R_Backend}
\alias{multipleVariantPValue_R_Backend}
\title{R backend for multipleVariantPValue calculation}
\usage{
multipleVariantPValue_R_Backend(
  snpMat,
  famIds,
  sharingProbs,
  minorAllele,
  filter = NULL,
  alpha = 0
)
}
\arguments{
\item{snpMat}{SnpMatrix}

\item{famIds}{family ids corresponding to rows of the snpMap}

\item{sharingProbs}{vector of sharing probabilites, must be a named vector
with famid's for each probability}

\item{minorAllele}{vector specifying the minor allele of each variant}

\item{filter}{criteria for filtering pvalues}

\item{alpha}{parameter for filter}
}
\value{
list of p-values and potential p-values
}
\description{
R backend for multipleVariantPValue calculation
}
