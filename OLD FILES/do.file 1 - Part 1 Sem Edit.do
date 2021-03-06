
*****************************************************
*File Description:	Take Home - Economics of European Integration 
*								 				
*Date:		April 2022
*
*Authors:		Bucchi Filippo 		
*			Fascione Luisa		3187069
*			Manna Sem		3087964
*			Pulvirenti Alessia 	3060894
*****************************************************


*commands to be downloaded
ssc install vioplot, replace
ssc install prodest, replace
ssc install outreg2, replace

*graphical settings
set scheme s1color //remove gridlines and create white sourrounding around the graph. More plotting schemes from Stata here: http://people.umass.edu/biostat690c/pdf/stata%20schemes%20and%20palettes.pdf

cap graph set window fontface "LM Roman 10" //setting LaTeX font

**# ******** Part 1 - dataset "EEI_TH_2022.dta" 

use EEI_TH_2022.dta, clear

des      //describes the data and variables present

summarize
*We do not need to clean the data from negative values: all variables have the minimum not lower than zero.
*In fact the command to clean the data from negative values: 
foreach var in L sales M W K {
        replace `var'=. if  `var'<=0
        }
//yields "zero changes made"
		
		
**# Problem I - Italy ***

preserve //preserves a copy of the dataset as it is for quick retrieval once we operated on the reduced one restricted to Italy
keep if country == "Italy" //drops all obvservations different from italy - so we can operate the .do without having to specify if country == Italy al the time

* a) Summary Statistics of Italian Firms in 2008 by sector
**note: consider using asdoc to export this and other useful commands
summarize if year==2008, d   // restricts summary stats to Italy in 2008

/**GENERAL DESCRIPTIVE STAT FOR ITALIAN FIRMS
The restriction yields a cross-sectional dataset of 4,324 Italian firms in 2008. Of those, 3,277 (or 75.79%) concern observations for firms operating in in the textile industry (NACE rev.2 code 13) while the remaining 1,047 (24.21%) operate in the Motor vehicles, trailers and semi-trailers industry (NACE rev.2 code 29).

Looking at relevant variables of interest, we notice how the average capital in 2008 of an italian firm in the dataset is 1,117.236 thousand Euro, with a median of just 52 thousand and values ranging from 0 to 745,032 thousand. Moreover, given a standard deviation of over 15 thousand Euro, we can expect capital to vary vastly across firms. Similarly, the average revenues amount to 13,829.01 Euro, with a median of 780 thousand Euro and a stdandard deviation of  264,004.8 Euro. For, half of the firms, we observe a real (deflated) value added below 1,218.60 thousand  Euro, with an overall mean value of 5017.402 thousand Euro. Looking at the number of employees, in 2008 Italian firms had an average of 50 workers for a median of 13, with values ranging from 1 up to 22639 employees. This leaves over half of the firms under scrutiny in the second category of the size class variable, employing between 10 and 19 workers. This workforce produced an average labour cost of 1,693.206 thousand Euro, with a median of 393 thousand Euro and a maximum value of 905,103 thousand Euro.
*? materials?

What we notice is that firms in the dataset vary greatly across all relevant variables. The density of the firm observed within these variables display large positive skewness, as reported by the command summarize with the option detail. This can be also noticed by looking at how the values of relevant covariates vary across percentiles. Starting from the 75th percentile, and especially after the 95th, values skyrocket as few observations display values further and further away from the median. 

This preliminary descriptive evidence is consistent with the common depiction of the italian economy as one comprised of many small and medium-sized enterprises (SMEs) and few large multinational companies.
*/

*COMPARING SECTOR 13 AND SECTOR 29
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

/!!/PLOT FOR N OF WORKERS: asse x classi, asse y numero medio di lavoratori per classe, diviso x settori (=> dovrebbe mostrare che in class 5 il num di lavoratori in sector 29 ?? molto maggiore che in sector 13).

