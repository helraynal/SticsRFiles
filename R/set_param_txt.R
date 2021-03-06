#' Set (replace) STICS input file parameters
#'
#' @description Replace or set an input parameter from a pre-existing STICS input
#'              file.
#'
#' @param dirpath  USM directory path
#' @param filepath Path to the parameter file
#' @param param    Parameter name
#' @param value    New parameter value
#' @param plant    Plant index. Optional, only for plant or technical parameters
#' @param add      Boolean. Append input to existing file (add to the list)
#' @param variety  Integer. The plant variety to set the parameter value.
#' @param layer    The soil layer if any (only concerns soil-related parameters)
#'
#' @details The \code{plant} parameter can be either equal to \code{1}, \code{2} for
#'          the associated plant in the case of intercrop, or \code{c(1,2)} for both
#'          Principal and associated plants.
#'          \code{\link{get_var_info}} is a helper function that returns all possible
#'          output variables.
#'
#' @note \code{gen_varmod} is not used by \code{set_param_txt}. To replace the output
#'       variables required from STICS, please directly call \code{gen_varmod}.
#'
#'
#' @importFrom magrittr "%>%"
#'
#' @examples
#'\dontrun{
#' # Replace the interrow distance parameter to 0.01:
#'
#' set_param_txt(dirpath = "stics_usm/usm_1", param = "interrang", value = 0.01)
#'
#' # Change the value of durvieF for the current variety:
#' set_param_txt(dirpath = "inst/extdata/txt/V8.5", param = "durvieF", value = 245)
#'
#' # Change the value of durvieF for another variety:
#' set_param_txt(dirpath = "inst/extdata/txt/V8.5", param = "durvieF", variety = "Nefer", value = 178)
#'
#' # Change the value of infil for a given layer:
#' set_param_txt(dirpath = "inst/extdata/txt/V8.5", param = "infil", layer = 2, value = 60)
#'
#' # If the parameter is found in several files, use the set_* functions direclty, e.g.
#' # cailloux is found in the general file ("codetycailloux") and the soil file. If we want to
#' # change its value in the soil file, we use set_soil_txt():
#' set_soil_txt(filepath = "inst/extdata/txt/V8.5/param.sol", param = "cailloux", layer = 2, value = 1)
#'}
#'
#' @export
set_param_txt= function(dirpath=getwd(),param,value,add=FALSE,plant=1,variety=NULL,layer=NULL){
  param= gsub("P_","",param)
  param_val= get_param_txt(dirpath = dirpath, param = param)

  file_type=
    lapply(strsplit(names(param_val),"\\."), function(x){x[1]})%>%
    unlist%>%unique

  if(length(file_type)>1){
    stop("Parameter found in several files:",paste(file_type,collapse = ", "),
         "\nPlease use the set_* functions directly to set the parameter value.")
  }
  switch(file_type,
         ini= {
           set_ini_txt(filepath = file.path(dirpath,"ficini.txt"),
                   param = param, value = value, add= add)
         },
         general= {
           set_general_txt(filepath = file.path(dirpath,"tempopar.sti"),
                       param = param, value = value, add= add)
         },
         tmp= {
           set_tmp_txt(filepath = file.path(dirpath,"tempoparV6.sti"),
                   param = param, value = value, add= add)
         },
         soil= {
           set_soil_txt(filepath = file.path(dirpath,"param.sol"),
                    param = param, value = value, layer= layer)
         },
         usm= {
           set_usm_txt(filepath = file.path(dirpath,"new_travail.usm"),
                   param = param, value = value)
         },
         station= {
           set_station_txt(filepath = file.path(dirpath,"station.txt"),
                       param = param, value = value, add= add)
         },
         tec= {
           tmp= lapply(plant, function(x){
             set_tec_txt(filepath = file.path(dirpath,paste0("fictec",x,".txt")),
                     param = param, value = value, add= add)
           })
         },
         plant= {
           tmp= lapply(plant, function(x){
             if(is.null(variety)){
               variety=
                 get_param_txt(dirpath = dirpath, param = "variete")[plant]%>%
                 as.numeric()
             }else{
               if(is.character(variety)){
                 varieties= get_plant_txt(filepath = file.path(dirpath,paste0("ficplt",x,".txt")))$codevar
                 variety= match(variety,varieties)
                 if(is.na(variety)){
                   cli::cli_alert_danger("Variety not found in plant file. Possible varieties are: {.val {varieties}}")
                   return()
                 }
               }
             }
             set_plant_txt(filepath = file.path(dirpath,paste0("ficplt",x,".txt")),
                       param = param, value = value, add= add, variety = variety)
           })
         },
         stop("Parameter not found")
  )
}


#' @rdname set_param_txt
#' @export
set_usm_txt= function(filepath="new_travail.usm",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}

#' @rdname set_param_txt
#' @export
set_station_txt= function(filepath="station.txt",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}


#' @rdname set_param_txt
#' @export
set_ini_txt= function(filepath= "ficini.txt",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}


#' @rdname set_param_txt
#' @export
set_general_txt= function(filepath= "tempopar.sti",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}

#' @rdname set_param_txt
#' @export
set_tmp_txt= function(filepath= "tempoparv6.sti",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}

