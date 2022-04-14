*****************************************************
*File Description:	Take Home - Economics of European Integration 
*								 				
*Date:		April 2022
*
*Authors:	Bucchi Filippo 		3186624
*			Fascione Luisa		3187069
*			Manna Sem			3087964
*			Pulvirenti Alessia 	3060894
*****************************************************


*commands to be downloaded
ssc install vioplot, replace
ssc install prodest, replace
ssc install outreg2, replace

*graphical settings
set scheme s1color //remove gridlines and create white sourrounding around the graph. More plotting schemes from Stata here: http://people.umass.edu/biostat690c/pdf/stata%20schemes%20and%20palettes.pdf

cap graph set window fontface "LM Roman 10" //setting LaTeX   font

**# ******** Part 1 - dataset "EEI_TH_2022.dta" 

use EEI_TH_2022.dta, clear

des      //describes the data and variables present

summarize
*We do not need to clean the data from negative values: all variables have the minimum not lower than zero.
*In fact the command to clean the data from negative values: 
foreach var in L sales M W K {
        replace `var'=. if  `var'<0
        }
//yields "zero changes made"
//add reference on how 0 value observations may also be problematic, but here there are very few.
		
		
**# Problem I - Italy ***

preserve //preserves a copy of the dataset as it is for quick retrieval once we operated on the reduced one restricted to Italy
keep if country == "Italy" //drops all obvservations different from italy - so we can operate the .do without having to specify if country == Italy al the time

* a) Summary Statistics of Italian Firms in 2008 by sector
**note: consider using asdoc to export this and other useful commands
summarize if year==2008, d   // restricts summary stats to Italy in 2008

*COMPARING SECTOR 13 AND SECTOR 29
bysort sector: summarize if year==2008

tab sizeclass sector if year==2008

ttest L if year==2008, by(sector) //avg number of workers statistically significantly different in the two sectors, same could be done for other covariates if needed

sum L sizeclass if year==2008 & sector == 13, d
sum L sizeclass if year==2017 & sector == 29, d

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


use EEI_TH_2022_NoNeg, clear

**# Prob IV.a ***
foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
    }
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
predict ln_TFP_OLS_13 if sector==13, residuals 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 
predict ln_TFP_OLS_29 if sector==29, residuals

gen TFP_OLS_13= exp(ln_TFP_OLS_13) 
gen TFP_OLS_29= exp(ln_TFP_OLS_29) //preliminary

** We perform the OLS regression, we obtain residuals and then we can plot:**

kdensity TFP_OLS_13 
kdensity TFP_OLS_29

** Both distributions do not follow a desirable pattern, we would like to work with a Pareto parametrisation and in both distribution the plot evidences the possibility of outliers in the right tail. Thus, we inquire the percentiles distribution of both TFPs. **

sum TFP_OLS_13, d
sum TFP_OLS_29, d

**Cleaning for outliers, cut the distribution at 1st and 99th percentile**
sum TFP_OLS_13, d
replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p1),r(p99)) 
sum TFP_OLS_13, d //Problem with this: after cleaning for outliers, it cleans the distribution too much! we are left with 6 as maximum tfp!!!

** 95%     3.056297       6.054492      Obs             110,459
** 99%      4.69797       6.054921 		Mean           1.242472,  Std. dev.      .8799894

sum TFP_OLS_29, d
replace TFP_OLS_29=. if !inrange(TFP_OLS_29,r(p1),r(p99)) 
sum TFP_OLS_29, d
**95%     2.461426        5.68164       Obs              48,122
**99%     3.953326       5.683885		Mean           1.163058,  Std. dev.      .6899439

**We can note that now in both the distributions the 99th percentile seems to follow a consistent path if compared to previous percentiles' values. As we expected the standard deviation decreases and also the mean does the same, confirming the presence of outliers in the original TFP distirbutions.**


save EEI_TH_2022_cleaned_IV.dta, replace 

***--------------------------------------**
*Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry

use EEI_TH_2022_cleaned_IV.dta, clear

