***Take Home - Part 2***
*Last Edit: April 3, 2022*

ssc install spmap, replace     
ssc install geo2xy, replace 
ssc install ivreg2, replace

************
**# Problem 5
************

**# (V.a)

/* Merge the first three datasets together. 
Compute the China shock for each region, in each year for which it is possible, according to equation (1). Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 with Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑈𝑆𝐴𝑘𝑡, following the identification strategy by Colantone and Stanig (AJPS, 2018). */

use "Datasets/Employment_Shares_Take_Home.dta", clear //We start from this dataset to merge all the three together 
sort year country nuts2_name nace

*Merge Employment_Shares (master dataset) with Imports_China (using dataset)**
merge m:1 year country nace using "Datasets/Imports_China_Take_Home.dta"

*Now, we merge the obtained dataset from the merger of Employment_Shares and Imports_China (master dataset) with the Import_US_China dataset (using)
merge m:1 year nace using "Datasets/Imports_US_China_Take_Home.dta", gen(_merge2) 

*At this point, we keep only the _merge2==3 observations, as these correspond to the years in which US and EU data are both availabe. (NOTE THAT US DATA ARE 1989-2006, WHILE EU DATA ARE 1988-2007), so we were expecting some unmatched observations!

keep if _merge2==3 
//We are thus left with 15,120 observations and we can start working on the computation of the China shock index for each region of each EU country//

drop _merge _merge2
save "Datasets/Merged_data_ProblemV.dta", replace

use "Datasets/Merged_data_ProblemV.dta", clear


********Compute the China shock for each European region********

/*We first compute the Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 in 5-years lags, as specified in the istructions: 
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1996 is 1995 - 1990
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1997 is 1996 - 1991
....
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2006 is 2005 - 2000
 
*/

sort nuts2 nace year 
br //browse after sorting to identify the individual observations in this dataset
//this dataset is basically a panel dataset where observations followed over time are industries within a region. So we generate a variable containing an individual region-industry code which allows us to reshape the dataset along the individual dimension to then easily compute the desired delta

egen id_code = concat(nuts2 nace)
sort id_code year //seems good! observations along the time dimension for one observation are now one below the other

reshape wide empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

save "Datasets/Merged_data_ProblemV_Wide.dta", replace

use "Datasets/Merged_data_ProblemV_Wide.dta", clear
//saving the wide dataset to simplify the subsequent merge with the regional China shocks computed 

des //840 individual regions-industries followed through time, now taking algebraic operations such as differences between two variables (which have been generated, by the rashaping, with time-indexes) will take differences in the values of time-indexed covariates for that specific region-industry!


//Computing Delta imports from China using national, industry-specify China imports

forvalues i = 1995(1)2006 {
	local b = `i'-6
	local t = `i'-1
	gen D_Imp_China`i' = real_imports_china`t' - real_imports_china`b'
}
//for each regional industry observation, we generate 2006-1995=11 variables for the 5-year variations (deltas) in real imports from China 

sort nuts2 nace //indeed, observations in the same region and industry, in the same year, display the same delta imports from china, as desired! we correctly produced the desired metric
//nuts2 ambigious ambbreviation

sum D_Imp_China1995 D_Imp_China1996 D_Imp_China1997 D_Imp_China1998 D_Imp_China1999 D_Imp_China2000 D_Imp_China2001 D_Imp_China2002 D_Imp_China2003 D_Imp_China2004 D_Imp_China2005 D_Imp_China2006

//Problem with this: lack of observations for the 1995 D_Imp_China1995 this is due to the fact that in Spain we have no data in real_imports_china in 1989 (real_imports_1989) FOR INDUSTRY nace = DF! 

*Now, we compute the China shock for each region in each year* 
//we start by computing the China shock for each industry, in each region, and then we make the sum across all industries in that region//

forvalues i = 1995(1)2006 {
	gen China_shock_k_`i' = ///
	(empl1989/tot_empl_nuts21989)*(D_Imp_China`i'/tot_empl_country_nace1989) 
}
*we have computed the china shock for each industry in each region.
/* 42 missing values generated!!! in WIDE dataset  
They come from missing employment data. To see where, use: 
 tab id_code if China_shock_k_1995==.
*/

//computing China shocks using US delta imports (that is, instrumenting the china shock on US imports)

