library(shiny)

championMapping <- read.csv("championMapping.csv")
championList <- as.character(championMapping$championName)
championList <- championList[order(championList)]


shinyUI(fluidPage(
	verticalLayout(
		titlePanel("Riot API Challenge"),
		p("Did Riot successfully increase item diversity by normalizing gold/stats for AP items in patch 5.13?"),
  	      p("First, let's get some visual understanding of the patch effect."),
    
      	selectInput("champion", 
        	label = "Choose a champion to display",
        	choices = championList),
    		
		p("The following graph shows the item distribution (by popularity) for patch 5.11 and 5.14, as a percentage of all items purchased."),

		plotOutput("graph1"),
		br(),

		p("The following table displays the 6 most purchased items for the selected champion before and after the patch."),
		tableOutput("table1"),
		br(),

		p("The following table summarizes the item distribution during the two patches by displaying 
		1) Variance of the item distribution and 2) Chi-squared test p-value. This will be described in detail below."),
		tableOutput("table2"),
		br(),
		
		h3("My Analysis"),

		h4("1. Introduction"),
		p("In ", a("patch 5.13", href="http://na.leagueoflegends.com/en/news/game-updates/patch/patch-513-notes"),
		"Riot Games made a massive change to a number of
		AP items, aiming to increase item diversity. The problem was that there were very few
		120 AP items, thus Deathcap, Luden's Echo, and Zhonyas were amongst the most popular items 
		purely because of the damage. As a result of the patch, 14 items were changed
		so that their stats and costs are more inline with one another, so that the 
		only difference is their effect. This should help players diversify their item
		choices depending on different situations/match-ups."),

		p("The purpose of this analysis is to attempt to answer the question of whether the 
		patch was successful in bringing about item diversity."),

		h4("2. Data"),
		p("The data used in this analysis were gathered from the Riot API using the 'jsonlite' 
		package. The requested items are stored in the following four files. Due to the time constraint,
		only 5x5 normal data for 'NA' server was analyzed."),
		p("'RequestData.csv'- 5.11 data for 5x5 Normal in 'NA' server, including matchId, region,	queueType, patch,	side,	
		champion,	rank,	role,	lane,	item0, item1, item2, item3, item4, item5, item6,
		and winner"),
		p("'RequestDataPost.csv'- 5.14 data for 5x5 Normal in 'NA' server, same attributes as above"),
		p("'championMapping.csv'- champion data, including champion ID, champion name, and
		whether it is AD or AP (a crude methodology was applied for this categorization-
		all champions with 'mage' in its 'tags' attribute were considered AP, all others AD.
		This categorizes champions like Kayle as AD, which is not optimal)"),
		p("'itemMapping.csv'- item data, including item ID and item name"),

		h4("3. Test Description"),
		p("To answer this question regarding item diversity, we need to first come up with a definition. 
		If a champion purchases less of the 'traditional' items and end the game with
		more 'non-conventional' items, then one could say that the item pool for the champion
		is more diverse. So formally, we define 'item diversity' as a decrease in variance of item distribution
		over the entire population of items."),
		p("An implicit assumption that we made is that the resulting item distribution should be viewed
		by champion subsets, instead of as a whole. This is to avoid the possible misleading results due to Simpson's Paradox."),
		p("The first step in the analysis is to clean the data so that it's in a usable form. This involves
		evaluating failed requests, removing empty slots, trinkets, and items that existed in 5.11 but
		not in 5.14 and vice versa. Then items in all slots, in all games, 
		are gathered so that the frequency of each item can be calculated. The frequency is then normalized
		by the total number of items so that each item is associated with a percentage of occurrence. The sum of
		all scaled item frequencies is thus 1."),
		p("Using these scaled item frequencies, plots and statistical measure can be generated to answer the question
		of item diversity. In addition to the plot of item frequency, two statistical measure were used.
		First is the variance of the distribution of items per champion, before and after the patch. A smaller variance
		would indicate that the items are closer to the mean, more uniformly distributed, and thus more diverse. The 
		second measurement used is the Chi-squared test for independence. The test is aimed to determine whether two samples
		populations come from the same discrete distribution. The null hypothesis is that the two distributions 
		are independent. Hence, we expect the variance of patch 5.14 item distribution to be lower, and that the 
		chi-square statistics to fail to reject the null of independent distribution."),
		

		h4("4. Results"),
		p("The following table displays the variance difference between the item distributions before and after
		the patch, as well as the p-value generated from the chi-squared test. (Empty cells were for champions that 
		had 0 observations due to bad data)"),
		
		tableOutput("summary"),
		
		p("Interestingly, the chi-squared statistic were significant for all champions, indicating that the distribution of items before and after the 
		patch were the same. This could be explained by the fact that we are looking at the distribution of the entire 
		set of items, instead of just those that are common. In other words, we don't necessary have to look at AD 
		items for champions like Ahri, since we wouldn't expect the change in AP items to cause any impact to the AD items, especially
		for AP champions. Hence by looking at a more restricted set of items, the chi-square test could offer more value."),

		p("The table below shows a breakdown of the champion variance differences by AP/AD champions and positive/negative difference.
		We observe that in general more champions actually increased in item specialization, since overall there were more 
		positive varDiffs than negative varDiffs. Furthermore, AP champions seem to be evenly split in terms of 
		item specialization vs. item diversification (20% vs. 21%)"),
		
		tableOutput("summary2"),

		p("Finally, the following table demonstrates the average varDiff per breakdown of population by AP/AD champions and pos/neg varDiff.
		It appears that, again, there was no significant item diversification, given that for AP champions, the mean of negative varDiff  
		was equal to that of positive varDiff in absolute value. In fact positive varDiff actually has a fatter tail (distribution not shown)"),

		tableOutput("summary3"),

		h4("5. Conclusion"),
		p("Given the above analysis, it appears that the patch of AP item apocalypse was just another patch. However, it is worthwhile to
		note that for champions like Cassiopeia, the item diversification benefits were significant, as the popularity
		of the top two items in 5.11 (Seraph's Embrace and Luden's Echo) both dropped in 5.14, while the less popular
		Rylai's and Rod of Ages went up. This demonstrates that certain champions benefited more from the balance of items,
		which is expected."),
		p("Another point to note is that this analysis could be improved in many areas. The most important one is to only analyze the 
		distribution of items that were changed as part of the 5.13 patch. This would allow us to see the impact of item popularity transitions 
		more easily. However, this approach would prevent us from observing any secondary effect of the AP item change, such as an increase in 
		popularity of other AP items, of a trend of building AD items on mages (for whatever reason?). Secondly, the data could have been
		cleaned up even more, in that intermediary items such as blasting wand and early game items like Doran's ring could be removed
		from our distributional analysis, as we are mostly interestd in what the core item selections would be. And finally, ranked data
		and regional data could offer more insight to this question of item diversity."),
		p("All in all, I think the patch was successful, in that it helped some champions to have a more varied set of 
		item choices. However, the impact of it wasn't as great as expected, since AD champions also observed a 
		wider selection of items, without experiencing any major item stat changes. It could be that the meta is changing
		to a more varied set of items. Whatever the reason is, it's a step in the right direction for the overall balance of League of Legends.")



  )
))
