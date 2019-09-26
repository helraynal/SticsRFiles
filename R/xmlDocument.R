# xml class based on fileDocument class
setClass("xmlDocument", contains = c("fileDocument"),validity=validDoc)


# object validation
setMethod("validDoc", signature(object = "xmlDocument"), function(object) {
  #callNextMethod()
  # print("calling xmlDocument validDoc")
  ext = getExt(object)
  # print(ext)
  #print(object@content)
  if (length(object@name) == 0 || object@name == "") {
    return("file name is empty !")
  }
  if (!length(ext) || !ext == "xml") {
    return("Error: pb with extension")
  }
  if (!exist(object)) {
    return("Error: file doesn't exist !")
  }
  if (exist(object) && isempty(object)) {
    return("Error: file is empty")
  }
  TRUE
})


# constructor
setMethod("xmldocument", signature(file = "character"), function(file = character(length = 0)) {
  # print(file)
  new("xmlDocument", file)
})

setMethod('initialize', 'xmlDocument', function(.Object,file = character(length = 0)){
  .Object<-callNextMethod(.Object,file)
  # print('xmlDocument initialization')
  # print(file)
  validObject(.Object)
  .Object<-loadContent(.Object)
  return(.Object) 
})


setMethod("show", "xmlDocument", function(object) {
  callNextMethod()
  #print("show de xmlDocument")
  if (isLoaded(object)){
    print(paste0("   content : ",class(object@content)[[1]]))
  }
})

# setter methods
setReplaceMethod("setContent", signature(docObj = "xmlDocument"), function(docObj, value) {
  if(!is(value,"XMLInternalDocument")){
    stop("Input value is not a XMLInternalDocument class object")
  }
  docObj@content <- value
  return(docObj)
})

# getter methods
setMethod("getContent", signature(docObj = "xmlDocument"), function(docObj) {
  return(docObj@content)
})


setMethod("getNodeS", signature(docObj = "xmlDocument"), function(docObj,path=NULL) {
  node_set=NULL
  if(!isLoaded(docObj)) { stop("xml file is not loaded in xmlDocument object")}
  
  if (is.null(path)){
    # getting root node name to get corresponding node set
    node_set=getNodeSet(docObj@content,paste0('/',xmlName(xmlRoot(docObj@content))))
    #node_set=getNodeSet(docObj@content,'/')
  } else {
    #print("getting node set")
    #print(path)
    node_set=getNodeSet(docObj@content,path)
    #browser("test getNodeS")
  }
  
  if (!length(node_set)) {
    warning("Node set is empty, check xml input path !")
    node_set=NULL
  }
  return(node_set)
})

setMethod("getAttrs", signature(docObj = "xmlDocument"), function(docObj,path) {
  attr_list=NULL
  node_set=getNodeS(docObj,path)
  #
  # browser("test getAttrs")
  if (is.null(node_set)) {
    return(attr_list)
  }
  
  # tranforming attributes to matrix (if only one attribute, a character 
  # vector is returned)
  attr_list = sapply(node_set,function(x) xmlAttrs(x))
  # not any attributes in nodeset
  if (is.null(unlist(attr_list))) {
    return()
  }
  
  if (is.character(attr_list) & !is.matrix(attr_list)) {
    new_list = vector(mode = "list",length(attr_list))
    for (i in 1:length(attr_list)){
      new_list[[i]] <- attr_list[i]
    }
    attr_list=new_list
  }
  #attr_list=as.matrix(attr_list)
  if (is.list(attr_list)) {
    attr_list=attributes_list2matrix(attr_list)
  } else {
    attr_list=t(attr_list)
  }
  # # test to detect if there's only one attribute
  # # TODO: add a contition to test if rownames (dimnames[[1]]) are identical
  # # and dim()[[2]]==1
  # r_names = unique(rownames(attr_list))
  # if (is.null(r_names)){
  #   
  # }
  # if (dim(attr_list)[[2]] ==1 & length(r_names) == 1) {
  #   colnames(attr_list) <- unique(rownames(attr_list))
  #   rownames(attr_list) <- c()
  # } else {
  #   # transposing the matrix to have attribute names as colnames !
  #   attr_list=t(attr_list)
  # }
  
  # testing if any node has not any attribute
  any_null=any(sapply(attr_list,function(x) is.null(x)))
  # print(attr_list)
  if (any_null) {paste(warning("Existing nodes without any attributes on xpath",path))}
  
  # testing if all nodes have the same attributes !!
  if (!is.matrix(attr_list) & !is.matrix(attr_list[,]) ) {
    print(class(attr_list))
    {paste(warning("Existing nodes with different attributes comparing to others on xpath, missing attributes ?",path))}
  }
  
  return(attr_list)
})

