

ori <- read.csv('~/Downloads/test_MI/2009001_combine.csv', stringsAsFactors = F)
gap <- read.csv('~/Downloads/test_MI/output/2009001_MI.csv', stringsAsFactors = F)

ori$AOT550 <- rep(NA, nrow(ori))
ori$AOT550[gap$ID] <- gap$AOT550_3

ori2 <- subset(ori, select = c(ID, Lat, Lon, AOD550_TAOT, AOT550))

# Lat/Lon
gap$Lat <- ori$Lat[gap$ID]
gap$Lon <- ori$Lon[gap$ID]

library(ggplot2)
library(ggmap)
# getting the map
mapgilbert <- get_map(location = c(lon = mean(gap$Lon), lat = mean(gap$Lat)), zoom = 6, maptype = "satellite")

# colorbar 
# define jet colormap
jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

gg <- ggmap(mapgilbert, extent = 'panel')
gg1 <- gg + geom_tile(data = ori, aes(Lon, Lat, fill = AOD550_TAOT, width = 0.047, height = 0.047), alpha = 0.8)
ggsave("mtcars.png", plot = gg1)
gg2 <- ggplot() + geom_tile(data = gap, aes(Lon, Lat, fill = AOT550_3, width = 0.02, height = 0.02), alpha = 0.7) + scale_fill_gradientn(colours = jet.colors(15))
# gg2 <- ggplot()+geom_tile(data = dat.tmp, aes(Lon, Lat, fill = Cloud_Frac, width = 0.1, height = 0.1), alpha = 1)

## AERONET vs MI
aero <- subset(ori, subset = !is.na(AERONET_AOD550))
plot(aero$AERONET_AOD550, aero$AOT550)

