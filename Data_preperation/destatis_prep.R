# This file prepares destatis for further processing
# We decided to merge Geoinformations (Coordinates) via shapefiles from https://www.diva-gis.org/gdata. At this point we were not sure about a further usage of geoinformations.
# This files use methods form functions.r , please make sure functions.r is executed.

library(openxlsx)
library(data.table)
library(tidyr)
library(dplyr)
library(sf)
library(stringr)
#Get shapefiles, downloaded from https://www.diva-gis.org/gdata

lnd84_bundl                      <- readRDS("data/gadm36_DEU_1_sp.rds")

lnd84_kreis                      <- readRDS("data/gadm36_DEU_2_sp.rds")

l_shapefile <- list()
l_shapefile[["lnd84_bundl"]]  <- lnd84_bundl
l_shapefile[["lnd84_kreis"]]  <- lnd84_kreis




#read GV100 Regionalstatistik excel file
df_xls <- read.xlsx("data/GV100.xlsx", sheet=2, startRow=5)
df_xls <- df_xls[-c(10,13)]
cols <- c("Satzart","Textkennzeichen","Land","RB","Kreis","VB","Gem","Gemeindename","Flaeche","Bevoelkerung_total", "Bevoelkerung_m","Bevoelkerung_w", "PLZ", "LON", "LAT", "Reisegebiete_Schluessel", "Reisegebiete_Name", "Siedlungsdichte_Schluessel", "Siedlungsdichte_Name")

colnames(df_xls) <- cols
#Mapping
#Create IDs for better preprocessing and clean data
df_xls                              <- cleansing_fcn(df_xls)

dtmapping_xls <- mapping_fcn(df_xls,l_shapefile)
dtmapping_xls <- dtmapping_xls[!duplicated(dtmapping_xls$Gemeindekey),]
dtmapping_xls[dtmapping_xls$KreiseSFID==229,"KreiseSF"]   <- "Göttingen"
dtmapping_xls[dtmapping_xls$KreiseSFID==229,"KreiseSFID"] <-  211

#Unemployment
#processing of the unemployment.csv


df_unemployment <- read.csv("data/13211-02-05-4.csv", sep=";", skip=7, colClasses=c("character"))
df_unemployment <- df_unemployment[c(1,2,3,4,11)]
colnames(df_unemployment) <-  c("Jahr","Kreisekey", "Ort", "Arbeitslose", "Arbeitslosenquote")
df_unemployment$Arbeitslosenquote       <- as.double(gsub(",",".",df_unemployment$Arbeitslosenquote))
df_unemployment$Arbeitslose <- as.double(df_unemployment$Arbeitslose)


df_unemployment$Kreisekey_pad  <- str_pad(df_unemployment$Kreisekey, width=5, side = c("right"), pad = "0")
df_unemployment$AUX_nchar      <- nchar(as.character(df_unemployment$Kreisekey))
df_unemployment_out                <- df_unemployment[is.na(df_unemployment$Arbeitslose)==F,]
df_unemployment_out                <- df_unemployment[is.na(df_unemployment$Arbeitslosenquote)==F,]
dt_unemployment_out                <- df_unemployment_out%>%select(Kreisekey_pad,Arbeitslose, Arbeitslosenquote)
dtout                 <- merge(dtmapping_xls,dt_unemployment_out,by.x=c("Kreisekey")
                               ,by.y=c("Kreisekey_pad"))

df_unemployment1                 <- df_unemployment[df_unemployment$AUX_nchar==2,]
df_unemployment1                 <- df_unemployment1%>%select(Kreisekey,Arbeitslose,Arbeitslosenquote)%>%rename(Arbeitslose_bl=Arbeitslose, Arbeitslosenquote_bl=Arbeitslosenquote)
dtout                 <- merge(dtout,df_unemployment1,by.x=c("Land"),by.y=c("Kreisekey"))


#population
#processing of the population.csv

df_pop <- read.csv("data/12411-02-03-4.csv", sep=";", skip=6)
colnames(df_pop) <- c("Kreisekey","Kreisname", "Altersklasse","Total","Male", "Female")
df_pop <- head(df_pop,-4)
lin                <- altersklasse_transform_fcn(df_pop)
df_pop              <- lin[["dtagg"]]
df_pop$Kreisekey_pad  <- str_pad(df_pop$Kreisekey, width=5, side = c("right"), pad = "0")
df_pop$AUX_nchar      <- nchar(as.character(df_pop$Kreisekey))
df_pop_out                  <- df_pop%>%select(Kreisekey_pad,AvgAge_total,AvgAge_female,AvgAge_male)
dtout                   <- merge(dtout,df_pop_out,by.x=c("Kreisekey")
                                 ,by.y=c("Kreisekey_pad"))