# getAttrsNames
setMethod("getAttrsNames", signature(docObj = "xmlDocument"), function(docObj,path) {
  attr_names=NULL
  attr_list=getAttrs(docObj,path)
  
  
  #print(path)
  #  print(attr_list)
  #   if (is.null(attr_list)){
  #     return(attr_list)}
  
  # TODO: Normally USELESS, see getAttrs (as.matrix ...)
  #if (!is.matrix(attr_list)){
  #  print("attrs characters ")
  #  # attr_names=unique(names(attr_list))
  #  attr_names=lapply(attr_list,function(x) names(x))
  #} # else {
  #print("attrs matrix ")
  dim_names=dimnames(attr_list)
  if(!is.null(dim_names[[1]])){
    attr_names=dim_names[[1]]
    #print(attr_names)
  } else {
    attr_names=dim_names[[2]]
  }
  #attr_names=unlist(attr_names)
  #print(attr_names)
  #}
  return(attr_names)
})


# getAttrsValues
setMethod("getAttrsValues", signature(docObj = "xmlDocument"), function(docObj,path,
                                                                        attr_list=character(length = 0),
                                                                        nodes_ids=NULL) {
  sel_values=NULL
  # getting attributes valeus from doc
  attr_values=getAttrs(docObj,path)
  
  # selecting outputs 
  # empty attr_list
  if( length(attr_list)==0 ) {
    return(attr_values)
  }
  
  #browser()
  
  # finding existing attr names in path
  sel = is.element(colnames(attr_values),attr_list)
  
  if (! any(sel)) {
    # not any given attr_list names exist in path 
    warning(paste("Not any given attribute name exist in ",path, "aborting !"))
    return()
  }
  
  # getting existing names from attr_list in attr_values
  # and getting the original order in initial attr_list
  found_list <- intersect(colnames(attr_values)[sel], attr_list)
  sel_list <- attr_list[is.element(attr_list,found_list)]
  
  # selecting wanted attributes columns 
  #by the col names
  sel_values = attr_values[,sel_list]
  
  # keeping only lines specified by nodes_ids
  if ( !is.null(nodes_ids) ) {
    sel_values <- sel_values[nodes_ids, ]
  }
  
  return(sel_values)
})


# factoriser avec getAttrs!! + getNode(docObj,path,kind)
setMethod("getValues", signature(docObj = "xmlDocument"), function(docObj,path,nodes_ids=NULL) {
  node_set=getNodeS(docObj,path)
  
  if ( !is.null(nodes_ids) ) {
    node_set = node_set[nodes_ids]
  }
  
  if (length(node_set) == 0) { return(invisible()) }
  
  # browser("getValues")
  val_list=unlist(lapply(node_set,function(x) xmlValue(x)))
  return(val_list)
})


# addAttrs
setMethod("addAttrs", signature(docObj = "xmlDocument"), function(docObj,path,named_vector) {
  # add not is.null node_set !!!!
  if (!is.null(names(named_vector))) {
    node_set=getNodeS(docObj,path)
    invisible(sapply(node_set,function(x) xmlAttrs(x)<-named_vector))
  }
})


# delete attributes
# delAttrs
# TODO: to remove all attrs !!!!!!!!!
setMethod("removeAttrs", signature(docObj = "xmlDocument"), function(docObj,path,attr_names) {
  # add not is.null node_set !!!!
  if (!is.null(attr_names)) {
    node_set=getNodeS(docObj,path)
    attr_nb=length(attr_names)
    for (i in  1:attr_nb){
      sapply(node_set,function(x) removeAttributes(x,attr_names[i]))
    }
  }
})


