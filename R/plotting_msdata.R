library(Hmisc)
#' legendplot
#' 
#' Plot a legend in an otherwise empty plot
#' 
#' @param ... all arguments passed on to legend
#'
#' @export
legendplot <- function(...){
  
  par(mfrow=c(1,1), 
      mar = c(0.1,0.1,0.1,0.1),
      oma = c(0,0,0,0)
  )
  plot(1, type = "n", axes=FALSE, xlab="", ylab="")
  legend(...)
  
  
}

#' EICgeneral
#' 
#' wrapper function to plot multiple EICs
#' 
#' 
#' @param rtmid vector of retention time values (not ranges)
#' @param mzmid vector of mz values (not ranges)
#' @param glist a named list of grouped file names (as supplied in $grouping of rawLayout objects)
#' @param cols integer, number of colors generated
#' @param colrange character(1), color range function used for line colors
#' @param transparency numeric(1), alpha (range 0..1) for transparency of lines
#' @param RTall if TRUE, entire RT range will be plotted
#' @param TICall if TRUE, TIC will be plotted instead of EIC
#' @param rtw retention time window +/- rtmid in seconds that will be plotted
#' @param ppm mz window +/- mzmid in ppm that will be plotted
#' @param rdata named list of xcmsRaw objects
#' @param pdfFile character - if not NULL, plotting result will be saved in a pdf file with this name.
#' @param leadingTIC if TRUE, a TIC plot is made before the EIC plots (e.g. as first page of pdf file)
#' @param midline if TRUE, dotted vertical line should be plotted at feature rt
#' @param lw line width for plot lines
#' @param yzoom zoom factor into y-axis
#' @param cx character expansion factor (font size)
#' @param adducts numeric() of mass shifts to be added to feature masses
#' @param RTcorrect if not NULL, this RTcorr object will be used to adjust retention times.
#' @param exportmode if TRUE, $EIC list is exported along with $plot (as list)
#' 
#' @export
EICgeneral <- function(rtmid = combino()[,"rt"],
                       mzmid = combino()[,"mz"],
                       glist = MSData$layouts[[MSData$active]]$grouping,
                       cols = MSData$layouts[[MSData$active]]$settings$cols,
                       colrange = MSData$layouts[[MSData$active]]$settings$colr,
                       transparency = MSData$layouts[[MSData$active]]$settings$alpha,
                       RTall = input$RTtoggle,
                       TICall = input$TICtoggle,
                       rtw = MSData$layouts[[MSData$active]]$settings$rtw,
                       ppm = MSData$layouts[[MSData$active]]$settings$ppm,
                       rdata = MSData$data,
                       pdfFile = file,
                       leadingTIC = T,
                       lw = 1,
                       adducts = c(0),
                       cx = 1,
                       midline = T,
                       yzoom = 1,
                       RTcorrect = NULL,
                       importEIC = NULL
){
  #number of plot rows
  rows <- ceiling(length(glist)/cols)
  
  #make color scales for each group, color shades based on group with most members
  colvec <- do.call(colrange,
                    list(n=max(sapply(glist,length)), alpha = transparency))
  colrs <- list()
  for(i in 1:length(glist)){
    
    colrs[[i]] <- colvec[1:length(glist[[i]])]
    
  }
  
  #generate rt boundary df
  if(any(RTall, is.null(rtmid))){ # any can handle NULL, seems more flexible than ||
    rtmid <- NULL
    rtx <- NULL
  }else{
    rtx <- data.frame(rtmin = rtmid - rtw,
                      rtmax = rtmid + rtw)
  }  
  
  #generate mz boundary df
  if(any(TICall, is.null(mzmid)) ){
    mzmid <- if(!is.null(rtmid)){rep(100,length(rtmid))}else{100}
    mzx <- data.frame(mzmin = mzmid-1,
                      mzmax = mzmid+1)
    titx <- if(!is.null(rtmid)){rep("TICs",length(rtmid))}else{"TICs"}
    tictog <- TRUE
  }else{
    tictog <- FALSE
    mzx <- data.frame(mzmin = mzmid - mzmid*ppm*1e-6,
                      mzmax = mzmid + mzmid*ppm*1e-6)
    titx <- EICtitles(mzmid, rtmid, ppm)
  }
  
  
  
  
  
  #optionally export to pdf
  if(!is.null(pdfFile)){
    pdf(pdfFile,
        6*cols,
        6*ceiling(length(glist)/cols)+2
    )}
  
  #optionally plot TICs first (page 1 in pdf)
  if(leadingTIC){  
    EICsTIC <- multiEIC(rawdata= rdata,
                        mz = mzx[1,],
                        rt = NULL,
                        rnames = "1", #major item names
                        byFile = F,
                        RTcorr = RTcorrect  #if true, table will be sorted by rawfile, otherwise by feature
    )
    groupPlot(EIClist = EICsTIC,
              grouping = glist,
              plotProps = list(TIC = T, #settings for single plots
                               cx = cx,
                               colr = colrs,
                               lw = lw,
                               midline = NULL,
                               ylim = NULL, #these should be data.frames or matrices of nrow = number of plotted features
                               xlim = NULL,
                               yzoom = 1),
              compProps = list(mfrow=c(rows,cols), #par options for the composite plot
                               oma=c(0,2,4,0),
                               xpd=NA, bg="white",
                               header =  "TICs",
                               header2 = NULL,
                               pdfFile = NULL,
                               pdfHi = 6*rows,
                               pdfWi = 6*cols,
                               cx = cx,
                               adductLabs = 0)
    )
  }
  
  if(is.null(importEIC)){
  EICs <- multiEICplus(rawdata= rdata,
                       mz = mzx,
                       rt = if(is.null(RTcorrect)){rtx}else{NULL},
                       rnames = row.names(mzmid), #major item names
                       byFile = F, #if true, table will be sorted by rawfile, otherwise by feature
                       adducts,
                       RTcorr = RTcorrect
  )}
  else{
    EICs <- importEIC
  }
 
  groupPlot(EIClist = EICs,
            grouping = glist,
            plotProps = list(TIC = tictog, #settings for single plots
                             cx = cx,
                             colr = colrs,
                             xlim = rtx,
                             lw = lw,
                             midline = if(midline){rtmid}else{NULL},
                             yzoom = yzoom),
            compProps = list(mfrow=c(rows,cols), #par options for the composite plot
                             oma=c(0,2,4,0),
                             xpd=NA, bg="white",
                             header =  titx,
                             header2 = NULL,
                             pdfFile = NULL,
                             pdfHi = 6*rows,
                             pdfWi = 6*cols,
                             cx = cx,
                             adductLabs = adducts)
  )
  if(!is.null(pdfFile)){dev.off()}
  
  
  
}







