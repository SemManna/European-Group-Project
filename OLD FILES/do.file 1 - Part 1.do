clear all

*Creating log file
log using "Assignment.log", replace

**#Part 1 - dataset "EEI_TH_2022.dta"//
use "/Users/luisa/Documents/ESS/Economics of EU integration/Assignment/EEI_TH_2022.dta" 
use EEI_TH_2022.dta, clear

 describe        //describes the data and variables present

*** Problem I - Italy ***

* a) Summary Statistics of Italian Firms in 2008 by sector
summarize if year==2008 & country == "Italy"     
// restricts summary stats to Italy and 2008
by sector: summarize if year==2008 & country == "Italy" 

/*The restriction yields a cross-sectional dataset of 4'324 Italian firms in 2008. The observations for sector n.13 are 3'277 while for 29 are 1'047.
There is no significant loss of information in terms of missing values. 
Classsize indicates the size of the firms, which is a categorical variable rescaled between 1 and 5 to indicate the number of employees 
The mean value for both sectors is around 2, which indicates that the firms considered are relatively small 
and have, on average, between 10 and 29 employees. 
For what concerns the number of workers, in absolute values, we observe that the means show a significant difference, being 27.40 for 
firms in sector 13 versus 117.23 for firms in sector 29. Given the previous observation (size of the firm), this indicates that, in sector 29,
the firms belonging to category 5 (250+ employees) have a number of employees much greater than the firms in sector 13 belonging to the same size class.
Indeed, the maximum value for the number of workers in sector 13 is 1'248, versus 22'639 in sector 29. [plot? Expect skeweness; gini]
To correct for inflation, we prefer to comment on the values attained by real_sales (deflated values) rather than sales (absolute values). 
Real sales amount, in mean values, to 5'164.552 in sector 13 versus 42'093.11 in sector 29, unsurprisingly given the nature of the businesses in the two 
sectors considered, i.e. textile versus manufacturing of motor vehicles. Clearly, we would expect this discrepancy to be present also in the deflated 
values of capital and materials (see table). Analogously, the pattern also holds for real value added, i.e. revenues minus materials, showing a mean value 
of 11'981.93 for sector 29 versus 2'797.121 for sector 13. As opposed to the discrepancy in revenues, the difference between value added appears to be 
smaller probably due to the fact that raw materials in the motor sector are relatively higher.
For what concerns wages, given the higher average number of workers in sector 29, we expect a higher mean value for total wages per firm, 
and indeed we observe mean values of 918.72 in sector 13 and 4117.85 for sector 29. 
[plot??? Max value in 29 huge compared to mean... outlier? How skewed is the data?]
*/

* b) Compare  descriptive statistics for 2008 to the same figures in 2017
by sector: summarize if year==2017 & country == "Italy"     

/*  The restriction yields a cross-sectional dataset of 4'567 Italian firms in 2017. The observations for sector n.13 are 3'387 while for 29 are 1'173.
There is no significant loss of information in terms of missing values. 
The mean value of size_class for both sectors appears to be slighlty lower for both sectors, although still around the value of 2 which indicates
belonging to the class of firms with 10-29 employees, indicating a higher number of small firms, especially in sector 13.
Consistently, also the number of workers per firm appears to decrease, moving from an average value of 27.4 in 2008 to 21.8 in 2017 in sector 13 and from 
117.23 to 106.09 in sector 29. Indeed, we observe that the average value of wages slighlty decreases for sector 13, wheareas it increases in sector 29 by 
1'000'000 euro. 
Average real sales instead decrease for sector 13 from 5'164.55 to 4'240.52 thousands of euros. For sector 29, they increase from 42'093.11 to 51'886.3 
thousands of euros. 
The values of real capital and real raw materials decrease in the textile sector while slightly increase in the motor sector. 
Real value added decreases from 2797.12 in sector 13 in 2008 to 2407.43 in 2017, while it increases from 11'981.93 to 14'610.17 in sector 29. 
(Ulteriori osservazioni?)
*/


*** Problem II - Italy, Spain and France ***

* a) Estimate production function coefficients through OLS, WRDG and LP

/*OLS REGRESSION - VALUE ADDED
Estimate the coefficients of labour and capital*/

