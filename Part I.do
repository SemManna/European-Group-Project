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
ssc install asdoc
*ssc install joy_plot, replace //note this will download a not updated verison of the .ado file which does not allow for the by() option. New versino available here: https://github.com/friosavila/stataviz/blob/main/joy_plot/joy_plot.ado

*graphical settings
set scheme s1color //remove gridlines and create white sourrounding around the graph. More plotting schemes from Stata here: http://people.umass.edu/biostat690c/pdf/stata%20schemes%20and%20palettes.pdf

cap graph set window fontface "LM Roman 10" //setting LaTeX   font

**# ******** Part 1 - dataset "EEI_TH_2022.dta" 

use "Datasets/EEI_TH_2022.dta", clear

des      //describes the data and variables present

summarize
*We do not need to clean the data from negative values: all variables have the minimum not lower than zero.
*In fact the command to clean the data from negative values: 
foreach var in L sales M W K {
        replace `var'=. if  `var'<0
        }
//yields "zero changes made"
//add reference on how 0 value observations may also be problematic, but here there are very few.

********************************************************************************
**# Problem I - Italy ***

keep if country == "Italy" 
//To keep our code clean, we temporarily drop observations unrelated to Italian firms for this subsection. Original dataset will be restored in Problem II.

**# (I.a)
* Descriptive Statistics of Italian Firms in 2008 by sector
**note: consider using asdoc to export this and other useful commands

summarize if year==2008, d   
// plots summary stats for all relevant variables of Italian firms in 2008

*COMPARING SECTOR 13 AND SECTOR 29
bysort sector: summarize if year==2008

tab sizeclass sector if year==2008

