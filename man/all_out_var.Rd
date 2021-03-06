% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_out_var.R
\name{all_out_var}
\alias{all_out_var}
\title{Return all possible STICS outputs for var.mod}
\usage{
all_out_var(version = "last")
}
\arguments{
\item{version}{The stics version. See \code{get_stics_versions_compat()} to get all compatible versions. Default
to "last", a special code to get the last version.}
}
\description{
Helper function to print the list of all possible variables to set as output
from the STICS model.
}
\examples{
\dontrun{
 all_out_var()
}
}
\seealso{
\code{get_var_info()}, \code{gen_varmod()}, and \code{get_stics_versions_compat()}
}
\keyword{internal}
