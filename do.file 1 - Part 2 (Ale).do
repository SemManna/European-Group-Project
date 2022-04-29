***Take Home - Part 2***

ssc install ivreg2, replace		// for 2SLS regressions
ssc install spmap, replace		// for the maps package
ssc install geo2xy, replace		// for fixing the coordinate system in the map
ssc install reghdfe, replace	// for linear regression with country & industry FE
ssc install ivreghdfe, replace 	// for extended IV regression with country & industry FE
ssc install ftools, replace 	// for using ivreghfe and other commands

set scheme s1color				// nice colour scheme for graphs & maps

************
**# Problem 5
************

**# (V.a)

*** Merging the first three datasets together.

use "Datasets/Employment_Shares_Take_Home.dta", clear
sort year country nuts2_name nace

*Merge Employment_Shares (master dataset) with Imports_China
merge m:1 year country nace using "Datasets/Imports_China_Take_Home.dta"

*Merge the resulting dataset with the Import_US_China dataset (using)
merge m:1 year nace using "Datasets/Imports_US_China_Take_Home.dta", gen(_merge2) 

*At this point, we keep only the _merge2==3 observations, as they correspond to the years in which US and EU data are both availabe. (Note: US data is between 1989-2006, while EU data is between 1988-2007), unmatched observations are expected.

keep if _merge2==3 
*15,120 observations left. 

drop _merge _merge2

save "Datasets/Merged_data_ProblemV.dta", replace
use "Datasets/Merged_data_ProblemV.dta", clear


**** computing the delta imports from China

/*We start by computing the Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 in 5-years lags, as specified in the istructions: 
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1996 is 1995 - 1990
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1997 is 1996 - 1991
....
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2006 is 2005 - 2000
*/

sort nuts2 nace year 
br 
*we browse after sorting to identify the unit of observations followed through time in this dataset
*the dataframe is a panel where observations followed over time are industries within a region. Hence, we generate a variable containing an individual region-industry code which allows us to reshape the dataset along the individual dimension to then easily compute the desired delta and carry out similar unit-specific operations

egen id_code = concat(nuts2 nace)
sort id_code year 	
*all good, observations along the time dimension for one observation are now sorted one below the other

**reshape to wide dataframe
reshape wide empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

save "Datasets/Merged_data_ProblemV_Wide.dta", replace

use "Datasets/Merged_data_ProblemV_Wide.dta", clear
**saving the wide dataset to simplify the subsequent merge with the regional China shocks computed 

des
*840 individual regions-industries followed through time.
/*Now algebraic operations involving variables of a single unit can be esily carreid out.
We generated, by the rashaping, a time-indexed version of each variable, with one observation per unit. A difference between two variable will now be computed among single units of observation (region-industries). Thus, we can esaily carry out the delta imports for a specific region-industry by using the time-indexed variables.
*/

*Computing 5-year Delta imports from China using national, industry-specify China imports
forvalues i = 1995(1)2006 {
	local b = `i'-6
	local t = `i'-1
	gen D_Imp_China`i' = real_imports_china`t' - real_imports_china`b'
}
*for each regional industry observation, we generate 2006-1995=11 variables for the 5-year variations (deltas) in real imports from China 

sort country nace
*indeed, region-industry observations in the same country and industry, in the same year, display the same delta imports from china - as expected. Delta imports correctly computed

sum D_Imp_China1995-D_Imp_China2006
* note: 823 observations for the 1995 D_Imp_China1995 (vs 840 for the other years) this is due to the fact that in Spain we have no data in real_imports_china in 1989 (real_imports_1989) for industry Nace==DF


**** computing the regional China Shock in each year
*we start by computing the "China Shock" for each industry in a region, and then we make compute the regional shock by taking the sum over all industries in the region (following the formula by Colantone & Stanig, AJPS, 2018)

forvalues i = 1995(1)2006 {
	gen China_shock_k_`i' = ///
	(empl1989/tot_empl_nuts21989)*(D_Imp_China`i'/tot_empl_country_nace1989) 
}
*we have computed the china shock for each industry in each region.
/* 42 missing values generated (in WIDE dataset),
They come from missing employment data. To see where, use: 
tab id_code if China_shock_k_1995==.
the missing region/industries should not affect the results as they concern notably minor industries in small regions (i.e., for Italy we are missing data from Val D'Aosta, Molise e Bolzano for the Manufacture of coke, refined petroleum products and nuclear fuel)
*/