#' @rdname set_param_txt
#' @export
set_plant_txt= function(filepath="ficplt1.txt",param,value,add=F,variety= NULL){
  set_file_txt(filepath,param,value,add,variety)
}

#' @rdname set_param_txt
#' @export
set_tec_txt= function(filepath="fictec1.txt",param,value,add=F){
  set_file_txt(filepath,param,value,add)
}

#' @rdname set_param_txt
#' @export
set_soil_txt= function(filepath="param.sol",param,value,layer=NULL){
  param= gsub("P_","",param)
  ref= get_soil_txt(filepath)
  param= paste0("^",param,"$")

  if(!is.null(layer)){
    length_param_file= length(ref[grep(param,names(ref))][layer])
  }else{
    length_param_file= length(ref[grep(param,names(ref))])
  }

  if(length_param_file!=length(value)){
    cli::cli_alert_danger(paste("Length of input value different from parameter value length.\n",
                                "Original values: {.val {ref[grep(param,names(ref))]}} \n",
                                "Input values: {.val { value}}"))
    stop("Number of values don't match.")
  }

  if(!is.null(layer)){
    ref[[grep(param,names(ref))]][layer]= format(value, scientific=F)
  }else{
    ref[[grep(param,names(ref))]]= format(value, scientific=F)
  }


  writeLines(paste(" "," "," ",ref$numsol[1]," "," "," ",ref$typsol,
                   ref$argi,ref$Norg,ref$profhum,ref$calc,
                   ref$pH,ref$concseuil,ref$albedo,ref$q0,
                   ref$ruisolnu,ref$obstarac,ref$pluiebat,
                   ref$mulchbat,ref$zesx,ref$cfes,
                   ref$z0solnu ,ref$CsurNsol,ref$penterui),
             filepath)

  write(paste(" "," "," ",ref$numsol[1]," "," "," ",ref$codecailloux,ref$codemacropor,
              ref$codefente,ref$codrainage,ref$coderemontcap,
              ref$codenitrif,ref$codedenit),
        filepath,append = T)

  write(paste(" "," "," ",ref$numsol[1]," "," "," ",ref$profimper,ref$ecartdrain,ref$ksol,
              ref$profdrain,ref$capiljour,ref$humcapil,
              ref$profdenit,ref$vpotdenit),
        filepath,append = T)

  for(icou in 1:5){
    write(paste(" "," "," ",ref$numsol[1]," "," "," ",ref$epc[icou],ref$hccf[icou],
                ref$hminf[icou],ref$DAF[icou],ref$cailloux[icou],
                ref$typecailloux[icou],ref$infil[icou],
                ref$epd[icou]),
          filepath,append = T)
  }
}


#' Internal function to set some STICS input file parameters
#'
#' @description Replace or set an input parameter from a pre-existing STICS input
#'              file. This function is called by some of the generic \code{set_*}
#'              functions under the hood.
#'
#' @param filepath Path to the parameter file
#' @param param    Parameter name
#' @param value    New parameter value
#' @param add      Boolean. Append input to existing file (add to the list)
#'
#' @details The function uses `base::sys.call()` to know from which function
#'          of the \code{set_*} family it is called, so it won't work properly if called
#'          by the user directly. This is why this function is internal.
#'
#' @note This function is not used for \code{\link{set_soil_txt}}.
#'
#' @seealso \code{\link{set_param_txt}}.
#'
#' @keywords internal
#'
set_file_txt= function(filepath,param,value,add,variety= NULL){
  param= gsub("P_","",param)
  # access the function name from which set_file_txt was called
  type= strsplit(deparse(sys.call(-1)),split = "\\(")[[1]][1]
  params= readLines(filepath)
  param_= paste0(param,"$")
  switch(type,
         set_usm_txt = {
           ref= get_usm_txt(filepath)
           if(grep(param_,names(ref))<grep("fplt",names(ref))){
             ref_index= grep(param_,names(ref))*2
           }else{
             ref_index= grep(param_,params)+1
           }
         },
         set_station_txt= {
           ref= get_station_txt(filepath)
           ref_index= grep(param_,names(ref))*2
         },
         set_ini_txt= {
           ref= get_ini_txt(filepath)
           ref_index= grep(param_,names(ref))*2
         },
         set_plant_txt= {
           ref_index= grep(param_,params)+1
           if(!is.null(variety)){
             ref_index= ref_index[variety]
           }
         },
         # Default here
         {
           ref_index= grep(param_,params)+1
         }
  )

  if(!length(ref_index)>0){
    if(add){
      value= paste(value, collapse = " ")
      params= c(params,param,value)
      ref_index= grep(param_,params)+1
    }else{
      stop(paste(param,"parameter not found in:\n",filepath))
    }
  }else{
    if(add){
      stop(paste("Parameter",param,"already present in the file, try to replace its value",
                 "instead of adding the parameter"))
    }
  }

  if(length(ref_index)!=length(value)){
    stop(paste("Length of input value different from parameter value length.\n",
               "Original values:\n",paste(params[ref_index],collapse= ", "),
               "\ninput:\n",paste(value,collapse= ", ")))
  }
  params[ref_index]= format(value, scientific=F)
  writeLines(params,filepath)
}
