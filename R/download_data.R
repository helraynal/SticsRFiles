#' Download example USMs
#'
#' @description Download locally the example data from the [data repository](https://github.com/SticsRPacks/data)
#' in the SticsRPacks organisation.
#'
#' @param dir The directory where to download the data
#' @param example_dirs List of use case directories names (optional)
#' @param version_name An optional version string
#' within those given by get_stics_versions_compat()$versions_list, or "last"
#' for getting the last version (default : NULL)
#'
#' @return The path to the folder where data have been downloaded
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' # Getting all data
#' download_data()
#'
#  # Getting data for a given example : study_case_1
#' download_data(example_dirs = "study_case_1")
#'
#' # Getting data for a given example : study_case_1 and a given version
#' download_data(example_dirs = "study_case_1", version_name = "V9.0")
#'
#'
#' }
download_data= function(dir = tempdir(), example_dirs = NULL, version_name = NULL){

  # setting version value from input for version == "last"
  if (!base::is.null(version_name) && version_name == "last") version_name <- get_stics_versions_compat()$last_version

  # Getting path string(s) from examples data file
  dirs_str <- get_referenced_dirs(dirs = example_dirs, version_name = version_name)

  # Not any examples_dirs not found in example data file
  if (base::is.null(dirs_str)) stop("Error: no available data for ",example_dirs)

  data_dir = normalizePath(dir, winslash = "/", mustWork = FALSE)
  data_dir_zip = normalizePath(file.path(data_dir,"master.zip"), winslash = "/", mustWork = FALSE)
  utils::download.file("https://github.com/SticsRPacks/data/archive/master.zip", data_dir_zip)
  df_name = utils::unzip(data_dir_zip, exdir = data_dir, list = TRUE)

  # Creating files list to extract from dirs strings
  arch_files <- unlist(lapply(dirs_str,
                              function(x) grep(pattern = x, x = df_name$Name, value = TRUE)))

  # No data corresponding to example_dirs request in the archive !
  if (! length(arch_files)) stop("No downloadable data for example(s), version: ",example_dirs,",", version_name)

  # Finally extracting data
  utils::unzip(data_dir_zip, exdir = data_dir, files = arch_files)
  unlink(data_dir_zip)
  normalizePath(file.path(data_dir,df_name[1,1]), winslash = "/")
}


#' Getting valid directories string for download from SticsRpacks data repository
#'
#' @param dirs Directories names of the referenced use cases (optional), starting with "study_case_"
#' @param version_name An optional version string
#' within those given by get_stics_versions_compat()$versions_list
#'
#' @return Vector of referenced directories string (as "study_case_1/V9.0")
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' # Getting all available dirs from the data repos
#' SticsRFiles:::get_referenced_dirs()
#'
#' # Getting dirs for a use case
#' SticsRFiles:::get_referenced_dirs("study_case_1")
#'
#' # Getting dirs for a use case and a version
#' SticsRFiles:::get_referenced_dirs("study_case_1", "V9.0" )
#'
#' SticsRFiles:::get_referenced_dirs(c("study_case_1", "study_case_2"), "V9.0" )
#'
#' }
#'
get_referenced_dirs <- function(dirs = NULL, version_name = NULL) {

  # Loading csv file with data information
  ver_data <- get_versions_info(version_name = version_name)
  if (base::is.null(ver_data)) stop("No examples data referenced for version: ",version_name)

  dirs_names <- grep(pattern = "^study_case", x = names(ver_data), value = TRUE)
  if (base::is.null(dirs)) dirs <- dirs_names
  dirs_idx <-  dirs_names %in% dirs

  # Not any existing use case dir found
  if(!any(dirs_idx)) return()

  # Filtering existing dirs in examples data
  if (!all(dirs_idx)) {
    dirs <- dirs_names[dirs_idx]
  }

  # Only dirs, returned if no specified version
  if(base::is.null(version_name)) return(dirs)

  # Getting data according to version and dirs
  version_data <- ver_data %>% dplyr::select(dirs)

  # Compiling referenced dirs/version strings, for existing version
  is_na <- base::is.na(version_data)
  dirs_str <- sprintf("%s/%s", names(version_data)[!is_na],version_data[!is_na])

  return(dirs_str)

}
