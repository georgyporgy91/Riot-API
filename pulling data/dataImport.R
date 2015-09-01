#import packages
library("jsonlite")


#change directory
preN5 <- "data/5.11/NORMAL_5X5"
preR1 <- "data/5.11/RANKED_SOLO"
postN5 <- "data/5.14/NORMAL_5X5"
postR1 <- "data/5.14/RANKED_SOLO"

#Obtain matchIDs
filenames <- list.files(postN5,patter="*.json", full.names=TRUE)
allFiles <- fromJSON(filenames[7])

#Grab data from API based on MatchID
robustfromJSON = function(x,y){
	tryCatch(
		fromJSON(x),
		#warning = function(w) {print(x); warned <-rbind(warned,GAMEID)},
		error = function(e) {print(x); y}
	) 
}




KEY = "<ENTER YOUR KEY HERE>"
TIMELINE <- "true"
REGION <- "na"

output=data.frame()
failed <-c()

for (j in 1:10000){

Sys.sleep(1.3) #add delay in loop to be within rate limit, 1.3 sec per request
GAMEID <- allFiles[j] #for all 10,000 games
url <- paste("https://" , REGION , ".api.pvp.net/api/lol/" , REGION , "/v2.2/match/" , GAMEID , "?includeTimeline=", TIMELINE,"&api_key=" , KEY, sep="")
data <- robustfromJSON(url, GAMEID)

if (class(data)=="list"){
matchId <- data$matchId
region <- data$region
queueType <-data$queueType
patch <-data$matchVersion
side <- data$participants$teamId
champion <- data$participants$championId
rank <- data$participants$highestAchievedSeasonTier
role <- data$participants$timeline$role
lane <- data$participants$timeline$lane
item0 <- data$participants$stats$item0
item1 <- data$participants$stats$item1
item2 <- data$participants$stats$item2
item3 <- data$participants$stats$item3
item4 <- data$participants$stats$item4
item5 <- data$participants$stats$item5
item6 <- data$participants$stats$item6
winner <- data$participants$stats$winner

data_relevant <- data.frame(matchId,region,queueType,patch,side,champion,rank,role,lane,
		item0,item1,item2,item3,item4,item5,item6,winner)
output <- rbind(output,data_relevant)

} else{
	failed <- rbind(failed,data)
}

}

write.csv(output,"RequestData_post.csv")	
write.csv(failed,"FailedRequests_post.csv")		



#import items
urlItemPre <- paste("https://global.api.pvp.net/api/lol/static-data/na/v1.2/item?locale=en_US&version=5.11.1&itemListData=all&api_key=",KEY, sep="")
itemListPre <- fromJSON(urlItemPre)
urlItemPost <- paste("https://global.api.pvp.net/api/lol/static-data/na/v1.2/item?locale=en_US&version=5.14.1&itemListData=all&api_key=",KEY, sep="")
itemListPost <- fromJSON(urlItemPre)

#data structure #head(data)
#data [list]
	#timeline [data.frame]
		#frameInterval # frameinterval is 60000 ms, which is 1 minute
		#frames [data.frame]
			#timestamp
			#events
				#sorted by minute mark, within each a list of events that happened
			#participantFrames
				#1,2,3,4,5,6,7,8,9,10
					#various status by player


