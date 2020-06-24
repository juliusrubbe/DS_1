#This file contains helper functions for destatis_prep.R

geomapping_fcn <- function(dt,l_shapefile,nametmp){
  
  
  dt1tmp              <- unique(dt%>%select(nametmp))
  coordinates(dt1tmp) <- c("LON","LAT")
  dt1geo              <- st_as_sf(dt1tmp)%>%mutate(id=1:n())
  
  #Bundesland:
  lnd84 <- l_shapefile[["lnd84_bundl"]]
  
  i <- 1
  dt1geo[,"BundeslandSF"]   <- NA
  dt1geo[,"BundeslandSFID"] <- NA
  for(i in 1:length(lnd84$NAME_1)){
    print(i)
    shape_sel             <- lnd84[lnd84$NAME_1==lnd84$NAME_1[i],]
    checktmp              <- as_Spatial(dt1geo$geometry)
    proj4string(checktmp) <- proj4string(shape_sel)
    inside.check          <- !is.na(over(checktmp, as(shape_sel, "SpatialPolygons")))
    dt1geo[inside.check,"BundeslandSF"]    <- lnd84$NAME_1[i]
    dt1geo[inside.check,"BundeslandSFID"]  <- i
    
  }
  
  #Kreis:
  lnd84 <- l_shapefile[["lnd84_kreis"]]
  
  i <- 1
  dt1geo[,"KreiseSF"]   <- NA
  dt1geo[,"KreiseSFID"] <- NA
  for(i in 1:length(lnd84$NAME_2)){
    print(i)
    shape_sel             <- lnd84[lnd84$NAME_2==lnd84$NAME_2[i],]
    checktmp              <- as_Spatial(dt1geo$geometry)
    proj4string(checktmp) <- proj4string(shape_sel)
    inside.check          <- !is.na(over(checktmp, as(shape_sel, "SpatialPolygons")))
    dt1geo[inside.check,"KreiseSF"]    <- lnd84$NAME_2[i]
    dt1geo[inside.check,"KreiseSFID"]  <- i
    
  }
  dt1geo <- dt1geo[is.na(dt1geo$BundeslandSF)==F & is.na(dt1geo$KreiseSF)==F, ]
  
  
  return(dt1geo)
}

convert2numeric <- function(dt,col="Bevoelkerung_total"){
  
  df  <- as.data.frame(dt)
  
  df[,col]  <- gsub(" ","",df[,col])
  df[,col]  <- as.double(df[,col])
  df        <- df[is.na(df[,col])==F,]
  
  dt        <- as.data.table(df)
  
  return(dt)
  
  
}

#Clean the dataset
cleansing_fcn <- function(df){
  
  df$LAT                <- as.double(gsub(",",".",df$LAT))
  df$LON                <- as.double(gsub(",",".",df$LON))
  df$Flaeche            <- as.double(gsub(",",".",df$Flaeche))
  df$Bevoelkerung_m     <- as.double(gsub(" ","",df$Bevoelkerung_m))
  df$Bevoelkerung_w     <- as.double(gsub(" ","",df$Bevoelkerung_w))
  df$Bevoelkerung_total <- as.double(gsub(" ","",df$Bevoelkerung_total))
  
  return(df)
}