foreach k in sizeclass L real_sales real_K real_M real_VA {
    di ""
	di "ttest of `k' in 2008 in the two sectors"
	ttest `k' if year==2008, by(sector)
 }
//average of sizeclass, number of workers, real sales, real value of intermediate goods and real value added are significantly larger in industry 29 (when considering Italy in 2008) at all conventional levels of significance when carrying out a ttest. //elaborate
**#do we need this tttest?

by sector: sum L sizeclass if year==2008,d

**possibly relevant graphs for dataframe visualization and industry comparisons

qui{ //hist of to compare the number of firms in each class size across the two industries
twoway(hist sizeclass if sector == 13 & year==2008, lcolor(blue) color(blue%30) ///
	discrete percent start(1) xlabel(1 2 3 4 5, valuelabel)) ///
	(hist sizeclass if sector == 29 & year==2008, ///
	lcolor(red) color(red%30) ///
	discrete percent start(1) xlabel(1 2 3 4 5, valuelabel)), ///
	legend(label(1 "Textiles") ///
	label(2 "Motor vehicles, trailers and semi-trailers")) ///
	xtitle("Size class of the firm") ytitle("Percentage") ///
	xscale(titlegap(*10)) yscale(titlegap(*10)) ///
	title("Class Size Distribution by Industries in Italy", margin(b=3)) ///
	subtitle("Manufacture classification based on NACE rev.2", margin(b=2)) ///
	note("Data for 2008 from EEI", margin(b=2)) 

graph export "Graphs/Ia_hist_sizeclass_ita_sector.png", replace
}

qui { //kdensities of all relevant variables in Italy in 2008 separately for the two industries

*Using ln to 'normalize' the distribution - more readible but perhaps less interpretable for what concerns values on the x-axis
foreach k in L real_sales real_K real_M real_VA {
	gen ln_`k'=ln(`k')
	local varlabel : variable label `k'

	tw (kdensity ln_`k' if year==2008 & sector==13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_`k' if year==2008 & sector == 29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textiles") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") ///
	size(2.5) symxsize(2)) ///
	xtitle("ln_`k'") xscale(titlegap(*2.5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("`varlabel'", margin(b=3)) ///
	scale(.7)

	graph rename Log_`k'_by_In_Ita_2008, replace
 }

graph combine Log_L_by_In_Ita_2008 Log_real_sales_by_In_Ita_2008 Log_real_K_by_In_Ita_2008 Log_real_M_by_In_Ita_2008 Log_real_VA_by_In_Ita_2008, note("Data from the EEI", margin(b=1)) title("Distribution of the Log of relevant variables" "by industry in Italy, in 2008", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))

graph export "Graphs/Ia_Combined_Log_by_Industry_Ita_2008.png", replace
//NOTE wired pattern in capital distribution: double-peaked!


*Similarly, we can show hot the variables themselves are distributed, so to maintain values of the x-axis more interpretable at face value, although the presence of outliers requires for plotting but cleaning for outliers rather than using the distributions cleaned of outliers.
foreach k in L real_sales real_K real_M real_VA {
	sum `k', d
	replace `k'=. if !inrange(`k',r(p5),r(p95))
	local varlabel : variable label `k'
	
	tw (kdensity `k' if year==2008 & sector==13, lw(medthick) lcolor(blue)) ///
	(kdensity `k' if year==2008 & sector == 29,  lw(medthick) lcolor(red)), ///
	legend(label(1 "Textiles") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") ///
	size(2.5) symxsize(2)) ///
	xtitle("`k'") xscale(titlegap(*3)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("`varlabel'", margin(b=3)) ///
	scale(.7)

	graph rename `k'_by_Industry_Ita_2008, replace
 }

graph combine L_by_Industry_Ita_2008 real_sales_by_Industry_Ita_2008 real_K_by_Industry_Ita_2008 real_M_by_Industry_Ita_2008 real_VA_by_Industry_Ita_2008, note("Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) title("Distribution of relevant variables" "by industry in Italy, in 2008", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))

graph export "Graphs/Ia_Combined_by_Industry_Ita_2008.png", replace
}

qui{ //Graph box and violin Plot 
*some extra to be considered, note: same graphs could be plot using log as done before, to "normalize" the distributions
 
foreach k in L real_sales real_K real_M real_VA {
	local varlabel : variable label `k'
	graph box `k', over (sector) ///
	title("`varlabel'", margin(b=3)) scale(.7)

	graph rename `k'_Graph_Box_In_Ita_2008, replace
	
}

graph combine L_Graph_Box_In_Ita_2008 real_sales_Graph_Box_In_Ita_2008 real_K_Graph_Box_In_Ita_2008 real_M_Graph_Box_In_Ita_2008 real_VA_Graph_Box_In_Ita_2008, note("13 is Textiles, 29 is Motor vehicles, trailers and semi-trailers" "Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) title("Box Plot of relevant variables" "by Industries in Italy in 2008",	margin(b=3))subtitle("Ia_Manufacture classification based on NACE rev. 2",	margin(b=2))

graph export "Graphs/Ia_Combined_Graph_Box_by_In_Ita_2008.png", replace


*Violin Plot
foreach k in L real_sales real_K real_M real_VA {
	local varlabel : variable label `k'
	vioplot `k', over(sector) ///
	title("`varlabel'",	margin(b=3)) scale(.7)

	graph rename `k'_VPlot_In_Ita_2008, replace
}

graph combine L_VPlot_In_Ita_2008 real_sales_VPlot_In_Ita_2008 real_K_VPlot_In_Ita_2008 real_M_VPlot_In_Ita_2008 real_VA_VPlot_In_Ita_2008, note("13 is Textiles, 29 is Motor vehicles, trailers and semi-trailers" "Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) title("Violin Plot of relevant variables" "by Industries in Italy in 2008",	margin(b=3))subtitle("Ia_Manufacture classification based on NACE rev. 2",	margin(b=2))

graph export "Graphs/Ia_Combined_VPlot_by_In_Ita_2008.png", replace
}


**# (I.b) Compare  descriptive statistics for 2008 to the same figures in 2017
use "Datasets/EEI_TH_2022.dta", clear
keep if country == "Italy" //this is to be maintained for all graphs and tables in this section

by sector: summarize if year==2008
by sector: summarize if year==2017


qui{ //change in sizeclass from 2008 to 2017 in the two sectors
tw (hist sizeclass if year==2008 & sector==13, discrete freq ///
	lcolor(blue) color(blue%30)  ///
	start(1) xlabel(1 2 3 4 5, valuelabel)) ///
	(hist sizeclass if year == 2017 & sector==13, discrete freq ///
	lcolor(red) color(red%30) ///
	start(1) xlabel(1 2 3 4 5, valuelabel)), ///
	legend(label(1 "2008") label(2 "2017")) ///
	xtitle("Size class of the firm") xscale(titlegap(*10)) ///
	ytitle("Frequency") yscale(titlegap(*10)) ///
	title("Textiles", margin(b=3)) ///
	scale(.7)
graph rename hist13_08_17, replace

tw (hist sizeclass if year==2008 & sector==29, discrete freq ///
	lcolor(blue) color(blue%30)  ///
	start(1) xlabel(1 2 3 4 5, valuelabel)) ///
	(hist sizeclass if year == 2017 & sector==29, discrete freq ///
	lcolor(red) color(red%30) ///
	start(1) xlabel(1 2 3 4 5, valuelabel)), ///
	legend(label(1 "2008") label(2 "2017")) ///
	xtitle("Size class of the firm") xscale(titlegap(*10)) ///
	ytitle("Frequency") yscale(titlegap(*10)) ///
	title("Motor vehicles, trailers and semi-trailers", margin(b=3)) ///
	scale(.7)
graph rename hist29_08_17, replace

graph combine hist13_08_17 hist29_08_17, title("Change in Class size distribution in Italy", margin(b=1)) subtitle("From 2008 to 2017",	margin(b=2)) note("Manufacture classification based on NACE rev. 2" "Data from the EEI", margin(b=2)) 

graph export "Graphs/Ib_Combined_hist_08_17.png", replace
}


qui{ //looking at changes in the distributions of relevant covariates in sector 13
	
foreach k in L real_sales real_K real_M real_VA {
	gen ln_`k'=ln(`k')
	local varlabel : variable label `k'
	
	tw (kdensity ln_`k' if year==2008 & sector==13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_`k' if year==2017 & sector == 13,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "2008") ///
	label(2 "2017") ///
	size(3) symxsize(2)) ///
	xtitle("ln_`k'") xscale(titlegap(*3)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("`varlabel'", margin(b=2)) ///
	scale(.7)

	graph rename Log_`k'13_08_17, replace
 }

graph combine Log_L13_08_17 Log_real_sales13_08_17 Log_real_K13_08_17 Log_real_M13_08_17 Log_real_VA13_08_17 , title("Change in the distribution of relevant variables" "in Italy, from 2008 to 2017" "Textile Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))note("Data from the EEI", margin(b=1)) 

graph export "Graphs/Ib_Combined_Log13_08_17.png", replace
}

qui { //looking at changes in the distributions of relevant covariates in sector 29
foreach k in L real_sales real_K real_M real_VA {
	//gen ln_`k'=ln(`k')
	local varlabel : variable label `k'
	
	tw (kdensity ln_`k' if year==2008 & sector==29, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_`k' if year==2017 & sector == 29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "2008") ///
	label(2 "2017") ///
	size(3) symxsize(2)) ///
	xtitle("ln_`k'") xscale(titlegap(*3)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("`varlabel'", margin(b=2)) ///
	scale(.7)

	graph rename Log_`k'29_08_17, replace
 }

graph combine Log_L29_08_17 Log_real_sales29_08_17 Log_real_K29_08_17 Log_real_M29_08_17 Log_real_VA29_08_17 , title("Change in the distribution of relevant variables" "in Italy, from 2008 to 2017" "Motor vehicles, trailers and semi-trailers Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))note("Data from the EEI", margin(b=1)) 

graph export "Graphs/Ib_Combined_Log29_08_17.png", replace
}


qui{ //generate time series for the relevant variables

//Sector 13
foreach k in L real_sales real_K real_M real_VA {
	local varlabel : variable label `k'
	
	preserve
	sum `k', d
	replace `k'=. if !inrange(`k',r(p5),r(p95))	//discuss on this
	collapse (mean) `k' if sector == 13, by(year)
	
	gen mean_`k' = round(`k')
	tw (connected mean_`k' year if inrange(year, 2008, 2017), ///
	sort mcolor(black) msymbol(triangle) mlabel(mean_`k') ///
	mlabposition(6) mlabcolor(black)), ///
	ytitle("mean `k'")  xtitle("Year") ///
	title("`varlabel'") ///
	yscale(titlegap(*15)) xscale(titlegap(*15)) ///
	scale(.7)
	
	graph rename `k'13_series_08_17, replace
	
	restore 
}

graph combine L13_series_08_17 real_sales13_series_08_17 real_K13_series_08_17 real_M13_series_08_17 real_VA13_series_08_17, title("Time Series of relevant variables" "in Italy, from 2008 to 2017" "Textile Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) 

graph export "Graphs/Ib_Combined_Time_Series_13.png", replace

//Sector 29
foreach k in L real_sales real_K real_M real_VA {
	local varlabel : variable label `k'
	
	preserve
	sum `k', d
	replace `k'=. if !inrange(`k',r(p5),r(p95))	//discuss on this
	collapse (mean) `k' if sector == 29, by(year)
	
	gen mean_`k' = round(`k')
	tw (connected mean_`k' year if inrange(year, 2008, 2017), ///
	sort mcolor(black) msymbol(triangle) mlabel(mean_`k') ///
	mlabposition(6) mlabcolor(black)), ///
	ytitle("mean `k'")  xtitle("Year") ///
	title("`varlabel'") ///
	yscale(titlegap(*15)) xscale(titlegap(*15)) ///
	scale(.7)
	
	graph rename `k'29_series_08_17, replace
	
	restore 
}

graph combine L29_series_08_17 real_sales29_series_08_17 real_K29_series_08_17 real_M29_series_08_17 real_VA29_series_08_17, title("Time Series of relevant variables" "in Italy, from 2008 to 2017" "Motor vehicles, trailers and semi-trailers Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) 

graph export "Graphs/Ib_Combined_Time_Series_29.png", replace
}


//Possibly a graph summing up all mean-differences between 2017 and 2008 with T-test's CI for the relevant variables in an rcap Graph?


qui{ //Summary table for relevant statistics
matrix define R = J(5,6,.)
local i = 1

preserve
keep if  year==2008 | year==2017

foreach k in L real_sales real_K real_M real_VA {
	replace `k'=. if !inrange(`k',r(p5),r(p95)) //discuss on this!!
