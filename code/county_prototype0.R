######################
# Load Packages
######################
require(ggplot2)
require(reshape2)
require(scales)

######################
### Load & Clean Data
######################
# Assumes data can be found in ../data from R working directory (location of script)
cars = read.csv('../data/cars_affordability.csv', stringsAsFactors = FALSE)
DirtyPeriod = cars$Period

#clean dates
cleanPeriod = function(per){
  day = '01'
  q2m = c('Mar', 'Jun', 'Sep', 'Dec')
  
  perdate = as.Date(paste0(day,'-',per), '%d-%b-%y')
  if(is.na(perdate)){
    yr_q = as.numeric(strsplit(per,'\\.')[[1]])
    m = q2m[yr_q[2]]
    perdate = as.Date(paste(day,m,yr_q[1],sep='-'), '%d-%b-%Y')
  }
  return(as.character(perdate))
}

cars$Period = as.Date(sapply(DirtyPeriod, cleanPeriod))



#####################
### Testing...
#####################

metal = melt(cars, id.vars='Period', variable.name='County', value.name='Affordability')
head(metal)
ggplot(metal, aes(x=Period, y=Affordability)) + geom_line() + facet_wrap(~County) + scale_x_date(labels = date_format("%y"))

