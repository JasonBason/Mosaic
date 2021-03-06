% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class_feature_table.R
\name{constructFeatureTable}
\alias{constructFeatureTable}
\title{constructFeatureTable}
\usage{
constructFeatureTable(df = data.frame(mz = numeric(3), rt = numeric(3)),
  mzcol = "mz", rtcol = "rt", commentcol = "comments",
  fragmentcol = "fragments", rtFormat = "sec", anagrouptable = NULL,
  tablename = "Custom Table", editable = T)
}
\arguments{
\item{df}{feature table as data.frame, with retention time (rt), mz and (optionally) intensity values.}

\item{mzcol}{column in df with mz values (columnname), defaults to "mz"}

\item{rtcol}{column in df with rt values (columnname), defaults to "rt"}

\item{commentcol}{column in df with comments (columnname), defaults to "comments"}

\item{fragmentcol}{column in df with fragmentation information (columnname), defaults to "fragments"}

\item{rtFormat}{Are retention times given in seconds ("sec") or minutes ("min")}

\item{anagrouptable}{Analysis grouping table: a data.frame with columns "Column" (containing column names from df with intensity values) and "Group" (defining a group for each entry in "Column")}

\item{tablename}{Name of the table as displayed by Mosaic}

\item{editable}{allow editing of this table in the Mosaic app? if FALSE, only comments column can be edited. editable tables are also not paginated.}
}
\description{
Constructor function for "MosaicFT" object from a feature table data.frame.
uses and retains the original data frame plus names of columns containing relevant data.
}
\details{
NOTE: currently, only the default values for column names are supported.
}