qui sum `k' if year==2017, d
		matrix R[`i',1]=r(mean)
		matrix R[`i',3]=r(sd)
		scalar m1=r(mean)
	
	qui sum `k' if year==2008, d
		matrix R[`i',2]=r(mean)
		matrix R[`i',4]=r(sd)
		scalar m0=r(mean)
			
	matrix R[`i',5]=m1-m0
		
	qui ttest `k', by (year)
		matrix R[`i',6]=r(se)
		
	local i=`i'+1 
}

matrix colnames R = Mean_2017 Mean_2008 StDev_2017 StDev_2008 Diff StDev_Diff
matrix rownames R = L real_sales real_K real_M real_VA

matrix list R

putexcel set "Output/TABLE_P1.xlsx", replace
putexcel A1=matrix(R), names
local i = 2
foreach k in  L real_sales real_K real_M real_VA {
    local varlabel : variable label `k'
    putexcel  A`i'=" `varlabel' "
	local ++i
	}

restore
}


//balance-table like graph? (tw(rcap)(scatter))
//correlational graphs?

********************************************************************************
**#** Problem II - Italy, Spain and France ****
use "Datasets/EEI_TH_2022.dta", clear

**# (II.a)
*Estimate for the two industries available in NACE Rev.2 2-digit format the production function coefficients, by using standard OLS, the Wooldridge (WRDG) and the Levinsohn & Petrin (LP) procedure.

***OLS REGRESSION - VALUE ADDED

//generate logs vars
foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
 }

//We estimate the pruduction function coefficients including the TFP, which we store in a variable. Morover, we set up an output table with outreg2 and progressively add estimates for the coefficients of interest
 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13
predict ln_TFP_OLS_13 if sector==13
outreg2 using "Output/TABLE_P2.xls", excel replace keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) title (Production Function Coefficients Estimates) cttop(OLS Nace-13)  

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
predict ln_TFP_OLS_29 if sector==29
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(OLS Nace-29)


