#' Load and format Stics daily output file(s)
#'
#' @description Reads and format daily output file(s) (mod_s*.sti) for usm(s) with
#'  possible selection on variable names, cumulative DOY, dates list.
#'
#' @param workspace  Stics or JavaStics workspace path containing the `mod_s*.sti` files (see details)
#' @param usm_name   usm name(s) to filter
#' @param var_list   vector of output variables names to filter (optional, see `get_var_info()` to get the names of the variables)
#' @param doy_list   vector of cumulative DOYs to filter (optional)
#' @param dates_list list of dates to filter (optional)
#' @param mixed      A booean (recycled), or a list of. `TRUE`: intercrop, `FALSE`: sole crops (default), `NULL`: guess from XML file.
#' @param usms_file  usms file path (e.g. "usms.xml") if any `mixed= NULL`.
#' @param javastics_path JavaStics installation path (Optional, needed if the plant files are not in the `workspace`
#' but rather in the JavaStics default workspace)
#' @param verbose  Logical value (optional), TRUE to display infos on error, FALSE otherwise (default)
#'
#' @details The function can guess if the usm(s) is/are mixed or not by reading the XML
#' input file. To do so, set the `mixed` argument to `NULL`.
#'
#' @return A list, where each element is a tibble of simulation results for the given usm. The list is named
#'  after the usm name.
#'
#' @examples
#' \dontrun{
#' path <- get_examples_path( file_type = "sti")
#' get_daily_results(path,"banana")
#' }
#' @export
#'
get_daily_results <- function(workspace,
                              usm_name=NULL,
                              var_list=NULL,
                              doy_list=NULL,
                              dates_list=NULL,
                              mixed= NULL,
                              usms_file= "usms.xml",
                              javastics_path = NULL,
                              verbose= TRUE){

  if(length(mixed)>1 & length(mixed)!=length(usm_name)){
    stop("The 'mixed' argument must either be of length one or length(usm_name)")
  }

  if(is.null(usm_name)){
    # getting usms names from the usms.xml file if no usm is provided:
    usm_name= get_usms_list(usm_path = file.path(workspace,usms_file))
  }

  if(is.null(mixed)){
    mixed= "NULL"
  }

  results_tbl_list <-
    mapply(function(x,y){
      get_daily_result(workspace,
                       x,
                       var_list = var_list,
                       doy_list = doy_list,
                       dates_list = dates_list,
                       mixed = if(y=="NULL"){NULL}else{y},
                       usms_file = usms_file)
    },
    x= usm_name, y= mixed, SIMPLIFY = FALSE)

  names(results_tbl_list) <- usm_name

  attr(results_tbl_list, "class")= "stics_simulation"

  return(results_tbl_list)
}



