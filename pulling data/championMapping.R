#############
#AP Champions
KEY = "<ENTER YOUR KEY HERE>"

urlChampion <- paste("https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?version=5.14.1&champData=all&api_key=",KEY, sep="")
championList <- fromJSON(urlChampion)
championNames <- row.names(summary(championList$data))
champion <- c()
for (i in 1:length(championNames)){
	champion[i] <- championList$data[[championNames[i]]]$id
}


championMapping <- data.frame(champion, championNames, APAD="")
championMapping$APAD <- as.character(championMapping$APAD)

for (i in 1:length(championNames)){
	if("Mage" %in% championList$data[[championNames[i]]]$tags){
	championMapping$APAD[i] <- "AP"
	} else {
	championMapping$APAD[i] <- "AD"
	}
}

write.csv(championMapping, "championMapping.csv")
##############