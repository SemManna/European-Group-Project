
*****************************************************
*File Description:	Take Home - Economics of European 
*								Integration  				
*Date:				April 2022
*Authors:			Bucci Filippo 		
*					Fascione Luisa		
*					Manna Sem
*					Pulvirenti Alessia 
*****************************************************


*commands to be downloaded
ssc instal vioplot

*graphical settings
set scheme s1color //remove gridlines and create white sourrounding around the graph. More plotting schemes from Stata here: http://people.umass.edu/biostat690c/pdf/stata%20schemes%20and%20palettes.pdf

cap graph set window fontface "LM Roman 10" //setting LaTeX font

**# ******** Part 1 - dataset "EEI_TH_2022.dta" 

use EEI_TH_2022.dta, clear

des      //describes the data and variables present

**# Problem I - Italy ***
preserve //preserves a caopy of the dataset as it is for quick retrival once we operated on the reduced one restricted to Italy
keep if country == "Italy" //drops all obvservations different from italy - so we can operate the .do without having to specify if country == Italy al the time

* a) Summary Statistics of Italian Firms in 2008 by sector
**note: consider using asdoc to export this and other useful commands
summarize if year==2008, d   // restricts summary stats to Italy in 2008

*GENERAL DESCRIPTIVE STAT FOR ITALIAN FIRMS
/*The restriction yields a cross-sectional dataset of 4,324 Italian firms in 2008. Of those, 3,277 (or 75.79%) concern observations for firms operating in in the textile industry (NACE rev.2 code 13) while the remaining 1,047 (24.21%) operate in the Motor vehicles, trailers and semi-trailers industry (NACE rev.2 code 29).
There is no significant loss of information in terms of missing values. 
//Q: what do you mean here by this?

Looking at relevant variables of interest, we notice how the average capital in 2008 of an italian firm in the dataset is 1,117.236 thousand Euro, with a median of just 52 thousand and values ranging from 0 to 745,032 thousand. Moreover, given a standard deviation of over 15 thousand Euro, we can expect capital to vary vastly across firms. Similarly, the average revenues amount to 13,829.01 Euro, with a median of 780 thousand Euro and a stdandard deviation of  264,004.8 Euro. For, half of the firms, we observe a real (deflated) value added below 1,218.60 thousand  Euro, with an overall mean value of 5017.402 thousand Euro. Looking at the number of employees, in 2008 Italian firms had an average of 50 workers for a median of 13, with values ranging from 1 up to 22639 employees. This leaves over half of the firms under scrutiny in the second category of the size class variable, employing between 10 and 19 workers. This workforce produced an average labour cost of 1,693.206 thousand Euro, with a median of 393 thousand Euro and a maximum value of 905,103 thousand Euro.
*? materials?

What we notice is that firms in the dataset vary greatly across all relevant variables. The density of the firm observed within these variables display large positive skewness, as reported by the command summarize with the option detail. This can be also noticed by looking at how the values of relevant covariates vary across percentiles. Starting from the 75th percentile, and especially after the 95th, values skyrocket as few observations display values further and further away from the median. 


This preliminary descriptive evidence is consistent with the common depiction of the italian economy as one comprised of many small and medium-sized enterprises (SMEs) and few large multinational companies.
*/

*COMPARING SECTOR 13 AND SECTOR 29 (note, this useful but not explicitely asked so I would keep it short)
bysort sector: summarize if year==2008

tab sizeclass sector if year==2008

ttest L if year==2008, by(sector) //avg number of workers statistically significantly different in the two sectors, same could be done for other covariates if needed

sum L sizeclass if year==2008 & sector == 13, d
sum L sizeclass if year==2017 & sector == 29, d
/*
Restricting our analysis to one or the other industry, we point out how firms in the textile idustry are characterized by significantly smaller values across all relevant variables in the dataframe.

The class size of the firms has an  mean value for both sectors is around 2, which indicates that the firms considered are relatively small and have, on average, between 10 and 29 employees. 
For what concerns the number of workers, in absolute values, we observe that the means show a significant difference, being 27.40 for firms in sector 13 versus 117.23 for firms in sector 29. Given the previous observation (size of the firm), this indicates that, in sector 29, the firms belonging to category 5 (250+ employees) have a number of employees much greater than the firms in sector 13 belonging to the same size class. 
***!!NOTE: this is not properly right, there are also more workers in the category 3 and 4 which drive up the mean

Indeed, the maximum value for the number of workers in sector 13 is 1'248, versus 22'639 in sector 29. [plot? Expect skeweness; gini]

To correct for inflation, we prefer to comment on the values attained by real_sales (deflated values) rather than sales (absolute values). 
Real sales amount, in mean values, to 5'164.552 in sector 13 versus 42'093.11 in sector 29, unsurprisingly given the nature of the businesses in the two sectors considered, i.e. textile versus manufacturing of motor vehicles. Clearly, we would expect this discrepancy to be present also in the deflated values of capital and materials (see table). Analogously, the pattern also holds for real value added, i.e. revenues minus materials, showing a mean value of 11'981.93 for sector 29 versus 2'797.121 for sector 13. As opposed to the discrepancy in revenues, the difference between value added appears to be smaller probably due to the fact that raw materials in the motor sector are relatively higher.
For what concerns wages, given the higher average number of workers in sector 29, we expect a higher mean value for total wages per firm, and indeed we observe mean values of 918.72 in sector 13 and 4117.85 for sector 29. 
[plot??? Max value in 29 huge compared to mean... outlier? How skewed is the data?]
*/


