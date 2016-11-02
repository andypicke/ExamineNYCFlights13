#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
        
        # Application title
        titlePanel("nycflights13 data exploration"),
        
        # Sidebar with a slider input for number of bins 
        sidebarLayout(
                sidebarPanel(
                        selectInput(inputId = "airport",
                                    label = "select NYC airport:",
                                    choices = c("EWR", "LGA", "JFK"),
                                    selected = "LGA"),
                        selectInput(inputId = "month",
                                    label = "select month",
                                    choices = c(1:12),
                                    selected = "6"),
                        selectInput(inputId = "day",
                                    label = "select day",
                                    choices = c(1:31),
                                    selected = "15")
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        tabsetPanel(
                                tabPanel("Dep Delay Histogram", plotOutput("dep_delay_plot")),
                                tabPanel("Arr Delay Histogram", plotOutput("arr_delay_plot")),
                                tabPanel("Map", plotOutput("map_plot")),
                                tabPanel("Data",dataTableOutput('dtab'))
                        )
                )
        )
))