#' EICtitles
#' 
#' helper function to generate titles for EICgeneral
#' 
#' 
#' @param rts vector of retention time values (not ranges)
#' @param mzs vector of mz values (not ranges)
#' @param ppm mz window +/- mzmid in ppm that will be plotted
#' 
#' @export
EICtitles <- function(mzs, rts, ppm){
  
  if(!is.null(ppm)){
  numbs <- matrix(mapply(sprintf,matrix(c(mzs,
                                          mzs-mzs*ppm*1e-6,
                                          mzs+mzs*ppm*1e-6),ncol=3),
                         MoreArgs = list(fmt = "%.5f")),
                  ncol=3)
  
  titx <- paste0('m/z range: ',numbs[,1], " +/- ", 
                 format(ppm, scientific = F),
                 " ppm (", numbs[,2]," - ", numbs[,3],")",
                 if(!is.null(rts)){
                   paste0(
                     " @ RT: ", sprintf( "%.2f", rts/60), " min",
                     " (", sprintf("%.1f", rts)," sec)")})
  }
  else{
    numbs <- sprintf("%.5f", mzs)
    
    titx <- paste0('m/z: ',numbs, 
                   if(!is.null(rts)){
                     paste0(
                       " @ RT: ", sprintf( "%.2f", rts/60), " min",
                       " (", sprintf("%.1f", rts)," sec)")})
    
    
  }
  return(titx)
  
}

