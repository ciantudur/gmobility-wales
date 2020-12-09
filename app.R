## -------------------------------------------------------------------------- ##
## Google Mobility Reports Shiny Web App - Wales ---------------------------- ##
## -------------------------------------------------------------------------- ##
## app.R
## 22 November 2020
## Cian Sion (SionC1@cardiff.ac.uk)



## REMARKS ---------------------------------------------------------------------
#  This web app produces user-friendly charts showing Google mobility data for
#  Wales and the UK.



## LOAD REQUIRED PACKAGES ------------------------------------------------------
library(shiny) # Web app framework
library(cowplot) # To add logo
library(ggplot2) # For charts
library(dplyr) # For data transformation
library(metathis) # For meta tags
library(shinycssloaders) # For loading animation on chart
library(fst) # For reading input data



## GLOBAL PARAMATERS -----------------------------------------------------------

# Read csv data
gd <- read.fst("google_data.fst")
google_data <- as.data.frame(gd)

# Convert column to date format
google_data$date <- as.Date(google_data$date)

# Set system locale
Sys.setlocale(category = "LC_ALL", locale = "english")

# Define relative font size for plot
geom.text.size <- 16
theme.size <- (9 / 12) * geom.text.size

# Set URL for Twitter Sharing button
url <- "https://twitter.com/intent/tweet?url=https://gmobility.wfa.cymru"



## DEFINE APPLICATION UI -------------------------------------------------------
ui <- fluidPage(

  # Meta tags for social media
  meta() %>%
    meta_social(
      title = "Wales Mobility Trends",
      description = "<meta> Explore the latest Google Mobility Trends for Wales",
      url = "https://gmobility.wfa.cymru",
      image = "https://cdn-images-1.medium.com/max/1200/1*SWYlxgSShBBtFeRSzGPTXg.png",
      image_alt = "An image for social meda cards",
      twitter_creator = "@ciantudur",
      twitter_card_type = "summary",
      twitter_site = "@ciantudur"
    ),


  # Title panel
  titlePanel(("Wales Mobility Trends")),

  # Sidebar with input form
  sidebarLayout(
    sidebarPanel(
      radioButtons("measure", "1. Choose a measure",
        choices = list(
          "Retail and recreation" = "retail_and_recreation_percent_change_from_baseline",
          "Grocery and pharmacy" = "grocery_and_pharmacy_percent_change_from_baseline",
          "Parks" = "parks_percent_change_from_baseline",
          "Transit stations" = "transit_stations_percent_change_from_baseline",
          "Workplaces" = "workplaces_percent_change_from_baseline",
          "Residential" = "residential_percent_change_from_baseline"
        ),
        selected = "retail_and_recreation_percent_change_from_baseline"
      ),

      selectInput("area1", "2. Select a country / local authority",
        choices = list(
          "Wales" = "Wales",
          "UK" = "UK",
          "Blaenau Gwent" = "Blaenau Gwent",
          "Bridgend" = "Bridgend",
          "Caerphilly" = "Caerphilly",
          "Cardiff" = "Cardiff",
          "Carmarthenshire" = "Carmarthenshire",
          "Ceredigion" = "Ceredigion",
          "Conwy" = "Conwy",
          "Denbighshire" = "Denbighshire",
          "Flintshire" = "Flintshire",
          "Gwynedd" = "Gwynedd",
          "Isle of Anglesey" = "Isle of Anglesey",
          "Merthyr Tydfil" = "Merthyr Tydfil",
          "Monmouthshire" = "Monmouthshire",
          "Neath Port Talbot" = "Neath Port Talbot",
          "Newport" = "Newport",
          "Pembrokeshire" = "Pembrokeshire",
          "Powys" = "Powys",
          "Rhondda Cynon Taf" = "Rhondda Cynon Taf",
          "Swansea" = "Swansea",
          "The Vale of Glamorgan" = "Vale of Glamorgan",
          "Torfaen" = "Torfaen",
          "Wrexham" = "Wrexham"
        ),
        selected = "Wales"
      ),

      selectInput("area2", "3. Select another country / local authority",
        choices = list(
          "Wales" = "Wales",
          "UK" = "UK",
          "Blaenau Gwent" = "Blaenau Gwent",
          "Bridgend" = "Bridgend",
          "Caerphilly" = "Caerphilly",
          "Cardiff" = "Cardiff",
          "Carmarthenshire" = "Carmarthenshire",
          "Ceredigion" = "Ceredigion",
          "Conwy" = "Conwy",
          "Denbighshire" = "Denbighshire",
          "Flintshire" = "Flintshire",
          "Gwynedd" = "Gwynedd",
          "Isle of Anglesey" = "Isle of Anglesey",
          "Merthyr Tydfil" = "Merthyr Tydfil",
          "Monmouthshire" = "Monmouthshire",
          "Neath Port Talbot" = "Neath Port Talbot",
          "Newport" = "Newport",
          "Pembrokeshire" = "Pembrokeshire",
          "Powys" = "Powys",
          "Rhondda Cynon Taf" = "Rhondda Cynon Taf",
          "Swansea" = "Swansea",
          "The Vale of Glamorgan" = "Vale of Glamorgan",
          "Torfaen" = "Torfaen",
          "Wrexham" = "Wrexham"
        ),
        selected = "UK"
      ),

      dateRangeInput("dateRange", "4. Specify a date range",
        min = min(google_data$date),
        max = max(google_data$date),
        start = min(google_data$date),
        end = max(google_data$date),
      )
    ),

    # Show a plot in main panel
    mainPanel(
      plotOutput("distPlot") %>% withSpinner(color = "#ce0538"),

      # Dowload button for charts
      tags$div(
        tags$br(),
        downloadButton("downloadPlot", "Download chart")
      ),


      # Share on Twitter button
      tags$div(
        tags$br(),
        tags$a(href = url, "Tweet", class = "twitter-share-button"),
        includeScript("http://platform.twitter.com/widgets.js")
      ),


      # Footer info
      tags$div(
        tags$br(),
        tags$a(href = "https://support.google.com/covid19-mobility/answer/9824897?hl=en&ref_topic=9822927", "How to interpret these results?"),
        tags$br(),
        tags$br(),
        "This web app (v1.1) was produced by the ", tags$a(href = "https://www.cardiff.ac.uk/wales-governance-centre/publications/finance", "Wales Fiscal Analysis (WFA)"),
        " team using ",
        tags$a(href = "https://shiny.rstudio.com/", "RShiny"), "- find the code and source data on ",
        tags$a(href = "https://github.com/ciantudur/gmobility-wales/", "GitHub"),
      ),


      # Warning messages for insufficient data / small geographies
      span(textOutput("caution"), style = "color:white"),
      span(textOutput("error"), style = "color:white")
    ),
  )
)