kdensity TFP_OLS_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_13_t, replace) //Controlla range

kdensity TFP_OLS_29, lw(medthick) lcolor(red) ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_29_t, replace) //COntrolla range


gen ln_TFP_OLS_13=ln(TFP_OLS_13), replace
gen ln_TFP_OLS_29_t=ln(TFP_OLS_29), replace

tw kdensity ln_TFP_OLS_13, lw(medthick) lcolor(blue) || kdensity TFP_OLS_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) xscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry" " ") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_13_t, replace)  //Qui forse il titolo dell'asse delle x è sbagliato? Metterei "TFP and Log(TFP)"

tw kdensity ln_TFP_OLS_29, lw(medthick) lcolor(blue) || kdensity TFP_OLS_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values")xtitle("Log of the TFP") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 29 - Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_29_t, replace)

graph combine ln_TFP_OLS_13_t.gph ln_TFP_OLS_29_t.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))

*sovrapporre i grafici dei due sectors in un unico: plottare overall mean + sect 13 + sect 29 (grafico slide 49 "Productivity & Markup")

/*Comment:
Expect graph of lnTFP13 has tails that are above the tails of lnTFP29, signalling higher productivity values for the Textile sector as compared to the Motor sector. Indeed, the summary statics of the TFP estimated from the sample cleaned for extreme values does show a higher overall mean value for sector 13 (1.24 vs 1.16). Interestingly, this reverses what has been noted previously when computing the TFP on the initial sample, which yielded an average TFP of 1.48 for sector 29 vs 1.32 for sector 13. (Commento Ale aggiunta: [...] This would point out to the fact that productivity in the Motor sector was mainly driven by firms at the extremes of the right tail, which have been cleaned for above)*/


graph export "Graphs/combined_kdensity_Log_TFP_OLS.png", replace


//Compare LevPet & WRDRG
//LEVPET
*Sector 13
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_13 if sector==13, omega    //Levpet predicts the coefs, already in exponential values


sum TFP_LP_13, d //Again, here there are some outliers we should clean for. But how many?

replace TFP_LP_13=. if !inrange(TFP_LP_13,r(p1),r(p99))	
*3,236 real changes made, 3,236 to missing*

kdensity TFP_LP_13
gen ln_TFP_LP_13=ln(TFP_LP_13)        //generate log values
sum ln_TFP_LP_13, d					
kdensity TFP_LP_13
kdensity ln_TFP_LP_13        //not bad


*Sector 29
xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_29 if sector==29, omega
sum TFP_LP_29, d

replace TFP_LP_29=. if !inrange(TFP_LP_29,r(p1),r(p99))	
*3,235 real changes made, 3,235 to missing*

sum TFP_LP_29, d
kdensity TFP_LP_29  //Now the graph and the distribution look good 
gen ln_TFP_LP_29=ln(TFP_LP_29)
sum ln_TFP_LP_29, d				
kdensity ln_TFP_LP_29           

/*replace ln_TFP_LP_29=. if !inrange(ln_TFP_LP_29, r(p1),r(p99))  
sum ln_TFP_LP_29, d
kdensity ln_TFP_LP_29     
 //Again, already dropped
								useless */ 

tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity TFP_LP_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) title("LevPet-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_LP_13, replace)
*--> problems with plotting the tw densities: the range of values of ln_TFP and TFP are too different to be plotted together. Commento Ale: forse meglio non plottarli insieme questi. Li lasciamo qui con commento esplicativo ma poi non li inseriamo nel documento. 
*Sem: sì non ha senso plottare insieme TFP e il suo log, piuttosto potremmo fare i plot con levpet vs ols 
//Luisa: no si raga qua c'è qualcosa di sbagliato, non so da dove esca questo grafico ma non ha senso

*Now, we try to plot TFP_LP_13 and TFP_LP_29 together, after having cleaned for outliers:
tw kdensity TFP_LP_13, lw(medthick) lcolor(blue) || kdensity TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("TFP") title("LevPet-Computed TFPs", margin(b=3)) subtitle("TFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(TFP_LP_13_29_joint, replace)
//It's a nice graph now! :) 


//Plot instead the logarithms of both sectors together:
tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.5) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)

