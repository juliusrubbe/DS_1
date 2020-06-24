# This file merges the immobilienscour24 dataset from kaggle, with the prepared destatis dataset
library(stringr)
library(data.table)
library(dplyr)
library(tidyverse)
library(magrittr)

#Read files
df <- read.csv2("data/immo_data.csv", sep=",")
df_destatis <- read.csv2("data/destatis_data.csv", sep=";")


#Prepare Gemeindename for better merging
df$geo_plz <- str_pad(df$geo_plz,5, side="left", pad=0)
df_destatis$Gemeindename <- str_replace(df_destatis$Gemeindename, ", (Stadt)", "")
df_destatis$Gemeindename <- str_replace(df_destatis$Gemeindename, ", (Stadt)", "")
df_destatis$Gemeindename <- str_replace(df_destatis$Gemeindename, ", (Landeshauptstadt)", "")
df_destatis$Gemeindename <- str_replace(df_destatis$Gemeindename, ", (Landeshauptstadt)", "")
df_destatis$Gemeindename <- gsub("\\,.*","",df_destatis$Gemeindename)
df$geo_krs <- str_replace(df$geo_krs, "ÃŸ", "ß")
df$geo_krs <- str_replace(df$geo_krs, "Ã¼", "ü")
df$geo_krs <- str_replace(df$geo_krs, "Ã¤", "ä")
df$geo_krs <- str_replace(df$geo_krs, "Ã¶", "ö")
df$geo_krs <- str_replace(df$geo_krs, " Kreis", "")
df$geo_krs <- str_replace_all(df$geo_krs, "_", " ")


#merge data
df_merged_new <- merge(df,df_destatis, by.x='geo_krs', by.y="Gemeindename", all=F)

df <- data.table(df)
df_destatis <-  data.table(df_destatis)
df_destatis$PLZ <- as.character(df_destatis$PLZ)
df_merged <- merge(df, df_destatis, by.x = 'geo_plz', by.y ='PLZ', all = F)

df_population <- df_merged %>% group_by(df_merged$geo_plz) %>% summarise(sum(df_merged$Bevoelkerung_total))
df_pop <- df_merged %>% filter(df_merged$Bevoelkerung_total > 20000)

df_pop_new <- df_merged_new %>% filter(df_merged_new$Bevoelkerung_total > 20000)


cols <- colnames(df_merged_new)
na_count <-sapply(df_merged_new, function(y) sum(length(which(is.na(y)))))

df_nans <- data.frame(na_count)
df_nans <- data.frame(rownames(df_nans),df_nans$na_count)
df_nans <- df_nans %>% filter(df_nans$df_nans.na_count > 40000)

#Data Cleaning and preperation
#Drop columns with NaNs and not relevant columns
drop_cols <- c(df_nans$rownames.df_nans.)

df_cleaned <- df_merged_new
df_cleaned <- df_cleaned[-drop_cols]
drop_cols2 <- c("street", "streetPlain", "PLZ", "description", "facilities","regio2","regio3","picturecount","Kreisekey" )
df_cleaned <- df_cleaned[, !colnames(df_cleaned) %in% drop_cols2]
drops <- c("geo_krs", "regio1", "telekomTvOffer","telekomHybridUploadSpeed", "scoutId" , "geo_bln", "houseNumber", "condition", "interiorQual", "geo_plz", "electricityBasePrice", "Gemeindekey", "Reisegebiete_Schluessel","KreiseSF", "KreiseSFID", "AvgAge_female_bl", "heatingCosts","BIP_pro_Erwerbstaetige_bl", "energyEfficiencyClass",  "Einkommen_proKopf_bl", "Einkommen_total_bl", "Arbeitslose_bl")
df_cleaned <- df_cleaned[,!colnames(df_cleaned) %in% drops]
na_count <-sapply(df_cleaned, function(y) sum(length(which(is.na(y)))))
df_nans2 <- data.frame(na_count)
df_nans2 <- data.frame(rownames(df_nans2),df_nans2$na_count)
df_cleaned <- df_cleaned[, !colnames(df_cleaned) %in% c("noParkSpaces", "electricityKwhPrice")]


#Split into numerical and categorial vars
numerical_vars <- c('serviceCharge','pricetrend','telekomUploadSpeed','totalRent','yearConstructed','noParkSpaces','yearConstructedRange' 
                     ,'baseRentRange','numberOfFloors','noRoomsRange','livingSpaceRange','Flaeche','Bevoelkerung_m','Bevoelkerung_w' 
                     ,'LON','LAT','Siedlungsdichte_Schluessel','Arbeitslosenquote','Arbeitslose','AvgAge_total' 
                     ,'AvgAge_female','AvgAge_male','BIP','BIP_pro_Einwohner','BIP_pro_Erwerbstaetige','Einkommen_proKopf','Einkommen_total' 
                     ,'Arbeitslosenquote_bl','AvgAge_male_bl','BIP_pro_Einwohner_bl' ,'baseRent','livingSpace')



