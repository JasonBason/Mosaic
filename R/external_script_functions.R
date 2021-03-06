#' writeStatus
#' 
#' Write or update a status dataframe with custom messages, time stamp and time elapsed since last status. Useful to document time consumed analysis by steps.
#' 
#' @param previous a writeStatus object to be updated (must have same column names); new object generated if NULL.
#' @param message named list of columns with custom messages
#' @param wd directory where the status.csv file should be written and updated. If NULL, no status.csv is written.
#' 
#' @examples 
#' 
#' status <- writeStatus(previous = NULL,
#'             message = list(Status = "Starting analysis",
#'                            Details = "loading files"
#'                           ),
#'            wd = getwd())
#'            
#'            
#' status <- writeStatus(previous = status,
#'             message = list(Status = "Running analysis",
#'                            Details = "detecting features"
#'                           ),
#'            wd = getwd())
#' 
#' @export
writeStatus <- function(previous = NULL,
                        message = list(Status = "Starting analysis",
                                       Details = "loading files"
                                       ),
                        wd = getwd()
                        ){
  if(is.null(previous)){
    history <- data.frame(Time = strftime(Sys.time(),"%Y%m%d_%H%M%S"),
                          Status = message$Status,
                          Details = message$Details,
                          elapsed_time = 0,
                          stringsAsFactors = F
    )
    
    for(i in names(message)){
      history[[i]] <- as.character(message[[i]])
    }
    
    pt1 <- proc.time()
    
    if(!is.null(wd)){
    write.csv(history,file = file.path(wd,"status.csv"))}
    
  return(list(pt = pt1,
              status = history))
    }
  
  #If there is a previous input, update the status
  pt1 <- proc.time() - previous$pt
  previous$status[1,"elapsed_time"] <- pt1[3]
  pt1 <- proc.time()
  
  history <- rbind(data.frame(Time = strftime(Sys.time(),"%Y%m%d_%H%M%S"),
                             Status = message$Status,
                             Details = message$Details,
                             elapsed_time = 0,
                             stringsAsFactors = F
                             ),
                              previous$status)
  
  write.csv(history,file = file.path(wd,"status.csv"))
  
  return(list(pt = pt1,
              status = history)
         )
}


#' savetable
#' 
#' Write or update a status dataframe with custom messages, time stamp and time elapsed since last status. Useful to document time consumed analysis by steps.
#' 
#' @param xset an xcms::XCMSnExp, xcms::xcmsSet or xcms::xsAnnotate object from which to extract the peaklist
#' @param status a writeStatus object to be modified and returned by the function.
#' @param fill xcms::FillChromPeaksParam object to specify how to fill peaks (only works if xset is an XCMSnExp object). No peak filling if NULL.
#' @param nonfill also write the non-filled peaktable data? TRUE or FALSE
#' @param filename filename to use when writing the csv file (including file extension). "_filled" will be added for filled data.
#' @param bparams BBPARAMs (BiocParallel::BiocParallelParam object with parameters for parallel computing used in fill peaks)
#' @param intensities list of parameters for Mosaic EIC intensity extraction (for each feature in the peaklist). ppm: mz window, rtw: rt window (+/- seconds), rtrange: if TRUE, rtw extends from rtmin and rtmax, if FALSE rtw centers around value in column rt. Not performed if intensities = NULL.
#' @param rawdata named list of xcmsRaw objects (as returned by Mosaic::loadRawM), required for Mosaic EIC intensity extraction which is not performed if NULL.
#' @param saveR save the xset object as .Rdata file
#'  
#' @export
savetable <- function(xset,
                      status = NULL,
                      fill = FillChromPeaksParam(expandMz = 0.005, expandRt = 5, ppm = 3),
                      nonfill = F,
                      filename = "tableoutxx.csv",
                      bparams = SnowParam(workers = 1),
                      intensities = list(ppm = 5,
                                         rtw = 5,
                                         rtrange = T),
                      rawdata = NULL,
                      saveR = T){
  
  if(is.null(fill) & !nonfill){return(status)}
  
  
  
  
  
  if(!is.null(status)){
   status <- writeStatus (previous = status,
                           message = list(Status = paste0("Saving table ", filename),
                                         Details = "Extracting peaktable"))
  }
  
  if(class(xset) == "xsAnnotate"){
    tb <- getPeaklist(xset)}
  else{
    tb <- peakTable(as(xset,"xcmsSet"))
  }
      #set NAs to 0 (mostly important if !fill)
    tb[is.na(tb)]<-0
    

    
    if(!is.null(intensities) & !is.null(rawdata)){
         
       if(!is.null(status)){
      status <- writeStatus (previous = status,
                              message = list(Status = paste0("Saving table ", filename),
                                             Details = "Getting Mosaic intensities"))
       }
      
  rtx <-  rtexport(xset)    
  
 rta <- rtadjust(rtx, # XCMSnExp, xcmsSet or xsAnnotate object
                      tb[,c("rt","rtmin","rtmax")])
 
 intens <- data.frame(pholder = numeric(nrow(tb)))
 
      for(i in 1:length(rawdata)){
        if(intensities$rtrange){
        rtwin <- data.frame(rtmin = rta[[i]]$rtmin-intensities$rtw,
                            rtmax = rta[[i]]$rtmax+intensities$rtw)
        rtwin[rtwin < 0]<-0
        }else{
          rtwin <- data.frame(rtmin = rta[[i]]$rt-intensities$rtw,
                              rtmax = rta[[i]]$rt+intensities$rtw)
          rtwin[rtwin < 0]<-0
        }
        
        intens[[paste0(basename(names(rawdata)[i]),"__XIC")]] <- exIntensities(rawfile= rawdata[[i]],
                                                               mz = tb$mz,
                                                               ppm=intensities$ppm,
                                                               rtw= rtwin
                                                               )
      }
 intens <- intens[,which(colnames(intens) != "pholder")]
    }
  if(nonfill){
    
    if(!is.null(intens)){
    tb <- cbind(tb,intens) } 

    if(!is.null(status)){
      status <- writeStatus (previous = status,
                              message = list(Status = paste0("Saving table ", filename),
                                             Details = "Writing file"))
    }
    write.csv(tb, file = filename)
    if(saveR){save(xset,file = paste0(filename,".Rdata"))}    
    
  }
  
    if(!is.null(fill) & class(xset) == "XCMSnExp"){
      
      if(!is.null(status)){
        status <- writeStatus (previous = status,
                                message = list(Status = paste0("Saving table ", filename),
                                               Details = "Filling peaks (xcms fillChromPeaks)"))
      }
      
      fparam = fill
      xset <- fillChromPeaks(xset, fparam,
                             BPPARAM = bparams)
      
      tbf <- peakTable(as(xset,"xcmsSet"))
    
    #set NAs to 0 (mostly important if !fill)
      tbf[is.na(tbf)]<-0
      
      if(!is.null(intens)){
        tbf <- cbind(tbf,intens) } 
      
    
 
    fn <- unlist(strsplit(filename, split="\\."))
    if(length(fn)==1){fn <- paste0(fn,"_filled")}
    else{
    fn <-  paste(paste0(paste(fn[1:(length(fn)-1)], collapse = "."),"_filled"),fn[length(fn)], sep = ".", collapse = NULL)
    }
    
    if(!is.null(status)){
      status <- writeStatus (previous = status,
                              message = list(Status = paste0("Saving table ", fn),
                                             Details = "Writing file"))
    }
    
    write.csv(tbf, file = fn)
    if(saveR){save(xset,file = paste0(fn,".Rdata"))}
  }
  return(status)
}