**possibly relevant graphs for dataframe visualization

twoway(hist sizeclass if sector == 13, lcolor(blue) color(blue%30) discrete percent start(1) xlabel(1 2 3 4 5, valuelabel))(hist sizeclass if sector == 29, lcolor(red) color(red%30) discrete percent start(1) xlabel(1 2 3 4 5, valuelabel)), legend(label(1 "Textiles") label(2 "Motor vehicles, trailers and semi-trailers")) xtitle("Size class of the firm") ytitle("Percentage") xscale(titlegap(*10)) yscale(titlegap(*10)) title("Class Size Distribution by Industries in Italy", margin(b=3)) subtitle("Manufacture classification based on NACE rev. 2", margin(b=2)) note("Data between 2000 and 2017 from EEI", margin(b=2)) //hist of to compare the number of firms in each class size across the two industries
graph export "Graphs/hist_sizeclass_ita_sector.png", replace

*note: what is done below with log_L could be carried out with any other relevant vars of choice
gen log_L = log(L) //L has few very high values skewing its distribution, using log(L) helps with the readibility of the data
label variable log_L "log of Labour imput"
kdensity log_L if year == 2008, lw(medthick) lcolor(black) xtitle("Log of the number of employees") ytitle("Distribution") xscale(titlegap(*5)) yscale(titlegap(*10)) title("Labour Distribution in Italy in 2008", margin(b=3)) note("Data from the EEI for both the Textile and Motor vehicles, trailers and semi-trailers industries", margin(b=2))
graph export "Graphs/kdensity_labour.png", replace

twoway (kdensity log_L if sector == 13, lw(medthick) lcolor(blue)) || (kdensity log_L if sector == 29,  lw(medthick) lcolor(red) color(red%30)), legend(label(1 " Textiles") label(2 "Motor vehicles, trailers and semi-trailers")) xtitle("Log of Labour") ytitle("Distribution") xscale(titlegap(*10)) yscale(titlegap(*10)) title("Log of Labour Distribution by Industries in Italy", margin(b=3)) note("Data between 2000 and 2017 from the EEI", margin(b=2)) subtitle("Manufacture classification based on NACE rev. 2", margin(b=2)) //similar to the previous one but using  the log of the n of employees 
graph export "Graphs/kdens_log_L_ita_sector.png", replace

//some extra to be considered
graph box log_L, by(sector)
vioplot log_L, over(sector) //interesting, adding labels etc could be kept


* b) Compare  descriptive statistics for 2008 to the same figures in 2017
by sector: summarize if year==2017

//more comments needed here, what has changed, ecc

**graphs
tw (kdensity log_L if year == 2008, lw(medthick) lcolor(blue))(kdensity log_L if year == 2017, lw(medthick) lcolor(red)),xtitle("Log of the number of employees") ytitle("Distribution") xscale(titlegap(*5)) yscale(titlegap(*10)) title("Labour Distribution in Italy in 2008 vs 2017", margin(b=3)) note("Data from the EEI for both the Textile and Motor vehicles, trailers and semi-trailers industries", margin(b=2)) legend(label(1 "2008") label(2 "2017"))
graph export "Graphs/kdensity_labour_08-17.png", replace


restore //very important, restores dataset as saved when used the command preserve



**# Problem II - Italy, Spain and France ***   

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
foreach var in real_sales real_M real_K L real_VA {
        gen ln_`var'=ln(`var')
        }

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
//add x.i to tell Stata that the OLS regression has fixed effects


//WOOLDRIDGE - VALUE ADDED

***INSTALL PACKAGE FIRST! (search prodest => install package prodest) --> Inserire linea di codice per installazione pacchetto per completezza (il codice deve poter runnare senza intoppi in qualsiasi pc)

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va 
xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va


//LEVINSOHN-PETRIN - VALUE ADDED --> questo è un pacchetto no? Inserire linea di codice per installazione pacchetto
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

//For some reason il command replace non funziona, da' sempre "0 changes" che è weird perchè gli outliers ci sono//  
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


//I grafici con le tre densities non vengono perché la distribuzionde della TFP con LP esce super flat. 
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