To correct for inflation, we prefer to comment on the values attained by real_sales (deflated values) rather than sales (absolute values). 
Real sales amount, in mean values, to 5'164.552 in sector 13 versus 42'093.11 in sector 29, unsurprisingly given the nature of the businesses in the two sectors considered, i.e. textile versus manufacturing of motor vehicles. Clearly, we would expect this discrepancy to be present also in the deflated values of capital and materials (see table). Analogously, the pattern also holds for real value added, i.e. revenues minus materials, showing a mean value of 11'981.93 for sector 29 versus 2'797.121 for sector 13. As opposed to the discrepancy in revenues, the difference between value added appears to be smaller probably due to the fact that raw materials in the motor sector are relatively higher.
For what concerns wages, given the higher average number of workers in sector 29, we expect a higher mean value for total wages per firm, and indeed we observe mean values of 918.72 in sector 13 and 4117.85 for sector 29. 
[plot??? Max value in 29 huge compared to mean... outlier? Look at the quintiles...]
sum W if sector == 29, d

*/


**possibly relevant graphs for dataframe visualization and industry comparisons
qui{

twoway(hist sizeclass if sector == 13, lcolor(blue) color(blue%30) discrete percent start(1) xlabel(1 2 3 4 5, valuelabel))(hist sizeclass if sector == 29, lcolor(red) color(red%30) discrete percent start(1) xlabel(1 2 3 4 5, valuelabel)), legend(label(1 "Textiles") label(2 "Motor vehicles, trailers and semi-trailers")) xtitle("Size class of the firm") ytitle("Percentage") xscale(titlegap(*10)) yscale(titlegap(*10)) title("Class Size Distribution by Industries in Italy", margin(b=3)) subtitle("Manufacture classification based on NACE rev. 2", margin(b=2)) note("Data between 2000 and 2017 from EEI", margin(b=2)) 
//hist of to compare the number of firms in each class size across the two industries
******** why not two columns instead? The merged colours make it difficult to understand at first sight
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
}



* b) Compare  descriptive statistics for 2008 to the same figures in 2017

by sector: summarize if year==2017

//how did the number firms changed? [solved, check draft]
//did turnover change? [solved, check draft]

//hist in the sizeclass 2008 vs 2017 here it is

tw (hist sizeclass if year == 2008, lcolor(blue) color(blue%30) discrete ///
	percent start(1) xlabel(1 2 3 4 5, valuelabel)) ///
	(hist sizeclass if year == 2017, lcolor(red) color(red%30) discrete ///
	percent start(1) xlabel(1 2 3 4 5, valuelabel)), ///
	legend(label(1 "2008") label(2 "2017")) xtitle("Size class of the firm") ///
	ytitle("Percentage") xscale(titlegap(*10)) yscale(titlegap(*10)) ///
	title("Class Size Distribution in 2008 and 2017", margin(b=3)) ///
	subtitle("NACE rev. 2 industries 13 and 20, Italy France and Spain", ///
	margin(b=2)) note("Data from EEI", margin(b=2)) 


**graphs
qui{
    
tw (kdensity log_L if year == 2008, lw(medthick) lcolor(blue))(kdensity log_L if year == 2017, lw(medthick) lcolor(red)),xtitle("Log of the number of employees") ytitle("Distribution") xscale(titlegap(*5)) yscale(titlegap(*10)) title("Labour Distribution in Italy in 2008 vs 2017", margin(b=3)) note("Data from the EEI for both the Textile and Motor vehicles, trailers and semi-trailers industries", margin(b=2)) legend(label(1 "2008") label(2 "2017"))
graph export "Graphs/kdensity_labour_08-17.png", replace
}


restore //very important, restores dataset as saved when used the command preserve

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
*/


**#** Problem II - Italy, Spain and France ****
use EEI_TH_2022_NoNeg.dta, clear

* a) Estimate for the two industries available in NACE Rev.2 2-digit format the production function coefficients, by using standard OLS, the Wooldridge (WRDG) and the Levinsohn & Petrin (LP) procedure.

*OLS REGRESSION - VALUE ADDED
*Estimate the coefficients of labour and capital

//generate logarthmic values

foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
 }

graph twoway (scatter ln_real_K ln_L) (lfit ln_real_K ln_L) //could be an intresting graph to consider
binscatter ln_real_K ln_L //also perhpas, ssc install binscatter, replace