forvalues i = 1995(1)2006 {
	local b = `i'-6
	local t = `i'-1
	gen D_US_Imp_China`i' = real_USimports_china`t' - real_USimports_china`b'
}
*generating the instrumented China shock
forvalues i = 1995(1)2006 {
	gen IV_China_shock_k_`i' = ///
	(empl1989/tot_empl_nuts21989)*(D_US_Imp_China`i'/tot_empl_country_nace1989) 
}
//42 missing again


**# (V.b)
/*Collapse the dataset by region 
to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. --> READ ARTICLE
*/

collapse (sum) China_shock_k_1995 China_shock_k_1996 China_shock_k_1997 China_shock_k_1998 China_shock_k_1999 China_shock_k_2000 China_shock_k_2001 China_shock_k_2002 China_shock_k_2003 China_shock_k_2004 China_shock_k_2005 China_shock_k_2006 IV_China_shock_k_1995 IV_China_shock_k_1996 IV_China_shock_k_1997 IV_China_shock_k_1998 IV_China_shock_k_1999 IV_China_shock_k_2000 IV_China_shock_k_2001 IV_China_shock_k_2002 IV_China_shock_k_2003 IV_China_shock_k_2004 IV_China_shock_k_2005 IV_China_shock_k_2006, by(nuts2)


forvalues i = 1995(1)2006 {
	rename China_shock_k_`i' China_shock_`i'
}

forvalues i = 1995(1)2006 {
	rename IV_China_shock_k_`i' IV_China_shock_`i'
}
//Once collapsed the dataset, we now have only one observation per region, with values for the two year-index China shock variables (from 1995 to 2006) as the sum of the China shock in each individual industry within that region, in that year - using country-specific China imports, or instrumenting them for China-imports in the US. This Regional China Shock is stored under the previous China_shock_k_YEAR and IV_China_shock_k_YEAR variables, since k is now useless (we summed the values for each industry to compute values of the shock at the regional level) we rename the variable accordingly


save "Datasets/Regional_China_Shocks.dta", replace
*saving the region-specific China shocks in a specific dataset


*****Merging the china shocks produced to the full dataset

**using the wide merged original dataset to merge the wide-dataset with the newly computed china shocks into it
use "Datasets/Merged_data_ProblemV_Wide.dta", clear
merge m:1 nuts2 using "Datasets/Regional_China_Shocks.dta" 
//840 (all) matched
drop _merge


if 1=0{ //alternative, more mechanical (aka less elegant) way to merge the china shock variables into the dataset
use "Datasets/Merged_data_ProblemV.dta", clear
merge m:1 nuts2 using "Datasets/Regional_China_Shocks.dta"
drop _merge
//note, we have a set of year-indexed China shocks, we only want to keep one, with the right value specific for each year

gen China_shock=.

forvalues i = 1995(1)2006 {
	replace China_shock = China_shock_`i' if year == `i'
}

drop China_shock_1995 China_shock_1996 China_shock_1997 China_shock_1998 China_shock_1999 China_shock_2000 China_shock_2001 China_shock_2002 China_shock_2003 China_shock_2004 China_shock_2005 China_shock_2006

}

//saving the new dataset, complete of regional-level, year-indexed China shocks! //for both methods!
save "Datasets/Merged_data_ProblemV_Shocks.dta", replace


//collapsing the dataset by region to obtain the average 5-year China shock over the sample period
use "Datasets/Merged_data_ProblemV_Shocks.dta", clear
 
reshape long China_shock_ IV_China_shock_, i(id_code) j(year)
//reshaping we have our original dataset, but with the China shocks merged into it under a single varibale with the right measure per each year and region

collapse (mean) China_shock_ IV_China_shock_, by (nuts2)

pwcorr China_shock_ IV_China_shock_, sig //a quick check to see how similar the two shocks are

save "Datasets/Merged_data_ProblemV_shocks_regionalcrossection", replace




**# (V.c)
/*Using the cross-sectional data, 
produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment_Shares_Take_Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. 
Do you notice any similarities between the two maps? What were your expectations? Comment. */
use "Datasets/Merged_data_ProblemV_shocks_regionalcrossection", clear

*first install the program to transform shapefiles into dta files*

ssc install spmap, replace      // for the maps package
ssc install geo2xy, replace   // for fixing the coordinate system

