dashboardPage(skin = "black",
              dashboardHeader(title = "MOSAiC",
                              dropdownMenu(messageItem("Tip of the day", "Press F11 to enter/exit full screen mode.",
                                                            icon = shiny::icon("fullscreen", lib = "glyphicon"), 
                                                            href = NULL),
                                           type = c("messages"),
                                           badgeStatus = "primary", icon = NULL, headerText = NULL, .list = NULL)
                              ),
              dashboardSidebar(
                
                sidebarMenu(
                  useShinyjs(),
                  source(file.path("modules_nonformal", "background_ui.R"), local = TRUE)$value,
                     

                  menuItem("Data Explorer", tabName = "exploredata", icon = icon("area-chart")),
                  menuItem("XCMS analysis", tabName = "XCMSrunpanel", icon = icon("file-text-o")),
                  
                  menuItem("Workflows", tabName = "processdata", icon = icon("desktop"),
                            menuSubItem("Coming soon", tabName = "workflow1")),
                                    menuItem("Update / Help", tabName = "help", icon = icon("question-circle-o")),
                 
                  #bookmarkButton(label ="Bookmark this session"),
                  htmlOutput("activeTable"),
                  hr(),
                  h5(a(paste0("MOSAiC version ",packageVersion("Mosaic")), 
                     href="https://github.com/mjhelf/Mosaic", target="_blank"), align = "center")

                )
                
                
                
              ),
              dashboardBody(
                # Also add some custom CSS to make the title background area the same
                # color as the rest of the header.
                tags$head(tags$style(HTML('
                                          /* logo */
                                          .skin-black .main-header .logo {
                                          background-color: #C41230;
                                          color: #ffffff;
                                          }
                                          
                                          /* logo when hovered */
                                          .skin-black .main-header .logo:hover {
                                          background-color: #C41230;
                                          }
                                          
                                          /* navbar (rest of the header) */
                                          .skin-black .main-header .navbar {
                                          background-color: #C41230;
                                          color: #ffffff;
                                          }        
                                          
                                          /* main sidebar */
                                          .skin-black .main-sidebar {
                                          background-color: #595959;
                                          }

                                          /* background color in main window */
                                          .content-wrapper, .right-side {
                                          background-color: #A6A6A6;
                                          }
                                          
                                          /* active selected tab in the sidebarmenu */
                                          .skin-black .main-sidebar .sidebar .sidebar-menu .active a{
                                          background-color: #404040;
                                          color: #ffffff;
                                          }
                                          
                                          /* other links in the sidebarmenu */
                                          .skin-black .main-sidebar .sidebar .sidebar-menu a{
                                          background-color: #595959;
                                          color: #ffffff;
                                          }
                                          
                                          /* other links in the sidebarmenu when hovered */
                                          .skin-black .main-sidebar .sidebar .sidebar-menu a:hover{
                                          background-color: #404040;
                                          }

                                          /* toggle button  */                    
                                          .skin-black .main-header .navbar .sidebar-toggle{
                                          background-color: #C41230;
                                          color: #ffffff;
                                          }

                                          /* toggle button when hovered  */                    
                                          .skin-black .main-header .navbar .sidebar-toggle:hover{
                                          background-color: #595959;
                                          color: #ffffff;
                                          }


                                          
                                          
                                   .skin-black.box.box-solid.box-primary>.box-header {
                                color:#FFFFFF;
                                background-color:#C41230;}

                                .skin-black.box.box-solid.box-primary{
                                border-bottom-color:#C41230;
                                border-left-color:#C41230;
                                border-right-color:#C41230;
                                border-top-color:#C41230;
}

                                          /* color of sliver in selected tabs of tabBoxes */
                                          .nav-tabs-custom .nav-tabs li.active {
                                          border-top-color: #C41230;
                                          }

                                          /* removes padding for all column width 12 objects */
                                          div.col-sm-12 {
                                          padding: 0px;
                                          
                                          }


                                          div.col-sm-12 {
                                          padding: 0px;
                                          margin-bottom:-15px;
                                          margin-right: 0px;
                                          margin-left: 0px;
                                          }

                                          .box-body {
                                          padding-bottom: 0px;
                                          }
.shiny-plot-output {
margin-bottom: 0px;
}


                                          '))),
            tabItems(
                tabItem(tabName = "help",
                        source(file.path("modules_nonformal", "help_ui.R"), local = TRUE)$value
                ),
                
               # tabItem(tabName = "loadtables",
                #        source(file.path("modules_nonformal", "loadtables_ui.R"), local = TRUE)$value
                 #       ),
              #  tabItem(tabName = "rawfiles",
               #         source(file.path("modules_nonformal", "loadMSdata_ui.R"), local = TRUE)$value
                #),
                tabItem(tabName = "XCMSrunpanel",
                        source(system.file("MosaicApp", "xcmsRunner","modules_nonformal", "xcms_light_ui.R",package = "Mosaic"), local = TRUE)$value
                ),
                tabItem(tabName = "exploredata",
                        source(file.path("modules_nonformal", "exploreData_main_ui.R"), local = TRUE)$value
                ),
              tabItem(tabName = "workflow1",
                      p("In the making")
              )
            )


    
        )
        )