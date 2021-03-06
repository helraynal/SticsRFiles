% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gen_varmod.R
\name{gen_varmod}
\alias{gen_varmod}
\title{Generating a var.mod type file}
\usage{
gen_varmod(
  workspace,
  var_names,
  append = FALSE,
  file_name = "var.mod",
  version = "last",
  force = FALSE
)
}
\arguments{
\item{workspace}{Stics or JavaStics workspace path}

\item{var_names}{vector of variables names (see details)}

\item{append}{Boolean. Append to existing file ?}

\item{file_name}{file name to generate (default value: "var.mod")}

\item{version}{The version of the STICS model used (used to control the variable names)}

\item{force}{Force the variable writing even if the variable is not a STICS variable.}
}
\value{
Nothing. Writes to a file.
}
\description{
Generating a daily variable list file from variables names
}
\details{
The variable names can be found using \code{get_var_info()}. The variable names are
checked before writting. If any variable names does not exist, the function will still write the
variables that exist, but not the variable that does not exist, unless \code{force= TRUE}
}
\examples{
\dontrun{
 gen_varmod(".", c("lai(n)","hauteur"))
 gen_varmod("/path/to/stics/workspace", c("lai(n)","hauteur"))
 # Add a variable to the others:
 gen_varmod(., "masec(n)", add= TRUE)
 # NB: var.mod will have "lai(n)","hauteur" and "masec(n)"
}

}