****computing China shocks using US delta imports (that is, using US imports as an instrument for the exogenous (i.e. supply driven) part of the increase in Chinese imports

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
*42 missing again from missing employment data


**# (V.b)
**** generating the regional China Shocks
*using national imports and the US imports as an IV

collapse (sum) China_shock_k_1995-China_shock_k_2006 IV_China_shock_k_1995-IV_China_shock_k_2006, by(nuts2)

/* Once collapsed the dataset, we now have only one observation per region,
with values for each of the two year-index China shock variables (from 1995 to 2006) computed as the sum of the China shock in each individual industry within that region, in that year - using country-specific China imports, or instrumenting them through the China-imports in the US. 
This Regional China Shock is stored under the previous China_shock_k_YEAR and IV_China_shock_k_YEAR variables by the command sum. Since we now summed the values for each industry with a region to compute the regional China shock, we rename the variable accordingly by dropping the k 
*/

forvalues i = 1995(1)2006 {
	rename China_shock_k_`i' China_shock_`i'
}

forvalues i = 1995(1)2006 {
	rename IV_China_shock_k_`i' IV_China_shock_`i'
}


save "Datasets/Regional_China_Shocks.dta", replace
*saving the region-specific China shocks in a specific dataset


*****Merging the china shocks produced to the full dataset

**using the wide merged original dataset to merge into it the wide dataset with the newly computed China Shocks
use "Datasets/Merged_data_ProblemV_Wide.dta", clear
merge m:1 nuts2 using "Datasets/Regional_China_Shocks.dta" 
*840 (all) matched
drop _merge

**saving the new dataset, complete of regional-level, year-indexed China shocks (computed using both using national imports and US imports)
save "Datasets/Merged_data_ProblemV_Shocks.dta", replace

use "Datasets/Merged_data_ProblemV_Shocks.dta", clear
 
reshape long China_shock_ IV_China_shock_, i(id_code) j(year)
*reshaping we have our original dataset, but with the China shocks merged into it under a single varibale with the right measure per each year and region

**** collapsing the dataset by region to obtain the average 5-year China shock over the sample period
collapse (mean) China_shock_ IV_China_shock_, by (nuts2)

* we save our new cross-sectional dataset with one observation per region
save "Datasets/Merged_data_ProblemV_shocks_regionalcrossection", replace


**# (V.c)
use "Datasets/Merged_data_ProblemV_shocks_regionalcrossection", clear

spshape2dta "Shapefiles/NUTS_RG_03M_2010_4326.shp", replace saving(europe_nuts)
*we have created two dta datasets based on the shp dataset of nuts codification of 2010.


****Setting up the two files needed for the production of the map***

use europe_nuts, clear //This contains the nuts2 names and characteristics of the regions
*we keep only Spain, France and Italy and Nuts2 regions classification
keep if CNTR_CODE == "IT" | CNTR_CODE == "ES" | CNTR_CODE == "FR"
keep if LEVL_CODE == 2

**Renaming the idenfitiers and compressing the file
ren NUTS_ID nuts2 //This allows us the merge it with the dataset containing the China Shock
cap ren NAME_LATN nuts2_name 
compress //Compress the dataset to save some space
sort _ID //Sort by ID. Recall: the ID is necessary for the production of the map
save "Shapefiles/europe_nuts_ready.dta", replace

**Now, we work on the shape file, which is the base file necessary to construct the map with the command spmap
use europe_nuts_shp.dta, clear
merge m:1 _ID using "Shapefiles/europe_nuts_ready.dta"
*We merge the shapefile with the .dta in order to retrieve the characteristics of the nuts regions in the dta
drop if _merge!= 3  //We drop the unmatched (i.e. we only keep FR, ITA, and ES)
keep if _X > -25 & _Y >30 // Get rid of the small islands from the map which will be generated
keep _ID _X _Y _CY _CX //keep the coordinates and unique identifyer
geo2xy _CY _CX, proj (lambert_sphere) replace	 //resize and center the map in the graph (standard command which works with this type of nuts to recentre the map)
scatter _Y _X, msize(tiny) msymbol(point)  //It's a map!
sort _ID
save "Shapefiles/europe_nuts_Shapefile_readyformap", replace


**# *****Now, we produce the graph for the China shock!**
*We use the first shape file with all the nuts info and we merge it to our dataset with the china shock data
use "Shapefiles/europe_nuts_ready", clear
merge 1:m nuts2 using "Datasets/Merged_data_ProblemV_shocks_regionalcrossection"
**6 unmatched observations: they are Guadeloupe, Martinique, Guyane, Réunion (small former colonies in France, for which we do not have data) and Ciudad Autónoma de Ceuta and Ciudad Autónoma de Melilla (small independent Spanish cities in the Moroccan territory): all good!

drop if _merge!= 3
save "Datasets/ReadyforMap",replace 
*This dataset has to be in use when we graph the map, as is the one on which we run the spmap command, using the created europe_nuts_Shapefile_readyformap above as "basis" for the map.  

spmap China_shock_ using "Shapefiles/europe_nuts_Shapefile_readyformap", id(_ID) fcolor(Blues2) legtitle("Mean China Shock in years 1989-2006") legend(pos(6) row(8) ring(1) size(*1.2) symx(*.75) symy(*.75) forcesize) title("China Shock computed using National imports from China")
graph rename China_Shock, replace

graph export "Maps/China_Shock_Map.png", replace

*Extra, map of the China shocks computed through the US-imports instrument
spmap IV_China_shock_ using "Shapefiles/europe_nuts_Shapefile_readyformap", id(_ID) fcolor(Blues2) legtitle("Mean China Shock in years 1989-2006") legend(pos(6) row(8) ring(1) size(*1.2) symx(*1.2) symy(*.75) forcesize) title("China Shock computed using US imports from China (IV)")
graph rename IV_China_Shock, replace  //quite similar 

graph export "Maps/IV_China_Shock_Map.png", replace 


**# ****Now, we produce the same map using employment in industry 29**
*Again, we use the variable nuts2 to merge the dataset with the "Shapefiles/europe_nuts_ready" file. Therefore, as above:
use "Shapefiles/europe_nuts_ready", clear 
merge 1:m nuts2 using "Datasets/Employment_Shares_Take_Home.dta" 
*Same unmatched as above, good!
drop if _merge!= 3

*generating a unique region-industry code to keep only one observation for each, containing the pre-sample employment values
egen id_code = concat(nuts2 nace)
duplicates drop id_code, force
collapse _ID tot_empl_nuts2 (sum) empl, by (nuts2)

*generating regional manuefacturing employment shares (over the overall regional employment)
gen empl_share_manu = empl/tot_empl_nuts2 

spmap empl_share_manu  using "Shapefiles/europe_nuts_Shapefile_readyformap", id(_ID) fcolor(Blues2) legtitle("Employment share in manufacturing sector") legend(pos(6) row(8) ring(1) size(*1.2) symx(*.75) symy(*.75) forcesize) title ("Pre-sample employment share in the manufacturing sector")
graph rename Emp_share, replace

graph export "Maps/Employment_Share_Map.png", replace

** combining the two China Shock maps
graph combine China_Shock IV_China_Shock, title("The China Shock in Europe" "by region, 1989-2006 average", size(4)) subtitle("Shock omputation following Colantone and Stanig, 2018 (AJPS)", size(2)) iscale(*.65)
graph export "Maps/Combined_Shocks.png", replace 

** combining the China shock and the employment share maps
graph combine China_Shock Emp_share, iscale(*.65)
graph export "Maps/Combined_Shock_Emp.png", replace 



***************
**# Problem VI
***************

use "Datasets/EEI_TH_5d_2022_V2.dta", clear
//generating a unique identifier for each industry-region
egen id_code = concat(nuts_code nace2_2_group)	

codebook id_code 
sort id_code year 

reshape wide tfp mean_uwage share_tert_educ lnpop control_gdp, i(id_code) j(year)
*We have now 700 observations and tfp and mean_wage are indexed by year which we can easily use to construct their means for each industry-region unit of observation

**mean of tfp* 
gen Mean_tfp = ((tfp2014 + tfp2015 + tfp2016 + tfp2017)/4)

**Now, mean of wages**
gen Mean_wages = ((mean_uwage2014 +mean_uwage2015 + mean_uwage2016 + mean_uwage2017)/4) 

**we also generate the control variables for population, education and GDP in 2014 which will be used as controls
gen pop_14 = lnpop2014
gen educ_14 = share_tert_educ2014 
gen gdp_14 = control_gdp2014

*restoring original shap of the dataframe - with time-invariant variables repeated every year
reshape long tfp mean_uwage share_tert_educ lnpop control_gdp, i(id_code) j(year)

*Rename the nuts2 identifier over which we merge China shocks dataset
rename nuts_code nuts2 

merge m:1 nuts2 using "Datasets/Merged_data_ProblemV_shocks_regionalcrossection"
//768 unmatched observations, coming from nuts2 for which we do not have observations in the China_shocks datasets-->  ES63 ES64 FRA1 FRA2 FRA3 FRA4

keep if _merge == 3
drop _merge
save "Datasets/EEI_TH_5d_2022_V2_ChinaShock_merged", replace


**# (VI.a)
use "Datasets/EEI_TH_5d_2022_V2_ChinaShock_merged", clear

*storing average baseline values of our dependent variables to add them in our tables for evaluation of TE magnitude
sum Mean_tfp
scalar M_tfp=r(mean) 

**OLS
reghdfe Mean_tfp China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel replace  title("Effect of the China Shock (1995-2006) on the Post-Crisis (2014-2017) industry-region average TFP and Wage") addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) addnote("Robust Standard Errors") cttop(OLS) nocons
//China shock coefficient is positive and significant, F-stat well-above the rule-of-thumb value of 10


