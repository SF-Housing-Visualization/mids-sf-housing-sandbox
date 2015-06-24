######################
# Load Packages
######################
require(ggplot2)
require(reshape2)
require(scales)

# go here for info about installing this
# http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html
require(rgdal)
require(rgeos)

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
### Testing Clean Data ...
#####################

make_image_name = function(base_name,filetype='png'){
  return(paste0(base_name, '_', format(Sys.time(), "%Y%m%d_%H%M%S"), '.', filetype))
}

metal = melt(cars, id.vars='Period', variable.name='County', value.name='Affordability')

# make a simple viz
linegrid = ggplot(metal, aes(x=Period, y=Affordability)) + geom_line() + facet_wrap(~County) + scale_x_date(labels = date_format("%y"))
linegrid
#ggsave(filename = make_image_name('county_affordability_grid'), plot=linegrid, path='../image', width = 10, height = 7)

#########################
### Testing Maps
########################

# Using this link as guid
# https://rud.is/b/2014/09/26/overcoming-d3-cartographic-envy-with-r-ggplot/

mapjson = '../data/caCountiesGeo.json'

ogrListLayers(mapjson)

layer = 'OGRGeoJSON'
ogrInfo(mapjson, layer)

map = readOGR(mapjson, layer)

map_df = fortify(map)

gg <- ggplot()
gg <- gg + geom_map(data=map_df, map=map_df,
                    aes(map_id=id, x=long, y=lat, group=group),
                    color="#ffffff", fill="#bbbbbb", size=0.25)

