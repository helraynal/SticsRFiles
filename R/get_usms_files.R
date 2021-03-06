#' Getting existing xml files path list per usm from an usms.xml file
#'
#' @param workspace_path The path to a JavaStics-compatible workspace
#' @param usms_list Vector of usms names (Optional)
#' @param file_name Usms XML file name (Optional)
#' @param file_type Vector of file(s) type to get (if not given, all types are returned, see details)
#' @param javastics_path JavaStics installation path (Optional, needed if the plant files are not in the `workspace_path`
#' but rather in the JavaStics default workspace)
#'
#' @details The possible values of file types are: "fplt", "finit", "fclim1",
#' "fclim2", "fstation" and "ftec"
#'
#' @return A named list with existing files path in each usm element
#'
#' @export
#' @seealso See `get_soils_list()` to get all soils in a usm file, and `get_usms_list()` to get
#' the list of usms.
#'
#' @examples
#'
#' \dontrun{
#'
#' get_usms_files(workspace_path = "/path/to/workspace",
#' javastics_path = "/path/to/javastics")
#'
#' get_usms_files(workspace_path = "/path/to/workspace",
#' javastics_path = "/path/to/javastics", usm_list = c("usm1", "usm3"))
#'
#' get_usms_files(workspace_path = "/path/to/workspace",
#' file_type = c("finit", "ftec" ))
#'
#'
#' }
#'
get_usms_files <- function(workspace_path,
                           usms_list = NULL,
                           file_name = "usms.xml",
                           file_type = NULL,
                           javastics_path = NULL) {

  # Types definition
  files_types <- c("fplt","finit","fclim1","fclim2","fstation", "ftec")
  if(is.null(file_type)){
    file_type <- files_types
  }else{
    # Checking if type(s) exist(s)
  }

  # Checking if plt files are needed
  plt_path <- NULL
  check_plt <- FALSE

  # Getting first the plant dir path from the workspace, if any
  if("fplt" %in% file_type){

    javastics_plt_path <- NULL
    ws_plt_path <- NULL

    if (! base::is.null(javastics_path) && dir.exists(file.path(javastics_path, "plant")))  {
      javastics_plt_path <- suppressWarnings(normalizePath(file.path(javastics_path, "plant")))
    }

    if (dir.exists(file.path(workspace_path,"plant"))) {
      ws_plt_path <- suppressWarnings(normalizePath(file.path(workspace_path,"plant")))
    }

    # if(is.null(javastics_path)){
    #   plt_path <- file.path(workspace_path, "plant")
    #   if(!dir.exists(plt_path)){
    #     stop("plant folder not found, please add javastics_path to check in the plant files from javaStics !")
    #   }
    # }else{
    #   plt_path <- try(normalizePath(file.path(workspace_path, "plant")))
    # }

    plt_path <- c(ws_plt_path, javastics_plt_path)

    if (base::is.null(plt_path)) {
      stop("not any plant folder found, please add javastics_path directory as function input argument or a workspace plant directory !")
    }
    check_plt <- TRUE
    file_type <- setdiff(file_type, "fplt")
  }

  # Getting usms.xml path
  usms_xml_path <- file.path(workspace_path, file_name)

  # Checking usms file
  if(!file.exists(usms_xml_path)){
    stop(paste("Unknown path:", usms_xml_path))
  }

  # Getting usms_list
  usms_full_list <- get_usms_list(usm_path = usms_xml_path)

  # Getting the full list or a subset
  if(is.null(usms_list)){
    usms_list <- usms_full_list
  }else{
    # checking if usms names exist
    usm_idx <- usms_full_list %in% usms_list
    if(!length(usms_list) == sum(usm_idx)){
      usms_list <- usms_full_list[usm_idx]
      warning(paste("There are missing usms in usms.xml file:\n",
                    paste(usms_full_list[!usm_idx], collapse = ", ")))
    }
  }

  usms_nb <- length(usms_list)
  usms_files <- vector("list", usms_nb)

  # Loop over usms names
  for(i in 1:usms_nb){
    usm_name <- usms_list[i]
    usm_files <- unlist(get_param_xml(xml_file = usms_xml_path,
                                      param_name = file_type,
                                      select = "usm",
                                      value = usm_name), use.names = F)

    usm_files <- usm_files[usm_files != "null"]
    usm_files_path <- file.path(workspace_path, usm_files)
    files_idx <- file.exists(usm_files_path)
    usm_files_path <- usm_files_path[files_idx]
    usm_files_all_exist <- length(usm_files) == length(usm_files_path)

    plt_files <- NULL
    plt_files_path <- NULL
    if(check_plt){
      plt_files <- unlist(get_param_xml(xml_file = usms_xml_path,
                                        param_name = "fplt",
                                        select = "usm",
                                        value = usm_name)[[1]], use.names = F)

      plt_files <- plt_files[plt_files != "null"]
      # applying for multiple paths (javastics, workspace)
      plt_files_path <- unlist(lapply(plt_path, function(x) file.path(x, plt_files)))
      plt_idx <- file.exists(plt_files_path)
      plt_files_path <- plt_files_path[plt_idx]
      # If one occurrence of each file at least, NOT checking duplicates !
      plt_files_all_exist <- length(plt_files) <= length(plt_files_path)
    }
    # Adding the files lists
    usms_files[[i]] <- list(paths=c(usm_files_path, plt_files_path),
                            all_exist=usm_files_all_exist & plt_files_all_exist)
  }

  # Returning a named list
  names(usms_files) <- usms_list
  return(usms_files)
}