***WOOLDRIDGE - VALUE ADDED

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va //note, book uses afc not va
predict ln_TFP_WRDG_13, resid
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(WRDG Nace-13)

xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29, resid
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(WRDG Nace-29)


***LEVINSOHN-PETRIN - VALUE ADDED 

xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_13, omega
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(L-P Nace-13)

xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_29, omega
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(L-P Nace-29)

//For completness and consistency, at this stage we make sure to have both the TFP and Log TFP for all methods
gen ln_TFP_LP_13 = log(TFP_LP_13)
gen ln_TFP_LP_29 = log(TFP_LP_29)
gen TFP_OLS_13 = exp(ln_TFP_OLS_13)
gen TFP_OLS_29 = exp(ln_TFP_OLS_29)
gen TFP_WRDG_13 = exp(ln_TFP_WRDG_13)
gen TFP_WRDG_29 = exp(ln_TFP_WRDG_29)

save "Datasets/EEI_TH_2022_TFP.dta", replace
********************************************************************************
**# Problem III - Theoretical comments ***


********************************************************************************
**# Prob IV

**# (IV.a)
use "Datasets/EEI_TH_2022_TFP.dta", clear
*** NOTE: we are using the TFP and LOG TFP estimates generated in Problem II.a

***Extreme values - OLS
sum TFP_OLS_13, d
sum TFP_OLS_29, d

qui{ //visualising outliers by plotting kdensity of the OLS-computed TPF and Log TFP in both industries

tw (kdensity TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_OLS_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textile") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") size(2.5)) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_OLS_TFP, replace

tw (kdensity ln_TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_OLS_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textile") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") size(2.5)) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_LOG_OLS_TFP, replace	

graph combine IVa_OLS_TFP IVa_LOG_OLS_TFP, title("Extreme values in the OLS-computed TFP", size(4) margin(b=1)) subtitle("Before cleaning for outliers", size(3)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) 

graph export "Graphs/IVa_Combined_OLS_TFP.png", replace
}

*CLEANING for extreme values in the OLS-computed TFP
foreach k in 13 29 {
	qui sum TFP_OLS_`k', d
	replace TFP_OLS_`k'=. if !inrange(TFP_OLS_`k',r(p1),r(p99))
	qui sum ln_TFP_OLS_`k', d
	replace ln_TFP_OLS_`k'=. if !inrange(ln_TFP_OLS_`k',r(p1),r(p99))
}

