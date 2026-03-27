
# function to make the required dataframe
NestedData <- function(dat, children){
  stopifnot(length(children) == nrow(dat))
  g <- function(d){
    if(is.data.frame(d)){
      purrr::transpose(d)
    }else{
      purrr::transpose(NestedData(d[[1]], children = d$children))
    }
  }
  subdats <- lapply(children, g)
  oplus <- sapply(subdats, function(x) if(length(x)) "&#11208;" else "")
  cbind(" " = oplus, dat, "_details" = I(subdats), stringsAsFactors = FALSE)
}






create_nested_exam_table <- function(summarized, original, joinby){
  
  summarized_joined <- summarized %>% 
    nest_join(original, by = joinby ) 
  
  
  n <-  nrow(summarized_joined)
  children_list <- replicate(n, original, simplify = FALSE)
  
  mloc_cat_dat <- NestedData(
    dat = summarized, 
    children = summarized_joined$original
  )
  
  
}