spshape2dta "Shapefiles/NUTS_RG_03M_2010_4326.shp", replace saving(europe_nuts)  //we have created two dta datasets based on the shp dataset of nuts codification of 2010. Take a look at them


***Now we prepare the two files for the production of the map***

use europe_nuts, clear //This has the nuts2 names and characteristics of the regions
keep if CNTR_CODE == "IT" | CNTR_CODE == "ES" | CNTR_CODE == "FR"  //keep only Spain, France and Italy
keep if LEVL_CODE == 2 //keep only nuts2 regions

**Renaming a couple of variables and compressing the file**
ren NUTS_ID nuts2 //This allows us the merge with the dataset which contains the China Shock
cap ren NAME_LATN nuts2_name  //not very useful
compress //Compress the dataset to save some space
sort _ID //Sort by ID. Recall: the ID is necessary for the production of the map! 
save "Shapefiles/europe_nuts_ready.dta", replace

**Now, we work on the shape file, which is the base file necessary to construct the map with the command spmap* 

use europe_nuts_shp.dta, clear
merge m:1 _ID using "Shapefiles/europe_nuts_ready.dta"
//We merge the shapefile with the .dta in order to retrieve the characteristics of the nuts regions in the dta
drop if _merge!= 3  //We drop the unmatched (i.e. we only keep FR, ITA, and ES)
keep if _X > -25 & _Y >30 // Get rid of the small islands from the map which will be generated
keep _ID _X _Y _CY _CX //keep the coordinates and unique identifyer
geo2xy _CY _CX, proj (lambert_sphere) replace	 //resize and center the map in the graph (standard command which works with this type of nuts to recentre the map)
scatter _Y _X, msize(tiny) msymbol(point)  //It's a map!
sort _ID
save "Shapefiles/europe_nuts_Shapefile_readyformap", replace

**# Now, we produce the graph for the China shock!**
use "Shapefiles/europe_nuts_ready", clear //We use the first shape file with all the nuts info and we merge it to our dataset with the china shock data
merge 1:m nuts2 using "Datasets/Merged_data_ProblemV_shocks_regionalcrossection"
**6 unmatched observations: they are Guadeloupe, Martinique, Guyane, Réunion (small former colonies in France, for which we do not have data) and Ciudad Autónoma de Ceuta and Ciudad Autónoma de Melilla (small independent Spanish cities in the Moroccan territory) --> Perfect!
drop if _merge!= 3

save "Datasets/ReadyforMap",replace  //This dataset in use is the one on which we have to run the spmap command, using the created europe_nuts_Shapefile_readyformap above as "basis" for the map.  

spmap China_shock_ using "Shapefiles/europe_nuts_Shapefile_readyformap", id(_ID) fcolor(Blues2) legtitle("Mean China Shock in years 1989-2006") legend(pos(6) row(8) ring(1) size(*.75) symx(*.75) symy(*.75) forcesize) title ("China shock in years 1989-2006")

graph export "Maps/China_Shock_Map.png", replace

/*Going back to the "Employment_Shares_Take_Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. 
Do you notice any similarities between the two maps? What were your expectations? Comment. */

***Now, we produce the same map but using employment in the 29 sector***
use "Datasets/Employment_Shares_Take_Home.dta" //Look at the dataset, we need the variable nuts2 to merge it with the "Shapefiles/europe_nuts_ready" file. Therefore, as above:
use "Shapefiles/europe_nuts_ready", clear 
merge 1:m nuts2 using "Datasets/Employment_Shares_Take_Home.dta" //Same unmatched as above, good!
drop if _merge!= 3

*generating a unique region-industry code to keep only one observation for each, containing the pre-sample employment values
egen id_code = concat(nuts2 nace)
duplicates drop id_code, force
collapse _ID tot_empl_nuts2 (sum) empl, by (nuts2)

gen empl_share_manu = empl/tot_empl_nuts2 //generating regional manuefacturing employment shares (over the overall regional employment)

spmap empl_share_manu  using "Shapefiles/europe_nuts_Shapefile_readyformap", id(_ID) fcolor(Blues2) legtitle("Employment share in manufacturing sector") legend(pos(6) row(8) ring(1) size(*.75) symx(*.75) symy(*.75) forcesize) title ("Employment share in manufacturing sector in pre-sample year")

graph export "Maps/Employment_Share_Map.png", replace

