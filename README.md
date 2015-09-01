# Riot-API
Riot API Challenge

Use the following code to run app

if (!require('shiny')) install.packages("shiny")

shiny::runGitHub('Riot-API', 'georgyporgy91')

The data used in this analysis were gathered from the Riot API using the 'jsonlite' package. The requested items are stored in the following four files. Due to the time constraint, only 5x5 normal data for 'NA' server was analyzed.

'RequestData.csv'- 5.11 data for 5x5 Normal in 'NA' server, including matchId, region,	queueType, patch,	side,	champion,	rank,	role,	lane,	item0, item1, item2, item3, item4, item5, item6, and winner

'RequestDataPost.csv'- 5.14 data for 5x5 Normal in 'NA' server, same attributes as above

'championMapping.csv'- champion data, including champion ID, champion name, and whether it is AD or AP (a crude methodology was applied for this categorization- all champions with 'mage' in its 'tags' attribute were considered AP, all others AD. This categorizes champions like Kayle as AD, which is not optimal)

'itemMapping.csv'- item data, including item ID and item name
