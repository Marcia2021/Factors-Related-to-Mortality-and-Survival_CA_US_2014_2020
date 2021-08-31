# Factors Related to Mortality and Survival in California Population, 2014 - 2020

*Group members: Bayan Bahloul, Caelan Doherty, Mouad Lachhab, Ryan Lerner & Miaomiao Shen*

## Overview 

In the last few decades, U.S. mortality rates have declined and as a result, life expectancy at birth reached a record high, at 78.8 years in 2019 compared to 69.7 years in 1960 [1]. However, compared to other nations the US had the 20th highest life expectancy in the world in 1960 and 46th in 2019, which is projected to drop to 43rd by 2060 [1]. In addition to that, among developed nations, the 35 OECD countries, U.S. life expectancy at birth ranks at 28 [2].

Much of the available analyses regarding the reduction in mortality rates (increase of life expectancy) focuses primarily on medical innovations and advances in health care. However, there are many other factors that impact mortality that are not studied as closely. Demographic factors such as education level, gender, ethnicity, marital status, place of birth (immigration), veteran status, and urban sprawl could also have an impact on life expectancy. Therefore, this project aims to investigate the relationship of these broad range of factors to mortality and survival in the population of California. The project hopes to shade light on these factors to make the case for policy makers and average citizens to show that beside health-related factors, there may be demographic features that affect these differences in age of death. This study can prove valuable to add to the research on longevity and help find new strategies to ensure a longer and healthier life for future generations in the US and world. The state of California was chosen, given that this state is both heavily populated and diverse, while also containing adequate datasets available to work with.

### Why do we care?
This analysis can certainly be useful not just for government officials in California, but also for everday Californians. California officials can use this information to notice inequalities and potentially allocate resources to account for these inequalities. In addition, citizens of the state can always use this information to estimate the age of their own death. Everyone is going to die at some age, and mortality can often cause humans a fair amount of anxiety. This information can allow individuals to plan for death and retirement by finding a rough estimate of what their age of death may be given certain demographic factors. 

