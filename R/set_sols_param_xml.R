#' @title Setting a sol param value(s) in a sols xmlDocument
#' @param xml_doc_object an xmlDocument object (created from an xml sols file)
#'
#' @param sols_param soils parameters (data.frame)
#' @param overwrite replace existing soil (TRUE) or not, updating existing ones (FALSE)
#'
#'
#' @examples
#'
#' \dontrun{
#' xml_path = file.path(get_examples_path( file_type = "xml"),"sols.xml")
#' sols_doc <- SticsRFiles:::xmldocument(xml_path)
#'
#' xl_path <- file.path(get_examples_path( file_type = "xl"),"inputs_stics_example.xlsx")
#' sols_df <- read_excel(xl_path, sheet = "Soils")
#'
#' # For updating an existing xml doc (using existing soils names)
#' # Creating a fake existing_doc
#' existing_doc <- SticsRFiles:::gen_xml_doc("sols",nodes_nb = 3)
#' SticsRFiles:::set_param_value(existing_doc, param_name = "sol",
#' param_value = sols_df$Soil_name[c(3,1,5)])
#'
#' SticsRFiles:::set_sols_param_xml(existing_doc, sols_df)
#'
#'
#' # For a new xml doc
#' # In that case: sols_df must contain all the soils parameters !)
#' soils_nb <- dim(sols_df)[1]
#' new_doc <- SticsRFiles:::gen_xml_doc("sols",nodes_nb = soils_nb)
#'
#' SticsRFiles:::set_sols_param_xml(new_doc, sols_df, overwrite = T)
#'
#' }
#'
#' @keywords internal
#'

set_sols_param_xml <- function(xml_doc_object, sols_param, overwrite = FALSE) {


  if ( ! "data.frame" %in% class(sols_param) ) {
    stop("sols_param do not belong to data.frame class/type")
  }

  if (! "xmlDocument" %in% class(xml_doc_object) ) {
    stop("xml_doc_object is not an XMLDocument object")
  }


  # detecting soils names column
  in_params <- names(sols_param)
  col_id <- grep("^soil",tolower(in_params))
  if (! length(col_id)) {
    stop("The column for identifying soil names has not been found !")
  }
  sol_col <- in_params[ col_id ]

  # Checking parameter names from param_table against xml ones
  check_param_names(param_names = in_params[ - col_id],
                    ref_names = get_param_names(xml_object = xml_doc_object))

  # checking soils based on names if overwrite == FALSE
  if ( ! overwrite ) {
    # getting soils names
    xml_sols <- as.vector(get_param_value(xml_doc_object,"sol"))


    ###############################################
    # TODO : see adding sols not in xml file ?
    ###############################################

    # checking xl names against xml names
    xl_in_xml <- sols_param[[sol_col]] %in% xml_sols

    if ( ! any(xl_in_xml) ) {
      stop("Not any sol name in sols_param table is in xml doc !")
    }

    # xl sols idx in xml doc to be updated
    sols_xml_idx <- which(xml_sols %in% sols_param[[sol_col]])

    # Selecting data & ordering upon xml
    # order
    sols_param <- sols_param[xl_in_xml,]
    sols_param <- sols_param[match(xml_sols[sols_xml_idx], sols_param[[sol_col]]),]

  } else {
    # setting soils names
    set_param_value(xml_doc_object,"sol",sols_param[[sol_col]])
  }


  # Managing parameter values replacement from sols_param
  # data.frame

  # Treating Layers params
  # reshape them to set values for all soils
  # select epc_1 to epc_5 in df and as.vector to
  # set_sols_param(xml_doc_object, "epc", epc_vec)

  layers_params <- grep("_[0-9]*$",in_params, value = T)
  layers_params_names <- unique(gsub("_[0-9]*$","",layers_params))

  for (i in 1:5) {
    for (p in layers_params_names){
      par <- paste0(p,"_",i)
      layer <- paste("layer",as.character(i))
      if (is.element(par,layers_params)) {
        set_param_value(xml_doc_object,p,sols_param[[par]], layer)
      } else {
        delNodes(xml_doc_object,paste0("//tableau[@nom=\"",layer,"\"]"))
      }
    }
  }

  # Treating other params, simple and options
  other_params <- setdiff(in_params, c(layers_params,sol_col))

  if ( ! length(other_params) ) return(xml_doc_object)

  # setting param values
  for (p in other_params) {
    #print(p)
    set_param_value(xml_doc_object,p,sols_param[[p]])
  }

}