qui{ //visualising outliers in the CLEANED variable by plotting kdensity of the OLS-computed TPF and Log TFP in both industries

tw (kdensity TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_OLS_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textile") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") size(2.5)) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_C_OLS_TFP, replace

tw (kdensity ln_TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_OLS_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textile") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") size(2.5)) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_C_LOG_OLS_TFP, replace	

graph combine IVa_C_OLS_TFP IVa_C_LOG_OLS_TFP, title("Extreme values in the OLS-computed TFP", size(4) margin(b=1)) subtitle("After cleaning for outliers", size(3)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) 

graph export "Graphs/IVa_C_Combined_OLS_TFP.png", replace
}



**#OLD VERSION OF THIS PART - TO BE REMOVED
if 1 == 0 {
qui{ //looking at outliers by plotting kdensity of the TPF

**Industry 13 - Textiles
tw (kdensity TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_WRDG_13,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity TFP_LP_13,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3))
graph rename IVa_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity TFP_OLS_29, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_WRDG_29,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity TFP_LP_29,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("TFP Estimate'") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3))
graph rename IVa_TFP_29, replace

graph combine IVa_TFP_13 IVa_TFP_29, title("TFP Estimates by Industry" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) 

graph export "Graphs/IVa_Combined.png", replace
}

*** Both distribution are hard to read and interpret due to the presence of outliers, especially in the right tail. Thus, we also plot the Log TFP and then inquire the TFP distributions by looking at the values at percentiles.

qui{ //looking at outliers by plotting the kedensity of the LOG TPF

**Industry 13 - Textiles
tw (kdensity ln_TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_13,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_13,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3))
graph rename IVa_LOG_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity ln_TFP_OLS_29, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_29,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_29,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate'") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3))
graph rename IVa_LOG_TFP_29, replace

graph combine IVa_LOG_TFP_13 IVa_LOG_TFP_29, title("Log TFP Estimates by Industry" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) 

graph export "Graphs/IVa_LOG_Combined.png", replace
}


**looking for outliers in the distribution thourgh by comparing values at different percentiles

foreach k in OLS WRDG LP {
	sum TFP_`k'_13, d
	sum TFP_`k'_29, d
}
**even when looking just at the 99th percentile and the 4 highest values, we notice how for all estimation methods, the highest values are an order of magnitude or more above the the value at the 99th percentile. These values are completely out of scale and serve as evidence for the presence of outliers, which we will clean for.

**CLEANING for outliers, we replace into missing values outside the 1st and 99th percentiles for all TFP computed, in both industries. We also do the same for the Log TFP previously computed
foreach k in OLS WRDG LP {
	qui sum TFP_`k'_13, d
	replace TFP_`k'_13=. if !inrange(TFP_`k'_13,r(p1),r(p99))
	qui sum TFP_`k'_29, d
	replace TFP_`k'_29=. if !inrange(TFP_`k'_29,r(p1),r(p99))
	qui sum ln_TFP_`k'_13, d
	replace ln_TFP_`k'_13=. if !inrange(ln_TFP_`k'_13,r(p1),r(p99))
	qui sum ln_TFP_`k'_29, d
	replace ln_TFP_`k'_29=. if !inrange(ln_TFP_`k'_29,r(p1),r(p99))
}

**We can note that now how the values at the 99th percentiles are more consistent with those above, when compared with the pre-cleaning distribution. 
foreach k in OLS WRDG LP {
	sum TFP_`k'_13, d
	sum TFP_`k'_29, d
}

**As expected, in each distribution the standard deviation decreases and so does the mean, getting closer to the median of the distribution. This further confirms our expectation of outliers especially in the right-tail of the original TFP distirbutions.**
}

****************** Saving the cleaned dataset ******************
save "Datasets/EEI_TH_2022_cleaned_IV.dta", replace 

***--------------------------------------**
*Plot the kdensity of the TFP distribution and the kdensity of the logarithmic transformation of TFP in each industry

use "Datasets/EEI_TH_2022_cleaned_IV.dta", clear

//we repeat the same graphs showed before in this same section, but using the cleaned TFP variables just produced

qui{ //looking at outliers by plotting kdensity of the TPF

**Industry 13 - Textiles
tw (kdensity TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_WRDG_13,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity TFP_LP_13,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3))
graph rename IVa_C_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity TFP_OLS_29, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_WRDG_29,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity TFP_LP_29,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("TFP Estimate'") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3))
graph rename IVa_C_TFP_29, replace

