% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_param_txt.R
\name{get_param_txt}
\alias{get_param_txt}
\title{Read STICS input parameters from text files}
\usage{
get_param_txt(dirpath = getwd(), param = NULL, variety = NULL, ...)
}
\arguments{
\item{dirpath}{USM directory path}

\item{param}{Parameter name. Optional, if not provided, the function
return an object with all parameters}

\item{variety}{Either the variety name or index for plant parameters (optional, see details).}

\item{...}{Further arguments to pass (for future-proofing only).}
}
\value{
A parameter value, or if \code{param= NULL} a list of all parameters:
\item{ini}{Initialization parameters}
\item{general}{General parameters}
\item{tec}{Technical parameters}
\item{plant}{Plant parameters}
\item{soil}{Soil parameters}
\item{station}{Station parameters}
}
\description{
Read STICS model input parameters from a usm in text format (STICS input)
Generally used after calling building a usm with \code{JavaStics}.
}
\details{
If the \code{variety} is not given and a \code{param} is asked, the function will return the values
for the variety that is simulated in the USM by checking the \code{variete} parameter in the technical file.
If \code{param} is not provided by the user, the values from all varieties will be returned unless the user
ask for a given \code{variety}.
}
\note{
Users would generally use \code{get_param_txt} to identify parameters names and values and pass
them to other functions.
}
\examples{
# Read the interrow distance parameter:

\dontrun{
library(SticsRFiles)
path = get_examples_path( file_type = "txt" )
get_param_txt(path, param='interrang')

# Getting varietal values:

# Get the leaf lifespan of the variety used in the usm:
get_param_txt(dirpath = path, param = "durvieF") #0.29
# Get the leaf lifespan of another variety available in the plant file:
get_param_txt(dirpath = path, param = "durvieF", variety = "Nefer")
# To get the values for several (or all) varieties, either put all varieties:
varieties= c("Biensur","Acalou","Amarillo","Lloyd","Neodur","Nefer","Montseg")
get_param_txt(dirpath = path, param = "durvieF", variety = varieties)
# Or get it from the output of the function returning all parameters:
get_param_txt(dirpath = path)$plant$plant1$durvieF
}

}
\seealso{
\code{gen_varmod()},
}
