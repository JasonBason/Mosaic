% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting_msdata.R
\name{groupPlot}
\alias{groupPlot}
\title{groupPlot}
\usage{
groupPlot(EIClist = res, grouping = grouping2, plotProps = list(TIC = T,
  cx = 1, colr = topo.colors(nrow(minoritem), alpha = 1), ylim = NULL, xlim =
  NULL, lw = 1, midline = 100, yzoom = 1), compProps = list(mfrow = c(1, 2),
  oma = c(0, 2, 8, 0), xpd = NA, bg = NA, header = paste0(names(res)), header2 =
  NULL, pdfFile = NULL, pdfHi = 6, pdfWi = 12, cx = 1, adductLabs = c("0", "1",
  "2")))
}
\arguments{
\item{EIClist}{list of EICs from Mosaic:multiEIC}

\item{grouping}{a named list of grouped file names (as supplied in $grouping of rawLayout objects)}

\item{plotProps}{a list of settings for the individual plots}

\item{compProps}{layoout options for the composite plot}

\item{plotProps.TIC}{if TRUE, TIC instead of EIC}

\item{plotProps.cx}{numeric(1) font size (character expansion) factor}

\item{plotProps.colr}{color range (actual vector of color values)}

\item{plotProps.ylim}{data.frame or matrix of nrow = number of plotted features, with min and max visible rt value (in seconds) for each feature}

\item{plotProps.xlim}{data.frame or matrix of nrow = number of plotted features, with min and max visible intensity value for each feature}

\item{plotProps.midline}{numeric() of y-axis positions where a dotted vertical line should be plotted}

\item{plotProps.lw}{line width for plot lines}

\item{plotProps.yzoom}{zoom factor into y-axis}

\item{compProps.mfrow}{integer(2) rows and columns for plotting (cf. par(), mfrow)}

\item{compProps.oma}{numeric(4) outer margins (cf. par(), oma)}

\item{compProps.xpd}{drawing outside of plot region, cf. par(), xpd}

\item{compProps.bg}{background color, cf. par(), bg}

\item{compProps.header}{First (title) line of composite plot}

\item{compProps.header2}{Subtitle line of composite plot}

\item{compProps.pdfFile}{character - if not NULL, plotting result will be saved in a pdf file with this name.}

\item{compProps.pdfHi}{pdf height in inches}

\item{compProps.pdfWi}{pdf width in inches}

\item{compProps.cx}{numeric(1) font size (character expansion) factor}

\item{compProps.adductLabs}{adduct labels (nonfunctional)}
}
\description{
generate multiple EICs on one page
}
