***Take Home - Part 2***
*Last Edit: April 3, 2022*

************
**# Problem 5
************

**Point a.
//Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to equation (1). Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 with Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑈𝑆𝐴𝑘𝑡, following the identification strategy by Colantone and Stanig (AJPS, 2018).//

use "Datasets/Employment_Shares_Take_Home.dta", clear //We start from this dataset to merge all the three together 
sort year country nuts2_name nace

*Merge Employment_Shares (master dataset) with Imports_China (using dataset)**
merge m:1 year country nace using "Datasets/Imports_China_Take_Home.dta"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        0
    Matched                            16,800  (_merge==3)
    -----------------------------------------
*/

*Now, we merge the obtained dataset from the merger of Employment_Shares and Imports_China (master dataset) with the Import_US_China dataset (using)
merge m:1 year nace using "Datasets/Imports_US_China_Take_Home.dta", gen(_merge2) 

/*   Result                      Number of obs  -----------------------------------------
    Not matched                         1,680
        from master                     1,680  (_merge2==1)
        from using                          0  (_merge2==2)

    Matched                            15,120  (_merge2==3)
    -----------------------------------------  
*/
*At this point, we keep only the _merge2==3 observations, as these correspond to the years in which US and EU data are both availabe. (NOTE THAT US DATA ARE 1989-2006, WHILE EU DATA ARE 1988-2007), so we were expecting some unmatched observations!

keep if _merge2==3 //We are thus left with 15,120 observations and we can start working on the computation of the China shock index for each region of each EU country//
drop _merge _merge2
save "Datasets/Merged_data_ProblemV.dta", replace

use "Datasets/Merged_data_ProblemV.dta", clear

******Compute the China shock for each European region****** 
/*We first compute the Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 in 5-years lags, as specified in the istructions: 
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1996 is 1995 - 1990
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1997 is 1996 - 1991
....
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2006 is 2005 - 2000

Voi che ne dite? non saprei come altro dividerli in questi "bins". Fate sapere! 
*/
**Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 computation**

sort nuts2 nace year 
br //browse after sorting to identify the individual observations in this dataset
//this dataset is basically a panel dataset where observations followed over time are industries within a region. So we generate a variable containing an individual region-industry code which allows us to reshape the dataset along the individual dimension to then easily compute the desired delta
 

egen id_code = concat(nuts2 nace)
sort id_code year //seems good! observations along the time dimension for one observation are now one below the other

reshape wide empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

save "Datasets/Merged_data_ProblemV_Wide.dta", replace

des //840 individual regions followed through time, now taking algebraic operations such as differences between two variables (which have been generated, by the rashaping, with time-indexes) will take differences in the values of time-indexed covariates for that specific region-industry!

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
//42 missing values generated!!! in WIDE dataset  (which make sense if they come to pre-1989 observations)



collapse (sum) China_shock_k_1995 China_shock_k_1996 China_shock_k_1997 China_shock_k_1998 China_shock_k_1999 China_shock_k_2000 China_shock_k_2001 China_shock_k_2002 China_shock_k_2003 China_shock_k_2004 China_shock_k_2005 China_shock_k_2006, by(nuts2)
//collapsed the dataset, we now only have one observation per region, with values for a year-index variable with the computed chinashock (from 1994 to 2006) as the sum of the chinashock in each individual industry within that region, in that year. This is stored under the previous China_shock_k_YEAR variables, since k is now useless (we summed the values for each industry to compute values of the shock at the regional level) we rename the variable 
forvalues i = 1995(1)2006 {
	rename China_shock_k_`i' China_shock_`i'
}

duplicates drop nuts2, force //no region-duplicates, seems like we did all correctly

save "Datasets/Regional_China_Shocks.dta", replace
*saving the region-specific China shocks in a specific dataset


*****Merging the china shocks produced to the full dataset

**using the wide merged original dataset to merge the wide-dataset with the newly computed china shocks into it
use "Datasets/Merged_data_ProblemV_Wide.dta", clear
merge m:1 nuts2 using "Datasets/Regional_China_Shocks.dta" 
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




**Point b.
/*Collapse the dataset by region 
to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data. --> READ ARTICLE
*/
use "Datasets/Merged_data_ProblemV_Shocks.dta", clear

collapse (mean) China_shock_1995 China_shock_1996 China_shock_1997 China_shock_1998 China_shock_1999 China_shock_2000 China_shock_2001 China_shock_2002 China_shock_2003 China_shock_2004 China_shock_2005 China_shock_2006, by(nuts2)

//should be identical to 
duplicates drop nuts2, force

reshape long China_shock_, i(nuts2) j(year)
//reshaping we have our original dataset, but with the China shocks merged into it under a single varibale with the right measure per each year and region

save "Datasets/Merged_data:ProblemV_shocks_regionalcrossection_long", replace

use "Datasets/Merged_data:ProblemV_shocks_regionalcrossection_long", clear



**Point c.
/*Using the cross-sectional data, 
produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment_Shares_Take_Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. 
Do you notice any similarities between the two maps? What were your expectations? Comment. */

*first install the program to transform shapefiles into dta files*
ssc install spshape2dta //it should be a built-in package, but still 
//produces an error - spshape2dta not found
ssc install spmap      // for the maps package
ssc install geo2xy   // for fixing the coordinate system

spshape2dta "Shapefiles/NUTS_RG_03M_2021_4326.shp", replace saving(europe_nuts)  //we have created two dta datasets based on the shp dataset

*we can explore the datasets just created (in a very raw way)*
use europe_nuts_shp, clear
scatter _Y _X, msize(tiny) msymbol(point)


*Now, let's get the dataset with the geo coordinates ready to produce the map*
merge m:1 _ID using europe_nuts //merge with the other dta file to retrieve the country codes. All observations matched!
drop _merge 
keep if CNTR_CODE == "IT" | CNTR_CODE == "ES" | CNTR_CODE == "FR"  //keep only Spain, France and Italy
keep if LEVL_CODE == 2 //keep only nuts2 regions
scatter _Y _X, msize(tiny) msymbol(point) //now we have only Spain, Italy and France!

ren NUTS_ID nuts2_id
cap ren NAME_LATN nuts2_name  
cap ren NUTS_NAME nuts2_name
compress
sort _ID


keep if _X > -25 & _Y >30 	//Get rid of the small islands
scatter _Y _X, msize(tiny) msymbol(point)
keep NUTS_ID _X _Y _CX _CY
geo2xy _CY _CX, proj (lambert_sphere) replace //we resize everything to have Italy, Spain and France in a proper size 
scatter _Y _X, msize(medium) msymbol(point) //very cute
save "Datasets/Map_structure_ready" //The skeleton of the map is ready, we save this dataset

*Produce the map*
use "Datasets/Map_structure_ready"
spmap using Map_structure_ready, id(NUTS_ID) 







 
 