**# (Note to self Ale):
* Combine the two graphs together and Write comment here for their comparison// 


***************
**# Problem VI
***************
/*Use the dataset "EEI_TH_5d_2022_V2.dta" to construct, for each NUTS-2 and industry level, an average of tfp and wages during the post-crisis years (2014-2017). These will be your dependent variables. Now merge the data you have obtained with data on the China shock (region-specific average).*/
use "Datasets/EEI_TH_5d_2022_V2.dta", clear

egen id_code = concat(nuts_code nace2_2_group)
sort id_code year 


reshape wide tfp mean_uwage share_tert_educ lnpop control_gdp, i(id_code) j(year) //We have now 700 observations and tfp and mean_wage are indexed by year in order to construct their means

save "Datasets/EEI_TH_5d_2022_V2_wide.dta", replace

use "Datasets/EEI_TH_5d_2022_V2_wide.dta", clear

*Let's create the mean of tfp* 
gen Mean_tfp = ((tfp2014 + tfp2015 + tfp2016 + tfp2017)/4)

**Now, mean of wages**
gen Mean_wages = ((mean_uwage2014 +mean_uwage2015 + mean_uwage2016 + mean_uwage2017)/4) 

reshape long tfp mean_uwage share_tert_educ lnpop control_gdp, i(id_code) j(year)
rename nuts_code nuts2 //Rename the nuts2 identifier over which merge china shocks dataset

merge m:1 nuts2 using "Datasets/Merged_data_ProblemV_shocks_regionalcrossection"
//768 unmatched observations, coming from nuts_2 for which we do not have observations in the China_shocks datasets-->  ES63 ES64 FRA1 FRA2 FRA3 FRA4

keep if _merge == 3

drop _merge

save "Datasets/EEI_TH_5d_2022_V2_ChinaShock_merged", replace


**# (VI.a)
/*Regress (simple OLS) the post-crisis average of tfp against the region-level China shock previously constructed. Use population, education and gdp set at the beginning of the period in which your dependent variable is measured (2014) as controls. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues.*/

use "Datasets/EEI_TH_5d_2022_V2_ChinaShock_merged", clear
sort id_code year

*Now, to keep the code clean, since we only need the average tfp,  average wages, and china shocks (which are equal across all years) along with controls measured in 2014 for the rest of the problem, we drop all observations for years different from 2014. In this way we will have each firm, uniquely identified by the id_code previously constructed, only in year 2014 (we use the controls in that year)

drop if year != 2014

sum Mean_tfp
scalar M_tfp=r(mean) 
reg Mean_tfp China_shock_ lnpop share_tert_educ control_gdp, cluster(nuts2) 

outreg2 using "Output/TABLE_P6.xls", excel replace  title("Regional-level Effect of the China Shock (1995-2006) on the average Post-Crisis TFP(2014-2017)") addstat("Mean TFP", M_tfp) addnote("Standard Errors Clustered at the Nuts2 level") cttop(OLS)  
//China shock coefficient is positive
**# Discuss endogeneity issues

**# (VI.b)
/*To deal with endogeneity issues,
use the instrumental variable you have built before, based on changes in Chinese imports in the USA, and run again the regression as in a). Do you see any change in the coefficient? */