#' groupPlot
#' 
#' generate multiple EICs on one page
#' 
#' 
#' @param EIClist list of EICs from Mosaic:multiEIC
#' @param grouping a named list of grouped file names (as supplied in $grouping of rawLayout objects)
#' @param plotProps a list of settings for the individual plots
#' @param plotProps.TIC if TRUE, TIC instead of EIC
#' @param plotProps.cx numeric(1) font size (character expansion) factor
#' @param plotProps.colr color range (actual vector of color values)
#' @param plotProps.ylim data.frame or matrix of nrow = number of plotted features, with min and max visible rt value (in seconds) for each feature
#' @param plotProps.xlim data.frame or matrix of nrow = number of plotted features, with min and max visible intensity value for each feature
#' @param plotProps.midline numeric() of y-axis positions where a dotted vertical line should be plotted
#' @param plotProps.lw line width for plot lines
#' @param plotProps.yzoom zoom factor into y-axis
#' @param compProps layoout options for the composite plot
#' @param compProps.mfrow integer(2) rows and columns for plotting (cf. par(), mfrow)
#' @param compProps.oma numeric(4) outer margins (cf. par(), oma)
#' @param compProps.xpd drawing outside of plot region, cf. par(), xpd
#' @param compProps.bg background color, cf. par(), bg
#' @param compProps.header First (title) line of composite plot
#' @param compProps.header2 Subtitle line of composite plot
#' @param compProps.pdfFile character - if not NULL, plotting result will be saved in a pdf file with this name.
#' @param compProps.pdfHi pdf height in inches
#' @param compProps.pdfWi pdf width in inches
#' @param compProps.cx numeric(1) font size (character expansion) factor
#' @param compProps.adductLabs adduct labels (nonfunctional)
#' 
#' @export
groupPlot <- function(EIClist = res,
                      grouping = grouping2,
                      plotProps = list(TIC = T, #settings for single plots
                                       cx = 1,
                                       colr = topo.colors(nrow(minoritem), alpha=1),
                                       ylim = NULL, #these should be data.frames or matrices of nrow = number of plotted features
                                       xlim = NULL,
                                       lw = 1,
                                       midline = 100,
                                       yzoom = 1),
                      compProps = list(mfrow=c(1,2), #par options for the composite plot
                                       oma=c(0,2,8,0),
                                       xpd=NA, bg=NA,
                                       header =  paste0(names(res)),
                                       header2 = NULL,
                                       pdfFile = NULL,
                                       pdfHi = 6,
                                       pdfWi = 12,
                                       cx = 1,
                                       adductLabs = c("0","1","2"))
){
  
  #majoritem is the EIClist top level (typically by mz, but could be)
  
  if(!is.null(compProps$pdfFile)){pdf(compProps$pdfFile,compProps$pdfWi,compProps$pdfHi)}
  
  if(!is.null(compProps$header)){
    
    autosize <- compProps$cx*1.5
    while(max(strwidth(compProps$header, units = "figure", cex = autosize, font = 2)) > 1){
      autosize <- autosize*0.975
    }
  }
  
  nrowcheck <- if(!is.null(nrow(EIClist))){nrow(EIClist)}else {1}
  
  for(majoritem in c(1:nrowcheck)){
    
    #adductLabs legend does not work yet
    #if(length(compProps$adductLabs)>1){compProps$mfrow[1] <- compProps$mfrow[1]+1}
    
    par(mfrow=compProps$mfrow,
        oma=compProps$oma,
        xpd=compProps$xpd,
        bg=compProps$bg,
        mar = c(2.6*(1+(compProps$cx-1)/2),4.1*(1+(compProps$cx-1)/4),4.1,2.1))
    # layout(t(as.matrix(c(1,2))))
    
    for(plotgroup in c(1:length(grouping))){
      #par(mfrow=c(1,2))
      items = grouping[[plotgroup]]
      
      preminoritem <- if(nrowcheck ==1){EIClist}else{EIClist[majoritem,]}
      
      minoritem <- subsetEICs(preminoritem,
                              items)
      #minoritem <- if(length(items) == 1){t(as.matrix(EIClist[[majoritem]][items,]))}else{EIClist[[majoritem]][items,]}
      #if(length(items) == 1){row.names(minoritem) <- items}
      
      xlimes = if (is.null(plotProps$xlim)){c(min(unlist(minoritem$EIClist[[1]][,'rt'])),
                                            max(unlist(minoritem$EIClist[[1]][,'rt'])))/60}
      else{c(min(plotProps$xlim[majoritem,]), max(plotProps$xlim[majoritem,]))/60}
      
      ### by default, only the visible part of the spectrum will be used to determine y-max
      if(plotProps$TIC){
        mm <- 1
          for(k in 1:length(minoritem$EIClist)){
            mm <- max(mm,
                      max(unlist(minoritem$EIClist[[k]][,"tic"])[which(unlist(minoritem$EIClist[[k]][,"rt"]) >= min(xlimes)*60 
                                                                       & unlist(minoritem$EIClist[[k]][,"rt"]) <= max(xlimes)*60)]))
          }
        ylimes = c(0,mm)
        }
      else if (is.null(plotProps$ylim)){
        mm <- 1
        for(k in 1:length(minoritem$EIClist)){
          mm <- max(mm,
                    max(unlist(minoritem$EIClist[[k]][,"intensity"])[which(unlist(minoritem$EIClist[[k]][,"rt"]) >= min(xlimes)*60 
                                                                     & unlist(minoritem$EIClist[[k]][,"rt"]) <= max(xlimes)*60)]))
        }
        ylimes = c(0,mm)
      }
      else{ylimes = c(min(plotProps$ylim[majoritem,]), max(plotProps$ylim[majoritem,]))}
      
      
      
      EICplot(EICs = minoritem$EIClist, cx = plotProps$cx, 
              ylim = ylimes, 
              xlim = xlimes,
              colr = if(is.list(plotProps$colr)){plotProps$colr[[plotgroup]]}
              else{plotProps$colr[1:nrow(minoritem$EIClist[[1]])]},
              legendtext = paste(sub("^([^.]*).*", "\\1",basename(row.names(minoritem$EIClist[[1]])))),
              heading = names(grouping)[plotgroup],
              relto = NULL,
              TIC = plotProps$TIC,
              lw = plotProps$lw,
              midline = plotProps$midline[majoritem],
              yzoom = plotProps$yzoom
              #mfrow=c(1,2)
      ) 
      # }
      
    }
    
    if(!is.null(compProps$header)){
    
      title(main = compProps$header[majoritem], outer=T,line=2, cex.main=autosize, font = 2)}
    
    
    if(!is.null(compProps$header2)){mtext(compProps$header2[majoritem], side=3, outer=T,line=0.5, cex=compProps$cx)}
    # par(mar=c(0,0,0,0))
    
    #   if(length(compProps$adductLabs)>1){
    #    mod <- ((compProps$mfrow[1]-1)*compProps$mfrow[2])%%length(grouping)
    #   if(mod >0){
    #    for(n in 1:mod){
    #     plot(1, type = "n", axes=FALSE, xlab="", ylab="")
    #  }
    #  }
    #for(n in )
    # plot(1, type = "n", axes=FALSE, xlab="", ylab="")
    #legend("top",
    # inset=c(-0.08,-0.08),#c(0.025*max(xlim),0.025*max(ylim)),
    #      legend = compProps$adductLabs, lty=1:length(compProps$adductLabs), lwd=2.5, col="black", bty="n",  cex=cx*0.7, horiz = T)
    #}
    
    
  }
  
  
  if(!is.null(compProps$pdfFile)){dev.off()}
}

