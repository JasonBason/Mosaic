% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting_msdata.R
\name{EICgeneral}
\alias{EICgeneral}
\title{EICgeneral}
\usage{
EICgeneral(rtmid = combino()[, "rt"], mzmid = combino()[, "mz"],
  glist = MSData$layouts[[MSData$active]]$grouping,
  cols = MSData$layouts[[MSData$active]]$settings$cols,
  colrange = MSData$layouts[[MSData$active]]$settings$colr,
  transparency = MSData$layouts[[MSData$active]]$settings$alpha,
  RTall = input$RTtoggle, TICall = input$TICtoggle,
  rtw = MSData$layouts[[MSData$active]]$settings$rtw,
  ppm = MSData$layouts[[MSData$active]]$settings$ppm, rdata = MSData$data,
  pdfFile = file, leadingTIC = T, lw = 1, adducts = c(0), cx = 1,
  midline = T, yzoom = 1, RTcorrect = NULL, importEIC = NULL)
}
\arguments{
\item{rtmid}{vector of retention time values (not ranges)}

\item{mzmid}{vector of mz values (not ranges)}

\item{glist}{a named list of grouped file names (as supplied in $grouping of rawLayout objects)}

\item{cols}{integer, number of colors generated}

\item{colrange}{character(1), color range function used for line colors}

\item{transparency}{numeric(1), alpha (range 0..1) for transparency of lines}

\item{RTall}{if TRUE, entire RT range will be plotted}

\item{TICall}{if TRUE, TIC will be plotted instead of EIC}

\item{rtw}{retention time window +/- rtmid in seconds that will be plotted}

\item{ppm}{mz window +/- mzmid in ppm that will be plotted}

\item{rdata}{named list of xcmsRaw objects}

\item{pdfFile}{character - if not NULL, plotting result will be saved in a pdf file with this name.}

\item{leadingTIC}{if TRUE, a TIC plot is made before the EIC plots (e.g. as first page of pdf file)}

\item{lw}{line width for plot lines}

\item{adducts}{numeric() of mass shifts to be added to feature masses}

\item{cx}{character expansion factor (font size)}

\item{midline}{if TRUE, dotted vertical line should be plotted at feature rt}

\item{yzoom}{zoom factor into y-axis}

\item{RTcorrect}{if not NULL, this RTcorr object will be used to adjust retention times.}

\item{exportmode}{if TRUE, $EIC list is exported along with $plot (as list)}
}
\description{
wrapper function to plot multiple EICs
}
