#' Convert to an RTF document
#'
#' Format for converting from R Markdown to an RTF document.
#'
#' See the \href{https://rmarkdown.rstudio.com/rtf_document_format.html}{online
#' documentation} for additional details on using the \code{rtf_document} format.
#'
#' R Markdown documents can have optional metadata that is used to generate a
#' document header that includes the title, author, and date. For more details
#' see the documentation on R Markdown \link[=rmd_metadata]{metadata}.
#'
#' R Markdown documents also support citations. You can find more information on
#' the markdown syntax for citations in the
#' \href{https://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html}{Bibliographies
#' and Citations} article in the online documentation.
#' @inheritParams pdf_document
#' @inheritParams html_document
#' @inheritParams word_document
#' @return R Markdown output format to pass to \code{\link{render}}
#' @examples
#' \dontrun{
#'
#' library(rmarkdown)
#'
#' # simple invocation
#' render("input.Rmd", rtf_document())
#'
#' # specify table of contents option
#' render("input.Rmd", rtf_document(toc = TRUE))
#' }
#' @export
rtf_document <- function(toc = FALSE,
                         toc_depth = 3,
                         fig_width = 5,
                         fig_height = 4,
                         keep_md = FALSE,
                         md_extensions = NULL,
                         pandoc_args = NULL) {

  # knitr options and hooks
  knitr <- knitr_options(
    opts_chunk = list(dev = 'png',
                      dpi = 96,
                      fig.width = fig_width,
                      fig.height = fig_height)
  )

  # build pandoc args
  args <- c("--standalone")

  # table of contents
  args <- c(args, pandoc_toc_args(toc, toc_depth))

  # pandoc args
  args <- c(args, pandoc_args)

  preserved_chunks <- character()

  pre_processor <- function(metadata, input_file, runtime, knit_meta,
                             files_dir, output_dir) {
    preserved_chunks <<- extract_preserve_chunks(input_file, knitr::extract_raw_output)
    NULL
  }

  post_processor <- function(metadata, input_file, output_file, clean, verbose) {
    output_str <- readLines(output_file, encoding = 'UTF-8')
    output_res <- knitr::restore_raw_output(output_str, preserved_chunks)
    if (!identical(output_str, output_res))
      writeLines(enc2utf8(output_res), output_file, useBytes = TRUE)
    output_file
  }

  # return output format
  output_format(
    knitr = knitr,
    pandoc = pandoc_options(to = "rtf",
                            from = from_rmarkdown(extensions = md_extensions),
                            args = args),
    keep_md = keep_md,
    pre_processor = pre_processor,
    post_processor = post_processor
  )
}
