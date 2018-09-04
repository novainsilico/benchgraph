library(shiny)
library(ggplot2)
library(plotly)
library(optparse)
library(purrr)

loadBenchmarksFromFile <- function(inFile) {
  tryCatch ({
    benchs <- jsonlite::stream_in(file(inFile))
    return (benchs[order(benchs$timestamp),])
  }, error = function(error) {
    print(error)
    return (data.frame())
  })
}

loadBenchmarks = function(inPaths) {
  allSubBenchs <- list()
  for (inPath in inPaths) {
    fileInfo <- file.info(inPath)
    if (fileInfo$isdir == TRUE) {
      childFiles <- map(list.files(inPath), function(x) { file.path(inPath, x) })
      thisBenches <- loadBenchmarks(childFiles)
    } else {
      thisBenches <- loadBenchmarksFromFile(inPath)
    }
    if (length(thisBenches) != 0) {
      allSubBenchs <- rbind(allSubBenchs, thisBenches)
    }
  }
  allSubBenchs
}

cli_options = list(
  make_option(c("-n", "--name"), type="character", default="My Shiny Benches",
              help="Name of the application",
              )
  )

opt_parser = OptionParser(
  option_list=cli_options,
  usage = "%prog [options] file1 ... fileN",
  description = "Serves a graph from the benchmark results given as input"
)
opt = parse_args(opt_parser, positional_arguments=c(0,Inf))
inputFile = opt$input

benchs <- loadBenchmarks(opt$args)
allBenchNames <- unique (benchs["bench_name"][,1])

ui <- fluidPage(
  titlePanel(opt$name),

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

server <- function(input, output, session) {
    output$plot <- renderPlotly ({
        query <- parseQueryString(session$clientData$url_search)
        if (exists("reload", where=query)) {
          benchs <- loadBenchmarks(inputFile)
        } else if (exists("exit", where=query)) {
          stopApp()
        }
        enabledBenchmarkNames <- input$enabledBenchmarkNames
        displayedBenchs = benchs[benchs$bench_name %in% enabledBenchmarkNames, ]
        if (length(enabledBenchmarkNames) > 0) {
            ggplot(
                displayedBenchs,
                aes(
                    x = as.POSIXct(timestamp, origin="1970-01-01", tz = "GMT"),
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