# Setters
#
# TODO : same code as setValues,  
setMethod("setAttrValues", signature(docObj = "xmlDocument"), function(docObj,path,attr_name,
                                                                       values_list,nodes_ids = NULL) {
  node_set=getNodeS(docObj,path)
  if(is.null(node_set)) {
    return(invisible())
  }
  
  if ( ! is.null(nodes_ids) ) {
    node_set = node_set[nodes_ids]
  }
  
  nodes_nb=length(node_set)
  
  if (length(values_list)==1){values_list=rep(values_list,nodes_nb)}
  values_nb=length(values_list)
  if(values_nb!=nodes_nb){stop("Values number is not consistent with nodes number !")}
  for (i in 1:nodes_nb){
    value=values_list[[i]]
    xmlAttrs(node_set[[i]])[[attr_name]]<-value
  }
})


# setValues
setMethod("setValues", signature(docObj = "xmlDocument"), 
          function(docObj, path, values_list, nodes_ids = NULL ) {
            
            node_set=getNodeS(docObj,path)
            #browser("setValues")
            if(is.null(node_set)) {
              return(invisible())
            }
            
            if ( ! is.null(nodes_ids) ) {
              node_set = node_set[nodes_ids]
            }
            
            nodes_nb=length(node_set)
            
            
            if (length(values_list)==1) { values_list=rep(values_list,nodes_nb) }
            values_nb=length(values_list)
            
            if(values_nb!=nodes_nb) { 
              stop("Values number is not consistent with nodes number to be modified !")
            }
            
            for (i in 1:nodes_nb){
              xmlValue(node_set[[i]]) <- values_list[[i]]
            }
            
          })

#  

# insert after ?????

# addNodes
setMethod("addNodes", signature(docObj = "xmlDocument"), function(docObj,nodes_to_add,parent_path=NULL){
  # parent node is root node
  if (is.null(parent_path)){
    pnode=xmlRoot(docObj@content)
    # getting parent node from given parent_path
  }else{
    node_set=getNodeS(docObj,parent_path)
    #print(node_set[[1]])
    if (is.null(node_set)){
      return()
    }
    pnode=node_set[[1]]
  }
  # for a node set
  if (class(nodes_to_add)[[1]]=="XMLNodeSet"){
    for (n in 1:length(nodes_to_add)){
      addChildren(pnode,nodes_to_add[[n]])
    }
    # for a single node
  } else {
    addChildren(pnode,nodes_to_add)
  }
})


# removeNodes
setMethod("delNodes", signature(docObj = "xmlDocument"), function(docObj,path){
  
  node_set <- getNodeS(docObj,path)
  
  if (is.null(node_set)){
    return()
  }
  
  removeNodes(node_set)
  
  
})



# replaceNodes ??

# delNode
# removeChildren
# removeNodes
# nodes=getNodeS(xnode,'//param[@nom="lvmax"]')
# removeChildren(xmlRoot(xnode@content),nodes[[1]])

# other methods
setMethod("loadContent", signature(docObj = "xmlDocument"), function(docObj) {
  #print("dans loadContent...")
  setContent(docObj) <- xmlParse(getPath(docObj))
  return(docObj)
})


setMethod("isLoaded", signature(docObj = "xmlDocument"), function(docObj) {
  return(is(docObj@content,"XMLInternalDocument"))
})

setMethod("is.xmlDocument", signature(docObj = "ANY"), function(docObj) {
  if (is(docObj , "xmlDocument")) {
    return(TRUE)
  } else { 
    return(FALSE)
  }
})


# save method
setMethod("saveXmlDoc", signature(docObj = "xmlDocument"), function(docObj,xml_path) {
  if (isLoaded(docObj)){
    write(saveXML(docObj@content),xml_path)
  }
})

# clone method
setMethod("cloneXmlDoc", signature(docObj = "xmlDocument"), function(docObj) {
  if (! isLoaded(docObj)){
    return(NULL)
  }
  
  setContent(docObj) <- xmlClone(getContent(docObj))
  
  return(docObj)
})