**# (VI.b)
*using the instrumental variable built before, based on changes in Chinese imports in the USA, we run again the regression in a using 2SLS.
*For completeness, every time we run an IV regression, we output every step in a table for future reference

**Estimating the FIRST STAGE 
*to argue for relevance of the instrument
*Using FIRST and SAVEFIRST to output the first stage

ivreghdfe Mean_tfp (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) robust first savefirst
scalar F_weak = e(widstat) //creating scalar with the F-stat from the IVreg
est restore _ivreg2_China_shock_ //restore first stage

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons
//output the first stage!

**Estimating the REDUCED FORM
*to argue for the validity of the IV by looking at the sign and magnitude of its impact on the outcome. We show the reduced form regression for sake of completness. (note, we don't restrict the regression to exclude missing values of the variable to be instrumented since in this case there is none)
reghdfe Mean_tfp IV_China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons
//reduced form significant!

** Estimate the SECOND STAGE. 
ivreghdfe Mean_tfp (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) robust

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons 
//China Shock, instrumented by the US china shocks, is a relevant and powerful explanatory var for the average post-crisis TFP


**# (VI.c)

sum Mean_wages
scalar M_wages=r(mean) 

**OLS

reghdfe Mean_wages China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(OLS) nocons  


**Estimating the FIRST STAGE 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) robust first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons

