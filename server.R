#rm(list=ls())

library(shiny)
library(ggplot2)
library(reshape2)
library(scales)

dataPre <- read.csv("data/RequestData.csv")
dataPost <- read.csv("data/RequestData_post.csv")
championMapping <- read.csv("data/championMapping.csv")
itemMapping <- read.csv("data/itemMapping.csv")


#merge data
dataPre <- merge(dataPre, championMapping, by="champion")
dataPost <- merge(dataPost, championMapping, by="champion")

changedItems <- c(
"Rabadon's Deathcap",
"Zhonya's Hourglass",
"Luden's Echo",
"Rylai's Crystal Scepter",
"Archangel's Staff",
"Seraph's Embrace",
"Rod of Ages",
"Haunting Guise",
"Liandry's Torment",
"Void Staff",
"Nashor's Tooth",
"Will of the Ancients",
"Morellonomicon",
"Athene's Unholy Grail")

changedItemsDF <- data.frame(itemName=changedItems)
changedItemsDF <- merge(changedItemsDF, itemMapping, by="itemName")
changedItemsDF$X = NULL



shinyServer(
  function(input, output) {

    #-------------------- bar plot of item frequency by champion --------------------------#
    output$graph1 <- renderPlot({
	dataPre <- subset(dataPre, subset=(championNames == input$champion))
	dataPost <- subset(dataPost, subset=(championNames == input$champion))

		##### Calculations
		#data cleaning and aggregation
		itemPre <- with(dataPre, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPost <- with(dataPost, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPre$value <- as.factor(itemPre$value)
		itemPost$value <- as.factor(itemPost$value)
		itemPre$patch <- "5.11"
		itemPost$patch <- "5.14"
		itemPre$variable <- NULL
		itemPost$variable <- NULL
		
		#common set of items between patches
		itemCommon <- intersect(unique(itemPre$value),unique(itemPost$value))
		itemExclude <-c("0","3340","3361","3362","3364","3363","3341","3342") #remove empty slot and trinkets
		itemCommon <- setdiff(itemCommon, itemExclude)
		itemPre_sub <- subset(itemPre, subset=(value %in% itemCommon)) 
		itemPost_sub <- subset(itemPost, subset=(value %in% itemCommon)) 
		allItem <- rbind(itemPre_sub,itemPost_sub)
		
		#frequency of each item
		freqPre <- data.frame(table(itemPre_sub))
		freqPre_sub <- freqPre[freqPre$Freq!=0,]
		freqPre_sub$FreqScaled <- freqPre_sub$Freq/nrow(itemPre_sub)
		freqPre_sub <- freqPre_sub[order(-freqPre_sub$FreqScaled),]
		colnames(freqPre_sub)[1] <- "itemID"
		freqPre_sub <- merge(freqPre_sub, itemMapping , by="itemID")
	
		freqPost <- data.frame(table(itemPost_sub))
		freqPost_sub <- freqPost[freqPost$Freq!=0,]
		freqPost_sub$FreqScaled <- freqPost_sub$Freq/nrow(itemPost_sub)
		freqPost_sub <- freqPost_sub[order(-freqPost_sub$FreqScaled),]
		colnames(freqPost_sub)[1] <- "itemID"
		freqPost_sub <- merge(freqPost_sub, itemMapping , by="itemID")

		allItem_sub <- rbind(freqPre_sub, freqPost_sub)

    	  	######
	
      ggplot(data=allItem_sub) + 
	geom_bar(position="dodge", stat="identity")+
	aes(x=reorder(itemName, -FreqScaled), y=FreqScaled, fill=patch)+
	geom_hline(yintercept=1/nrow(freqPost_sub)) + 
	theme(axis.text.x=element_text(angle=90, size=10, vjust=0.5)) +
	labs(title=paste("Item frequency distribution for ",input$champion, " in 5.11 and 5.14"), x="Item by popularity", y="Scaled item frequency")
	})






	#-------------------- table of item frequency by champion --------------------------#
	output$table1 <- renderTable({
	dataPre <- subset(dataPre, subset=(championNames == input$champion))
	dataPost <- subset(dataPost, subset=(championNames == input$champion))

		##### Calculations
		#data cleaning and aggregation
		itemPre <- with(dataPre, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPost <- with(dataPost, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPre$value <- as.factor(itemPre$value)
		itemPost$value <- as.factor(itemPost$value)
		itemPre$patch <- "5.11"
		itemPost$patch <- "5.14"
		itemPre$variable <- NULL
		itemPost$variable <- NULL
		
		#common set of items between patches
		itemCommon <- intersect(unique(itemPre$value),unique(itemPost$value))
		itemExclude <-c("0","3340","3361","3362","3364","3363","3341","3342") #remove empty slot and trinkets
		itemCommon <- setdiff(itemCommon, itemExclude)
		itemPre_sub <- subset(itemPre, subset=(value %in% itemCommon)) 
		itemPost_sub <- subset(itemPost, subset=(value %in% itemCommon)) 
		allItem <- rbind(itemPre_sub,itemPost_sub)
		
		#frequency of each item
		freqPre <- data.frame(table(itemPre_sub))
		freqPre_sub <- freqPre[freqPre$Freq!=0,]
		freqPre_sub$FreqScaled <- freqPre_sub$Freq/nrow(itemPre_sub)
		freqPre_sub <- freqPre_sub[order(-freqPre_sub$FreqScaled),]
		colnames(freqPre_sub)[1] <- "itemID"
		freqPre_sub <- merge(freqPre_sub, itemMapping , by="itemID")
	
		freqPost <- data.frame(table(itemPost_sub))
		freqPost_sub <- freqPost[freqPost$Freq!=0,]
		freqPost_sub$FreqScaled <- freqPost_sub$Freq/nrow(itemPost_sub)
		freqPost_sub <- freqPost_sub[order(-freqPost_sub$FreqScaled),]
		colnames(freqPost_sub)[1] <- "itemID"
		freqPost_sub <- merge(freqPost_sub, itemMapping , by="itemID")

		allItem_sub <- rbind(freqPre_sub, freqPost_sub)

    	  	######
	table1 <- data.frame( "Items" =  freqPre_sub$itemName,
				    "Patch 5.11 frequency" = percent(as.numeric(freqPre_sub$FreqScaled)), 
				    "Patch 5.14 frequency" = percent(as.numeric(freqPost_sub$FreqScaled))
				  )
	table1 <- table1[order(-freqPre_sub$FreqScaled),]
	head(table1, 6)
	})




	#-------------------- table of summary statistics --------------------------#
	output$table2 <- renderTable({
		dataPre <- subset(dataPre, subset=(championNames == input$champion))
		dataPost <- subset(dataPost, subset=(championNames == input$champion))

		##### Calculations
		#data cleaning and aggregation
		itemPre <- with(dataPre, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPost <- with(dataPost, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
		itemPre$value <- as.factor(itemPre$value)
		itemPost$value <- as.factor(itemPost$value)
		itemPre$patch <- "5.11"
		itemPost$patch <- "5.14"
		itemPre$variable <- NULL
		itemPost$variable <- NULL
		
		#common set of items between patches
		itemCommon <- intersect(unique(itemPre$value),unique(itemPost$value))
		itemExclude <-c("0","3340","3361","3362","3364","3363","3341","3342") #remove empty slot and trinkets
		itemCommon <- setdiff(itemCommon, itemExclude)
		itemPre_sub <- subset(itemPre, subset=(value %in% itemCommon)) 
		itemPost_sub <- subset(itemPost, subset=(value %in% itemCommon)) 
		allItem <- rbind(itemPre_sub,itemPost_sub)
		
		#frequency of each item
		freqPre <- data.frame(table(itemPre_sub))
		freqPre_sub <- freqPre[freqPre$Freq!=0,]
		freqPre_sub$FreqScaled <- freqPre_sub$Freq/nrow(itemPre_sub)
		freqPre_sub <- freqPre_sub[order(-freqPre_sub$FreqScaled),]
		colnames(freqPre_sub)[1] <- "itemID"
		freqPre_sub <- merge(freqPre_sub, itemMapping , by="itemID")
	
		freqPost <- data.frame(table(itemPost_sub))
		freqPost_sub <- freqPost[freqPost$Freq!=0,]
		freqPost_sub$FreqScaled <- freqPost_sub$Freq/nrow(itemPost_sub)
		freqPost_sub <- freqPost_sub[order(-freqPost_sub$FreqScaled),]
		colnames(freqPost_sub)[1] <- "itemID"
		freqPost_sub <- merge(freqPost_sub, itemMapping , by="itemID")

		allItem_sub <- rbind(freqPre_sub, freqPost_sub)

    	  	######
	varPre <- as.character(var(freqPre_sub$FreqScaled))
	varPost <- as.character(var(freqPost_sub$FreqScaled))
	chiStat <- chisq.test(freqPre_sub$FreqScaled, freqPost_sub$FreqScaled) #null is independence
	pval <- as.character(chiStat$p.value)
	
	table2 <- data.frame(varPre,varPost,pval)
	table2
	})



	#-------------------- table of ALL champion statistics --------------------------#
	summaryTable <- data.frame(championNames=character(), varDiff=numeric(), pval=numeric(), stringsAsFactors = FALSE)
	championList <- as.character(championMapping$championName)
	championList <- championList[order(championList)]

	for (i in 1: length(championList)){
		dataPre1 <- subset(dataPre, subset=(championNames == championList[i]))
		dataPost1 <- subset(dataPost, subset=(championNames == championList[i]))

		if (nrow(dataPre1)!=0 && nrow(dataPost1)!=0){

			#data cleaning and aggregation
			itemPre <- with(dataPre1, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
			itemPost <- with(dataPost1, melt(data.frame(item0,item1,item2,item3,item4,item5,item6)))
			itemPre$value <- as.factor(itemPre$value)
			itemPost$value <- as.factor(itemPost$value)
			itemPre$patch <- "3.11"
			itemPost$patch <- "3.14"
			itemPre$variable <- NULL
			itemPost$variable <- NULL
		
			#common set of items between patches
			itemCommon <- intersect(unique(itemPre$value),unique(itemPost$value))
			itemExclude <-c("0","3340","3361","3362","3364","3363","3341","3342") #remove empty slot and trinkets
			itemCommon <- setdiff(itemCommon, itemExclude)
			itemPre_sub <- subset(itemPre, subset=(value %in% itemCommon)) #all items
			itemPost_sub <- subset(itemPost, subset=(value %in% itemCommon)) #all items
			allItem <- rbind(itemPre_sub,itemPost_sub)
			
			#frequency of each item
			freqPre <- data.frame(table(itemPre_sub))
			freqPre_sub <- freqPre[freqPre$Freq!=0,]
			freqPre_sub$FreqScaled <- freqPre_sub$Freq/nrow(itemPre_sub)
			freqPre_sub <- freqPre_sub[order(-freqPre_sub$FreqScaled),]
			colnames(freqPre_sub)[1] <- "itemID"
			freqPre_sub <- merge(freqPre_sub, itemMapping , by="itemID")
			
			freqPost <- data.frame(table(itemPost_sub))
			freqPost_sub <- freqPost[freqPost$Freq!=0,]
			freqPost_sub$FreqScaled <- freqPost_sub$Freq/nrow(itemPost_sub)
			freqPost_sub <- freqPost_sub[order(-freqPost_sub$FreqScaled),]
			colnames(freqPost_sub)[1] <- "itemID"
			freqPost_sub <- merge(freqPost_sub, itemMapping , by="itemID")
		
			allItem_sub <- rbind(freqPre_sub, freqPost_sub)
		

			varPre <- var(freqPre_sub$FreqScaled)
			varPost <- var(freqPost_sub$FreqScaled)
			varDiff <- varPost/varPre-1
			chiStat <-chisq.test(freqPre_sub$Freq, freqPost_sub$Freq) #null is independence
			pval <- chiStat$p.value
			
			summaryTable[i,] <- c(championList[i], varDiff, pval)
		} else {
		summaryTable[i,] <- c(championList[i], 0, 0)
		}
	}
	summaryTable$varDiff <- as.numeric(summaryTable$varDiff)
	summaryTable$pval<-as.numeric(summaryTable$pval)

	output$summary <- renderTable({
		summaryTable
	})


	#-------------------- Summary of results --------------------------#
	result <- merge(summaryTable,championMapping, by="championNames")
	result1 <- nrow(result[(result$varDiff < 0) & (result$APAD=="AP"),])/nrow(result)
	result2 <- nrow(result[(result$varDiff < 0 & result$APAD=="AD"),])/nrow(result)
	result3 <- nrow(result[(result$varDiff > 0 & result$APAD=="AP"),])/nrow(result)
	result4 <- nrow(result[(result$varDiff > 0 & result$APAD=="AD"),])/nrow(result)
	summaryTable2 <- data.frame(AP=c(result1, result3), AD=c(result2, result4), Total=c(result1+result3, result2+result4))
	row.names(summaryTable2) <- c("varDiff<0", "varDiff>0")

	med1 <- median(result[(result$varDiff < 0) & (result$APAD=="AP"),]$varDiff, na.rm=TRUE)
	med2 <- median(result[(result$varDiff < 0) & (result$APAD=="AD"),]$varDiff, na.rm=TRUE)
	med3 <- median(result[(result$varDiff > 0) & (result$APAD=="AP"),]$varDiff, na.rm=TRUE)
	med4 <- median(result[(result$varDiff > 0) & (result$APAD=="AD"),]$varDiff, na.rm=TRUE)
	summaryTable3 <- data.frame(AP=c(med1, med3), AD=c(med2, med4), Total=c(med1+med3, med2+med4))
	row.names(summaryTable3) <- c("varDiff<0", "varDiff>0")

	output$summary2 <- renderTable({
		summaryTable2 
	})

	output$summary3 <- renderTable({
		summaryTable3
	})

  }
)
