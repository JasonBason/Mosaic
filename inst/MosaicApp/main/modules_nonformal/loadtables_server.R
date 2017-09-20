
inputTable <- reactiveValues(df = NULL,
                             colrange = NULL, #columns in tablestuff$tablecut containing intensity values of interest
                             anagroupraw = NULL, #columnnames in tablestuff$tablecut containing intensity values of interest with their respective analysis group (dataframe)
                             tablename = NULL
                             )

#When Load Table button is pressed, initialize inputTable with defaults
 observeEvent(input$ldtbl,
              {inputTable$df <- read.csv(input$file1$datapath, header=input$header, sep=input$sep, 
                                               quote=input$quote, stringsAsFactors = F)
              inputTable$tablename <- input$file1$name
               if(length(grep("_XIC",colnames(inputTable$df)))==0){
                   inputTable$colrange <- 1
               }else{
                   inputTable$colrange <- grep("_XIC",colnames(inputTable$df))}
              
              inputTable$anagroupraw <- data.frame(Column=colnames(inputTable$df)[inputTable$colrange],
                                                 Group = rep("G1",(length(inputTable$colrange))),
                                                 stringsAsFactors = F)
                           })


####Render the preview table with first 10 rows of inputTable$df
output$preview <- renderRHandsontable({if(!is.null(inputTable$df)){
    rhandsontable(inputTable$df[1:10,], selectCallback = T)%>%
        hot_cols(renderer = "
                 function(instance, td, row, col, prop, value, cellProperties) {
                 Handsontable.TextCell.renderer.apply(this, arguments);
                 td.style.color = 'black';
                 }")
        #return td;
}
})


####Currently selected columns in preview rhandsontable
selcols <- reactive({ # sp<- strsplit("R1C1:R10C10",":")
    C1 <- as.integer(input$preview_select$select$c)#substr(sp[[1]][1],gregexpr("C",sp[[1]][1])[[1]][[1]]+1,nchar(sp[[1]][1])))
    C2 <- as.integer(input$preview_select$select$c2)#substr(sp[[1]][2],gregexpr("C",sp[[1]][2])[[1]][[1]]+1,nchar(sp[[1]][2])))
    rng <- C1:C2
    return(rng)
})


#output$importSettings <- renderUI ({
 # 
  #tagList(
   # selectizeInput('rtColSelect', label = "Retention Time column", choices = colnames(inputTable$df), selected = "rt")
    #selectizeInput('mzColSelect', label = "Retention Time column", choices = colnames(inputTable$df), selected = "rt")
    
  #)
  
#})

#' when pressing Select Columns button (intcols)
###Override default column range with selected columns when pressing Button intcols, and load new anagrouptable template
observeEvent(input$intcols,{inputTable$colrange <- selcols()
                            inputTable$anagroupraw <- data.frame(Column=colnames(inputTable$df)[inputTable$colrange],
                                                      Group = rep("G1",(length(inputTable$colrange))),
                                                      stringsAsFactors = F)
                            })


##### Render the current grouping table
output$anagrouping <- renderRHandsontable({if(!is.null(inputTable$anagroupraw)){
    rhandsontable(inputTable$anagroupraw)
}
})

######## Download current grouping table as shown
output$savegroups <- downloadHandler(filename= function(){paste("AnalysisGrouping.tsv")}, 
                                     content = function(file){write.table(hot_to_r(input$anagrouping)
                                                                          #colstuff$anagroupraw
                                                                          , file, sep = "\t", quote = F,
                                                                          row.names = F
                                                                          )},
                                     contentType = "text/tab-separated-values")

# onRestored(function(state){
#### Load grouping table from file
observeEvent(input$loadgroups$datapath,{inputTable$anagroupraw <- read.table(input$loadgroups$datapath, header=T, sep='\t', stringsAsFactors = F)})

### When the Groups are confirmed, generate a Mosaic Feature table object
### And also generate corresponding list objects

observeEvent(input$confgroups,{inputTable$anagroupraw <- if(input$anagroupswitch){data.frame(Column = as.character(hot_to_r(input$anagrouping)$Column),
                                                                  Group = as.character(hot_to_r(input$anagrouping)$Group), stringsAsFactors = F)}
                                                         else{NULL}

                               tabid <- paste0("table",length(featureTables$tables))
                               featureTables$tables[[tabid]] <- constructFeatureTable(inputTable$df,
                                                                                 mzcol= "mz", #column in df with mz values (columnname)
                                                                                 rtcol= "rt", #column in df with mz values (columnname)
                                                                                 commentcol = "comments",
                                                                                 fragmentcol = "fragments",
                                                                                 rtFormat = "sec", # "sec" or "min" 
                                                                                 anagrouptable = inputTable$anagroupraw,
                                                                                 tablename = inputTable$tablename,
                                                                                 editable = F)
                               featureTables$index <- updateFTIndex(featureTables$tables)
                               featureTables$active <- tabid
              })

##control whether buttons are clickable

observe({
    toggleState(id = "ldtbl", condition = !is.null(input$file1$datapath))
    toggleState(id = "confgroups", condition = !is.null(inputTable$df))
    #toggle(id = "intcols", condition = !is.null(inputTable$df))
    toggleState(id = "intcols", condition = !is.null(input$preview_select$select$c))
    toggle(id = 'anagrouping', condition = input$anagroupswitch)
    toggle(id = 'savegroups', condition = input$anagroupswitch)
    toggle(id = 'loadgroups', condition = input$anagroupswitch)
    
})