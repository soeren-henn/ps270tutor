# `ps270tutor` Interactive Tutorials for Quantitative Social Science

This package contains [`learnr`](https://rstudio.github.io/learnr/index.html) for [PS 270](https://canvas.wisc.edu/courses/420318) at University of Wisconsin-Madison and is building upon Matthew Blackwell's Gov50 course at Harvard University which is loosely based on [*Quantitative Social Science: An Introduction*](http://qss.princeton.press/) by [Kosuke Imai](https://imai.fas.harvard.edu/) from Princeton University Press. To install this package, first install its dependencies:

``` r
remotes::install_github("kosukeimai/qss-package", build_vignettes = TRUE)
remotes::install_github("rstudio/learnr")
remotes::install_github("rstudio-education/gradethis")
remotes::install_github("soeren-henn/ps270tutor")
```

Then you can start the tutorials in one of two ways. First, in RStudio 1.3 or later, you will find the tutorials listed in the "Tutorial" tab in the top-right pane (by default). Find a tutorial and click "Run Tutorial" to get started. Second, you can run any tutorial from the R console by typing the following line: 

``` r
learnr::run_tutorial("01-r-basics-data-viz", package = "ps270tutor")
```

This should bring up a tutorial in your default web browser. 

## Submission Reports

At the end of each tutorial, students can download submission reports that describe what questions and exercises they attempted. Students can then upload these PDFs to a learning management system like Canvas or Gradescope. 