if 1=0 { //a way to keep some code without running it when we run the .do
//setting up our table ilke his through a matrix
matrix coeff_table=(.,.,.\.,.,.\.,.,.\.,.,.\.,.,.\.,.,.\.,.,.\.,.,. )
matrix rownames coeff_table=Lev-Pet "" WRDG "" OLS "" "" "" 
matrix colnames coeff_table= "" Nace-13 Nace-29
matrix list coeff_table
//to be filled up with coeffs if we decide to go for this, problem: how to fill in the asterix for significance levels - could store values in a local variable then use a concatenate which adds stars conditional on significance level, rather complex, maybe we can stick to outreg and file the table by hand or use excel functions to retrive data from the table generated by outreg to compile another excel file which updates automatically when we re-run the code
}

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 //add x.i to tell Stata that the OLS regression has fixed effects
outreg2 using TABLE_P2.xls, excel replace keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) title (Production Function Coefficients Estimates) cttop(OLS Nace-13)  //setting up an output table and adding the first coefficients of interest

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
outreg2 using TABLE_P2.xls, excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(OLS Nace-29) //appending with coefficents for sector 29


//WOOLDRIDGE - VALUE ADDED

ssc install prodest, replace

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va //note, book uses afc not va
outreg2 using TABLE_P2.xls, excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(WRDG Nace-13)



xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
outreg2 using TABLE_P2.xls, excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(WRDG Nace-29)


//LEVINSOHN-PETRIN - VALUE ADDED 
install package st0060

xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
outreg2 using TABLE_P2.xls, excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(L-P Nace-13)

xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
outreg2 using TABLE_P2.xls, excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(L-P Nace-29)


* b) Present a Table (like the one below), where you compare the coefficients obtained in the estimation outputs, indicating their significance levels (*, ** or *** for 10, 5 and 1 per cent). Is there any bias of the labour coefficients? What is the reason for that?
/*@sem per produzione tabella
You can choose your preferred way of preparing tables:
(1) one option is to use the command outsheet to construct the tables of summary statistics and the command outreg2 to construct the regression tables (you can use them to export results of summary statistics and regressions to an excel file); (2) another option is to save results using the command eststo and then export these directly to a .tex (latex) file using the command esttab. Read carefully help for each command you choose and try different options, so as to have well-formatted tables.
*/

**# Problem III - Theoretical comments ***




**# Problem IV - TFP distribution ***

/*a)Comment on the presence of "extreme" values in both industries. 
Clear the TFP estimates from these extreme values (1st and 99th percentiles) 
and save a "cleaned sample".*/

//Q: we do everything separated by industry even if not explicitly asked, what is the reason/interpretation


//TFP ESTIMATION IN OLS

** OLS TFP: 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
predict ln_TFP_OLS_13 if sector==13, residuals  //(62,439 missing values generated)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 
predict ln_TFP_OLS_29 if sector==29, residuals //(126,048 missing values generated)
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
replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p1),r(p99)) 
//since we use the post-estimation command r(p5) to retrive the value of the precentile calculated using sum, but we do not store it into a scalar, we must use the command making use of it right away, before using sum again 
sum TFP_OLS_29, d
replace TFP_OLS_29=. if !inrange(TFP_OLS_29,r(p1),r(p99)) 


***save the cleaned dataset***

*save EEI_TH_2022_cleaned_IV.dta, replace 

//as requested in point (a) of P.IV, we save the 'cleaned' sample. Note, this is also useful to avoid repeating the time-consuming operation of computing the LEVINSOHN-PETRIN - I put it as a comment to avoid ACCIDENTAL savings

use EEI_TH_2022_cleaned_IV.dta, clear //using the cleaned dataset rember to update it with the dropped negative observations

***Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry.
kdensity TFP_OLS_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_13_t, replace)

kdensity TFP_OLS_29, lw(medthick) lcolor(red) ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_29_t, replace)

graph combine TFP_OLS_13_t.gph TFP_OLS_29_t.gph, note("Data from the EEI, univariate kernel density estimates" , margin(b=2))
graph export "Graphs/combined_kdensity_TFP_OLS.png", replace

//now the log
gen ln_TFP_OLS_13_t=ln(TFP_OLS_13) 
gen ln_TFP_OLS_29_t=ln(TFP_OLS_29)
// t stands for transformed (post !inrange)
/*Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry*/ 
*what is the interpretation?