#' EICplot
#' 
#' generate one EIC plot for multiple files
#' 
#' 
#' @param EIClistItem item from a list of EICs from Mosaic:multiEIC
#' @param ylim numeric(2) min and max visible rt value (in seconds)
#' @param xlim numeric(2) min and max visible intensity value (in seconds)
#' @param legendtext character() with item for each shown EIC for the plot legend
#' @param colr color range (actual vector of color values)
#' @param heading plot title
#' @param relto normalize intensities to this number
#' @param TIC if TRUE plot TIC
#' @param single TRUE if this is not part of a composite plot
#' @param midline numeric() of y-axis positions where a dotted vertical line should be plotted
#' @param lw line width for plot lines
#' @param yzoom zoom factor into y-axis
#' 
#' @export

EICplot <- function(EICs = sEICs$EIClist, cx = 1, 
                    ylim = c(0,max(unlist(EIClistItem[,'tic']))), 
                    xlim = c(min(unlist(EIClistItem[,'rt'])),
                             max(unlist(EIClistItem[,'rt'])))/60,
                    legendtext = paste(sub("^([^.]*).*", "\\1",basename(row.names(sEICs$EIClist[[1]])))),
                    colr = topo.colors(nrow(sEICs$EIClist[[1]]), alpha=1),
                    heading = "test",
                    relto = NULL,
                    TIC = F,
                    single = F,
                    midline = 100,
                    lw = 1,
                    yzoom = 1
){
  
  if(max(ylim)==0){ylim = c(0,1)}
  
  maxint <- format(max(ylim), digits =3, scientific = T)
  
  if(!is.null(relto) && relto != 1 ){
    maxint <- format(relto, digits =3, scientific = T)
  }
  
  if(is.null(relto)){relto <-1}
  
  if(!is.null(yzoom) && yzoom != 1 ){
    ylim[2] <- ylim[2]/yzoom
  }
  
  if(!is.null(relto) && relto != 1 ){ylim[2] <- (ylim[2]/relto)*100}
  
  PlotWindow(cx, 
             ylim, 
             xlim,
             heading,
             single,
             liwi = lw
  )
  
  if(length(midline)> 0 ){
    for(i in midline){
      abline(v=i/60, lty = 2, lwd = 1)
    }
  }
  
  ##draw the eics
  addLines(EIClist = EICs,
           TIC,
           colr,
           relto,
           liwi = lw
  )    
  #fix axis to not have gaps at edges
  abline(v=min(xlim), h=min(ylim))
  
  par(xpd=NA)
  text(min(xlim), 1.05*max(ylim),
       labels = maxint, bty="n",
       font = 2, cex=cx*1)
  
  if(!is.null(legendtext)){
    legend("topright",
           # inset=c(-0.08,-0.08),#c(0.025*max(xlim),0.025*max(ylim)),
           legend = legendtext, lty=1,lwd=2.5, col=colr, bty="n",  cex=cx*0.7)
  }
  
}