df_pop1                 <- df_pop[df_pop$AUX_nchar==2,]
df_pop1               <- df_pop1%>%select(Kreisekey,AvgAge_total,AvgAge_female,AvgAge_male)%>%rename(AvgAge_total_bl=AvgAge_total
                                                                                                     ,AvgAge_female_bl=AvgAge_female
                                                                                                     ,AvgAge_male_bl=AvgAge_male)
dtout                 <- merge(dtout,df_pop1,by.x=c("Land"),by.y=c("Kreisekey"))

#BIP
#processing of the bip.csv

df_bip <- read.csv("data/82111-01-05-4.csv", sep=";", skip=8)
df_bip <- df_bip[c(2,3,4,5,6)]
colnames(df_bip) <- c("Kreisekey", "Kreisname", "BIP", "BIP_pro_Erwerbstaetige", "BIP_pro_Einwohner")
df_bip$Kreisekey_pad  <- str_pad(df_bip$Kreisekey, width=5, side = c("right"), pad = "0")
df_bip$AUX_nchar      <- nchar(as.character(df_bip$Kreisekey))
df_bip_out                <- df_bip[is.na(df_bip$BIP)==F,]
df_bip_out                <- df_bip_out%>%select(Kreisekey_pad,BIP,BIP_pro_Einwohner,BIP_pro_Erwerbstaetige)
dtout                 <- merge(dtout,df_bip_out,by.x=c("Kreisekey")
                               ,by.y=c("Kreisekey_pad"))
df_bip1                 <- df_bip[df_bip$AUX_nchar==2,]
df_bip1                <- df_bip1%>%select(Kreisekey,BIP,BIP_pro_Einwohner,BIP_pro_Erwerbstaetige)%>%rename(BIP_bl=BIP
                                                                                                            ,BIP_pro_Einwohner_bl=BIP_pro_Einwohner
                                                                                                            ,BIP_pro_Erwerbstaetige_bl=BIP_pro_Erwerbstaetige)
dtout                 <- merge(dtout,df_bip1,by.x=c("Land"),by.y=c("Kreisekey"))


#Income
#preprocessing of income.csv

df_income <- read.csv("data/82411-01-03-4.csv", sep=";", skip=6)
colnames(df_income) <- c("Jahr","Kreisekey", "Kreisname", "Einkommen_total", "Einkommen_proKopf")
df_income$Kreisekey_pad       <- str_pad(df_income$Kreisekey, width=5, side = c("right"), pad = "0")
df_income$AUX_nchar           <- nchar(as.character(df_income$Kreisekey))
df_income_out                  <- df_income[is.na(df_income$Einkommen_total)==F,]
df_income_out                  <- df_income_out%>%select(Kreisekey_pad,Einkommen_proKopf,Einkommen_total)
dtout                   <- merge(dtout,df_income_out,by.x=c("Kreisekey")
                                 ,by.y=c("Kreisekey_pad"))

df_income1                 <- df_income[df_income$AUX_nchar==2,]
df_income1                 <- df_income1%>%select(Kreisekey,Einkommen_proKopf,Einkommen_total)%>%rename(Einkommen_proKopf_bl=Einkommen_proKopf
                                                                                                        ,Einkommen_total_bl=Einkommen_total)
dtout                 <- merge(dtout,df_income1,by.x=c("Land"),by.y=c("Kreisekey"))


dtdestatis   <- dtout


#Select the features


dtdestatis  <- dtdestatis%>%select(Kreisekey,Gemeindekey,Gemeindename
                                   ,Flaeche,Bevoelkerung_total,Bevoelkerung_m,Bevoelkerung_w
                                   ,PLZ,LON,LAT,Reisegebiete_Schluessel,Reisegebiete_Name
                                   ,Siedlungsdichte_Schluessel,Siedlungsdichte_Name
                                   ,BundeslandSF,BundeslandSFID,KreiseSF,KreiseSFID
                                   ,Arbeitslosenquote,Arbeitslose,AvgAge_total,AvgAge_female,AvgAge_male
                                   ,BIP,BIP_pro_Einwohner,BIP_pro_Erwerbstaetige,Einkommen_proKopf,Einkommen_total
                                   ,Arbeitslosenquote_bl,Arbeitslose_bl,AvgAge_total_bl,AvgAge_female_bl,AvgAge_male_bl
                                   ,BIP_bl,BIP_pro_Einwohner_bl,BIP_pro_Erwerbstaetige_bl,Einkommen_proKopf_bl,Einkommen_total_bl
)
#Write csv
write.table(dtdestatis, file = "data/destatis_data.csv", row.names = FALSE, sep = ";", quote = FALSE)