tw kdensity ln_TFP_OLS_13_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(ln_TFP_OLS_13_t, replace)
//saving the graph in a Stata readible format to combine it with the next one
 
tw kdensity ln_TFP_OLS_29_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(ln_TFP_OLS_29_t, replace)

graph combine ln_TFP_OLS_13_t.gph ln_TFP_OLS_29_t.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))
graph export "Graphs/combined_kdensity_Log_TFP_OLS.png", replace
*

//explain what we do as we go through this part


** LP and WDRDG TFP:
//LP
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13 if sector==13, omega

gen TFP_LP_13=exp(ln_TFP_LP_13)
qui sum TFP_LP_13, d	//FIX BELOW TOO INVERTED ORDER
replace TFP_LP_13=. if !inrange(TFP_LP_13, r(p1),r(p99))
**#missing values?
g ln_TFP_LP_13_t=ln(TFP_LP_13) 

//WDRDG
xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13 if sector==13, resid
**#should we use prodest or levpet? correction available in levpet! discuss and choose

tw kdensity ln_TFP_LP_13_t || kdensity ln_TFP_WRDG_13 || kdensity ln_TFP_OLS_13_t //interpretation and comment + imporve graph


xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29 if sector==29, omega

gen TFP_LP_29=exp(ln_TFP_LP_29)
replace TFP_LP_29=. if !inrange(TFP_LP_29, r(p1),r(p99))
sum TFP_LP_29, d	
g ln_TFP_LP_29_t=ln(TFP_LP_29) 

xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29 if sector==29, resid

tw kdensity ln_TFP_LP_29_t || kdensity ln_TFP_WRDG_29 || kdensity ln_TFP_OLS_29_t //interpretation and comment + imporve graph


***b) Plot the TFP distribution for each country

**IT 13
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "Italy"
predict ln_TFP_OLS_13_IT if sector==13 & country == "Italy", residuals 

gen TFP_OLS_13_IT= exp(ln_TFP_OLS_13_IT) 
kdensity TFP_OLS_13_IT 
sum TFP_OLS_13_IT, d
replace TFP_OLS_13_IT=. if !inrange(TFP_OLS_13_IT,r(p5),r(p99)) 
kdensity TFP_OLS_13_IT //much nicer
gen ln_TFP_OLS_13_IT_t=ln(TFP_OLS_13_IT) 
kdensity ln_TFP_OLS_13_IT_t //quasi-Normal

**SP 13
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "Spain"
predict ln_TFP_OLS_13_SP if sector==13 & country == "Spain", residuals 

gen TFP_OLS_13_SP= exp(ln_TFP_OLS_13_SP) 
kdensity TFP_OLS_13_SP 
sum TFP_OLS_13_SP, d
replace TFP_OLS_13_SP=. if !inrange(TFP_OLS_13_SP,r(p5),r(p99)) 
kdensity TFP_OLS_13_SP
gen ln_TFP_OLS_13_SP_t=ln(TFP_OLS_13_SP) 
kdensity ln_TFP_OLS_13_SP_t

**FR 13
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 & country == "France"
predict ln_TFP_OLS_13_FR if sector==13 & country == "France", residuals //(159,456 missing values generated)

gen TFP_OLS_13_FR= exp(ln_TFP_OLS_13_FR) 
kdensity TFP_OLS_13_FR 
sum TFP_OLS_13_FR, d
replace TFP_OLS_13_FR=. if !inrange(TFP_OLS_13_FR,r(p5),r(p99)) 
kdensity TFP_OLS_13_FR
gen ln_TFP_OLS_13_FR_t=ln(TFP_OLS_13_FR) 
kdensity ln_TFP_OLS_13_FR_t

**IT 29
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "Italy"
predict ln_TFP_OLS_29_IT if sector==29 & country == "Italy", residuals //(157,521 missing values generated)

gen TFP_OLS_29_IT= exp(ln_TFP_OLS_29_IT) 
kdensity TFP_OLS_29_IT 
sum TFP_OLS_29_IT, d
replace TFP_OLS_29_IT=. if !inrange(TFP_OLS_29_IT,r(p5),r(p99)) 
kdensity TFP_OLS_29_IT
gen ln_TFP_OLS_29_IT_t=ln(TFP_OLS_29_IT) 
kdensity ln_TFP_OLS_29_IT_t

