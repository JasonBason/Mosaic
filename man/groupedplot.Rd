% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotting_stats.R
\name{groupedplot}
\alias{groupedplot}
\title{Plot summary data on grouped data}
\usage{
groupedplot(..., main = c("boxplot", "barplot", "violinplot"), dotplot = T,
  dsize = 1, mark = c("mean", "median"),
  errorbar = c("Standard Deviation", "95\% Confidence Interval"),
  rotate = T)
}
\arguments{
\item{...}{arguments passed to ggplot2::ggplot}

\item{main}{plot type}

\item{dotplot}{boolean whether or not to plot individual values as dots}

\item{mark}{select a value to be plotted}

\item{errorbar}{select type of error bar}

\item{rotate}{boolean whether or not to rotate x-axis labels}
}
\description{
Plot summary data on grouped data
}
