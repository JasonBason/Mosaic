% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class_msdata.R
\name{rawEICm}
\alias{rawEICm}
\title{rawEICm}
\usage{
rawEICm(object, mzrange = numeric(), rtrange = numeric(),
  scanrange = numeric(), viewermode = T)
}
\arguments{
\item{object}{xcmsRaw object}

\item{mzrange}{a range of m/z values (numeric(2)).}

\item{rtrange}{a range of rt values (numeric(2)).}

\item{scanrange}{a range of scan number values (numeric(2)).}

\item{viewermode}{True to change handling of out of range rt values for the Mosaic viewer. DEPRECATED (always used)}
}
\description{
EICs from an xcmsRaw object, modified version of xcms::rawEIC xcmsRaw method.
Major difference: Handling of cases where no scan is in rt range.
xcms::rawEIC also drops the last scan within range, rawEICm does not.
}
