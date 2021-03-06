#' @title Generatefrom a template a Stics sta xmlDocument
#'
#' @param xml_doc an optional xmlDocument object (created from an sta file)
#' @param param_table a table (df, tibble) containing parameters to use (optional)
#' @param stics_version the stics files version to use (optional, default to last). Only used if xml_doc = NULL.
#' @param check_names logical for checking names of param_table columns or not
#' @return an invisible xmlDocument object or a list of
#'
#'
#' @examples
#' \dontrun{
#' library(readxl)
#'
#' xl_path <- "inputs_stics_example.xlsx"
#' download_usm_xl(xl_name = xl_path)
#' sta_param_df <- readxl::read_excel(xl_path, sheet = "Station")
#' sta_doc <- SticsRFiles:::gen_sta_doc(param_table = sta_param_df)
#' }
#'
#' @keywords internal
#'
gen_sta_doc <- function(xml_doc = NULL,
                        param_table = NULL,
                        stics_version ="last",
                        check_names = TRUE) {


  # check/get version
  stics_version <- get_xml_stics_version(stics_version = stics_version,xml_doc = xml_doc)

  # getting a default xml template
  if ( base::is.null(xml_doc) ) {
    xml_doc <- get_xml_base_doc("sta", stics_version = stics_version)
  }

  # Nothing to do
  if ( base::is.null(param_table) ) {
    return(xml_doc)
  }

  in_params <- names(param_table)

  # Checking parameter names from param_table against xml ones
  if (check_names) {
    check_param_names(param_names = in_params,
                      ref_names = get_param_names(xml_object = xml_doc))
  }



  # managing several doc generation based upon the lines number in param_table
  lines_nb <- dim(param_table)[1]
  if (lines_nb > 1) {
    xml_docs <- apply(param_table,1,
                      function(x) gen_sta_doc(xml_doc = cloneXmlDoc(xml_doc),
                                              param_table = as.data.frame(t(x)),
                                              stics_version = stics_version,
                                              check_names = FALSE))
    return(xml_docs)
  }

  #print(stics_version)


  for (p in in_params) {
    set_param_value(xml_doc,p, param_table[[p]])
  }


  return(invisible(xml_doc))

}