graph combine ln_TFP_LP_13_29_joint.gph TFP_LP_13_29_joint.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))


//WRDG (anche qui, aggiunto righe di codice per pulire per outliers. I grafici adesso vengono belli e comparabili)

*Sector 13
xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13, resid
gen TFP_WRDG_13=exp(ln_TFP_WRDG_13)
sum ln_TFP_WRDG_13, d
kdensity ln_TFP_WRDG_13


replace TFP_WRDG_13=. if !inrange(TFP_WRDG_13,r(p1),r(p99))	
//(3,236 real changes made, 3,236 to missing)//

kdensity TFP_WRDG_13
kdensity TFP_OLS_13

*Sector 29
xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29, resid
sum ln_TFP_WRDG_29, d

g TFP_WRDG_29=exp(ln_TFP_WRDG_29)     
sum TFP_WRDG_29, d

replace TFP_WRDG_29=. if !inrange(TFP_WRDG_29,r(p1),r(p99))	
//(3,236 real changes made, 3,236 to missing)//

kdensity TFP_WRDG_29

//Plot the two kdensity WRDG after having cleaned for outliers
tw kdensity TFP_LP_13, lw(medthick) lcolor(blue) || kdensity TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("TFP") xscale(titlegap(*5)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("TFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(TFP_WRDG_13_29_joint, replace)
//It's a nice graph now! :) 


//Plot instead the logarithms of both sectors together:
tw kdensity ln_TFP_WRDG_13, lw(medthick) lcolor(blue) || kdensity ln_TFP_WRDG_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("Wooldridge-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_WRDG_13_29_joint, replace)

/*tw kdensity ln_TFP_WRDG_13, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry" " ") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_WRDG_13, replace)

tw kdensity ln_TFP_WRDG_29, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values")xtitle("Log of the TFP") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 29 - Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_WRDG_29, replace)

graph combine ln_TFP_WRDG_13.gph ln_TFP_WRDG_29.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))*/

tw kdensity TFP_OLS_13 || kdensity TFP_WRDG_13 || kdensity TFP_LP_13

tw kdensity TFP_OLS_29 || kdensity TFP_WRDG_29 || kdensity TFP_LP_29

tw kdensity ln_TFP_LP_13 || kdensity ln_TFP_WRDG_13|| kdensity ln_TFP_OLS_13
tw kdensity ln_TFP_LP_29 || kdensity ln_TFP_WRDG_29|| kdensity ln_TFP_OLS_29

tw kdensity ln_TFP_WRDG_13 || kdensity ln_TFP_WRDG_29 || kdensity ln_TFP_LP_13 || kdensity ln_TFP_LP_29


/* The graphs through LevPet and Wooldridge are almost overlapping, 
with the average value being systematically greater in sector 13 than in sector 29.
(Other comments?)
*/

save EEI_TH_2022_cleaned_IV_a.dta, replace

**# Prob 4.b: plot the TFP distribution for each country ***

use EEI_TH_2022_cleaned_IV_a.dta, replace


//OLS
**Estimation
xi: reg ln_real_VA ln_L ln_real_K i.country i.year 
predict ln_TFP_OLS, residuals 
gen TFP_OLS= exp(ln_TFP_OLS) 
kdensity TFP_OLS
sum TFP_OLS, d
replace TFP_OLS=. if !inrange(TFP_OLS,r(p5),r(p99)) 
sum TFP_OLS, d

**IT

kdensity TFP_OLS if country=="Italy"

**FR

kdensity TFP_OLS if country=="France"

**SP

kdensity TFP_OLS if country=="Spain"

tw kdensity TFP_OLS if country=="Italy" || kdensity TFP_OLS if country=="France"|| kdensity TFP_OLS if country=="Spain"

//LevPet
**Estimation
xi: levpet ln_real_VA, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP, omega
sum TFP_LP, d
replace TFP_LP=. if !inrange(TFP_LP,r(p5),r(p99)) 
sum TFP_LP, d


**IT
sum TFP_LP if country == "Italy", d
kdensity TFP_LP if country == "Italy"


**FR
sum TFP_LP if country == "France", d
kdensity TFP_LP if country == "France"


**SP
sum TFP_LP if country == "Spain", d
kdensity TFP_LP if country == "Spain"

tw kdensity TFP_LP if country == "Italy" || kdensity TFP_LP if country == "France"|| kdensity TFP_LP if country == "Spain"   


/*tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)*/


//Wooldridge
**Estimation
xi: prodest ln_real_VA, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG, resid     //WRDG genera la TFP in log
gen TFP_WRDG=exp(ln_TFP_WRDG)
sum TFP_WRDG
sum TFP_WRDG, d
replace TFP_WRDG=. if !inrange(TFP_WRDG,r(p5),r(p99)) 
sum TFP_WRDG, d

**IT
      
sum TFP_WRDG if country == "Italy", d
kdensity TFP_WRDG if country == "Italy"

**FR

sum TFP_WRDG if country == "France", d
kdensity TFP_WRDG if country == "France"


**SP

sum TFP_WRDG if country == "Spain", d
kdensity TFP_WRDG if country == "Spain"

tw kdensity TFP_WRDG if country == "Italy" || kdensity TFP_WRDG if country == "France"|| kdensity TFP_WRDG if country == "Spain"   

/*Comments:
From plotting the three countries, we can make the following observations:
- Italy appears to be more productive than Spain, under both LevPet and Wooldridge
- Italy appears to be more productive than France under Levpet, but slighlty less
productive ( 210.7353 vs 186.4549) under Wooldridge.
- French TFP appears closer to Italian TFP under Wooldridge, while closer to Spain 
under Levpet.
(Other comments?)
*/

*** Prob 4.c: plot the TFP distribution for Italy_29 and France_29 2001vs2008; compare LP and WRDG ***

***!!!I just want to add that levpet works with panel data. As you may know, you need to have observations for the study subject, a firm for example, at least in two years (or points in time). Then, before running the command you should use the xtset command or specify i() t().Nevertheless, I experienced that after checking that variables are numeric, the behavior of missing values and declaring the panel data, among others, the message "r(2000) no observations" kept appearing. What worked for me is to have consecutive years in the variable that sets the time for the panel data (xtset panelid year). My "year" variable was 2003 and 2009. When I changed this to consecutive values, for example, 1 and 2, the program worked. I wanted to share this just in case. If you can, please let us know if it works or how you solved the problem.***


**We have already predicted both TFP_LP and TFP_WRDG

**LEVPET-FR**

sum TFP_LP if sector==29 & country == "France" & year==2001
sum TFP_LP if sector==29 & country == "France" & year==2001, d
kdensity TFP_LP if sector==29 & country == "France" & year==2001

sum TFP_LP if year==2008
sum TFP_LP if year==2008, d
kdensity TFP_LP if year==2008 // We have performed levpet procedure and we consider France and sec.29, then we mantain only year==2001 or year==2008

**LEVPET-IT**

sum TFP_LP if sector==29 & country == "Italy" & year==2001
sum TFP_LP if sector==29 & country == "Italy" & year==2001, d
kdensity TFP_LP if sector==29 & country == "Italy" & year==2001

sum TFP_LP if sector==29 & country == "Italy" & year==2008
sum TFP_LP if sector==29 & country == "Italy" & year==2008, d
kdensity TFP_LP if sector==29 & country == "Italy" & year==2008 // We have performed levpet procedure and we consider Italy and sec.29, then we mantain only year==2001 or year==2008

**WRDG-FR**

sum TFP_WRDG if sector==29 & country == "France" & year==2001
sum TFP_WRDG if sector==29 & country == "France" & year==2001, d
kdensity TFP_WRDG if sector==29 & country == "France" & year==2001

sum TFP_WRDG if sector==29 & country == "France" & year==2008
sum TFP_WRDG if sector==29 & country == "France" & year==2008, d
kdensity TFP_WRDG if sector==29 & country == "France" & year==2008 


**WRDG-IT**

sum TFP_WRDG if sector==29 & country == "Italy" & year==2001
sum TFP_WRDG if sector==29 & country == "Italy" & year==2001, d
kdensity TFP_WRDG if sector==29 & country == "Italy" & year==2001

sum TFP_WRDG if sector==29 & country == "Italy" & year==2008
sum TFP_WRDG if sector==29 & country == "Italy" & year==2008, d
kdensity TFP_WRDG if sector==29 & country == "Italy" & year==2008 


**PLOTS**
// grafico tutto lev pet e tutto wrdg
tw kdensity ln_TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green) || kdensity ln_TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)
// FR: lp01-lp08-wrdg01-wrdg08
tw kdensity ln_TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green) || kdensity ln_TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)
// IT: lp01-lp08-wrdg01-wrdg08
tw kdensity ln_TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green)
// FR: lp01-lp08
tw kdensity ln_TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red)
// FR: wrdg01-wrdg08
tw kdensity ln_TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(red)
// lp01fr-lp01it
tw kdensity ln_TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(red)
// lp08fr-lp08it
tw kdensity ln_TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(red)
// wrdg01fr-wrdg01it
tw kdensity ln_TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(blue) || kdensity ln_TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red)
// wrdg08fr-wrdg08it
tw kdensity ln_TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green)
// IT: lp01-lp08
tw kdensity ln_TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red)
// IT: wrdg01-wrdg08