#' addLines
#'
#' Helper function for EICplot to plot the lines of EICs into a PlottingWindow. 
#' Mass shifts will be handled by plotting different line types
#' 
#' @param EIClist matrix or list of EIC objects (potentially subsetted)
#' @param TIC logical() if TRUE, TIC will be plotted instead of EIC
#' @param colr character() of color values for lines
#' @param relto if not NULL, intensities will be given as relative to this numeric(1)
#' @param liwi line width of plotted lines
#'
#' @export
addLines <- function(EIClist = EICsAdducts,
                     TIC = F,
                     colr = topo.colors(nrow(EIClistItem), alpha=1),
                     relto = NULL,
                     liwi = 2
){
  if(TIC){
    reps <- 1
  }else{
    reps <- length(EIClist)
  }
  
  for(n in 1:reps){
    if(TIC){
      int <- EIClist[[n]][,'tic']
    }else{
      int <- EIClist[[n]][,'intensity']
    }
    
    if(!is.null(relto) && relto != 1 ){int <- lapply(lapply(int,"/",relto),"*",100)
    maxint <- format(relto, digits =3, scientific = T)
    }
    
    #convert to minutes
    rts <- lapply(EIClist[[n]][,"rt"],"/",60)
    #  par(xpd=NA)
    # options(scipen=20)
    
    #colr <- topo.colors(2, alpha=1)#rainbow(length(eiccoll[[t]]), s = 1, v = 1, start = 0, end = max(1, length(eiccoll[[t]]) - 1)/length(eiccoll[[t]]), alpha = 0.7)#topo.colors(length(eiccoll[[t]]), alpha=1)
    
    ##draw the eics
    tmp <-mapply(lines, x= rts, y = int, col = as.list(colr), MoreArgs = list(lty = n, lwd = liwi))}
}


