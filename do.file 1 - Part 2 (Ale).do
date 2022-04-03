***Take Home - Part 2***
*Last Edit: April 3, 2022*

************
* Problem 5
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
use Merged_data_ProblemV.dta

******Compute the China shock for each European region****** 
/*We first compute the Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡 in 5-years lags, as specified in the istructions: 
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1995 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1996 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 is 1994 - 1989
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2000 is 2000 - 1995
Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_2006 is 2005 - 2001

Voi che ne dite? non saprei come altro dividerli in questi "bins". Fate sapere! 
*/
**Δ𝐼𝑀𝑃𝐶ℎ𝑖𝑛𝑎𝑐𝑘𝑡_1994 computation**
gen D_Imp_China1994= 
foreach i inrange(1989,2006) {
	di `i'
	
}
ge 
egen Delta_Imports_1994 = imports 1994 - imports 1989
foreach v in year{
	
}
gen real_imports_1989 = real_imports_china if year == 1989

 