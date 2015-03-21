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

        isolate( project.years <- seq(2015, input$window))
        window.filter <- c("Now", sapply(project.years, as.character) )
    })
    
    # Read macrovariables
    macroRead <- reactive({
        # Take dependency on  action button
        input$goButton

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
        k.v.2014 <- get.PD(k.vivo,MACRO)
        k.v.2014 <- get.LGD(k.v.2014,MACRO)
        k.m.2014 <- get.PD(k.moroso,MACRO)
        k.m.2014 <- get.LGD(k.m.2014,MACRO)
        
        k.v.2015 <- get.PD(k.v.2014,MACRO)
        k.v.2015 <- get.LGD(k.v.2015,MACRO)
        k.m.2015 <- get.PD(k.m.2014,MACRO)
        k.m.2015 <- get.LGD(k.m.2015,MACRO)
        
        k.v.2016 <- get.PD(k.v.2015,MACRO)
        k.v.2016 <- get.LGD(k.v.2016,MACRO)
        k.m.2016 <- get.PD(k.m.2015,MACRO)
        k.m.2016 <- get.LGD(k.m.2016,MACRO)
        
        # Generate  final output
        simulation <- rbind(simulation,
                            data.frame(year=c("2015","2015"), 
                                       Capital= c(get.k.vivo(k.v.2014),
                                                  get.k.moroso(k.m.2014) ),
                                       Status= c("Performing", "Defaulted")),
                            data.frame(year= c("2016","2016"),
                                       Capital= c(get.k.vivo(k.v.2015),
                                                  get.k.moroso(k.m.2015) ),
                                       Status= c("Performing", "Defaulted")),
                            data.frame(year=c("2017","2017"),
                                       Capital= c(get.k.vivo(k.v.2016),
                                                  get.k.moroso(k.m.2016) ),
                                       Status= c("Performing", "Defaulted")) )        
    })

    simulationP <- reactive({ 
        # Generate product-wise simulation dataset
        simu.prods <- data.frame(year=c("Now","Now"),
                                 Capital= c(get.k.vivo(k.vivo, breakdown=T),
                                            get.k.moroso(k.moroso, breakdown=T)),
                                 Status= c("Performing", "Defaulted"))

        # Incorporate macro variables
        MACRO <- macroRead()

        # Calculate performing and defaulted capital
        k.v.2014 <- get.PD(k.vivo,MACRO)
        k.v.2014 <- get.LGD(k.v.2014,MACRO)
        k.m.2014 <- get.PD(k.moroso,MACRO)
        k.m.2014 <- get.LGD(k.m.2014,MACRO)

        k.v.2015 <- get.PD(k.v.2014,MACRO)
        k.v.2015 <- get.LGD(k.v.2015,MACRO)
        k.m.2015 <- get.PD(k.m.2014,MACRO)
        k.m.2015 <- get.LGD(k.m.2015,MACRO)

        k.v.2016 <- get.PD(k.v.2015,MACRO)
        k.v.2016 <- get.LGD(k.v.2016,MACRO)
        k.m.2016 <- get.PD(k.m.2015,MACRO)
        k.m.2016 <- get.LGD(k.m.2016,MACRO)

        # Generate  final output
        simu.prods <- data.frame(year=c("Now","Now"),
                                 Capital= c(get.k.vivo(k.vivo, breakdown=T),
                                            get.k.moroso(k.moroso, breakdown=T)),
                                 Status= c("Performing", "Defaulted"))
    })
    
    
    output$capitalPlot <- renderPlot({
        # Take dependency on  action button
        input$goButton
        
        simu <- simulationT()
        
        # Filter years
        window <- windowRead()
        data <- subset(simu, year %in% window)

#     browser()

        p <- ggplot(data, aes(x=year,y=Capital/1000000, fill=Status)) +
            geom_bar(colour= "black", stat="identity") +
            labs(x=NULL, y="Capital Requirements ($ Millions)")   
        print(p)
    })

output$productsPlot <- renderPlot({
    # Filter years
    windorF <- windowRead()
    
    p <- ggplot(simulationP(), aes(x=year,y=Capital/1000000, fill=Status)) +
        geom_bar(colour= "black", stat="identity") +
        labs(x=NULL, y="Capital Requirements ($ Millions)")   
    print(p)
    })

})