*Estimate the FIRST STAGE to argue for relevance.
//Using FIRST and SAVEFIRST
ivreg2 Mean_tfp (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp, cluster(nuts2) first savefirst
scalar F_weak = e(widstat) //creating scalar with the F stat from the IVreg
est restore _ivreg2_China_shock_ //restore first stage

outreg2 using "Output/TABLE_P6.xls", excel append addstat("F-statistic instruments", F_weak) cttop(First Stage)
//output the first stage!
*


* Estimating the REDUCED FORM model, to argue for validity and hint about the sign and magnitude of IV estimates. We further show the reduced form regression for sake of completness, excluding missing values of the variable to be instrumented (in this case, luckily there is none).

reg Mean_tfp IV_China_shock_ lnpop share_tert_educ control_gdp if China_shock_!=., cluster(nuts2)
outreg2 using "Output/TABLE_P6.xls", excel append addstat("Mean TFP", M_tfp) cttop(Reduced Form)
//reduced form not significant!!!!

//discuss changes in the coefficient and verify literature on reduced form

* Estimate the SECOND STAGE. 
ivreg2 Mean_tfp (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp, cluster(nuts2)
outreg2 using "Output/TABLE_P6.xls", excel append addstat("Mean TFP", M_tfp) cttop(Second Stage)
//china shock, instrumented by US china shocks, does not explain significantly any change on average tfp 

**#check if everything was done correctly
/* (especially at the first stages in setting the dataset and merging everythin, prior to point a)
*/


**# (VI.c)
/*Now, regress (both OLS and IV) the post-crisis average of wage against the region-level China shock previously constructed. Use population, education and gdp set at the beginning of the period in which your dependent variable is measured (2014) as controls. Comment on the estimated coefficient on the China shock, and discuss possible endogeneity issues.*/

sum Mean_wages
scalar M_wages=r(mean) 
reg Mean_wages China_shock_ lnpop share_tert_educ control_gdp, cluster(nuts2) 

outreg2 using "Output/TABLE_P6c.xls", excel replace  title("Regional-level Effect of the China Shock (1995-2006) on average Post-Crisis Wages (2014-2017)") addstat("Mean Wages", M_wages) addnote("Standard Errors Clustered at the Nuts2 level") cttop(OLS)  
//China shock coefficient is positive
**# Discuss endogeneity issues


*Estimate the FIRST STAGE 
ivreg2 Mean_wages (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp, cluster(nuts2) first savefirst
scalar F_weak = e(widstat) //creating scalar with the F stat from the IVreg
est restore _ivreg2_China_shock_ //restore first stage

outreg2 using "Output/TABLE_P6c.xls", excel append addstat("F-statistic instruments", F_weak) cttop(First Stage)
//output the first stage!
*
* Estimating the REDUCED FORM model
reg Mean_wages IV_China_shock_ lnpop share_tert_educ control_gdp if China_shock_!=., cluster(nuts2)
outreg2 using "Output/TABLE_P6c.xls", excel append addstat("Mean Wages", M_wages) cttop(Reduced Form)
//reduced form not significant!!!!
//discuss changes in the coefficient and verify literature on reduced form

* Estimate the SECOND STAGE. 
ivreg2 Mean_wages (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp, cluster(nuts2)
outreg2 using "Output/TABLE_P6c.xls", excel append addstat("Mean Wages", M_wages) cttop(Second Stage)


**# (VI.d)
/* Lastly, run again the regression as in c), but now also add the average of tfp during the post-crisis years (the dependent variable of regressions a) and b)) as a control. Do you see any change in the coefficient of the China shock? Comment.*/

sum Mean_wages
scalar M_wages=r(mean) 
reg Mean_wages China_shock_ lnpop share_tert_educ control_gdp Mean_tfp, cluster(nuts2) 

outreg2 using "Output/TABLE_P6d.xls", excel replace  title("Regional-level Effect of the China Shock (1995-2006) on average Post-Crisis Wages (2014-2017)") addstat("Mean Wages", M_wages) addnote("Standard Errors Clustered at the Nuts2 level") cttop(OLS)  
//China shock coefficient is positive
**# Discuss endogeneity issues


*Estimate the FIRST STAGE 
ivreg2 Mean_wages (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp Mean_tfp, cluster(nuts2) first savefirst
scalar F_weak = e(widstat) //creating scalar with the F stat from the IVreg
est restore _ivreg2_China_shock_ //restore first stage

outreg2 using "Output/TABLE_P6d.xls", excel append addstat("F-statistic instruments", F_weak) cttop(First Stage)
//output the first stage!
*
* Estimating the REDUCED FORM model
reg Mean_wages IV_China_shock_ lnpop share_tert_educ control_gdp Mean_tfp if China_shock_!=., cluster(nuts2)
outreg2 using "Output/TABLE_P6d.xls", excel append addstat("Mean Wages", M_wages) cttop(Reduced Form)
//reduced form not significant!!!!
//discuss changes in the coefficient and verify literature on reduced form

* Estimate the SECOND STAGE. 
ivreg2 Mean_wages (China_shock_= IV_China_shock_) lnpop share_tert_educ control_gdp Mean_tfp, cluster(nuts2)
outreg2 using "Output/TABLE_P6d.xls", excel append addstat("Mean Wages", M_wages) cttop(Second Stage)
//NOT SIGNIFICANT