graph combine IVa_C_TFP_13 IVa_C_TFP_29, title("TFP Estimates by Industry" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI for Italy, France, and Spain  cleaned for outliers at the first and last percentiles", margin(b=2)) 

graph export "Graphs/IVa_C_Combined.png", replace
}


qui{ //looking at outliers by plotting the kedensity of the LOG TPF

**Industry 13 - Textiles
tw (kdensity ln_TFP_OLS_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_13,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_13,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3))
graph rename IVa_C_LOG_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity ln_TFP_OLS_29, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_29,  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_29,  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate'") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3))
graph rename IVa_C_LOG_TFP_29, replace

graph combine IVa_C_LOG_TFP_13 IVa_C_LOG_TFP_29, title("Log TFP Estimates by Industry" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI for Italy, France, and Spain cleaned for outliers at the first and last percentiles", margin(b=2)) 

graph export "Graphs/IVa_C_LOG_Combined.png", replace
}

//COMMENT ON DIFFERENCES LP OR WRDG


/*Comment:
Expect graph of lnTFP13 has tails that are above the tails of lnTFP29, signalling higher productivity values for the Textile sector as compared to the Motor sector. Indeed, the summary statics of the TFP estimated from the sample cleaned for extreme values does show a higher overall mean value for sector 13 (1.24 vs 1.16). Interestingly, this reverses what has been noted previously when computing the TFP on the initial sample, which yielded an average TFP of 1.48 for sector 29 vs 1.32 for sector 13. (Commento Ale aggiunta: [...] This would point out to the fact that productivity in the Motor sector was mainly driven by firms at the extremes of the right tail, which have been cleaned for above)*/

/* The graphs through LevPet and Wooldridge are almost overlapping, 
with the average value being systematically greater in sector 13 than in sector 29.
*/


**#Other possible graph: plotting for each estimation method the kdensity for both sectors, then combined them (final graph has 3 graphs, one per estimation method with 2 kedensities each, one per sector) - should we add it???


**# (IV.b) - plot the TFP distribution of each industry for each country
use "Datasets/EEI_TH_2022_cleaned_IV.dta", clear

qui{ //generating a combined graph with separate plots for each country and industry within

foreach k in "France" "Italy" "Spain" {
	
**Industry 13 - Textiles
tw (kdensity ln_TFP_OLS_13 if country=="`k'", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_13 if country=="`k'",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_13 if country=="`k'",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title(`k' "Textile", size(4) margin(b=3)) ///
	scale(.7)
graph rename IVb_`k'_C_LOG_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity ln_TFP_OLS_29 if country=="`k'", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_29 if country=="`k'",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_29 if country=="`k'",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "OLS") ///
	label(2 "WRDG") label(3 "LP")) ///
	xtitle("Log TFP Estimate'") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title(`k' "Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3)) ///
	scale(.7)
graph rename IVb_`k'_C_LOG_TFP_29, replace
}

graph combine IVb_France_C_LOG_TFP_13 IVb_Italy_C_LOG_TFP_13 IVb_Spain_C_LOG_TFP_13 IVb_France_C_LOG_TFP_29 IVb_Italy_C_LOG_TFP_29 IVb_Spain_C_LOG_TFP_29, title("Log TFP Estimates by Industry and Country" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) 

graph export "Graphs/IVb_ByCountry_C_LOG_Combined.png", replace
}


qui{ //comparing LP TFP for the three countries, in the two industries
	
**Industry 13 - Textiles
tw (kdensity ln_TFP_LP_13 if country=="France", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_LP_13 if country=="Italy",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_13 if country=="Spain",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "France") ///
	label(2 "Italy") label(3 "Spain")) ///
	xtitle("Log LP TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3)) ///
	scale(.8)
graph rename IVb_C_LOG_LP_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity ln_TFP_LP_29 if country=="France", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_LP_29 if country=="Italy",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_LP_29 if country=="Spain",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "France") ///
	label(2 "Italy") label(3 "Spain")) ///
	xtitle("Log LP TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3)) ///
	scale(.8)
graph rename IVb_C_LOG_LP_TFP_29, replace


graph combine IVb_C_LOG_LP_TFP_13 IVb_C_LOG_LP_TFP_29, title("Cross-Country Log TFP comparison by industry" "using LP estimation", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) 

graph export "Graphs/IVb_C_LOG_LP_TFP_Combined.png", replace	
}

qui{ //comparing WRDG TFP for the three countries, in the two industries
	
**Industry 13 - Textiles
tw (kdensity ln_TFP_WRDG_13 if country=="France", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_13 if country=="Italy",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_WRDG_13 if country=="Spain",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "France") ///
	label(2 "Italy") label(3 "Spain")) ///
	xtitle("Log WRDG TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Textile", size(4) margin(b=3)) ///
	scale(.8)
graph rename IVb_C_LOG_WRDG_TFP_13, replace

**Industry 29 - Textiles
tw (kdensity ln_TFP_WRDG_29 if country=="France", ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_WRDG_29 if country=="Italy",  ///
	lw(medthick) lcolor(red)) ///
	(kdensity ln_TFP_WRDG_29 if country=="Spain",  ///
	lw(medthick) lcolor(green)), ///
	legend(label(1 "France") ///
	label(2 "Italy") label(3 "Spain")) ///
	xtitle("Log WRDG TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Motor vehicles, trailers and semi-trailers", ///
	size(4) margin(b=3)) ///
	scale(.8)
graph rename IVb_C_LOG_WRDG_TFP_29, replace


graph combine IVb_C_LOG_WRDG_TFP_13 IVb_C_LOG_WRDG_TFP_29, title("Cross-Country Log TFP comparison by industry" "using WRDG estimation", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) 

graph export "Graphs/IVb_C_LOG_WRDG_TFP_Combined.png", replace	
}