**SP 29
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "Spain"
predict ln_TFP_OLS_29_SP if sector==29 & country == "Spain", residuals //(157,037 missing values generated)

gen TFP_OLS_29_SP= exp(ln_TFP_OLS_29_SP) 
kdensity TFP_OLS_29_SP 
sum TFP_OLS_29_SP, d
replace TFP_OLS_29_SP=. if !inrange(TFP_OLS_29_SP,r(p5),r(p99)) 
kdensity TFP_OLS_29_SP
gen ln_TFP_OLS_29_SP_t=ln(TFP_OLS_29_SP) 
kdensity ln_TFP_OLS_29_SP_t

**FR 29
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "France"
predict ln_TFP_OLS_29_FR if sector==29 & country == "France", residuals //(161,794 missing values generated)

gen TFP_OLS_29_FR= exp(ln_TFP_OLS_29_FR) 
kdensity TFP_OLS_29_FR 
sum TFP_OLS_29_FR, d
replace TFP_OLS_29_FR=. if !inrange(TFP_OLS_29_FR,r(p5),r(p99)) 
kdensity TFP_OLS_29_FR
gen ln_TFP_OLS_29_FR_t=ln(TFP_OLS_29_FR) 
kdensity ln_TFP_OLS_29_FR_t

*c) c. Focus now on the TFP distributions of industry 29 in France and Italy. Do you find changes in these two TFP distributions in 2001 vs 2008? Did you expect these results? Compare the results obtained with WRDG and LP procedure and comment
//Compare LP and WRDG by country//
*also here same small issue as previous points when using predit
//fixed sem 04/04

** LP and WDRDG TFP:

**IT 13
xi: levpet ln_real_VA if sector==13 & country=="Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_IT if sector==13 & country=="Italy", omega
//(13,335 missing values generated)

gen TFP_LP_13_IT=exp(ln_TFP_LP_13_IT)
replace TFP_LP_13_IT=. if !inrange(TFP_LP_13_IT, r(p1),r(p99)) //(0 real changes made)
sum TFP_LP_13_IT, d	
g ln_TFP_LP_13_IT_t=ln(TFP_LP_13_IT) //(128,823 missing values generated)

xi: prodest ln_real_VA if sector==13 & country=="Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_IT if sector==13 & country=="Italy", resid

tw kdensity ln_TFP_LP_13_IT_t || kdensity ln_TFP_WRDG_13_IT || kdensity ln_TFP_OLS_13_IT_t //interpretation/meaning?

**SP 13
xi: levpet ln_real_VA if sector==13 & country=="Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_SP if sector==13 & country=="Spain", omega

gen TFP_LP_13_SP=exp(ln_TFP_LP_13_SP)
replace TFP_LP_13_SP=. if !inrange(TFP_LP_13_SP, r(p1),r(p99))
sum TFP_LP_13_SP, d	
g ln_TFP_LP_13_SP_t=ln(TFP_LP_13_SP) //(106,190 missing values generated)

xi: prodest ln_real_VA if sector==13 & country=="Spain", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_SP if sector==13 & country=="Spain", resid

tw kdensity ln_TFP_LP_13_SP_t || kdensity ln_TFP_WRDG_13_SP || kdensity ln_TFP_OLS_13_SP_t

**FR 13
xi: levpet ln_real_VA if sector==13 & country=="France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_13_FR if sector==13 & country=="France", omega

gen TFP_LP_13_FR=exp(ln_TFP_LP_13_FR)
replace TFP_LP_13_FR=. if !inrange(TFP_LP_13_FR, r(p1),r(p99))
sum TFP_LP_13_FR, d	
g ln_TFP_LP_13_FR_t=ln(TFP_LP_13_FR) //(104,729 missing values generated)

xi: prodest ln_real_VA if sector==13 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13_FR if sector==13 & country=="France", resid

tw kdensity ln_TFP_LP_13_FR_t || kdensity ln_TFP_WRDG_13_FR || kdensity ln_TFP_OLS_13_FR_t

