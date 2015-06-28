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

###########
###Trying another GeoJSON
###########
mapjson1 = '../data/ca-counties.json'
mapjson2 = '../data/caCountiesGeoOpenData.json'
usejson = 1

## Make map_dt and label_df from one of the json files
if(usejson == 1){
  mapjson = mapjson1
  
  ogrListLayers(mapjson)
  
  # layer to extract
  layer = 'OGRGeoJSON'
  
  ogrInfo(mapjson, layer)
  ogrFIDs(mapjson, layer)
  
  # get map data - this fails
  map = readOGR(mapjson, layer, drop_unsupported_fields = T)
  
  jsontext = readChar(mapjson, 100000000)
  json = fromJSON(jsontext)
  
  # centroids & labels
  countyInfo = json[[3]][[3]]
  countyInfo$name[countInfo$name=='Los Angeles'] = 'LA'
  
  # boundaries
  for(i in 1:nrow(countyInfo)){
    longlat = data.table(t(sapply(json[[3]][[4]][[2]][[i]][[1]][[1]],function(x){return(c(long=x[1], lat=x[2]))})))
    longlat$id = countyInfo[i,'name']
    if(i==1){
      map_dt = longlat
    } else{
      map_dt = rbind(map_dt, longlat)
    }
  }
  
  # restrict labels to counties in data
  label_df = subset(countyInfo, countyInfo$name %in% last_val$County)
  label_df$long = sapply(label_df$centroid, function(x){return(x[1])})
  label_df$lat = sapply(label_df$centroid, function(x){return(x[2])})
  
  # get the last value from the data for coloring the plot
  last_val = subset(metal, Period == max(Period))
  
  label_df$Affordability = last_val$Affordability[match(label_df$name, last_val$County)]
  map_dt$Affordability = last_val$Affordability[match(map_dt$id, last_val$County)]
  
}else{
  mapjson = mapjson2
  
  
  # layer to extract
  layer = 'OGRGeoJSON'
  
  #ogrListLayers(mapjson)
  #ogrInfo(mapjson, layer)
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
  
}

# initiate the plot
ggm = ggplot(data=map_dt, aes(x=long, y=lat)) + theme_bw()
# add map with affordability coloring
ggm = ggm + geom_map(map=map_dt,
                   aes(map_id=id, fill=Affordability),
                   color=rgb(0,0,0), size=0.25)
# add custom colors
ggm = ggm + scale_fill_continuous(low="darkred", high="thistle2", guide="colorbar",na.value=rgb(.7,.7,.7))
#gg = gg + scale_fill_continuous(na.value=rgb(.9,.9,.9))
# add county labels
ggm = ggm + geom_text(aes(label=name), data=label_df, color=rgb(.2,.2,.2), size = 4)
# restrict scope
#gg = gg + ylim(32.5, 39.1)
ggm = ggm + ylim(36, 39) + xlim(-125,-119.5)
ggm


##################
ba_counties = c('Sonoma', 'Napa', 'Sacremento', 'Solano', 'Marin', 'Contra Costa', 'San Joaquin', 'San Francisco', 'Alameda', 'Stanislaus', 'San Mateo', 'Santa Clara', 'Santa Cruz', 'Merced', 'Monterey')

metal_ba = subset(metal, County %in% ba_counties)
ggl = ggplot(data=metal_ba, aes(x=Period, y=Affordability, color=County, group=County))
ggl = ggl + geom_line() + facet_wrap(~County)
ggl

ggl2 = ggplot(data=metal_ba, aes(x=Period, y=Affordability, group=County, color=Affordability))
ggl2 = ggl2 + scale_color_continuous(low="darkred", high="thistle2", guide="colorbar",na.value=rgb(.9,.9,.9))
ggl2 = ggl2 + geom_line()
ggl2

ggl3 = ggplot(data=metal_ba, aes(x=Period, y=Affordability, group=County))
ggl3 = ggl3 + geom_line(color=rgb(0.4,0.4,0.4))
ggl3

##################
# Try Highlighting

hi = c('San Mateo', 'Santa Clara')

# initiate the plot
him = ggplot(data=map_dt, aes(x=long, y=lat)) + theme_bw()
# add map with affordability coloring
#him = him + geom_map(map=map_dt,
#                     aes(map_id=id, fill=Affordability, size=id %in% hi, color=id %in% hi)
#                     )
# him = him + scale_size_manual(values=c(0.25,1.25))
# him = him + scale_color_manual(values=c(rgb(0.4,0.4,0.4),rgb(0.1,0.1,0.1)))
him = him + geom_map(map=subset(map_dt, !id %in% hi),
                     aes(map_id=id, fill=Affordability),
                     size = 0.25, color = rgb(0.4,0.4,0.4)
)
him = him + geom_map(map=subset(map_dt, id %in% hi),
                     aes(map_id=id, fill=Affordability),
                     size = 1.25, color = rgb(0.15,0.15,0.15)
)
# add custom colors
him = him + scale_fill_continuous(low="darkred", high="thistle2", guide="colorbar",na.value=rgb(.7,.7,.7))
# add county labels
#him = him + geom_text(aes(label=name, color=name %in% hi), data=label_df, size = 4)
him = him + geom_text(aes(label=name), data=subset(label_df, name %in% hi), size = 4, color=rgb(0,0,0), fontface=2)
him = him + geom_text(aes(label=name), data=subset(label_df, ! name %in% hi), size = 4, color=rgb(0.2,0.2,0.2))
#him = him + scale_color_manual(values=c(rgb(0.2,0.2,0.2),rgb(0,0,0)))
# restrict scope
him = him + ylim(36, 39) + xlim(-125,-119.5)
him


hil = ggplot(data=metal_ba, aes(x=Period, y=Affordability, group=County))
hil = hil + geom_line(color=rgb(0.6,0.6,0.6), size=.5, data=subset(metal_ba, ! County %in% hi))
#hil = hil + geom_line(color=rgb(0.1,0.1,0.1), size=2, data=subset(metal_ba, County %in% hi))
hil = hil + geom_line(aes(color=County), size=2, data=subset(metal_ba, County %in% hi))
hil

last_val_ba = subset(last_val, County %in% ba_counties)
last_val_ba$Highlight = ifelse(last_val_ba$County %in% hi, last_val_ba$County, NA)

last_val_ba$OrderedCounty = reorder(last_val_ba$County, last_val_ba$Affordability)

hib = ggplot(data=last_val_ba, aes(x=OrderedCounty, y=Affordability))
#hil = hil + geom_bar(fill=rgb(0.6,0.6,0.6), data=subset(last_val_ba, ! County %in% hi))
hib = hib + geom_bar(aes(fill=Highlight), position = 'dodge',stat='identity')
hib = hib + theme(axis.text.y=element_text(size=14))
hib = hib+coord_flip()
hib