**Estimating the REDUCED FORM model

reghdfe Mean_wages IV_China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons

**estimating the SECOND STAGE. 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) robust 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons


**# (VI.d)

**OLS

reghdfe Mean_wages China_shock_ pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(OLS) nocons  

**Estimate the FIRST STAGE 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) robust first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons

**Estimating the REDUCED FORM model

reghdfe Mean_wages IV_China_shock_ pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) vce(robust) 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons

**estimating the SECOND STAGE. 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) robust 

outreg2 using "Output/TABLE_P6a.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons




if 1 == 0 { //Version of Problem VI with clustered SE

*(VI.a)
use "Datasets/EEI_TH_5d_2022_V2_ChinaShock_merged", clear
sum Mean_tfp
scalar M_tfp=r(mean) 

**OLS
reghdfe Mean_tfp China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel replace  title("Effect of the China Shock (1995-2006) on the Post-Crisis (2014-2017) industry-region average TFP and Wage") addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) addnote("Standard Errors Clustered at the Nuts2 level") cttop(OLS) nocons

*(VI.b)
**Estimating the FIRST STAGE 
ivreghdfe Mean_tfp (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) cluster(nuts2) first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_ 
outreg2 using "Output/TABLE_P6r.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons

**Estimating the REDUCED FORM
reghdfe Mean_tfp IV_China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons
//reduced form significant!

