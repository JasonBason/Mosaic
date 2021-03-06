% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/feature_table_data_analysis.R
\name{ttestx}
\alias{ttestx}
\title{ttestx}
\usage{
ttestx(x = c(1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 6, 6, 7), ltail = T,
  over = NULL, calc = NULL)
}
\arguments{
\item{x}{numeric vector}

\item{ltail}{TRUE or FALSE, passed on as lower.tail to stats::pt}

\item{over}{indexes of values in x to be used as population}

\item{calc}{indexes of values in x representing the hypothesized upper bond of population mean}
}
\description{
Upper or Lower Tail Test of Population Mean with Unknown Variance
}
