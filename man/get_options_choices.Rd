% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_options_choices.R
\name{get_options_choices}
\alias{get_options_choices}
\title{Getting options parameter choices from an xml parameter file}
\usage{
get_options_choices(xml_file_path, options_names = NULL)
}
\arguments{
\item{xml_file_path}{path of xml parameter file}

\item{options_names}{options names to take into account (optional)}
}
\value{
A list of strings of options choice values
}
\description{
Extracting options choices values from an xml file data
}
\examples{
\dontrun{

xml_path = file.path(get_examples_path( file_type = "xml"),"file_plt.xml")

# For getting all options choices
SticsRFiles:::get_options_choices(xml_path)

# For getting one option choices or more
SticsRFiles:::get_options_choices(xml_path,"codetemp")
SticsRFiles:::get_options_choices(xml_path,c("codegdh", "codetemp"))
}

}
\keyword{internal}