## Dashboard
[Click here to view the interactive Dashboard](https://public.tableau.com/app/profile/caelan.doherty/viz/California_Front_Page_16278552602550/CaliforniaFrontPage?publish=yes)

![picture](images/daashboard.PNG)
## Data Source: 

The data used in the analysis reflects information collected and transformed by Viral Records Business Intelligence System (VRBIS) for the State of California in the years 2014–2020. This death data is derived from information entered on death certificates for California residents [3]. 

The income data in this analysis is derived from the United States Census Bureau American Community Survey (ACS) Data for the State of California by county [4]. The ACS does not produce income level information specifically for mortality records, but does contain median income levels for the overall population. Pooling this information with the data from 2014–2020 might provide additional context to estimate life expectancy. 

The death data with underlying causes of death across the states for all U.S. counties is derived from the Centers for Disease Control and Prevention. Data are based on death certificates for U.S. residents [5]. 

## ETL Process

- We used python’s Pandas to load the downloaded data. After closely looking at the columns, we decided the drop the columns, ‘Type_of_Event’, ‘Residence_or_Place_of_Death’ and ‘Last_Data_Refresh’ because they don’t bring any valuable information to this analysis.
 
- The dataset had all values under 11 as ‘<11’, which is a problem if we want to perform some arithmetic or comparative operation on the data. Therefore, we needed to parse this value on an “int”. Our solution in this case was to average the value to 6 in order to ensure that the death totals were all numerical/graphable. We chose this default value because there are many instances in the table where the death count equals zero. Because 0 did exist in some rows, we could understand '<11' to be greater than 0 and less than 11. Therefore, 6 seemed like an appropriate compromise to place between these two values. 
 
- For The ethnicity data, the dataframe had race_ethnicity have “Non-Hispanic” attached to every Non-Hispanic ethnicity. To simplify the data, we used regex drop the “Non-Hispanic” label attached to all non Hispanic ethnicities. 
 
- For each table, we renamed the death record column to not confuse the numbers when we will use more than one criteria in a dashboard.
We also created a table that keeps the total number of deaths, not aggregated by any characteristic. 

- We created a table that keeps the total number of populations during the same years and how that population breakdown by county, after downloading the data we dropped the years that were outside of scope of this analysis.

- We made a table that shows the counties list and each county’s correspondent surface, and merged it with a table that shows if that county is considered to be a rural, urban or suburban county.

- After the cleaning process, the dataframes were exported into  csv files that would be later used to populate our SQL database, and used in the dashboard analysis part of the project. the SQL script can be found in the SQL folder.

- the databases were combined finally into one dataframe using the age categorie and county. to be used in the machine learning process the code for that can be found in the 'DEV' folder.

- the description column was encoded into 3 numerical variables 
- the target feature which is going to be the age category was a string, so we created a numerical categorical column based on it.
- we dropped the age column and the other non numerical columns that arent meaninful to this analysis
- we dropped the unknwon categories as they were very heavily correlated 
- we keep a reference data frame for the targer feature and drop it from the data frame
- use the rest of data for training dependent features.
- split the dataset into training and testing data 0.8 to 0.2.

-we tried scalling and standardizing the features but it turned out that it made the models behave worst so we removed that step from the pipeline

## Database 

### ERD Model
As shown below, our ERD model was mainly linked through the primary key for the county names. Each dataset contained county names, and most others also contained variables for the year of death and age. Each table represented a different factor that we are analyzing, and each factor included data by year, county, and age group.

![sql/ERD](sql/ERD.png)

### SQL Database
Our database was created in postreSQL with 9 tables separate tables linked by the corresponding county in California. 6 of these tables were from datasets gathered on the California Dept of Public Health website that yielded a year of death, county, age group, and a demographic factor with the total numbers of deaths in each age group. This image below displays a functioning query in PostgreSQL where we retrieve all 'White' death data from our ethnicity table in the year 2014.

![sql/sql_query](sql/sql_query.png)

### Data Dictionary

![Data Dictionary](https://github.com/Bayan-daux/Factors-Related-to-Mortality-and-Survival_CA_US_2014_2020/blob/main/Resources/Data_Dictionary.PNG)


## Methodology:

First, we will use the Viral Records data from CA to estimate the mortality rate for each age group by county in years 2014-2020 respectively. We would then estimate the overall mortality rate in CA, and with the collaboration of the U.S. census data, compare this to the mortality rate across the U.S in the years 2014–2020 respectively. 

Second, we will analyze the relationship between several demographic factors (sex, race/ethnicity, country of birth, education, marital status, veteran status, and income) and the mortality rate of each age group in the years 2014–2020. With this data, we can predict the trend of mortality rates across the years in CA, and by county. Additioanlly, we would use statistical modelling that includes all the possible factors to predict the life expectancy in CA. There will also be limitations and challenges posed by the data with the possibility of bias, which will be referenced in the final report.

## Machine Learning Model:

### feature exploration 
In the first part of our machine learning process we tried to focus on showing the average relation between each feature and the target variable, and how the other different factors relate to each other. 
we used correlation matrices to do so, we also used Seaborn heatmaps to make the correlations clear to grasp visually : 

- here are the correlation matrices: 
 
#### age categorie aggregated data heatmap:

![picture](images/age_agg_heatmap.png)
##### what we can understand from the heatmap :

by looking at the heatmap we can see the distributions for each feature for every age category, we notice:

* the peak for the never married death counts is at a much earlier age than the married ones.
* for the race criteria we noticed that the highest number for white and asian deaths accure at a much later age than the other races, and the black/african american one happens much significantely earlier than the other races.
* widows are the highest number in the oldest categories.
* female deaths counts are higher later than males, which means women oultive men on average.



####  Feature correlation matrix :

![Factors Correlation Matrix Heatmap](https://github.com/Bayan-daux/Factors-Related-to-Mortality-and-Survival_CA_US_2014_2020/blob/main/ETL%20-%20ML/heatmap%20for%20correlation%20matrix.png)

##### what we can understand from the matrix :
We can see by looking at the correlation matrix that unfortunately much of our data features are correlated. to deal with that we decided to use random forest classifiers in our analysis

Desicion trees are good for this type of classification because they don't make assumptions on relationships between features. the goal is to split the node on a single feature that improves classification each time, based on an impurity measure. for example, If features A, B are heavily correlated and no information  can be gained from splitting on B after having split on A. the model would typically ignore B in favor of C.

this introduces a problem of risk of overfitting, to deal with that we're going to try different ensemble algorithms to determine which algorithm results in the best performance. we will train a Random Forest Classifier and an Easy Ensemble AdaBoost classifier to see if that would improve our results from the decision tree model results


### ML models Logic and implementation 

![picture](images/sheat_sheet.png)

The picture above is from the Skitlearn library documentation, which is the library we used to build our ML algorithms for this analysis.

looking at the picture above and with respect to the problem at hand which is a multiclass classification problem (number of classes = 22), we decided to follow the flow of the shart By creating ceveral models that are suited for this type of analysis and compare their results:

#### linear SVC

- What is linear SVC?

The objective of a Linear SVC (Support Vector Classifier) is to fit to the data you provide, returning a "best fit" hyperplane that divides, or categorizes, your data. From there, after getting the hyperplane, you can then feed some features to your classifier to see what the "predicted" class is.

- Pictures of the model performance:

![picture](images/svc1.png)

- model confusion matrix:

![picture](images/svc2.png)

#### Decision Trees

MW definition : a tree diagram which is used for making decisions in business or computer programming and in which the branches represent choices with associated risks, costs, results, or probabilities

- next we decided to use ensemble techniques and started with a simple  decision Tree:

before we present the details of the algorithm, were gonna go over a metric that we used in addition tho the usal Recall, precision and F-score, 
the ROC AUC score :

![picture](images/roc_auc.png)

now that we understand the ROC AUC Score this is how our Decision Tree performed:

![picture](images/tree1.png)
 
 - we created a feature importance table for all the features for the Tree classifier
 ![picture](images/tree2.png)
 
 - we plotted the feature importance:
  ![picture](images/tree3.png)
  
 - Tree confusion matrix:
![picture](images/tree4.png)


#### Random forest

in short Random forests are a way of averaging multiple deep decision trees, trained on different parts of the same training set, with the goal of reducing the variance.

here is how random forest performed:

![picture](images/rf1.png)
 
 - we created a feature importance table for all the features for the random forest classifier
 ![picture](images/rf2.png)
 
 - we plotted the feature importance:
  ![picture](images/rf3.png)
  
 - Random Forest confusion matrix:
![picture](images/rf4.png)


#### Adaboost

AdaBoost is a type of algorithm that uses an ensemble learning approach to weight various inputs.

here is how adaboost performed:

![picture](images/ada1.png)
 
 - we created a feature importance table for all the features for the adaboost classifier
 ![picture](images/ada2.png)
 
 - we plotted the feature importance:
  ![picture](images/ada3.png)
  
 - adaboost confusion matrix:
![picture](images/ada4.png)

#### ML insights

A few steps have been attempted and then removed from the processes because they were seen to affect the result in a negative way or to not have any effect on the result at all, such as different sampling and scaling methods that were attempted to achieve higher measurement scores.

After our multiple attempts with the machine learning models the highest accuracy score we got was around 50% from the first model we tried which was the Support Vector Classifier model, which is not so bad for a 22 classes classification problem. but that wasnt high enough for our goal of 70% accuracy at least.

For the emsemble methods we notice that the ROC_AUC score gets better after applying the bagging and then boosting techniques but the accuracy doesnt see a similar gain unfortunately.

at this stage of the project we can not conclude that our models can be considered predictive but do believe that they bring valuable insight to further advance this analyses:

over all we picked the Easy Ensemble AdaBoost classifier algorithm because of the result metrics. we can see from its feature importance results that the most influential factors in having a long life are features that relate to marital status and sex and education. this is insight that will serve as a starting point for the next iteration of the project, it also proves that veteran status has no affect on life expenctancy.

###### WHATS NEXT?

in the next step we will first try to find more data to feed the model to see if that would better the performance.
later on the focus would be to find data recorded on a personal level from a study or other type of data collection thats to the personal level. we beleive that that would be the key for a succesful life expectancy machine learning model.


## Analysis Results

### Education
![picture](images/Education.png)

These stacked graphs display that there isn’t too much variation in age of death between the different education levels. One might expect that a higher education leads to a longer life, but this data actually shows that people with high school educations or less tend to die at an older age than those with higher level degrees. It is possible that this can be explained simply due to the fact that older people in the past seven years don’t have as many higher-level degrees as younger age groups. 

### Marital Status
![picture](images/Marital_Status.png)

The trend in the marital data shows that marital status and living arrangements may be the strongest indicator of an individual’s lifespan. The graphs portray unmarried individuals dying at younger ages than their married counterparts. It also shows how the transition between different marital statuses, such as divorce or outliving a spouse, has a distinct effect on individual’s mortality. While there were noticeable disparities in these charts, it might be tough to generalize these results to apply to one’s lifestyle. For example, even though widows tend to outlive non-widows, that would easily be explained by the fact that widows have to live longer than their spouse. This essentially means that a widow would always be the 2nd person in a marriage dying, which would explain why that distribution is significantly more left skewed than other marital categories. The same logic applies to the “Never Married” category. Although it might make sense that people in relationships might live happier and longer lives, it could be hard to assume that people at younger ages are dying because they’re single. It’s more probable that younger people who die just tend to not be married yet. Aside from many of these more explainable disparities, it appears that the distribution of divorced deaths occurs at a much younger age than that of married people. 

### Gender 
![picture](images/Gender.png)

The results in this section provide solid evidence as to what most modern data in the subject shows. There is a gender age gap, in which females tend to live longer lives than their male counterparts. While female deaths peak around the 85-94 age group, the male deaths peak lower between the 75-89 age group. It would be interesting for future analyses to look if gender differences in longevity can be attributed to gender-specific preferences and health behavior, rather than just their biological differences. 

### Veteran Status
![picture](images/Veterans.png)

Our Analysis shows that being a veteran doesn’t make a distinct difference to mortality as one might expect, given the hardship a veteran may endure in an adverse environment. The age of death for veterans is even slightly lower than that of non-veterans. It’s possible that those who participate in the military would tend to focus more on their physical health, which could lead to living a longer life. It would be interesting to conduct further exploration in longevity based on the socioeconomic differentials such as education and income in veterans and compare that to non-veterans. 


### Ethnicity, Race and Immigration
![picture](images/Ethnicity.png)

When filtering the stacked bars, it appears that white Californians have the oldest age of death compared to other ethnic groups. Asian Californians seem to be on a fairly similar distribution, but still appear to die at a slightly younger age. Black Californians also tend to die at a younger age. The distribution for non-white deaths peaks betweeen 75-89 years, while white California deaths peak between 80-94 years old. This disparity could be due to the fact that healthcare in America tends to be most effective for white Americans, while advancements in science/healthcare haven’t been optimized for ethnic minorities. An example of this theory in practice is that black women are 3-4 times more likely to die giving birth than white women in this country. 

### Immigration Status
![picture](images/Immigration.png)

For the most part, the distributions between foreign born and US-born Californians does not differ too much when viewing the above charts. As we did see some differences in ethnicity, those factors would likely account for the US-born graph being slightly more left skewed. The US-born Californians tend to die in more of the 85-94 range, while the foreign born Californians are in the 80-89 year range. However, both charts clearly have the top three bars between 80-94 years old. 


### Urban, Suburban and Rural 

When looking at the previously discussed factors in relation to urbanization, it appears that Californians who live in urban or suburban areas die at older ages than those who lives in rural areas regardless of their sex, ethnicity, education level or martial or veteran status. This could be attributed to the correlation of rural areas with other health and socioeconomic factors, such as higher poverty, lower education, and lower income. Urbanized areas are also likely to have more access to more health resources and additional infrastructure. 


## Conclusion & Practical Application

It appears that Californians who live in urban or suburban areas die at older ages than those who lives in rural areas. This could be attributed to the fact that rural areas tend to have higher poverty levels, lower education opportunities, and lower income. Urbanized areas are also likely to have more access to more healthcare resources and additional infrastructure.

It is incredibly important to be aware of one’s life expectancy, or that of a given population, for various reasons. The California Department of Public Health collects this information, and they can essentially pass this on to other government agencies in California, which could more effectively estimate population trends and then allocate resources appropriately. For a policymaker, the ability to identify what factors put an individual at risk of a shorter life helps in designing and building new frameworks or interventions that profoundly impacts both individuals and society. When a city or county or state aims to build more residential properties, they would want to know population growth numbers, but having an idea of the general age of death for certain groups can also be valuable information when making such decisions. We’ve also seen that ethnic minorities are dying at younger ages than white Californians are. The government could use this knowledge and decide to fund medical research that adjusts for health inequalities present in the state of California. 

This information can also be useful for everyday Californians. While they may not need to make policy decisions, individuals still need to make important life decisions when it comes to education and eventually retirement/financial planning. For an individual looking at these results, it may help in making more data-driven decisions in the pursuit of an education, joining the army or understanding the benefits of a healthy marriage or life partnership. And while an individual can’t do much about one’s ethnicity and place of birth, understanding how these factors correlate with longevity is important. 

Unfortunately, our analysis doesn’t grant us the ability to combine these various factors for a precise prediction, but anyone can view the dashboard and make estimates based on where they fall in each category. Giving Californians this rough estimate will assist them in making crucial life choices, such as when to retire or how to spend money when they are retired. This information would also be helpful if you needed to make these decisions for your elderly parents or family members. Using this data can assist you in deciding whether you can afford a nursing home for ‘x’ number of years, or if your elderly parent should stay with you. If an individual is using this information to plan for retirement, it would certainly be most practical to overestimate one’s age of death in order to guarantee financial security.


## **Project Limitation and Future Recommendations**

1. Looking at the **combined impacts** of different factors would provide a broader insight, however, due to the form of available data, we were only able to look at each factor individually. The California public health data website gave us a query tool, but only allowed us to choose one factor grouped with age bins at a time.
2. **Granularity**: We were unable to find granular data broken down by individual with an exact age of death, so our dataset would only include total death counts in 5-year age bins.
3. **Availability of the data**: it was hard to find datasets for other factors that would be interesting to include in this project, such as income and lifestyle behavior.
4. **Across states**  **comparison**: not all states have the datasets in a unified form that would make it possible to combined or merge them into one to reach the form we need to have it analyzed. Therefore, we limited our project to CA state data and missed the opportunity to compare results across different states.
5. **Explainability**: while there may be differences in the age of death distributions, it's likely that there are other reasons why the age of deaths differ. For example, widows dying at an older age could likely be due to the fact that most widows survive their spouse who dies first. 

## Reference

1.	Living Longer: Historical and Projected Life Expectancy in the United States, 1960 to 2060 [https://www.census.gov/content/dam/Census/library/publications/2020/demo/p25-1145.pdf](https://www.census.gov/content/dam/Census/library/publications/2020/demo/p25-1145.pdf) (Accessed: 7/10/2021)
2. 	International Comparison  
[https://www.americashealthrankings.org/learn/reports/2019-annual-report/international-comparison](https://www.americashealthrankings.org/learn/reports/2019-annual-report/international-comparison)(Accessed: 7/10/2021)  
3.	California Department of Public Health Vital Records Data and Statistics, VSB Data and Statistics (ca.gov) https://www.cdph.ca.gov/Programs/CHSI/Pages/California-Vital-Data.aspx
4.	United States Census Bureau, American Community Survey Data, American Community Survey Data (census.gov)        https://www.census.gov/programs-surveys/acs/data.html
5.	Centers for Disease Control and Prevention, CDC WONDER, Underlying Cause of Death, 1999 – 2019, Underlying Cause of Death,1999-2019 Request (cdc.gov) https://wonder.cdc.gov/controller/datarequest/D76;jsessionid=966B85BC1ED23DE79066DD928653
6.	Centers for Disease Control and Prevention, National Center for Health Statistics, Leading Cause of Death, NVSS - Leading Causes of Death (cdc.gov). https://www.cdc.gov/nchs/nvss/leading-causes-of-death.htm

## Communication Protocols

The following collaborative tools are used to facilitate communication and sharing among team members:

- **Slack** For streamline communication, using a private Slack channel as the main communication platform. Beside using it for real-time communication between members, it&#39;s also to share links for resources, schedule meetings, and general announcements.
- **Zoom** For virtual meetings and to share video and screen content between members. It serves as main platform for team to brain, make mutual decisions, give updates on ongoing tasks, and discuss future ones.
- **Google Documents** for team members to take notes, edit, and comment in real time. Also, to keeps record of meetings, assign tasks and track project milestones and deadlines.
- **GitHub** for data repositories that also provide version control, multiple branches, and ability to merge and update. Also serve as the project archives as it allows for all team members permanent access to the project and its resources.
