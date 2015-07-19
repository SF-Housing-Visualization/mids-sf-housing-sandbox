######################
# Load Packages
######################
require(ggplot2)
require(reshape2)
require(data.table)

# go here for info about installing this
# http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html
require(rgdal)
require(rgeos)

######################
### Load & Clean Data
######################
# Assumes data can be found in ../data from R working directory (location of script)
cars = read.csv('../data/cars_affordability.csv', stringsAsFactors = FALSE)
geo = read.csv('../data/data_geo.csv', stringsAsFactors = FALSE)

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


# melt data in to ggplot usable format
metal = melt(cars, id.vars='Period', variable.name='County', value.name='Affordability')
metal$County = gsub('\\.', ' ', metal$County)

unique(metal$County)[! unique(metal$County) %in% geo$ShortName]

metal$County[metal$County == 'LA'] = 'Los Angeles'
metal = subset(metal,County != 'CA')
metal$GeoID = geo$GeoID[match(metal$County, geo$ShortName)]
metal$VariableID = "CARS_Affordability"
metal$Date = format(metal$Period, '%Y-%m-%d')
metal$Value = metal$Affordability

metal = metal[!is.na(metal$Value),]

cars_formatted = metal[,c('GeoID', 'VariableID', 'Date', 'Value')]

write.csv(cars_formatted, file='../data/cars_affordability_formatted.csv', row.names=F)