qui{ //producing half violin plots to show the TFP distributions, over countries and by industry in an ore concise way
//not possible under available varsions of joy_plot
foreach k in OLS WRDG LP {

gen lnTFP_`k'= ln_TFP_`k'_13
replace lnTFP_`k' = ln_TFP_`k'_29 if ln_TFP_`k'_13==.

cap joy_plot lnTFP_`k', over(country) by(sector) violin ///
dadj(1.5) alegend fcolor(%30) iqr(5 95) iqrlcolor(*1.2) ///
iqrlwidth(1) color(blue red) ///
title("log TFP, `k' Estimates", size(4) margin(b=3))
graph rename IVb_ByCountry_C_V_LOG_`k'_TFP, replace
drop lnTFP_`k'

}

graph combine IVb_ByCountry_C_V_LOG_OLS_TFP IVb_ByCountry_C_V_LOG_WRDG_TFP IVb_ByCountry_C_V_LOG_LP_TFP, title("Log TFP Estimates by Industry and Country" "using different estimation techniques", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) cols(3) 

graph export "Graphs/IVb_ByCountry_C_V_LOG_Combined.png", replace
}



**#NOTE: Using both methods, Italy exibits the highest TFP distribution - could it be due to a larger 'unexplained' portion of productivity rather than from a larger all else equal TFP? //DISCUSS

**# Review those comments
/*Comments:
From plotting the three countries, we can make the following observations:
- Italy appears to be more productive than Spain, under both LevPet and Wooldridge
- Italy appears to be more productive than France under Levpet, but slighlty less
productive ( 210.7353 vs 186.4549) under Wooldridge.
- French TFP appears closer to Italian TFP under Wooldridge, while closer to Spain 
under Levpet.
(Other comments?)
*/



**# (IV.c).c: plot the TFP distribution for Italy_29 and France_29 2001vs2008; compare LP and WRDG ***