## DEFINE SERVER LOGIC ---------------------------------------------------------
server <- function(input, output) {
  vals <- reactiveValues()


  output$distPlot <- renderPlot({
    if (input$measure == "retail_and_recreation_percent_change_from_baseline") {
      lab <- "Retail and recreation"
    } else {
      if (input$measure == "grocery_and_pharmacy_percent_change_from_baseline") {
        lab <- "Grocery & pharmacy"
      } else {
        if (input$measure == "parks_percent_change_from_baseline") {
          lab <- "Parks"
        } else {
          if (input$measure == "transit_stations_percent_change_from_baseline") {
            lab <- "Transit stations"
          } else {
            if (input$measure == "workplaces_percent_change_from_baseline") {
              lab <- "Workplaces"
            } else {
              if (input$measure == "residential_percent_change_from_baseline") {
                lab <- "Residential"
              } else {
              }
            }
          }
        }
      }
    }

    filtered_data <- dplyr::filter(google_data, country == input$area1 |
      country == input$area2)
    if (input$area1 != input$area2) {
      filtered_data$country <- factor(filtered_data$country,
        levels = c(input$area1, input$area2)
      )
    } else {

    }

    # Draw chart
    gg <- ggplot(
      data = subset(filtered_data, !is.na(input$measure)),
      aes_string(
        x = "date", y = input$measure,
        group = "country",
        color = "country"
      )
    ) +
      geom_line(size = (1 / 20) * geom.text.size) +
      ylab("% of February baseline") +
      xlab("") +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
      scale_x_date(
        date_breaks = "1 month",
        date_minor_breaks = "1 month",
        date_labels = "%b",
        limits = c(input$dateRange[1], input$dateRange[2])
      ) +
      scale_color_manual(
        values = c("#ce0538", "#373737"),
        guide = guide_legend(reverse = FALSE)
      ) +
      theme_minimal() +
      theme(
        axis.text.x.bottom = element_text(
          angle = 0,
          hjust = 0.5,
          vjust = 0.5,
          size = theme.size
        ),
        axis.title.y = element_text(
          colour = "#373737",
          size = theme.size
        ),
        axis.text.y = element_text(size = theme.size),
        axis.text = element_text(color = "#373737"),
        legend.title = element_blank(),
        legend.text = element_text(size = theme.size),
        plot.title = element_text(face = "bold", size = geom.text.size),
        plot.subtitle = element_text(color = "#373737", size = theme.size),
        plot.caption = element_text(hjust = 0, size = (9 / 12) * geom.text.size)
      ) +
      labs(
        title = "Google Mobility Reports",
        subtitle = as.name(lab),
        caption = "Source: WFA analysis of Google LLC (2020) Google Covid-19 Community Mobility
             report. Data has been imputed and seasonally adjusted."
      )


    vals$gg <- gg
    print(gg)

    # Add logo
    gg2 <- ggdraw() +
      draw_image("wfalogob.png", x = 0.42, y = 0.44, scale = .13) +
      draw_plot(gg)

    vals$gg2 <- gg2
    print(gg2)
  })



  # Download plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste(input$measure, "_", input$area1, "_", input$area2, ".png", sep = "")
    },
    content = function(file) {
      png(file, width = 8, units = "in", res = 200, height = 4.5)
      print(vals$gg2)
      dev.off()
    }
  )



  # Caution for small geographies
  output$caution <- renderText({
    if (input$area1 == "Blaenau Gwent" |
      input$area1 == "Bridgend" |
      input$area1 == "Caerphilly" |
      input$area1 == "Cardiff" |
      input$area1 == "Carmarthenshire" |
      input$area1 == "Ceredigion" |
      input$area1 == "Conwy" |
      input$area1 == "Denbighshire" |
      input$area1 == "Flintshire" |
      input$area1 == "Gwynedd" |
      input$area1 == "Isle of Anglesey" |
      input$area1 == "Merthyr Tydfil" |
      input$area1 == "Monmouthshire" |
      input$area1 == "Neath Port Talbot" |
      input$area1 == "Newport" |
      input$area1 == "Pembrokeshire" |
      input$area1 == "Powys" |
      input$area1 == "Rhondda Cynon Taf" |
      input$area1 == "Swansea" |
      input$area1 == "Vale of Glamorgan" |
      input$area1 == "Torfaen" |
      input$area1 == "Wrexham" |
      input$area2 == "Blaenau Gwent" |
      input$area2 == "Bridgend" |
      input$area2 == "Caerphilly" |
      input$area2 == "Cardiff" |
      input$area2 == "Carmarthenshire" |
      input$area2 == "Ceredigion" |
      input$area2 == "Conwy" |
      input$area2 == "Denbighshire" |
      input$area2 == "Flintshire" |
      input$area2 == "Gwynedd" |
      input$area2 == "Isle of Anglesey" |
      input$area2 == "Merthyr Tydfil" |
      input$area2 == "Monmouthshire" |
      input$area2 == "Neath Port Talbot" |
      input$area2 == "Newport" |
      input$area2 == "Pembrokeshire" |
      input$area2 == "Powys" |
      input$area2 == "Rhondda Cynon Taf" |
      input$area2 == "Swansea" |
      input$area2 == "Vale of Glamorgan" |
      input$area2 == "Torfaen" |
      input$area2 == "Wrexham"
    ) {
      showNotification("Caution: The robustness of data for small geographies may vary", duration = 5, type = "warning")
    } else {

    }
  })

  # Error for insufficient data
  output$error <- reactive({
    if (input$measure == "retail_and_recreation_percent_change_from_baseline") {
      a <- 2
    } else {
      if (input$measure == "grocery_and_pharmacy_percent_change_from_baseline") {
        a <- 3
      } else {
        if (input$measure == "parks_percent_change_from_baseline") {
          a <- 4
        } else {
          if (input$measure == "transit_stations_percent_change_from_baseline") {
            a <- 5
          } else {
            if (input$measure == "workplaces_percent_change_from_baseline") {
              a <- 6
            } else {
              if (input$measure == "residential_percent_change_from_baseline") {
                a <- 7
              } else {
              }
            }
          }
        }
      }
    }

    filtered_data <- dplyr::filter(google_data, country == input$area1 |
      country == input$area2)

    if (all(!is.na(filtered_data[, a]))) {
    }
    else {
      showNotification("Error: One or more areas could not be plotted due to insufficient data", duration = 5, type = "error")
    }
  })
}



## RUN THE APPLICATION ---------------------------------------------------------
shinyApp(ui = ui, server = server)
