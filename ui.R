library(shiny)

# Radio Buttons choice list (macro-variables)
rb_choices = list("Green" = 1, "Amber" = 2, "Red" = 3, "Danger!" = 4)
# Checkbox  button choice list (products)
prod_choices = c("Mortgage", "Lease",
                 "Consumer Loan", "Credit Card")

# Define UI for CapiTool App
shinyUI(fluidPage(

    # Sidebar with a slider input for the number of bins
    verticalLayout(
        # Application title
        titlePanel(list( tags$head(tags$style("body {background-color: white;")),
                         h1("CapiTool") ) ),

        #Tabs:  Projection - About
        tabsetPanel(type="pills",
            # Projection tab
            tabPanel("Projection",
                fluidRow(
                    column(8,plotOutput("capitalPlot")),
                    # Conditional panel for product breakdown
                    conditionalPanel("input.breakdown",
                                     column(4, h3("Product breakdown"),
                                            plotOutput("productsPlot"))
                 )
                )
            ),
            # About tab
            tabPanel("About", includeMarkdown("About.md"))
        ),


        # Input panel
        wellPanel(
            fluidRow(
                # Simulate button & product breakdown
                column(4, actionButton("goButton","Simulate!"),
                       checkboxInput("breakdown", "Breakdown Products", FALSE) ),
                conditionalPanel("input.breakdown", 
                                 column(8, checkboxGroupInput("products",
                                                              label=h4("Products"),
                                                              choices=prod_choices,
                                                              selected=prod_choices,
                                                              inline=TRUE))
                                 )
            ),
            # Macro-economic variables
            h4("Macro-economic scenario"),            
            column(2, radioButtons("GDP", label=h4("GDP"),
                                   choices = rb_choices, selected = 1) ),
            column(3, radioButtons("UER", label=h4("Unemployment Rate"),
                                   choices = rb_choices, selected = 1) ),
            column(3, radioButtons("CPI", label=h4("Consumer Price Index"),
                                   choices = rb_choices, selected = 1) ),
            column(2, radioButtons("HPI", label=h4("House Prices"), 
                                   choices = rb_choices, selected = 1) ),
            column(2, radioButtons("TRS", label=h4("Treasury Rates"),
                                   choices = rb_choices, selected = 1) ),

            #  Projection window slider
            hr(),
            br(),
            sliderInput("window", label=h4("Projection Window"),
                        min=2015, max=2017, value=2017)
        ),

        # Footer
        h5("by WillahScott - WiDo Stuff")
    )
))