#' Load and format Stics daily output file
#'
#' @description Reads and format daily output file (mod_s*.sti) from STICS as a tibble with
#'  possible selection on variable names, cumulative DOY, dates list.
#'
#' @param workspace  Stics or JavaStics workspace path containing the `mod_s*.sti` files (see details)
#' @param usm_name   usm name
#' @param var_list   vector of output variables names (optional, see `get_var_info()` to get the names of the variables)
#' @param doy_list   vector of cumulative DOYs (optional)
#' @param dates_list list of dates (optional)
#' @param mixed      `TRUE`: intercrop, `FALSE`: sole crops (default), `NULL`: guess from XML file.
#' @param usms_file   usms file path (e.g. "usms.xml") if `mixed= NULL`.
#' @param javastics_path JavaStics installation path (Optional, needed if the plant files are not in the `workspace`
#' but rather in the JavaStics default workspace)
#' @param verbose  Logical value (optional), TRUE to display infos on error, FALSE otherwise (default)
#'
#' @details The function can guess if the usm is mixed or not by reading the XML
#' input file. To do so, set the `mixed` argument to `NULL`.
#'
#' @return A tibble
#'
#' @importFrom rlang .data
#'
#' @seealso `get_daily_results()`, the function exported by the package that calls `get_daily_result()` on all usms
#'
#' @examples
#' \dontrun{
#' path <- get_examples_path( file_type = "sti")
#' get_daily_result(path,"banana")
#' }
#' @keywords internal
#'
get_daily_result <- function(workspace,
                             usm_name,
                             var_list=NULL,
                             doy_list=NULL,
                             dates_list=NULL,
                             mixed= NULL,
                             usms_file= "usms.xml",
                             javastics_path = NULL,
                             verbose= TRUE){
  .= NULL

  if(length(mixed)>1 & length(mixed)!=length(usm_name)){
    stop("The 'mixed' argument must either be of length one or length(usm_name)")
  }

  if(is.null(usm_name)){
    stop("usm name is mandatory")
  }

  # Checking usms file
  usms_file_exist <- file.exists(file.path(workspace,usms_file))

  if(is.null(mixed)){

    if(!usms_file_exist){
      if(verbose){
        cli::cli_alert_danger("Unable to find an {.val usms.xml} file in the workspace directory.")
        cli::cli_alert_info("Please consider to set a valid {.val usms.xml} path as {.val usms_file} or put a value to {.val mixed}!")
      }
      stop("usms file not found")
    }

    # Try to guess if it is a mixture or not
    mixed = try(get_plants_nb(usm_file_path = file.path(workspace,usms_file), usms_list = usm_name) > 1)

    if(inherits(mixed,"try-error")){
      stop("Unable to guess if the usm is an intercrop. Please set mixed to TRUE or FALSE")
    }

  }

  if(mixed){

    plant_names= try(get_plant_name(workspace = workspace, usm_name = usm_name,
                                    usms_filename = usms_file, javastics_path = javastics_path,
                                    verbose = verbose))%>%unlist()

    if(inherits(plant_names,"try-error")){
      plant_names= c("plant_1", "plant_2")
      if(verbose) cli::cli_alert_warning("Error reading usms file, using dummy plant names")
    }

    out_file_path= file.path(workspace,paste0("mod_sp",usm_name,".sti"))

    if(!file.exists(out_file_path)){
      cli::cli_alert_warning("couldn't find output files for usm {.val {usm_name}}. Expected {.val {out_file_path}}")
      cli::cli_alert_info("Check if the simulation ran correctly, or if the simulation was a cole crop instead of an intercrop")
      return()
    }

    Table_1= try(data.table::fread(out_file_path,data.table = FALSE))

    if(inherits(Table_1,"try-error")){
      cli::cli_alert_warning("couldn't find valid outputs for usm {.val {usm_name}}: {.val {out_file_path}}")
      return()
    }

    out_file_path= file.path(workspace,paste0("mod_sa",usm_name,".sti"))

    if(!file.exists(out_file_path)){
      cli::cli_alert_warning("couldn't find output files for usm {.val {usm_name}}. Expected {.val {out_file_path}}")
      cli::cli_alert_info("Check if the simulation ran correctly, or if the simulation was a cole crop instead of an intercrop")
      return()
    }

    Table_2= try(data.table::fread(out_file_path, data.table = FALSE))

    if(inherits(Table_2,"try-error")){
      cli::cli_alert_warning("couldn't find valid outputs for usm {.val {usm_name}}: {.val {out_file_path}}")
      return()
    }

    Table_1$Plant = plant_names[1]
    Table_2$Plant = plant_names[2]
    Table_1$Dominance = "Principal"
    Table_2$Dominance = "Associated"

    results_tbl =
      dplyr::bind_rows(Table_1, Table_2)%>%
      dplyr::group_by(.data$Dominance)%>%
      dplyr::mutate(cum_jul= compute_doy_cumul(.data$jul, .data$ian))%>%
      dplyr::ungroup()

  }else{

    out_file_path= file.path(workspace,paste0("mod_s",usm_name,".sti"))

    if(!file.exists(out_file_path)){
      cli::cli_alert_warning("couldn't find output files for usm {.val {usm_name}}. Expected {.val {out_file_path}}")
      cli::cli_alert_info("Check if the simulation ran correctly, or if the simulation was an intercrop instead of a sole crop")
      return()
    }

    results_tbl =
      try(data.table::fread(file.path(workspace,paste0("mod_s",usm_name,".sti")),
                            data.table = FALSE)%>%tibble::as_tibble())
    if(inherits(results_tbl,"try-error")){
      cli::cli_alert_warning("couldn't find valid outputs for usm {.val {usm_name}}. Please check the file: {.val {out_file_path}}")
      return()
    }

    # Add cum_jul to table (cumulative DOY)

    results_tbl <-
      results_tbl%>%
      dplyr::mutate(cum_jul= compute_doy_cumul(.data$jul, .data$ian))
  }

  # filtering dates
  # only on cum_jul
  if(!is.null(doy_list)){
    results_tbl <-
      results_tbl%>%
      dplyr::filter(.data$cum_jul %in% doy_list)
  }

  # Converting (n) to _n in variable names to be homogeneous with get_obs_int
  # output colnames
  colnames(results_tbl)= var_to_col_names(colnames(results_tbl))

  # selecting variables columns
  if(!is.null(var_list)){
    results_tbl <-
      results_tbl%>%
      dplyr::select(c("ian", "mo","jo", "jul"),dplyr::one_of(var_to_col_names(var_list)))
  }

  # Adding the Date  in the simulation results tibble
  results_tbl <-
    results_tbl%>%
    dplyr::mutate(Date=as.POSIXct(x = paste(.data$ian,.data$mo,.data$jo,sep="-"),
                                  format = "%Y-%m-%d",tz="UTC"))%>%
    dplyr::select(.data$Date, dplyr::everything())

  return(results_tbl)
}