****LEVPET-Comparison**
**#constructing a table to highlight the changes, both with LP and WRDG, discuss
qui { //LP table construction
matrix define LP = J(2,6,.)
local i = 1

foreach k in "Italy" "France" { //sum, d and storing useful statistics 
	sum TFP_LP_29 if country =="`k'" & year==2001, d
	matrix LP[`i',1]=r(mean)
	scalar m0=r(mean)
	matrix LP[`i',4]=r(skewness)
	scalar s0=r(skewness)
	
	sum TFP_LP_29 if country =="`k'" & year==2008, d
	matrix LP[`i',2]=r(mean)
	scalar m1=r(mean)
	matrix LP[`i',5]=r(skewness)
	scalar s1=r(skewness)
	
	matrix LP[`i',3]=m1-m0
	matrix LP[`i',6]=s1-s0
	
	local i=`i'+1 
}

matrix colnames LP = Mean_2001 Mean_2008 Mean_Diff Skw_2001 Skw_2008 Skw_Diff
matrix rownames LP = Italy France
matrix list LP  
putexcel set "Output/TABLE_P4.xlsx", replace
putexcel A1=matrix(LP), names
putexcel  A1="LP"
}

qui{ //graph for LP comparison
	
tw (kdensity ln_TFP_LP_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity ln_TFP_LP_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)) /// 
	(kdensity ln_TFP_LP_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity ln_TFP_LP_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "France 2001") label(2 "France 2008") /// 
	label(3 "Italy 2001") label(4 "Italy 2008")) ///
	xtitle("Log LP TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("LP TFP Comparison Between France and Italy" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2))
 
graph export "Graphs/IVc_LOG_LP_TFP_FR_IT_01_08.png", replace	

}


****WRDG-Comparison**

qui { //WRDG table construction
matrix define W= J(2,6,.)
local i = 1

foreach k in "Italy" "France" { //sum, d and storing useful statistics 
	sum TFP_WRDG_29 if country =="`k'" & year==2001, d
	matrix W[`i',1]=r(mean)
	scalar m0=r(mean)
	matrix W[`i',4]=r(skewness)
	scalar s0=r(skewness)
	
	sum TFP_WRDG_29 if country =="`k'" & year==2008, d
	matrix W[`i',2]=r(mean)
	scalar m1=r(mean)
	matrix W[`i',5]=r(skewness)
	scalar s1=r(skewness)
	
	matrix W[`i',3]=m1-m0
	matrix W[`i',6]=s1-s0
	
	local i=`i'+1 
}

matrix colnames W = Mean_2001 Mean_2008 Mean_Diff Skw_2001 Skw_2008 Skw_Diff
matrix rownames W = Italy France
matrix list W //nice matrix with all the desired stats 
putexcel set "Output/TABLE_P4.xlsx", modify
putexcel A5=matrix(W), names
putexcel  A5="WRDG"
}

qui{ //graph for WRDG comparison
	
tw (kdensity ln_TFP_WRDG_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity ln_TFP_WRDG_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)) /// 
	(kdensity ln_TFP_WRDG_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity ln_TFP_WRDG_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "France 2001") label(2 "France 2008") /// 
	label(3 "Italy 2001") label(4 "Italy 2008")) ///
	xtitle("Log WRDG TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("LP WRDG Comparison Between France and Italy" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2))
 
graph export "Graphs/IVc_LOG_WRDG_TFP_FR_IT_01_08.png", replace	

}


**# In light of the two graphs I just plot, which of those would you still keep? 
if 1==0 { //Update variable names
**PLOTS**
// grafico tutto lev pet e tutto wrdg
tw kdensity ln_TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green) || kdensity ln_TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving("Graphs/ln_TFP_LP_13_29_joint", replace)
// FR: lp01-lp08-wrdg01-wrdg08
tw kdensity ln_TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green) || kdensity ln_TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity ln_TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving("Graphs/ln_TFP_LP_13_29_joint", replace)
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
}

**Comments**
/*For both countries we note a larger productivity in 2001 compared to 2008 if we use levpet procedure; for both countries the productivity seems to overlap in the two focused years.
According to LP procedure the French productivity is larger in 2001; in 2008 we can note the same result but the average produtivity gap halved (delta 0.16 vs delta 0.07).
In 2001, the Wooldridge procedure leads to same result but in this case the productivity gap is mantained constant and basically we can only observe a small common shift of productivity distribution to the right. 
Taking into account the 2007-08 financial crisis which spread also into real economy we expected a reduction in productivity which actually is not observed.
*/

**#what to keep of all those as well?
**PLOTS-per parte alternativa ** 
if 1==0 { //same here
tw kdensity TFP_LP_FR_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_FR_29 if year==2008, lw(medthick) lcolor(green) || kdensity TFP_WRDG_FR_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_FR_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving("Graphs/ln_TFP_LP_13_29_joint", replace)
// FR: lp01-lp08-wrdg01-wrdg08		for 01 both procedures give the same result but in 2008 WRDG seems to present a larger productivity while LP shows a decrease; in WRDG the mean does not vary importantly while in LP it can be observed a decrease in productivity over years
sum TFP_WRDG_FR_29 if year==2001
sum TFP_LP_FR_29 if year==2001
sum TFP_WRDG_FR_29 if year==2008
sum TFP_LP_FR_29 if year==2008


tw kdensity TFP_LP_IT_29 if year==2001, lw(medthick) lcolor(blue) || kdensity TFP_LP_IT_29 if year==2008, lw(medthick) lcolor(green) || kdensity TFP_WRDG_IT_29 if year==2001, lw(medthick) lcolor(black) || kdensity TFP_WRDG_IT_29 if year==2008, lw(medthick) lcolor(red), ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving("Graphs/ln_TFP_LP_13_29_joint", replace)
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
}

**# (IV.d)
*Looking at the previously constructed TABLE_P4.xlsx, we notice how, although remaining positive in all periods and countries considered, the skweness of Italy increases by 0.201 between 2008 and 2009, while that of France decreases by 0.179
*Instead, when we consider WRDG, we produce slightly smaller skeweness, and we witness a decrease in both countries: of 0.107 for Italy, and of 0.484 for France
**# RELATE THIS TO POINT IV.c

**# (IV.e) Theoretical question, compare kdensities ?
//how do we test significantly different shifts in the distribution?!

** LOOK AT THE k-dispersion parameter!!



