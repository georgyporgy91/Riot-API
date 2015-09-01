######
#creating item mapping from ID to name
KEY = "<ENTER YOUR KEY HERE>"

urlItemPre <- paste("https://global.api.pvp.net/api/lol/static-data/na/v1.2/item?locale=en_US&version=5.11.1&itemListData=all&api_key=",KEY, sep="")
itemListPre <- fromJSON(urlItemPre)
urlItemPost <- paste("https://global.api.pvp.net/api/lol/static-data/na/v1.2/item?locale=en_US&version=5.14.1&itemListData=all&api_key=",KEY, sep="")
itemListPost <- fromJSON(urlItemPre)

itemMapping <- data.frame(itemID=itemCommon, itemName="")
itemMapping$itemName <- as.character(itemMapping$itemName)
for (i in 1:length(itemCommon)){
	if(!is.null(itemListPost$data[[itemCommon[i]]]$name)){
	itemMapping$itemName[i] <- itemListPost$data[[itemCommon[i]]]$name
	}
}

write.csv(itemMapping, "itemMapping.csv")
######

#data.frame(summary(itemListPre$data))$Var1