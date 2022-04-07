***Take Home - Part 2***
*Last Edit: April 3, 2022*

************
**# Problem 5
************

**Point a.
//Merge the first three datasets together. Compute the China shock for each region, in each year for which it is possible, according to equation (1). Use a lag of 5 years to compute the import deltas (i.e., growth in imports between t-6 and t-1). Repeat the same procedure with US imports, i.e., substituting Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 with Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑈𝑆𝐴𝑘𝑡, following the identification strategy by Colantone and Stanig (AJPS, 2018).//

use Employment_Shares_Take_Home.dta, clear //We start from this dataset to merge all the three together 
sort year country nuts2_name nace

*Merge Employment_Shares (master dataset) with Imports_China (using dataset)**
merge m:1 year country nace using Imports_China_Take_Home.dta
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        0
    Matched                            16,800  (_merge==3)
    -----------------------------------------
*/

*Now, we merge the obtained dataset from the merger of Employment_Shares and Imports_China (master dataset) with the Import_US_China dataset (using)
merge m:1 year nace using Imports_US_China_Take_Home.dta, gen(_merge2) 

/*   Result                      Number of obs  -----------------------------------------
    Not matched                         1,680
        from master                     1,680  (_merge2==1)
        from using                          0  (_merge2==2)

    Matched                            15,120  (_merge2==3)
    -----------------------------------------  
*/
*At this point, we keep only the _merge2==3 observations, as these correspond to the years in which US and EU data are both availabe. (NOTE THAT US DATA ARE 1989-2006, WHILE EU DATA ARE 1988-2007), so we were expecting some unmatched observations!

keep if _merge2==3 //We are thus left with 15,120 observations and we can start working on the computation of the China shock index for each region of each EU country//

save Merged_data_ProblemV.dta, replace
use Merged_data_ProblemV.dta, clear

******Compute the China shock for each European region****** 
/*We first compute the Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 in 5-years lags, as specified in the istructions: 
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 is 1995 - 1990
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1996 is 1996 - 1991
....
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2006 is 2006 - 2001

Voi che ne dite? non saprei come altro dividerli in questi "bins". Fate sapere! 
*/
**Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 computation**

sort nuts2 year 
br //browse after sorting to identify the individual observations in this dataset
//this dataset is basically a panel dataset where observations followed over time are industries within a region. So we generate a variable containing an individual region-industry code which allows us to reshape the dataset along the individual dimension to then easily compute the desired delta
 
drop _merge _merge2
egen id_code = concat(nuts2 nace)
sort id_code year //seems good! observations along the time dimension for one observation are now one below the other

reshape wide country nuts2_name nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

des //840 individual regions followed through time, now taking algebraic operations such as differences between two variables (which have been generated, by the rashaping, with time-indexes) will take differences in the values of time-indexed covariates for that specific region-industry!

forvalues i = 1994(1)2006 {
	local d = `i'-5
	gen D_Imp_China`i' = real_imports_china`i' - real_imports_china`d'
}
//for each regional industry observation, we generate 2006-1994=12 variables for the 5-year variations (deltas) in real imports from China
 
reshape long country nuts2_name nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year) //finally, restoring the long dataset and magic! we have all our observation of interest in the desired format
//maybe we want to keep it wide also for the China shock calculation? 

sort nuts2 nace year //indeed, observations in the same region and industry, in the same year, display the same delta imports from china, as desired! we correctly produced the desired metric

sum D_Imp_China1994 D_Imp_China1995 D_Imp_China1996 D_Imp_China1997 D_Imp_China1998 D_Imp_China1999 D_Imp_China2000 D_Imp_China2001 D_Imp_China2002 D_Imp_China2003 D_Imp_China2004 D_Imp_China2005 D_Imp_China2006

//Problem with this: lack of observations for the 1994 D_Imp_China!!!// --> Solve later

*Now, we compute the China shock for each region in each year* 
//we start by computing the China shock for each industry, in each region, and then we make the sum across all industries in that region//

forvalues i = 1994(1)2006 {
	gen China_shock`i' = (empl/tot_empl_nuts2)*(D_Imp_China`i'/tot_empl_country_nace) 
}
*we have computed the china shock for each industry in each region. Now we sum across all industries

reshape wide country nuts2_name nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

forvalues i = 1994(1)2006 {
	foreach var in nace`i'{
	gen China_Shock_region`i'= sum(China_shock`i')
	}
}
**The China shock in that 

/*
egen Delta_Imports_1994 = imports 1994 - imports 1989
gen real_imports_1989 = real_imports_china if year == 1989
*/


//to be finished!

 
**Point b.
/*Collapse the dataset by region 
to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data.
*/

help collapse
collapse (mean) China_shock [pw= insert_weighting_var], by(nuts2)


**Point c.
/*Using the cross-sectional data, 
produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment_Shares_Take_Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. 
Do you notice any similarities between the two maps? What were your expectations? Comment. */
 
 
 