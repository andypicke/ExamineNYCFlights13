#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(nycflights13)
library(maps)

shinyServer(function(input, output) {
        
        # Filter flights based on input
        flights2 <- reactive({
                subset(flights,origin==input$airport & month==input$month & day==input$day)
                })
        
        # Render data table for selected flights
        output$dtab <- renderDataTable( flights2() )
        
        # make historam of departure delays
        output$dep_delay_plot <- renderPlot({
                hist(flights2()$dep_delay,
                     probability = TRUE,
                     xlab = "Delay (minutes)",
                     main = paste("delays for flights leaving",input$airport)
                )
                
        })
        
        # Make histogram of arrival delays 
        output$arr_delay_plot <- renderPlot({
                hist(flights2()$arr_delay,
                     probability = TRUE,
                     xlab = "Delay (minutes)",
                     main = paste("Arrival delays for flights leaving",input$airport)
                )
                
        })
        
        apnames<-reactive({unique(flights2()$dest)})
        airports2<-reactive({subset(airports,faa %in% apnames())})

                # Make map of airports and flights for selected input
        output$map_plot <- renderPlot({
                
                usa <- map_data("usa")
                states <- map_data("state")

                # Plot USA outline
                g<-ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill=NA, color="red") + coord_fixed(1.3) 
                
                # Plot states outlines
                g<-g+geom_polygon(data=states,aes(x = long, y = lat, group = group), fill="slategray",color = "white") + guides(fill=FALSE)  
                
                # Plot airport locations
                g2<-g+geom_point(data=airports2(),aes(x = lon, y = lat) )  # do this to leave off the color legend
                
                # Plot flight paths (just straight lines)
                
                # need to put data in a different format for this to work
                ig <- which(airports$faa==input$airport)
                orig_lat <- airports$lat[ig]
                orig_lon <- airports$lon[ig]
                dest_lon <-vector(mode="numeric",length=length(flights2()$dest) ) 
                dest_lat <-vector(mode="numeric",length=length(flights2()$dest) ) 
                
                for (i in seq_along(flights2()$dest)) {
                       igg <- which( flights2()$dest[i]==airports$faa )
#                       print(igg)
                       if (length(igg)>0){
                        dest_lon[i] <- airports$lon[igg]
                        dest_lat[i] <- airports$lat[igg]
                       }
                }
                
               flights3 <- cbind(flights2(),dest_lon,dest_lat)
              print( dim(flights3))
#                head(flights3)
               Npaths=length(flights3$dest_lon)
               print(Npaths)
               linedf <-data.frame(lons=vector(mode="numeric",length=Npaths*2),lats=vector(mode="numeric",length=Npaths*2), group=vector(mode="numeric",length=Npaths*2))
               for (i in seq(1,Npaths*2-1,by=2)){
                       linedf$lons[i]=orig_lon
                       linedf$lats[i]=orig_lat
               }
               
               whi<-1
               for (i in seq(2,Npaths*2,by=2)){
                       linedf$lons[i]=flights3$dest_lon[whi]
                       linedf$lats[i]=flights3$dest_lat[whi]
                       linedf$group[i]<-whi
                       linedf$group[i-1]<-whi
                       whi<-whi+1
               }
               
               
               g2 <- g2 + geom_line(data=linedf,aes(x=lons,y=lats,group=group),color="grey")+ guides(fill=FALSE)
               
#                g2 <- g2+ geom_line()
                g2
        })
        
        
        
})