mapping_fcn <- function(df,l_shapefile){
  
  
  #Gemeinden:
  df1                 <- df[is.na(df$LON)==F,]
  dt1                 <- as.data.table(df1)
  dt1$Gemeindekey     <- paste0(dt1$Land,dt1$RB,dt1$Kreis,dt1$VB,dt1$Gem)
  dt1$Kreisekey       <- paste0(dt1$Land,dt1$RB,dt1$Kreis)
  
  #Kreise:
  df2 <- df[df$VB=="" & df$Gem=="" & df$Kreis!="" & df$RB!="" & df$Land!="",]
  dt2 <- as.data.table(df2)
  dt2$Kreisekey       <- paste0(dt2$Land,dt2$RB,dt2$Kreis)
  
  dt1tmp              <- unique(dt1%>%select(Gemeindekey,LON,LAT))
  coordinates(dt1tmp) <- c("LON","LAT")
  dt1geo              <- st_as_sf(dt1tmp)%>%mutate(id=1:n())
  
  #Bundesland:
  lnd84 <- l_shapefile[["lnd84_bundl"]]
  
  i <- 1
  dt1geo[,"BundeslandSF"]   <- NA
  dt1geo[,"BundeslandSFID"] <- NA
  for(i in 1:length(lnd84$NAME_1)){
    print(i)
    shape_sel             <- lnd84[lnd84$NAME_1==lnd84$NAME_1[i],]
    checktmp              <- as_Spatial(dt1geo$geometry)
    proj4string(checktmp) <- proj4string(shape_sel)
    inside.check          <- !is.na(over(checktmp, as(shape_sel, "SpatialPolygons")))
    dt1geo[inside.check,"BundeslandSF"]    <- lnd84$NAME_1[i]
    dt1geo[inside.check,"BundeslandSFID"]  <- i
    
  }
  
  #Kreis:
  lnd84 <- l_shapefile[["lnd84_kreis"]]
  
  i <- 1
  dt1geo[,"KreiseSF"]   <- NA
  dt1geo[,"KreiseSFID"] <- NA
  for(i in 1:length(lnd84$NAME_2)){
    print(i)
    shape_sel             <- lnd84[lnd84$NAME_2==lnd84$NAME_2[i],]
    checktmp              <- as_Spatial(dt1geo$geometry)
    proj4string(checktmp) <- proj4string(shape_sel)
    inside.check          <- !is.na(over(checktmp, as(shape_sel, "SpatialPolygons")))
    dt1geo[inside.check,"KreiseSF"]    <- lnd84$NAME_2[i]
    dt1geo[inside.check,"KreiseSFID"]  <- i
    
  }
  dt1geo <- dt1geo[is.na(dt1geo$BundeslandSF)==F & is.na(dt1geo$KreiseSF)==F, ]
  dt1geo <- merge(dt1,dt1geo,by=c("Gemeindekey"))
  
  return(dt1geo)
  
  
}