#' PlotWindow
#'
#' Initiate a plot and draw axes
#'
#' @param cx character expansion factor (font size)
#' @param ylim numeric(2) of y-axis range
#' @param xlim numeric(2) of x-axis range
#' @param heading heading of the plot
#' @param single if TRUE, this plot is expected to be the only plot in a composite (different margin settings)
#' @param par if FALSE, par margin settings are not set inside the function and should be set outside
#' @param xlab x axis label
#' @param ylab y axis label
#' @param relto show y axis values relative to relto if not NULL.
#' @param ysci if TRUE, y axis label numbers are shown in scientific format
#' @param textadj passed on to mtext adj for orientation of plot description/title text line
#'
#' @export
PlotWindow <- function(cx = 1, 
                       ylim = c(0,max(unlist(EIClistItem[,'tic']))), 
                       xlim = c(min(unlist(EIClistItem[,'rt'])),
                                max(unlist(EIClistItem[,'rt'])))/60,
                       heading = "test",
                       single = F,
                       par = T,
                       relto = NULL,
                       ylab = "Intensity",
                       xlab = "RT (min)",
                       ysci = T,
                       liwi = 1,
                       textadj = 0.5
                       
){
  
  if(max(ylim)==0){ylim = c(0,1)}
  
  if(par){
    if(single){
      par(#mfrow=c(1,2),
        #oma=c(0,2,0,0),
        mar = c(5.1,6,4.1,0),#oma causes issues in interactive mode
        # mai=c(0,0.5,0,0),
        xpd=FALSE,
        bg=NA,
        xaxs = "i", yaxs = "i"
      )  
    }else{
      par(#mfrow=c(1,2),
        # oma=c(0,2,0,0),
        # mai=c(0,0.5,0,0),
        xpd=FALSE,
        bg=NA,
        xaxs = "i", yaxs = "i"
      )
    }
  }
  
  plot(numeric(),numeric(), type= "n", 
       ylim = ylim,
       xlim = xlim,
       axes=F, ylab="",xlab="")
  
  
  pn <- if(max(ylim)==0){1}else{5}
  #x axis
  axis(side=1, lwd=liwi, lwd.ticks = liwi, at = pretty(xlim),
       labels = format(pretty(xlim), scientific = F),
       mgp=c(0,0.4*cx,0), cex.axis=1*cx, xaxs = "i")#x-axis mgp[2] controls distance of tick labels to axis
  
  mtext(side=1, text= xlab, line=1.5*(1+(cx-1)/2), cex=par("cex")*cx*1)
  
  if(!is.null(relto) && relto != 1 ){
    axis(side=2,  las=2, at = pretty(ylim, n =pn),
         labels = format(pretty(ylim, n =pn), scientific = F),
         mgp=c(0,0.6,0), cex.axis=1*cx, lwd = liwi, lwd.ticks = liwi)
    #axis labels
    mtext(side=2, text= ylab, line=4*(1+(cx-1)/1.7), cex=par("cex")*1*cx)
  }
  else{
    #y axis
    axis(side=2,  las=2, at = pretty(ylim, n =pn),
         labels = format(pretty(ylim, n =pn), scientific = ysci,digits = 3),
         mgp=c(0,0.6,0), cex.axis=1*cx, lwd = liwi, lwd.ticks = liwi)
    #axis labels
    mtext(side=2, text= ylab, line=4*(1+(cx-1)/1.7), cex=par("cex")*1*cx)
  }
  
  #fix axis to not have gaps at edges
  abline(v=min(xlim), h=min(ylim), lwd = liwi)
  
  Hmisc::minor.tick(nx=2, ny=2, tick.ratio=0.5, x.args = list(), y.args = list())
  
  title(main=heading, line=2, cex.main = cx, adj = textadj)
}

