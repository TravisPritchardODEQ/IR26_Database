dup_check <- function(df) {
  
  dup_check <- df |>
    group_by(AU_ID, Char_Name, Pollu_ID, wqstd_code, period) |> 
    filter(n() > 1)
  
  if(nrow(dup_check > 0)){
    warning("Dups found")
    
  }
  
  return(dup_check)
  
  
}


dup_check_GNIS <- function(df){
  
  
  dup_check <- df |>
    group_by(AU_ID, AU_GNIS_Name, Char_Name, Pollu_ID, wqstd_code, period) |> 
    filter(n() > 1)
  
  if(nrow(dup_check > 0)){
    warning("Dups found")
    
  }
  
  return(dup_check)
  
  
}