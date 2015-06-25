######################
# Load Packages
######################
require(ggplot2)
require(reshape2)
require(scales)
#require(jsonlite)
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

# melt data in to ggplot usable format
metal = melt(cars, id.vars='Period', variable.name='County', value.name='Affordability')
metal$County = gsub('\\.', ' ', metal$County)

# make a simple viz
linegrid = ggplot(metal, aes(x=Period, y=Affordability)) + geom_line() + facet_wrap(~County) + scale_x_date(labels = date_format("%y"))
linegrid
#ggsave(filename = make_image_name('county_affordability_grid'), plot=linegrid, path='../image', width = 10, height = 7)

#########################
### Testing Maps
########################

# Used this link as guide
# https://rud.is/b/2014/09/26/overcoming-d3-cartographic-envy-with-r-ggplot/

# GeoJSON file
mapjson = '../data/caCountiesGeo.json'

# layer to extract
layer = 'OGRGeoJSON'

#ogrListLayers(mapjson)
#ogrInfo(mapjson, layer)
#OGRSpatialRef(mapjson, layer)
#ogrFIDs(mapjson, layer)

# get map data
map = readOGR(mapjson, layer)

# map data structure to data frame
map_df = fortify(map)

# get names of maps
map_names = map@data

# remove redundant county name info
map_names$name = gsub(' County, CA', '', map_names$name)

# add names to map data frame
map_df$name = as.character(factor(as.integer(map_df$id), labels = as.character(map_names$name)))

# clean up map names for merge with affordability data
map_df$name[map_df$name=='Los Angeles'] = 'LA'

# create map label dataframe
label_df = aggregate(map_df[,c('long','lat')], by = list(name=map_df$name), FUN=function(x){return(mean(c(max(x),min(x))))})

# get the last value from the data for coloring the plot
last_val = subset(metal, Period == max(Period))

# merge the data
map_dt = data.table(
  merge(map_df, last_val, by.x='name', by.y='County', all.x=TRUE, all.y=FALSE),
  key = c('id', 'order')
  )

# restrict labels to counties in data
label_df = subset(label_df, label_df$name %in% last_val$County)

# initiate the plot
gg = ggplot(data=map_dt, aes(x=long, y=lat)) + theme_bw()
# add map with affordability coloring
gg = gg + geom_map(map=map_dt,
                    aes(map_id=id, fill=Affordability),
                    color="#ffffff", size=0.25)
# add custom colors
gg = gg + scale_fill_continuous(low="darkred", high="thistle2", guide="colorbar",na.value=rgb(.9,.9,.9))
#gg = gg + scale_fill_continuous(na.value=rgb(.9,.9,.9))
# add county labels
gg = gg + geom_text(aes(label=name), data=label_df, color=rgb(.2,.2,.2), size = 4)
# restrict scope
#gg = gg + ylim(32.5, 39.1)
gg = gg + ylim(36, 39) + xlim(-125,-120)
gg

