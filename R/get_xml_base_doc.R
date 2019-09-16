#' @title Get an xmlDocument from a Stics xml file template
#' @param xml_type xml file type (see types returned when calling get_xml_base_doc())
#'
#' @param stics_version the stics files version to use
#'
#' @return an xmlDocument object
#'
#' @export
get_xml_base_doc <- function(xml_type = NULL,
                             stics_version = "last") {

  # types list
  types <- c("sols","usms","ini","tec","sta")
  # returning types if no args
  if (! nargs()) {
    return(types)
  }

  # index for getting files_pref value
  idx <- types %in% xml_type
  # checking the xml_type
  if (! any(idx)) {
    stop("Unknown xml type for getting an xml template xmlDocument !")
  }

  # check & get version
  stics_version <- get_xml_stics_version(stics_version = stics_version)

  # getting files prefix
  files_pref <- c("one","one","file","file","file")
  pref <- files_pref[idx]

  # getting a default xmldocument object template
  tmpl_file <- paste0("extdata/xml/templates/",stics_version,"/",pref,"_",xml_type,".xml")
  xml_doc_object <- xmldocument(system.file(tmpl_file, package = "SticsOnR"))

  return(xml_doc_object)

}