df_numerical <- df_cleaned[, colnames(df_cleaned) %in% numerical_vars]

i <- c(1:31)
#all to numeric type
df_numerical[ , i] <- apply(df_numerical[ , i], 2, 
                    function(x) as.numeric(as.character(x)))

#change type to numeric
df_categorial <- df_cleaned[, !colnames(df_cleaned) %in% colnames(df_numerical)]
df_categorial$heatingType <- as.numeric(df_categorial$heatingType)
df_categorial$newlyConst <- as.numeric(df_categorial$newlyConst)
df_categorial$balcony <- as.numeric(df_categorial$balcony)
df_categorial$firingTypes <- as.numeric(df_categorial$firingTypes)
df_categorial$hasKitchen <- as.numeric(df_categorial$hasKitchen)
df_categorial$cellar <- as.numeric(df_categorial$cellar)
df_categorial$petsAllowed <- as.numeric(df_categorial$petsAllowed)
df_categorial$lift <- as.numeric(df_categorial$lift)
df_categorial$typeOfFlat <- as.numeric(df_categorial$typeOfFlat)
df_categorial$garden <- as.numeric(df_categorial$garden)
df_categorial$Siedlungsdichte_Name <- as.numeric(df_categorial$Siedlungsdichte_Name)



na_count <-sapply(df_numerical, function(y) sum(length(which(is.na(y)))))
df_nans2 <- data.frame(na_count)
df_nans2 <- data.frame(rownames(df_nans2),df_nans2$na_count)
df_nans2 <- df_nans2 %>%filter(df_nans2$df_nans2.na_count==0)
cols_num <- df_nans2$rownames.df_nans2.



na_count <-sapply(df_categorial, function(y) sum(length(which(is.na(y)))))
df_nans2 <- data.frame(na_count)
df_nans2 <- data.frame(rownames(df_nans2),df_nans2$na_count)
df_nans2 <- df_nans2 %>%filter(df_nans2$df_nans2.na_count==0)
cols_cat <- df_nans2$rownames.df_nans2.

df_categorial <- df_categorial[, colnames(df_categorial) %in% cols_cat]
df_numerical <- df_numerical[, colnames(df_numerical) %in% cols_num]




#remerge categorial and numeric variables
df_v2_merged <- cbind(df_numerical, df_categorial)
#drop if livingSpace is less than 10
df_v2_merged <- df_v2_merged %>% filter(df_v2_merged$livingSpace > 10)
#drop if baserent is less than 100
df_v2_merged <- df_v2_merged  %>% filter(df_v2_merged$baseRent > 100)
#create new var rent_per_m2
df_v2_merged$rent_per_m2 <- df_v2_merged$baseRent /df_v2_merged$livingSpace
#Overview
summary(df_v2_merged$rent_per_m2)
#create new var category_rent
df_v2_merged$category_rent <- ifelse(df_v2_merged$rent_per_m2<=5,1,ifelse(df_v2_merged$rent_per_m2<=7,2,ifelse(df_v2_merged$rent_per_m2<=9,3,ifelse(df_v2_merged$rent_per_m2<=11,4,ifelse(df_v2_merged$rent_per_m2<=13,5,ifelse(df_v2_merged$rent_per_m2<=15,6,ifelse(df_v2_merged$rent_per_m2<=17,7,8))))))) 

df_agg_cat <- df_v2_merged %>% group_by(category_rent) %>% summarise(COUNT = n())
#drop Nans
na_count <-sapply(df_v2_merged, function(y) sum(length(which(is.na(y)))))
df_nans2 <- data.frame(na_count)
df_nans2 <- data.frame(rownames(df_nans2),df_nans2$na_count)
df_nan <- df_nans2 %>% filter(df_nans2$df_nans2.na_count>0)
drop_nans <- df_nan$rownames.df_nans2.

df_v2_merged <- df_v2_merged[, !colnames(df_v2_merged) %in% drop_nans]
df_v2_merged<- df_v2_merged[,!colnames(df_v2_merged) %in% c("LON","LAT","baseRent","baseRentRange","rent_per_m2","Siedlungsdichte_Schluessel","livingSpaceRange", "AvgAge_male_bl")]

cols <- c('living_space'	,'no_rooms_range',	'area'	,'population_m'	,'population_w',
'unemployment_quote'	,'unemployed',	'avg_age_total',	'avg_age_female','avg_age_female'	,'GDP',
'GDP_per_inhabitant',	'BIP_per_employed'	,'income_head',	'income_total'	,'unemplymentrate_federalstate',
'GDP_per_inhabitant_federstate',	'newly_const'	,'balcony'	,'has_kitchen',
'cellar',	'lift',	'garden',	'population_density',	'category_rent')

colnames(df_v2_merged) <- cols



write.table(df_v2_merged, file = "data_prepared_and_ready_numeric.csv", row.names = FALSE, sep = ";", quote = FALSE)