//generate logarthmic values
foreach var in real_sales real_M real_K L {
        gen ln_`var'=ln(`var')
        }

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
//add x.i to tell Stata that the OLS regression has fixed effects


//WOOLDRIDGE - VALUE ADDED

***INSTALL PACKAGE FIRST! (search prodest => install package prodest) --> Inserire linea di codice per installazione pacchetto per completezza (il codice deve poter runnare senza intoppi in qualsiasi pc)

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va 
xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va


//LEVINSOHN-PETRIN - VALUE ADDED --> questo ?? un pacchetto no? Inserire linea di codice per installazione pacchetto
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)


* b) Table for coefficients comparison
//@sem per produzione tabella

*** Problem III - Theoretical comments ***

*** Problem IV - TFP distribution ***
/*a)Comment on the presence of "extreme" values in both industries. 
Clear the TFP estimates from these extreme values (1st and 99th percentiles) 
and save a "cleaned sample".*/

//TFP ESTIMATION IN OLS
** OLS TFP: 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
predict ln_TFP_OLS_13, residuals 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 
predict ln_TFP_OLS_29, residuals 
/*Solow residual. 
This vector of residuals is the residual of a Cobb-Doubglas production function, so it is TFP, it is in log and for chemicals (look at the name)*/ 

gen TFP_OLS_13= exp(ln_TFP_OLS_13) 
gen TFP_OLS_29= exp(ln_TFP_OLS_29) 
/*Note that TFP is a multiplicative factor (The A in the production function, 
so I have to take the exponential of its log)*/

kdensity TFP_OLS_13 
kdensity TFP_OLS_29
//This command draws the density distribution of TFP. 
/* If the graph is very sweked, with very distant TFP observations, not plausible: 
Clean the distribution for outliers.*/ 

sum TFP_OLS_13, d
sum TFP_OLS_29, d
replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p5),r(p99)) 
replace TFP_OLS_29=. if !inrange(TFP_OLS_29,r(p5),r(p99)) 

//For some reason il command replace non funziona, da' sempre "0 changes" che ?? weird perch?? gli outliers ci sono//  
**Abbiamo controllato la effettiva presenza di osservazioni con valore >99th percentile, ad es per sect 13.
egen p99 = pctile(TFP_OLS_13), p(99)
sum p99
egen p99_5 = pctile(TFP_OLS_13), p(99_5)
sum p99_5
* valore di p99_5 > p99

sum TFP_OLS_13, d
kdensity TFP_OLS_13
sum TFP_OLS_29, d
kdensity TFP_OLS_29
gen ln_TFP_OLS_13_t=ln(TFP_OLS_13) 
gen ln_TFP_OLS_29_t=ln(TFP_OLS_29)// t stands for transformed (post !inrange)
/*Plot the kdensity of the TFP distribution and the kdensity of the logarithmic 
transformation of TFP in each industry*/

tw kdensity ln_TFP_OLS_13_t || TFP_OLS_13 \\error! TFP_OLS_ is not a twoway plot type 
tw kdensity ln_TFP_OLS_29_t || TFP_OLS_29

** LP and WDRDG TFP:
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13, omega
gen TFP_LP_13=exp(ln_TFP_LP_13)
replace TFP_LP_13=. if !inrange(TFP_LP_13, r(p1),r(p99))
sum TFP_LP_13, d	
g ln_TFP_LP_13_t=ln(TFP_LP_13)

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13, resid

tw kdensity ln_TFP_LP_13_t || kdensity ln_TFP_WRDG_13 || kdensity ln_TFP_OLS_13_t


xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29, omega
gen TFP_LP_29=exp(ln_TFP_LP_29)
replace TFP_LP_29=. if !inrange(TFP_LP_29, r(p1),r(p99))
sum TFP_LP_29, d	
g ln_TFP_LP_29_t=ln(TFP_LP_29)

xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29, resid

tw kdensity ln_TFP_LP_29_t || kdensity ln_TFP_WRDG_29 || kdensity ln_TFP_OLS_29_t


