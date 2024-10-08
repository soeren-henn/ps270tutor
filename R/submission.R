#' @title Tutorial submission functions
#'
#' @description The following function has modified from Colin Rundel's
#'   learnrhash package, available at https://github.com/rundel/learnrhash. Many
#'   thanks to Professor Rundel, who has developed a fantastic tool for courses
#'   that teach R and use the learnr package.
#'
#'   This note is also modified from Professor Rundel's description: Note that
#'   when including these functions in a learnr Rmd document it is necessary
#'   that the server function, `submission_server()`, be included in an R chunk
#'   where `context="server"`. Conversely, any of the ui functions, `*_ui()`,
#'   must *not* be included in an R chunk with a `context`.
#'
#'   WARNING: This function requires a global variable, `tut_reptitle` to be
#'   defined containing the title of the output report.  It also hard-codes the
#'   package name and expects the path `tutorials/tutorial-report.Rmd` within
#'   that package.
#'
#' @rdname submission_functions
#' @export
submission_server <- function(input, output) {
  p <- parent.frame()
  check_server_context(p)

  # Evaluate in parent frame to get input, output, and session
  local({
    build_report <- function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "tutorial-report.Rmd")
      tut_rep_path <- file.path(path.package("ps270tutor"),
                                "tutorials",
                                "tutorial-report.Rmd")
      file.copy(tut_rep_path, tempReport, overwrite = TRUE)


      # Set up parameters to pass to Rmd document
      objs <- learnr:::get_all_state_objects(session)
      skips <- learnr:::section_skipped_progress_from_state_objects(objs)
      subs <- learnr:::submissions_from_state_objects(objs)
      ##browser()
      out <- tibble::tibble(
        id = purrr::map_chr(subs, "id"),
        answers = purrr::map_chr(subs, list("data", "answer"),
                                 .default = NA),
        checked = purrr::map_lgl(subs, list("data", "checked"),
                                 .default = NA),
        correct = purrr::map_lgl(subs, list("data", "feedback", "correct"),
                                 .default = NA)
      )
      out$attempted <- !is.na(out$answers) | out$checked
      params <- list(reporttitle = tut_reptitle,
                     output = out,
                     student_name = input$name,
                     skipped = length(skips))

      ext <- tools::file_ext(file)
      out_format <- switch(ext, pdf = "pdf_document", html = "html_document")

      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(
        tempReport,
        output_format = out_format,
        output_file = file,
        params = params,
        envir = new.env(parent = globalenv())
      )
    }
    output$download_pdf <- downloadHandler(
      filename = "report.pdf",
      content = build_report
    )

    output$download_html <- downloadHandler(
      filename = "report.html",
      content = build_report
    )
  }, envir = p)
}

check_server_context <- function(.envir) {
  if (!is_server_context(.envir)) {
    calling_func <- deparse(sys.calls()[[sys.nframe() - 1]])

    err <- paste0(
      "Function `", calling_func, "`",
      " must be called from an Rmd chunk where `context = \"server\"`"
    )

    stop(err, call. = FALSE)
  }
}

is_server_context <- function(.envir) {
  # We are in the server context if there are the follow:
  # * input - input reactive values
  # * output - shiny output
  # * session - shiny session
  #
  # Check context by examining the class of each of these.
  # If any is missing then it will be a NULL which will fail.

  inherits(.envir$input,   "reactivevalues") &
    inherits(.envir$output,  "shinyoutput")    &
    inherits(.envir$session, "ShinySession")
}

#' @rdname submission_functions
#' @export
submission_ui <- shiny::div(
  "When you have completed this tutorial, follow these steps:",
  shiny::tags$br(),
  shiny::tags$ol(
    shiny::tags$li("Enter your name into the text box below."),
    shiny::tags$li("Click the Download button next to generate a report PDF with a summary of your work. "),
    shiny::tags$li("Upload this file to the appropriate assignment on Gradescope.")),
  shiny::textInput("name", "Your Name"),
  shiny::downloadButton(outputId = "download_pdf", label = "Download PDF"),
  shiny::downloadButton(outputId = "download_html", label = "Download HTML (backup)")
)

utils::globalVariables(c("input", "session", "download_report"))