**IT 29
xi: levpet ln_real_VA if sector==29 & country=="Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_IT if sector==29 & country=="Italy", omega

gen TFP_LP_29_IT=exp(ln_TFP_LP_29_IT)
replace TFP_LP_29_IT=. if !inrange(TFP_LP_29_IT, r(p1),r(p99))
sum TFP_LP_29_IT, d	
g ln_TFP_LP_29_IT_t=ln(TFP_LP_29_IT) //(14,387 missing values generated)

xi: prodest ln_real_VA if sector==29 & country=="Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_IT if sector==29 & country=="Italy", resid

tw kdensity ln_TFP_LP_29_IT_t || kdensity ln_TFP_WRDG_29_IT || kdensity ln_TFP_OLS_29_IT_t

**SP 29
xi: levpet ln_real_VA if sector==29 & country=="Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_SP if sector==29 & country=="Spain", omega

gen TFP_LP_29_SP=exp(ln_TFP_LP_29_SP)
replace TFP_LP_29_SP=. if !inrange(TFP_LP_29_SP, r(p1),r(p99))
sum TFP_LP_29_SP, d	
g ln_TFP_LP_29_SP_t=ln(TFP_LP_29_SP) //(118,265 missing values generated)

xi: prodest ln_real_VA if sector==29 & country=="Spain", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_SP if sector==29 & country=="Spain", resid

tw kdensity ln_TFP_LP_29_SP_t || kdensity ln_TFP_WRDG_29_SP || kdensity ln_TFP_OLS_29_SP_t

**FR 29
xi: levpet ln_real_VA if sector==29 & country=="France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_29_FR if sector==29 & country=="France", omega

gen TFP_LP_29_FR=exp(ln_TFP_LP_29_FR)
replace TFP_LP_29_FR=. if !inrange(TFP_LP_29_FR, r(p1),r(p99))
sum TFP_LP_29_FR, d	
g ln_TFP_LP_29_FR_t=ln(TFP_LP_29_FR) //(105,660 missing values generated)

xi: prodest ln_real_VA if sector==29 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_FR, resid

tw kdensity ln_TFP_LP_29_FR_t || kdensity ln_TFP_WRDG_29_FR || kdensity ln_TFP_OLS_29_FR_t


/*I grafici con le tre densities non vengono perch?? la distribuzionde della TFP con LP esce super flat. 
Abbiamo pensato di fare un tentativo con prodest(lp) invece di levpet, usando Francia #29 come trial e
funziona. La OLS viene un po' sbirulenca ma centrata su 0 e con una forma decente (approximately gaussiana),
mentre WRDG e LP quasi overlapping://
*/

//so is this a different code that should replace the previous one? 

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 & country == "France"
predict ln_TFP_OLS_29_FR if sector==29 & country == "France", residuals  //variable ln_TFP_OLS_29_FR already defined!!

gen TFP_OLS_29_FR= exp(ln_TFP_OLS_29_FR) //already defined!!
kdensity TFP_OLS_29_FR 
sum TFP_OLS_29_FR, d
replace TFP_OLS_29_FR=. if !inrange(TFP_OLS_29_FR,r(p5),r(p99)) 
kdensity TFP_OLS_29_FR
gen ln_TFP_OLS_29_FR_t=ln(TFP_OLS_29_FR)

xi: prodest ln_real_VA if sector==29 & country=="France", met(lp) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_LP_29_FR if sector==29 & country=="France", resid //already defined

xi: prodest ln_real_VA if sector==29 & country=="France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29_FR  if sector==29 & country=="France", resid //already defined

tw kdensity ln_TFP_LP_29_FR || kdensity ln_TFP_WRDG_29_FR || kdensity ln_TFP_OLS_29_FR_t



/*c) TFP distributions of industry 29 in France and Italy. Changes in TFP distributions in 2001 vs 2008. Compare LP and WRDG */

* try with use sum, d - which shows the value of skewness


*d) Look at changes in skewness in the same time window (again, focus on industry 29 only in these two countries). What happens? Relate this result to what you have found at point c.



*e) Do you find the shifts to be homogenous throughout the distribution? Once you have defined a specific parametrical distribution for the TFP, is there a way through which you can statistically measure the changes in the TFP distribution in each industry over time (2001 vs 2008)?




