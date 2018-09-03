library(shiny)
library(ggplot2)
library(plotly)
library(optparse)

loadBenchmarks <- function(inFile) {
  benchs <- jsonlite::stream_in(file(inFile))
  return (benchs[order(benchs$timestamp),])
}

cli_options = list(
  make_option(c("-i", "--input"), type="character", default="benchs.json",
              help="File to load the bench results from [default= %default]",
              metavar="file"
              )
  )

opt_parser = OptionParser(option_list=cli_options)
opt = parse_args(opt_parser)
inputFile = opt$input

benchs <- loadBenchmarks(inputFile)
allBenchNames <- unique (benchs["bench_name"][,1])

ui <- fluidPage(
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
                    x = as.POSIXct(timestamp, origin="1970-01-01"),
                    y = time_in_nanos,
                    group=bench_name,
                    color=bench_name,
                    text=paste("commit:", commit_rev),
                )) +
                theme(axis.text.x = element_text(angle = 45)) +
                theme(plot.margin = unit(c(1,1,1,1), "cm")) +
                geom_line() +
                geom_point() +
                labs(x = "Date", y = "Mean time (ns)")
        } else {
            ggplot()
        }
    })
}

app <- shinyApp(ui, server)
runApp(app, launch.browser = F, host="0.0.0.0", port=8123)