altersklasse_transform_fcn <- function(dt=dt3){
  
  v_seq  <- seq(1,9684,by=18)
  i <- 1
  for(i in v_seq){
    print(i)
    kreisekey      <- dt[i,1]
    dt[i:(i+17),1] <- kreisekey
    
  }
  
  dt[dt$Altersklasse=="unter 3 Jahre","Altersklasse_mean"]  <- 1
  dt[dt$Altersklasse=="unter 3 Jahre","Altersklasse_upper"] <- 2
  dt[dt$Altersklasse=="unter 3 Jahre","Altersklasse_lower"] <- 0
  
  dt[dt$Altersklasse=="3 bis unter 6 Jahre","Altersklasse_mean"]  <- 4
  dt[dt$Altersklasse=="3 bis unter 6 Jahre","Altersklasse_upper"] <- 5
  dt[dt$Altersklasse=="3 bis unter 6 Jahre","Altersklasse_lower"] <- 3
  
  dt[dt$Altersklasse=="6 bis unter 10 Jahre","Altersklasse_mean"]  <- 7.5
  dt[dt$Altersklasse=="6 bis unter 10 Jahre","Altersklasse_upper"] <- 9
  dt[dt$Altersklasse=="6 bis unter 10 Jahre","Altersklasse_lower"] <- 6
  
  dt[dt$Altersklasse=="10 bis unter 15 Jahre","Altersklasse_mean"]  <- 12
  dt[dt$Altersklasse=="10 bis unter 15 Jahre","Altersklasse_upper"] <- 14
  dt[dt$Altersklasse=="10 bis unter 15 Jahre","Altersklasse_lower"] <- 10
  
  dt[dt$Altersklasse=="15 bis unter 18 Jahre","Altersklasse_mean"]  <- 16
  dt[dt$Altersklasse=="15 bis unter 18 Jahre","Altersklasse_upper"] <- 17
  dt[dt$Altersklasse=="15 bis unter 18 Jahre","Altersklasse_lower"] <- 15
  
  dt[dt$Altersklasse=="18 bis unter 20 Jahre","Altersklasse_mean"]  <- 18.5
  dt[dt$Altersklasse=="18 bis unter 20 Jahre","Altersklasse_upper"] <- 19
  dt[dt$Altersklasse=="18 bis unter 20 Jahre","Altersklasse_lower"] <- 18
  
  dt[dt$Altersklasse=="20 bis unter 25 Jahre","Altersklasse_mean"]  <- 22
  dt[dt$Altersklasse=="20 bis unter 25 Jahre","Altersklasse_upper"] <- 24
  dt[dt$Altersklasse=="20 bis unter 25 Jahre","Altersklasse_lower"] <- 20
  
  dt[dt$Altersklasse=="25 bis unter 30 Jahre","Altersklasse_mean"]  <- 27
  dt[dt$Altersklasse=="25 bis unter 30 Jahre","Altersklasse_upper"] <- 29
  dt[dt$Altersklasse=="25 bis unter 30 Jahre","Altersklasse_lower"] <- 25
  
  dt[dt$Altersklasse=="30 bis unter 35 Jahre","Altersklasse_mean"]  <- 32
  dt[dt$Altersklasse=="30 bis unter 35 Jahre","Altersklasse_upper"] <- 34
  dt[dt$Altersklasse=="30 bis unter 35 Jahre","Altersklasse_lower"] <- 30
  
  dt[dt$Altersklasse=="35 bis unter 40 Jahre","Altersklasse_mean"]  <- 37
  dt[dt$Altersklasse=="35 bis unter 40 Jahre","Altersklasse_upper"] <- 39
  dt[dt$Altersklasse=="35 bis unter 40 Jahre","Altersklasse_lower"] <- 35
  
  dt[dt$Altersklasse=="40 bis unter 45 Jahre","Altersklasse_mean"]  <- 42
  dt[dt$Altersklasse=="40 bis unter 45 Jahre","Altersklasse_upper"] <- 44
  dt[dt$Altersklasse=="40 bis unter 45 Jahre","Altersklasse_lower"] <- 40
  
  dt[dt$Altersklasse=="45 bis unter 50 Jahre","Altersklasse_mean"]  <- 47
  dt[dt$Altersklasse=="45 bis unter 50 Jahre","Altersklasse_upper"] <- 49
  dt[dt$Altersklasse=="45 bis unter 50 Jahre","Altersklasse_lower"] <- 45
  
  dt[dt$Altersklasse=="50 bis unter 55 Jahre","Altersklasse_mean"]  <- 52
  dt[dt$Altersklasse=="50 bis unter 55 Jahre","Altersklasse_upper"] <- 54
  dt[dt$Altersklasse=="50 bis unter 55 Jahre","Altersklasse_lower"] <- 50
  
  dt[dt$Altersklasse=="55 bis unter 60 Jahre","Altersklasse_mean"]  <- 57
  dt[dt$Altersklasse=="55 bis unter 60 Jahre","Altersklasse_upper"] <- 59
  dt[dt$Altersklasse=="55 bis unter 60 Jahre","Altersklasse_lower"] <- 55
  
  dt[dt$Altersklasse=="60 bis unter 65 Jahre","Altersklasse_mean"]  <- 62
  dt[dt$Altersklasse=="60 bis unter 65 Jahre","Altersklasse_upper"] <- 64
  dt[dt$Altersklasse=="60 bis unter 65 Jahre","Altersklasse_lower"] <- 60
  
  dt[dt$Altersklasse=="65 bis unter 75 Jahre","Altersklasse_mean"]  <- 69.5
  dt[dt$Altersklasse=="65 bis unter 75 Jahre","Altersklasse_upper"] <- 74
  dt[dt$Altersklasse=="65 bis unter 75 Jahre","Altersklasse_lower"] <- 65
  
  dt[dt$Altersklasse=="75 Jahre und mehr","Altersklasse_mean"]  <- 81
  dt[dt$Altersklasse=="75 Jahre und mehr","Altersklasse_upper"] <- 87
  dt[dt$Altersklasse=="75 Jahre und mehr","Altersklasse_lower"] <- 75
  dt <- dt[dt$Altersklasse!="Insgesamt",]
  
  dt$Total   <- as.double(dt$Total)
  dt$Male    <- as.double(dt$Male)
  dt$Female  <- as.double(dt$Female)
  dt         <- dt[is.na(dt$Total)==F,]
  
  dt$AvgAge_total  <- dt$Total*dt$Altersklasse_mean
  dt$AvgAge_male   <- dt$Male*dt$Altersklasse_mean
  dt$AvgAge_female <- dt$Female*dt$Altersklasse_mean
  
  #Durchschnittsalter pro Kreis:
  dt     <- as.data.table(dt)
  dtagg  <- dt[,list(Total=sum(Total)
                     ,Female=sum(Female)
                     ,Male=sum(Male)
                     ,AvgAge_total=sum(AvgAge_total)
                     ,AvgAge_male=sum(AvgAge_male)
                     ,AvgAge_female=sum(AvgAge_female)
  )
  ,by=c("Kreisekey")
  ]
  dtagg$AvgAge_total  <- dtagg$AvgAge_total/dtagg$Total
  dtagg$AvgAge_male   <- dtagg$AvgAge_male/dtagg$Male
  dtagg$AvgAge_female <- dtagg$AvgAge_female/dtagg$Female
  
  
  
  lout <- list()
  
  lout[["dtagg"]]  <- dtagg
  lout[["dt"]]     <- dt
  
  return(lout)
  
}



