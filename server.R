library(shiny)
library(ggplot2)

# Read simulation functions
source("simulation.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # Read projection window    
    windowRead <- reactive({
        # Take dependency on  action button
        input$goButton

        # Isolate slider, only update with action button
        isolate( project.years <- seq(2015, input$window))
        window.filter <- c("Now", sapply(project.years, as.character) )
    })
    
    # Read macrovariables
    macroRead <- reactive({
        # Take dependency on  action button
        input$goButton

        # Isolate radio buttons, only update with action button
        isolate( macro <- sapply( c(input$GDP, input$UER, input$CPI,
                                    input$HPA, input$TRS),
                                  as.numeric) )
    })

    simulationT <- reactive({
        # Generate simulation output dataset
        simulation <- data.frame(year=c("Now","Now"),
                                 Capital= c(get.k.vivo(k.vivo),
                                            get.k.moroso(k.moroso)),
                                 Status= c("Performing","Defaulted"))
        
        # Incorporate macro variables
        MACRO <- macroRead()
        
        # Calculate performing and defaulted capital
        k.v.2015 <- get.PD(k.vivo,MACRO)
        k.v.2015 <- get.LGD(k.v.2015,MACRO)
        k.m.2015 <- get.PD(k.moroso,MACRO)
        k.m.2015 <- get.LGD(k.m.2015,MACRO)
        
        k.v.2016 <- get.PD(k.v.2015,MACRO)
        k.v.2016 <- get.LGD(k.v.2016,MACRO)
        k.m.2016 <- get.PD(k.m.2015,MACRO)
        k.m.2016 <- get.LGD(k.m.2016,MACRO)
        
        k.v.2017 <- get.PD(k.v.2016,MACRO)
        k.v.2017 <- get.LGD(k.v.2017,MACRO)
        k.m.2017 <- get.PD(k.m.2016,MACRO)
        k.m.2017 <- get.LGD(k.m.2017,MACRO)
        
        # Generate  final output
        simulation <- rbind(simulation,
                            data.frame(year=c("2015","2015"), 
                                       Capital= c(get.k.vivo(k.v.2015),
                                                  get.k.moroso(k.m.2015) ),
                                       Status= c("Performing", "Defaulted")),
                            data.frame(year= c("2016","2016"),
                                       Capital= c(get.k.vivo(k.v.2016),
                                                  get.k.moroso(k.m.2016) ),
                                       Status= c("Performing", "Defaulted")),
                            data.frame(year=c("2017","2017"),
                                       Capital= c(get.k.vivo(k.v.2017),
                                                  get.k.moroso(k.m.2017) ),
                                       Status= c("Performing", "Defaulted")) ) 
    })

    simulationP <- reactive({ 
        # Generate product-wise simulation dataset
        got.vivo <- get.k.vivo(k.vivo, breakdown=T)
#         browser()
        simu.prods <- data.frame(year=rep("Now",8),
                                 Capital= c(got.vivo,
                                            get.k.moroso(k.moroso, breakdown=T)),
                                 Status= c(rep("Performing",4), rep("Defaulted",4)),
                                 Products= rep(names(got.vivo),2) )

        # Incorporate macro variables
        MACRO <- macroRead()

        # Calculate performing and defaulted capital
        k.v.2015 <- get.PD(k.vivo,MACRO)
        k.v.2015 <- get.LGD(k.v.2015,MACRO)
        k.m.2015 <- get.PD(k.moroso,MACRO)
        k.m.2015 <- get.LGD(k.m.2015,MACRO)

        k.v.2016 <- get.PD(k.v.2015,MACRO)
        k.v.2016 <- get.LGD(k.v.2016,MACRO)
        k.m.2016 <- get.PD(k.m.2015,MACRO)
        k.m.2016 <- get.LGD(k.m.2016,MACRO)

        k.v.2017 <- get.PD(k.v.2016,MACRO)
        k.v.2017 <- get.LGD(k.v.2017,MACRO)
        k.m.2017 <- get.PD(k.m.2016,MACRO)
        k.m.2017 <- get.LGD(k.m.2017,MACRO)

        # Generate  final output
        k.2015 <- get.k.vivo(k.v.2015, breakdown=T)
        k.2016 <- get.k.vivo(k.v.2016, breakdown=T)
        k.2017 <- get.k.vivo(k.v.2017, breakdown=T)

        simu.prods <- rbind(simu.prods,
                            data.frame(year=rep("2015",8),
                                       Capital= c(k.2015,
                                                  get.k.moroso(k.m.2015, breakdown=T)),
                                       Status= c(rep("Performing",4), rep("Defaulted",4)),
                                       Products= rep(names(k.2015),2) ),
                            data.frame(year=rep("2016",8),
                                       Capital= c(k.2016,
                                                  get.k.moroso(k.m.2016, breakdown=T)),
                                       Status= c(rep("Performing",4), rep("Defaulted",4)),
                                       Products= rep(names(k.2016),2) ),
                            data.frame(year=rep("2017",8),
                                       Capital= c(k.2017,
                                                  get.k.moroso(k.m.2017, breakdown=T)),
                                       Status= c(rep("Performing",4), rep("Defaulted",4)),
                                       Products= rep(names(k.2017),2) ) )
    })
    
    
    output$capitalPlot <- renderPlot({
        # Take dependency on  action button
        input$goButton
        
        simu <- simulationT()

        # Filter years
        window <- windowRead()
        data <- subset(simu, year %in% window)
        
#         browser()

        p <- ggplot(data, aes(x=year,y=Capital/1000000, fill=Status)) +
            geom_bar(colour= "black", stat="identity") +
            labs(x=NULL, y="Capital Requirements ($ Millions)")   
        print(p)
    })

output$productsPlot <- renderPlot({
    # Take dependency on  action button
    input$goButton
    
    simuP <- simulationP()

    # Filter years
    window <- windowRead()

    dataP <- subset(simuP, year %in% window)

    # Isolate checkbox group, only update with action button
    isolate( prods <- input$products )
    # Filter products
    if (length(prods) > 0){
        dataP <- subset(dataP, Products %in% prods)
    }
    
#     browser()
    
    p <- ggplot(dataP, aes(x=year,y=Capital/1000000, fill=Status)) +
        facet_grid(Products ~ ., scales="free") +
        geom_bar(colour= "black", stat="identity") +
        labs(x=NULL, y=NULL)   
    print(p)
    })

})