** Estimate the SECOND STAGE. 
ivreghdfe Mean_tfp (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) cluster(nuts2)

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_tfp) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons 
//China Shock, instrumented by the US china shocks, is a relevant and powerful explanatory var for the average post-crisis TFP

*(VI.c)

sum Mean_wages
scalar M_wages=r(mean) 

**OLS

reghdfe Mean_wages China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(OLS) nocons  


**Estimating the FIRST STAGE 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) cluster(nuts2) first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons

**Estimating the REDUCED FORM model

reghdfe Mean_wages IV_China_shock_ pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons

**estimating the SECOND STAGE. 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 if year==2017, absorb(cou ind) cluster(nuts2)  

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons


*(VI.d)

**OLS

reghdfe Mean_wages China_shock_ pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(OLS) nocons  

**Estimate the FIRST STAGE 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) cluster(nuts2) first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("F-statistic instruments", F_weak) addtext(Country FE, Yes, Industry FE, Yes) cttop(First Stage) nocons

**Estimating the REDUCED FORM model

reghdfe Mean_wages IV_China_shock_ pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) vce(cluster nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Reduced Form) nocons

**estimating the SECOND STAGE. 

ivreghdfe Mean_wages (China_shock_= IV_China_shock_) pop_14 educ_14 gdp_14 Mean_tfp if year==2017, absorb(cou ind) cluster(nuts2) 

outreg2 using "Output/TABLE_P6r.xls", excel append addstat("Mean Dependent Var", M_wages) addtext(Country FE, Yes, Industry FE, Yes) cttop(Second Stage) nocons

	
}





***************
**# Problem VII
***************

**# (VII.a)

use "Datasets/ESS8e02_2.dta", clear
keep if cntry == "IT"
keep pspwght gndr agea eisced region  prtvtbit
rename region nuts2
merge m:1 nuts2 using"Datasets/Merged_data_ProblemV_shocks_regionalcrossection"
*40 from "using" dataset are unmatched - this is in order since we are interested only in Italian regions
drop if _merge != 3
drop _merge

*for better and easier outreg2 outputs, we rename the variables of interest
rename agea Age
gen Female=0
replace Female=1 if gndr==2
drop gndr

save "Datasets/ESS_IT_Shocks_merged.dta", replace

**# (VII.b)

use "Datasets/ESS_IT_Shocks_merged.dta", clear
gen Radical_Right_Dummy = 0
replace Radical_Right_Dummy = 1 if prtvtbit == 9 | prtvtbit == 10

**OLS
reg Radical_Right_Dummy China_shock_ Age Female i.eisced [pweight=pspwght], cluster(nuts2) 

outreg2 using "Output/TABLE_P7.xls", excel replace  title("Individual-level Effects of the China Shock (1995-2006) on the probability of radical-right voting")addtext(Education Dummies, Yes) addnote("Standard Errors Clustered at the Nuts2 level, Post-stratification weight including design weight") keep(China_shock_ Age Female IV_China_shock_) cttop(OLS)  

**# (VII.C)
*To correct for endogeneity issues, we use the instrumental variable built before, based on changes in Chinese imports in the USA

**Estimating the FIRST STAGE 
ivreg2 Radical_Right_Dummy (China_shock_= IV_China_shock_) Age Female i.eisced [pweight=pspwght], cluster(nuts2) first savefirst
scalar F_weak = e(widstat)
est restore _ivreg2_China_shock_

outreg2 using "Output/TABLE_P7.xls", excel append addstat("F-statistic instruments", F_weak) keep(China_shock_ Age Female IV_China_shock_) cttop(First Stage)
//output the first stage!
*
**Estimating the REDUCED FORM model
reg Radical_Right_Dummy IV_China_shock_ Age Female i.eisced, cluster(nuts2)
outreg2 using "Output/TABLE_P7.xls", excel append keep(China_shock_ Age Female IV_China_shock_) cttop(Reduced Form)
//Significant!

**Estimate the SECOND STAGE. 
ivreg2 Radical_Right_Dummy (China_shock_= IV_China_shock_) Age Female i.eisced [pweight=pspwght], cluster(nuts2)
outreg2 using "Output/TABLE_P7.xls", excel append keep(China_shock_ Age Female IV_China_shock_) cttop(Second Stage)
//Significant and quite sizable effect

**# (VII.d)
*THEORETICAL COMMENTS

*Thank you!




