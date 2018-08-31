library(shiny)
library(ggplot2)
library(plotly)

loadBenchmarks <- function(inFile) {
  benchs <- jsonlite::stream_in(file(inFile))
  return (benchs[order(benchs$timestamp),])
}

args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
    inputFile = "benchs.json"
} else {
    inputFile = args[1]
}

benchs <- loadBenchmarks(inputFile)
allBenchNames <- unique (benchs["bench_name"][,1])

ui <- fluidPage(

  # App title ----
  titlePanel("Simwork benchmarks"),

  sidebarLayout (
      sidebarPanel(
          shinyWidgets::pickerInput(
              "enabledBenchmarkNames",
              "Enabled benchmarks",
              allBenchNames,
              multiple = TRUE,
              options = list(
                  `actions-box` = TRUE,
                  `live-search` = TRUE,
                  `liveSearchNormalize` = TRUE
              ),
          )
      ),
      mainPanel(
          plotlyOutput(outputId = "plot", height="100%")

      )
  )
)

server <- function(input, output) {
    output$plot <- renderPlotly ({
        enabledBenchmarkNames <- input$enabledBenchmarkNames
        displayedBenchs = benchs[benchs$bench_name %in% enabledBenchmarkNames, ]
        if (length(enabledBenchmarkNames) > 0) {
            ggplot(
                displayedBenchs,
                aes(
                    commit_rev,
                    time_in_nanos,
                    group=bench_name,
                    color=bench_name
                )) +
                theme(axis.text.x = element_text(angle = 45)) +
                theme(plot.margin = unit(c(1,1,1,1), "cm")) +
                geom_line() +
                geom_point()
        } else {
            ggplot()
        }
    })
}

app <- shinyApp(ui, server)
runApp(app, launch.browser = F, host="0.0.0.0", port=8123)