#' specplot
#' 
#' Plot an MS spectrum
#' 
#' @param x mz coordinates
#' @param y intensity coordinates
#' @param norm normalize by
#' @param cx font size
#' @param k top k intensity peaks will be labeled
#' @param fileName plot title
#' @param yrange y axis range
#' @param xrange x axis range
#' @param maxi max intensity to be plotted on side
#'
#' @importFrom TeachingDemos spread.labs
#' @importFrom Hmisc minor.tick
#' @export
specplot <- function (x=sc[,1],
                      y=sc[,2],
                      norm=max(y)/100,
                      cx=1.5,
                      k = 10,
                      fileName = "title",
                      yrange = c(0,100),
                      xrange = range(x),
                      maxi = max(y)
){
  
  pd <- data.frame(x=x,y=y/norm)  
  par(#oma=c(0,2,0,0), 
      mar = c(4,6,6,2),#changed mar[2] to 6 because oma was removed because of issues with interactive view
      xpd = FALSE, xaxs = "i", yaxs = "i")
  PlotWindow(cx, 
             ylim = yrange, 
             xlim = xrange,
             heading = fileName,
             single = T,
             par = F,
             relto = norm,
             ylab = "Relative Intensity (%)",
             xlab = "m/z", textadj = 1
  )
  
  points(pd$x,pd$y,type="h", bty="n")
  #, axes=F,lwd=0.8,
  #     main=fileName, cex.main=0.5*cx, ann=FALSE, ylab="Relative intensity", 
  #    xlab= expression(italic(m/z)), 
  #   xaxs="i",yaxs="i",
  #  xlim=xrange,
  # ylim=yrange,
  # ...)
  
  
  currview <- pd[which(pd$y <= max(yrange)
                       & pd$y >= min(yrange)
                       & pd$x <= max(xrange) 
                       & pd$x >= min(xrange)),]
  
  if (length(currview$y) >= k){
    kn <-  sort(currview$y, decreasing = T)[k]
    labs <- currview[which(currview$y>=kn),]
  }else{
    labs <- currview}
  
  if(nrow(labs) > 0 ){
    par(xpd=NA)
    labs$xcorr <- spread.labs(labs[,1],1.05*strwidth("A"), maxiter=1000, min=min(labs[,1]), max=max(labs[,1]))
    segments(labs[,1],labs[,2]+0.01*max(yrange),labs$xcorr,labs[,2]+0.05*max(yrange), col="red", lwd=0.8)
    text(labs$xcorr,labs[,2]+0.055*max(yrange),labels=round(labs[,1],5), col="blue3", srt=90,adj=c(0,0.3), cex=1*cx)
    text(min(xrange), 1.06*max(yrange),
         labels = format(maxi*(max(labs$y)/100), scientific = T, digits =4), bty="n",
         font = 2, cex=cx*1)
    
  }
  
  # mtext(side=1, text= expression(italic(m/z)), line=0.7, cex=0.5*cx)
  #  mtext(side=2, text="Relative intensity (%)", line=1.1, cex=0.5*cx)
  # mtext(side=1, text=fileName, line=1.2, cex=0.5*cx)
  #mtext(side=3, text=Ptext, line=0.6, cex=0.5, adj=1)
  #par(cex.axis=0.5*cx, tcl=-0.3)            
  #axis(side=1, lwd=1, minor.tick(nx=10,ny=5, tick.ratio=0.5), mgp=c(0.5,0,0)) #x-axis mgp[2] controls distance of tick labels to axis
  #axis(side=2, lwd=1, las=2, mgp=c(0.5,0.4,0)) #y-axis
}

#' mosaic.colors
#' 
#' custom color spectrum using color brewer Set1 colors plus topo.colors; good color discrimination up to n = 13
#' 
#' @param n number of colors
#' @param alpha transparency
#' 
#' @export
mosaic.colors<- function (n, alpha){
  
  alphahex <- as.hexmode(as.integer(alpha*255))
  if(nchar(alphahex) == 1){alphahex <- paste0("0",alphahex)}
  alphahex <- toupper(alphahex)
  base <- c("#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628","#F781BF","#999999","#1FFFB4","#000000")
  
  
  
  if(n<=11){
    return(paste0(base[1:n],alphahex))
  }else{
    add <- topo.colors(n = n-11, alpha = alpha)
    return(c(paste0(base[1:11],alphahex),add))
  }
  
  
}