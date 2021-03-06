% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/set_codeoptim.R
\name{set_codeoptim}
\alias{set_codeoptim}
\title{Set codoptim}
\usage{
set_codeoptim(workspace, value = 1, file_name = "new_travail.usm")
}
\arguments{
\item{workspace}{Path of the Stics inputs files of an usm}

\item{value}{Value of the codeoptim parameter (1 = activating
parameters values forcing)}

\item{file_name}{Name of the file}
}
\description{
Change value of codeoptim in the new_travail.usm file
}
\examples{
\dontrun{

ws <- "path/to/stics/workspace"
SticsRFiles:::set_codoptim(workspace = ws, value = 0)

}


}
