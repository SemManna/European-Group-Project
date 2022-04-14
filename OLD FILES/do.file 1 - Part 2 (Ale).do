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
drop _merge _merge2
save Merged_data_ProblemV.dta, replace

use Merged_data_ProblemV.dta, clear

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

sort nuts2 year 
br //browse after sorting to identify the individual observations in this dataset
//this dataset is basically a panel dataset where observations followed over time are industries within a region. So we generate a variable containing an individual region-industry code which allows us to reshape the dataset along the individual dimension to then easily compute the desired delta
 

egen id_code = concat(nuts2 nace)
sort id_code year //seems good! observations along the time dimension for one observation are now one below the other

reshape wide country nuts2_name nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china, i(id_code) j(year)

des //840 individual regions followed through time, now taking algebraic operations such as differences between two variables (which have been generated, by the rashaping, with time-indexes) will take differences in the values of time-indexed covariates for that specific region-industry!

forvalues i = 1995(1)2006 {
	local b = `i'-6
	local t = `i'-1
	gen D_Imp_China`i' = real_imports_china`t' - real_imports_china`b'
}
//for each regional industry observation, we generate 2006-1995=11 variables for the 5-year variations (deltas) in real imports from China 

sort nuts21989 nace1989 //indeed, observations in the same region and industry, in the same year, display the same delta imports from china, as desired! we correctly produced the desired metric
//nuts2 ambigious ambbreviation

sum D_Imp_China1995 D_Imp_China1996 D_Imp_China1997 D_Imp_China1998 D_Imp_China1999 D_Imp_China2000 D_Imp_China2001 D_Imp_China2002 D_Imp_China2003 D_Imp_China2004 D_Imp_China2005 D_Imp_China2006

//Problem with this: lack of observations for the 1995 D_Imp_China1995 this is due to the fact that in Spain we have no data in real_imports_china in 1989 (real_imports_1989) FOR INDUSTRY nace = DF! 

*Now, we compute the China shock for each region in each year* 
//we start by computing the China shock for each industry, in each region, and then we make the sum across all industries in that region//

forvalues i = 1995(1)2006 {
	gen China_shock_k_`i' = ///
	(empl1989/tot_empl_nuts21989)*(D_Imp_China`i'/tot_empl_country_nace1989) 
}
*we have computed the china shock for each industry in each region. Now we sum across all industries
//note, 756 missings coming from empl, inquire more on which are - when computing this in long dataset (no 1989 needed in pre-sample vars when using long dataset!)
//42 missing values generated!!! in WIDE dataset 


if 1=0{
local nacelist "DA DB DC DD DE DF DG DH DI DJ DK DL DM DN"
local nuts2_list "________"

foreach z in `nuts2_list'{ 

}

reshape long country nuts2_name nuts2 nace empl tot_empl_nuts2 tot_empl_country_nace real_imports_china real_USimports_china D_Imp_China China_shock China_Shock_DA China_Shock_DB China_Shock_DC China_Shock_DD China_Shock_DE China_Shock_DF China_Shock_DG China_Shock_DH China_Shock_DI China_Shock_DJ China_Shock_DK China_Shock_DL China_Shock_DM China_Shock_DN , i(id_code) j(year)
}


preserve

collapse (sum) China_shock_k_1995 China_shock_k_1996 China_shock_k_1997 China_shock_k_1998 China_shock_k_1999 China_shock_k_2000 China_shock_k_2001 China_shock_k_2002 China_shock_k_2003 China_shock_k_2004 China_shock_k_2005 China_shock_k_2006, by(nuts21990)
//collapsed the dataset, we now only have one observation per region, with one observation per year (from 1994 to 2006) being the sum of the chinashock in each individual industry within that region, in that year stored under the previous China_shock_k_YEAR variables
forvalues i = 1995(1)2006 {
	rename China_shock_k_`i' China_shock_`i'
}

duplicates drop nuts21990, force //no region-duplicates, seems like we did all correctly

rename nuts21990 nuts2
save Regional_China_Shocks, replace

restore

*****Merging the china shocks produced to the full dataset
use Merged_data_ProblemV.dta, clear
merge m:1 nuts2 using Regional_China_Shocks.dta
sort nuts2 nace year
drop _merge

//saving the new dataset, complete of regional-level, year-indexed china shocks!
save Merged_data_ProblemV_Shocks.dta, replace

use Merged_data_ProblemV_Shocks.dta, clear

**Point b.
/*Collapse the dataset by region 
to obtain the average 5-year China shock over the sample period. This will be the average of all available years' shocks (for reference, see Colantone and Stanig, American Political Science Review, 2018). You should now have a dataset with cross-sectional data.
*/


collapse (mean) China_shock_1995 China_shock_1996 China_shock_1997 China_shock_1998 China_shock_1999 China_shock_2000 China_shock_2001 China_shock_2002 China_shock_2003 China_shock_2004 China_shock_2005 China_shock_2006, by(nuts2)

//should be identical to 
duplicates drop nuts2, force



**Point c.
/*Using the cross-sectional data, 
produce a map visualizing the China shock for each region, i.e., with darker shades reflecting stronger shocks. Going back to the "Employment_Shares_Take_Home.dta", do the same with respect to the overall pre-sample share of employment in the manufacturing sector. 
Do you notice any similarities between the two maps? What were your expectations? Comment. */
 
 
 