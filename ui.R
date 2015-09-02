library(shiny)

championMapping <- read.csv("data/championMapping.csv")
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
    		
		p("The following graph shows the item frequency distribution (by popularity) for patch 5.11 and 5.14. Note that the frequencies
		are scaled over all items purchased so that the sum of item frequencies add up to 1."),

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
		p("'RequestData.csv'- 5.11 data for 5x5 Normal in 'NA' server, including", em("matchId, region,	queueType, patch,	side,	
		champion,	rank,	role,	lane,	item0, item1, item2, item3, item4, item5, item6,
		and winner")),
		p("'RequestDataPost.csv'- 5.14 data for 5x5 Normal in 'NA' server, same attributes as above"),
		p("'championMapping.csv'- champion data, including", em("champion ID, champion name, and
		APAD"), "(a crude methodology was applied for this categorization-
		all champions with 'mage' in its 'tags' attribute were considered AP, all others AD.
		This categorizes champions like Kayle as AD, which is not optimal)"),
		p("'itemMapping.csv'- item data, including", em("item ID and item name")),

		h4("3. Test Description"),
		p("To answer this question regarding item diversity, we need to first come up with a definition. 
		If a champion purchases less of the 'traditional' items and end the game with
		more 'non-conventional' items, then one could say that the item pool for the champion
		is more diverse. So formally, we define 'item diversity' as a decrease in variance of item distribution
		over the entire population of items."),
		p("An implicit assumption that we made is that the resulting item distribution should be viewed
		by champion subsets, instead of as a whole. This is to avoid the possible misleading results due to", 
		a("Simpson's Paradox.", href="https://en.wikipedia.org/wiki/Simpson%27s_paradox")),
		p("The first step in the analysis is to clean the data so that it's in a usable form. This involves
		evaluating failed requests, removing empty slots, trinkets, and items that existed in 5.11 but
		not in 5.14 and vice versa. Then items in all slots, in all games, 
		are gathered so that the frequency of each item can be calculated. The frequency is then normalized
		by the total number of items so that each item is associated with a percentage of occurrence. The sum of
		all scaled item frequencies is thus 1."),
		p("Using these scaled item frequencies, plots and statistical measure can be generated to answer the question
		of item diversity. In addition to the plot of item frequency, two statistical measure were used.
		Firstly, the variance of the item frequency distribution of a particular champion may suggest how diverse or specialized a champion's item choice is.
		A smaller variance would indicate that the frequencies of the items are closer to the mean across all items, 
		suggesting a more uniformed distribution, and thus more diversity. Conversely, a large variance normally happens 
		where a few items have extremely high frequency, while the remaining items barely appear. This leads to a large difference
		between the each item frequency and the mean frequency, contributing to a larger variance.
		The second measurement used is the Chi-squared test for independence. The test is aimed to determine whether two samples
		populations come from the same discrete distribution. The null hypothesis is that the two distributions 
		are independent. Hence, if the patch was successful, then we would expect the variance of patch 5.14 item distribution to be lower, and that the 
		chi-square statistics to fail to reject the null of independent distribution."),
		

		h4("4. Results"),
		p("The following table displays the relative variance difference (varDiff) between the item distributions before and after
		the patch, as well as the p-value generated from the chi-squared test. (Note that a few champions display 0 for varDiff and p-value due to missing data)"),
		
		tableOutput("summary"),
		
		p("Interestingly, the chi-squared statistic were significant for all champions, indicating that the distribution of items before and after the 
		patch were the same. This could be explained by the fact that we are looking at the distribution of the entire 
		set of items, instead of just those that are common. In other words, we don't necessary have to look at AD 
		items for champions like Ahri, since we wouldn't expect the change in AP items to cause any impact to the AD items, especially
		for AP champions. Hence by looking at a more restricted set of items, the chi-square test could offer more value."),

		p("The table below shows a breakdown of the champion variance differences by AP/AD champions and positive/negative variance difference.
		We observe that there were slightly more champions that experienced negative varDiffs than positive varDiffs (51% vs. 47%), 
		indicating a bias towards item diversification. However, the margin is so small that it could arise from random chance. Furthermore, the argument breaks down when we look at the cut by AP/AD type, since most of the 4% difference actually come from AD champions (30% vs. 27%), while AP champions experienced roughly the same change to variance in item frequency distribution (21% vs. 20%)."),
		
		tableOutput("summary2"),

		p("One may raise the possibility of, even though frequency wise negative varDiff may be similar to positive varDiff, the magnitude of these variance differences may be different. If negative varDiffs are more 'negative', then it could still imply item diversification."),
		p("The following table displays the median varDiff breakdown by AP/AD champions and positive/negative varDiff.
		It appears that, again, there was no significant item diversification, given that the magnitude of total median negative varDiff is roughly the same as that of positive varDiff (0.12 vs 0.13). Breaking it down specifically for AP champions, the median of negative varDiff  
		is still similar to that of positive varDiff (0.06 vs 0.06). In fact for AP champions, positive varDiff actually has a fatter tail than  negative varDiff (distribution not shown), indicating that there were more cases of extreme item specialization than extreme item diversification."),

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
		from our distributional analysis, as we are mostly interested in what the core item selections would be. And finally, ranked data
		and regional data could offer more insight to this question of item diversity."),
		p("All in all, I think the patch was successful, in that it helped some champions to have a more varied set of 
		item choices. However, the impact of it wasn't as great as expected, since AD champions also observed a 
		wider selection of items, without experiencing any major item stat changes. It could be that the meta is changing
		to a more varied set of items. Whatever the reason is, it's a step in the right direction for the overall balance of League of Legends.")



  )
))