*b) Plot the TFP distribution for each country

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "Italy"
predict ln_TFP_OLS_13_IT, residuals 
gen TFP_OLS_13_IT= exp(ln_TFP_OLS_13_IT) 
kdensity TFP_OLS_13_IT 
sum TFP_OLS_13_IT, d
replace TFP_OLS_13_IT=. if !inrange(TFP_OLS_13_IT,r(p5),r(p99)) 
kdensity TFP_OLS_13_IT
gen ln_TFP_OLS_13_IT_t=ln(TFP_OLS_13_IT) 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "Spain"
predict ln_TFP_OLS_13_SP, residuals 
gen TFP_OLS_13_SP= exp(ln_TFP_OLS_13_SP) 
kdensity TFP_OLS_13_SP 
sum TFP_OLS_13_SP, d
replace TFP_OLS_13_SP=. if !inrange(TFP_OLS_13_SP,r(p5),r(p99)) 
kdensity TFP_OLS_13_SP
gen ln_TFP_OLS_13_SP_t=ln(TFP_OLS_13_SP) 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "France"
predict ln_TFP_OLS_13_FR, residuals 
gen TFP_OLS_13_FR= exp(ln_TFP_OLS_13_FR) 
kdensity TFP_OLS_13_FR 
sum TFP_OLS_13_FR, d
replace TFP_OLS_13_FR=. if !inrange(TFP_OLS_13_FR,r(p5),r(p99)) 
kdensity TFP_OLS_13_FR
gen ln_TFP_OLS_13_FR_t=ln(TFP_OLS_13_FR) 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "Italy"
predict ln_TFP_OLS_29_IT, residuals 
gen TFP_OLS_29_IT= exp(ln_TFP_OLS_29_IT) 
kdensity TFP_OLS_29_IT 
sum TFP_OLS_29_IT, d
replace TFP_OLS_29_IT=. if !inrange(TFP_OLS_29_IT,r(p5),r(p99)) 
kdensity TFP_OLS_29_IT
gen ln_TFP_OLS_29_IT_t=ln(TFP_OLS_29_IT) 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "Spain"
predict ln_TFP_OLS_29_SP, residuals 
gen TFP_OLS_29_SP= exp(ln_TFP_OLS_29_SP) 
kdensity TFP_OLS_29_SP 
sum TFP_OLS_29_SP, d
replace TFP_OLS_29_SP=. if !inrange(TFP_OLS_29_SP,r(p5),r(p99)) 
kdensity TFP_OLS_29_SP
gen ln_TFP_OLS_29_SP_t=ln(TFP_OLS_29_SP) 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "France"
predict ln_TFP_OLS_29_FR, residuals 
gen TFP_OLS_29_FR= exp(ln_TFP_OLS_29_FR) 
kdensity TFP_OLS_29_FR 
sum TFP_OLS_29_FR, d
replace TFP_OLS_29_FR=. if !inrange(TFP_OLS_29_FR,r(p5),r(p99)) 
kdensity TFP_OLS_29_FR
gen ln_TFP_OLS_29_FR_t=ln(TFP_OLS_29_FR) 

// no issues qua//

//Compare LP and WRDG by country//
** LP and WDRDG TFP:

xi: levpet ln_real_VA if sector==13 & country=="Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_IT, omega
gen TFP_LP_13_IT=exp(ln_TFP_LP_13_IT)
replace TFP_LP_13_IT=. if !inrange(TFP_LP_13_IT, r(p1),r(p99))
sum TFP_LP_13_IT, d	
g ln_TFP_LP_13_IT_t=ln(TFP_LP_13_IT)

xi: prodest ln_real_VA if sector==13 & country=="Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_IT, resid

tw kdensity ln_TFP_LP_13_IT_t || kdensity ln_TFP_WRDG_13_IT || kdensity ln_TFP_OLS_13_IT_t


xi: levpet ln_real_VA if sector==13 & country=="Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_SP, omega
gen TFP_LP_13_SP=exp(ln_TFP_LP_13_SP)
replace TFP_LP_13_SP=. if !inrange(TFP_LP_13_SP, r(p1),r(p99))
sum TFP_LP_13_SP, d	
g ln_TFP_LP_13_SP_t=ln(TFP_LP_13_SP)

xi: prodest ln_real_VA if sector==13 & country=="Spain", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_SP, resid

