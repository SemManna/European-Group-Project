clear all

*Creating log file
log using "Assignment.log", replace

**#Part 1 - dataset "EEI_TH_2022.dta"//
use "/Users/luisa/Documents/ESS/Economics of EU integration/Assignment/EEI_TH_2022.dta" 
use EEI_TH_2022.dta, clear

 describe        //describes the data and variables present

*** Problem I - Italy ***

* a) Summary Statistics of Italian Firms in 2008
summarize if year==2008 & country == "Italy"     
// restricts summary stats to Italy and 2008
/*The restriction yields a cross-sectional dataset of 4'324 firms.
... 
*/

* b) Compare  descriptive statistics for 2008 to the same figures in 2017
summarize if year==2017 & country == "Italy"     

/* Comment and interpretation 
*/


*** Problem II - Italy, Spain and France ***

* a) Estimate production function coefficients through OLS, WRDG and LP

/*OLS REGRESSION - VALUE ADDED
Estimate the coefficients of labour and capital*/

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==24 
//add x.i to tell Stata that the OLS regression has fixed effects

predict ln_TFP_OLS_24, residuals 
/*Solow residual. 
This vector of residuals is the residual of a Cobb-Doubglas production function, so it is TFP, it is in log and for chemicals (look at the name)*/ 

*Note: the marginal productivity of labour and capital can be different for different industries. So you might want to run restricted regressions clustering for industry. At least two-digits aggregation of industries (here, we regress industry by industry). moreover, remember that this is a panel estimation. What you want to do is to consider the fact that marginal productivities might change over time, and taking all of them together is equivalent to take the average across time. What we want to do is to add year FIXED EFFECTS. Moreover, had we consider add also country FIXED EFFECTS.

gen TFP_OLS_24= exp(ln_TFP_OLS_24) 
/*Note that TFP is a multiplicative factor (The A in the production function, 
so I have to take the exponential of its log)*/

kdensity TFP_OLS_24 
//This command draws the density distribution of TFP. 
/* If the graph is very sweked, with very distant TFP observations, not plausible: 
Clean the distribution for outliers.*/ 

sum TFP_OLS_24, d
replace TFP_OLS_24=. if !inrange(TFP_OLS_24,r(p5),r(p99)) 
//Inrange comma, with !, allows us to replace to missing the information of TFP if the value of productivity is outside the bottom 5% or above the top 99%. We are trimming the top 1% of the distribution and the bottom 5%, because I a interested in the right tail of the distribution. This way of cleaning for outliers allows  

sum TFP_OLS_24, d
kdensity TFP_OLS_24

//LEVINSOHN-PETRIN - VALUE ADDED

* INSTALL PACKAGE FIRST! (search levpet => install package st0060)

xi: levpet ln_real_VA if sector==24, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_24, omega

sum TFP_LP_24, d
replace TFP_LP_24=. if !inrange(TFP_LP_24, r(p1),r(p99))

sum TFP_LP_24, d
kdensity TFP_LP_24

g ln_TFP_LP_24=ln(TFP_LP_24)
kdensity ln_TFP_LP_24


//WOOLDRIDGE/PRODEST - VALUE ADDED

***INSTALL PACKAGE FIRST! (search prodest => install package prodest)

xi: prodest ln_real_VA if sector==24, met(lp) free(ln_L i.year) proxy(ln_real_M) state(ln_real_K) va acf

predict ln_TFP_LP_ACF_24, resid

xi: prodest ln_real_VA if sector==24, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va

predict ln_TFP_WRDG_24, resid

tw kdensity ln_TFP_LP_24 || kdensity ln_TFP_LP_ACF_24 || kdensity ln_TFP_WRDG_24 || kdensity ln_TFP_OLS_24


* b) Table for coefficients comparison

*** Problem III - Theoretical comments ***

*** Problem IV - TFP distribution ***
/*a)Comment on the presence of "extreme" values in both industries. 
Clear the TFP estimates from these extreme values (1st and 99th percentiles) 
and save a "cleaned sample".*/


/*Plot the kdensity of the TFP distribution and the kdensity of the logarithmic 
transformation of TFP in each industry*/

*b) Plot the TFP distribution for each country from LP and WRDG

/*c) TFP distributions of industry 29 in France and Italy. Changes in 
distributions in 2001 vs 2008. Compare LP and WRDG */

*d) Changes in skewness in 2001 vs 2008.