**Comments**
/*For both countries we note a larger productivity in 2001 compared to 2008 if we use levpet procedure; for both countries the productivity seems to overlap in the two focused years.
According to LP procedure the French productivity is larger in 2001; in 2008 we can note the same result but the average produtivity gap halved (delta 0.16 vs delta 0.07).
In 2001, the Wooldridge procedure leads to same result but in this case the productivity gap is mantained constant and basically we can only observe a small common shift of productivity distribution to the right. 
Taking into account the 2007-08 financial crisis which spread also into real economy we expected a reduction in productivity which actually is not observed.
*/


**PLOTS-per parte alternativa ** 

tw kdensity TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green) || kdensity TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)
// FR: lp01-lp08-wrdg01-wrdg08		for 01 both procedures give the same result but in 2008 WRDG seems to present a larger productivity while LP shows a decrease; in WRDG the mean does not vary importantly while in LP it can be observed a decrease in productivity over years
sum TFP_WRDG_FR_29 if year==2001
sum TFP_LP_FR_29 if year==2001
sum TFP_WRDG_FR_29 if year==2008
sum TFP_LP_FR_29 if year==2008


tw kdensity TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green) || kdensity TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)
// IT: lp01-lp08-wrdg01-wrdg08		also in this case for 01 both procedures give the same result but in 2008 WRDG seems to present a larger productivity while LP shows a decrease
sum TFP_WRDG_IT_29 if year==2001
sum TFP_LP_IT_29 if year==2001
sum TFP_WRDG_IT_29 if year==2008
sum TFP_LP_IT_29 if year==2008

tw kdensity TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green)
// FR: lp01-lp08		in LP French producitivity decreases
tw kdensity TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red)
// FR: wrdg01-wrdg08	in WRDG French producitivity is stable 
tw kdensity TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(red)
// lp01fr-lp01it		in LP French producitivity is larger than Italian in 2001
tw kdensity TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(blue) || kdensity TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(red)
// lp08fr-lp08it		in LP French producitivity is larger than Italian in 2008
tw kdensity TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(red)
// wrdg01fr-wrdg01it	in WRDG French producitivity is larger than Italian in 2001
tw kdensity TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red)
// wrdg08fr-wrdg08it	in WRDG French producitivity is larger than Italian in 2008
tw kdensity TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green)
// IT: lp01-lp08		in LP Italian producitivity decreases
tw kdensity TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red)
// IT: wrdg01-wrdg08	in WRDG Italian producitivity is stable