tw kdensity ln_TFP_LP_13_SP_t || kdensity ln_TFP_WRDG_13_SP || kdensity ln_TFP_OLS_13_SP_t

xi: levpet ln_real_VA if sector==13 & country=="France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_FR, omega
gen TFP_LP_13_FR=exp(ln_TFP_LP_13_FR)
replace TFP_LP_13_FR=. if !inrange(TFP_LP_13_FR, r(p1),r(p99))
sum TFP_LP_13_FR, d	
g ln_TFP_LP_13_FR_t=ln(TFP_LP_13_FR)

xi: prodest ln_real_VA if sector==13 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_FR, resid

tw kdensity ln_TFP_LP_13_FR_t || kdensity ln_TFP_WRDG_13_FR || kdensity ln_TFP_OLS_13_FR_t

xi: levpet ln_real_VA if sector==29 & country=="Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_IT, omega
gen TFP_LP_29_IT=exp(ln_TFP_LP_29_IT)
replace TFP_LP_29_IT=. if !inrange(TFP_LP_29_IT, r(p1),r(p99))
sum TFP_LP_29_IT, d	
g ln_TFP_LP_29_IT_t=ln(TFP_LP_29_IT)

xi: prodest ln_real_VA if sector==29 & country=="Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_IT, resid

tw kdensity ln_TFP_LP_29_IT_t || kdensity ln_TFP_WRDG_29_IT || kdensity ln_TFP_OLS_29_IT_t

xi: levpet ln_real_VA if sector==29 & country=="Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_SP, omega
gen TFP_LP_29_SP=exp(ln_TFP_LP_29_SP)
replace TFP_LP_29_SP=. if !inrange(TFP_LP_29_SP, r(p1),r(p99))
sum TFP_LP_29_SP, d	
g ln_TFP_LP_29_SP_t=ln(TFP_LP_29_SP)

xi: prodest ln_real_VA if sector==29 & country=="Spain", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_SP, resid

tw kdensity ln_TFP_LP_29_SP_t || kdensity ln_TFP_WRDG_29_SP || kdensity ln_TFP_OLS_29_SP_t

xi: levpet ln_real_VA if sector==29 & country=="France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_FR, omega
gen TFP_LP_29_FR=exp(ln_TFP_LP_29_FR)
replace TFP_LP_29_FR=. if !inrange(TFP_LP_29_FR, r(p1),r(p99))
sum TFP_LP_29_FR, d	
g ln_TFP_LP_29_FR_t=ln(TFP_LP_29_FR)

xi: prodest ln_real_VA if sector==29 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_FR, resid

tw kdensity ln_TFP_LP_29_FR_t || kdensity ln_TFP_WRDG_29_FR || kdensity ln_TFP_OLS_29_FR_t


//I grafici con le tre densities non vengono perch?? la distribuzionde della TFP con LP esce super flat. 
Abbiamo pensato di fare un tentativo con prodest(lp) invece di levpet, usando Francia #29 come trial e
funziona. La OLS viene un po' sbirulenca ma centrata su 0 e con una forma decente (approximately gaussiana),
mentre WRDG e LP quasi overlapping://

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "France"
predict ln_TFP_OLS_29_FR, residuals 
gen TFP_OLS_29_FR= exp(ln_TFP_OLS_29_FR) 
kdensity TFP_OLS_29_FR 
sum TFP_OLS_29_FR, d
replace TFP_OLS_29_FR=. if !inrange(TFP_OLS_29_FR,r(p5),r(p99)) 
kdensity TFP_OLS_29_FR
gen ln_TFP_OLS_29_FR_t=ln(TFP_OLS_29_FR)

xi: prodest ln_real_VA if sector==29 & country=="France", met(lp) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_LP_29_FR, resid

xi: prodest ln_real_VA if sector==29 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_FR, resid

tw kdensity ln_TFP_LP_29_FR || kdensity ln_TFP_WRDG_29_FR || kdensity ln_TFP_OLS_29_FR_t



/*c) TFP distributions of industry 29 in France and Italy. Changes in TFP distributions in 2001 vs 2008. Compare LP and WRDG */




*d) Changes in skewness in 2001 vs 2008.




