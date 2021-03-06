*****************************************************
*File Description:	Take Home - Economics of European Integration 
*Problems I-IV								 				
*Date:		May 2022
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
ssc install xttrans2, replace
*ssc install joy_plot, replace //note this will download a not updated verison of the .ado file which does not allow for the by() option. New versino available here: https://github.com/friosavila/stataviz/blob/main/joy_plot/joy_plot.ado

*graphical settings
set scheme s1color //remove gridlines and create white sourrounding around the graph. More plotting schemes from Stata here: http://people.umass.edu/biostat690c/pdf/stata%20schemes%20and%20palettes.pdf
cap graph set window fontface "LM Roman 10" //setting LaTeX font for Windows
cap graph set window fontface "Latin Modern Roman" //setting LaTeX font for Mac

**# ******** Part 1 - dataset "EEI_TH_2022.dta" 

use "Datasets/EEI_TH_2022.dta", clear

summarize
*No need to clean the data from negative values: all variables have the minimum not lower than zero.
*In fact the command to clean the data from negative values: 
foreach var in L sales M W K {
        replace `var'=. if  `var'<0
        }
*yields "zero changes made"


********************************************************************************
**# Problem I - Italy ***

keep if country == "Italy" 
//To keep our code clean, we temporarily drop observations unrelated to Italian firms for this subsection. Original dataset will be restored in Problem II.

**# (I.a)
* Descriptive Statistics of Italian Firms in 2008 by sector

summarize if year==2008, d   
// produce summary stats for all relevant variables of Italian firms in 2008

tab sizeclass if year == 2008
// Firms mostly belong to categories 2 and 3 


*COMPARING SECTOR 13 AND SECTOR 29
bysort sector: summarize if year==2008

tab sizeclass sector if year==2008,

foreach k in sizeclass L real_sales real_K real_M real_VA {
    di ""
	di "ttest of `k' in 2008 in the two sectors"
	ttest `k' if year==2008, by(sector)
 }
//average of sizeclass, number of workers, real sales, real value of intermediate goods and real value added are significantly larger in industry 29 (when considering Italy in 2008) at all conventional levels of significance when carrying out a ttest. 

**Comments on sizeclass and number of workers
by sector: sum L sizeclass if year==2008,d
**Comments on accounting variables
by sector: sum real_M if country == "Italy" & year == 2008 , d

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
	title("Class Size Distribution by Industries in Italy in 2008", margin(b=3)) ///
	subtitle("Manufacture classification based on NACE rev.2", margin(b=2)) ///
	note("Data from EEI", margin(b=2)) 

graph export "Graphs/Ia_hist_sizeclass_ita_sector.png", replace
}

qui { //kdensities of all relevant variables in Italy in 2008 separately for the two industries

*Using ln to 'normalize' the distribution - more readable but perhaps less interpretable for what concerns values on the x-axis
foreach k in L W real_sales real_K real_M real_VA {
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

graph combine Log_L_by_In_Ita_2008 Log_W_by_In_Ita_2008 Log_real_sales_by_In_Ita_2008 Log_real_K_by_In_Ita_2008 Log_real_M_by_In_Ita_2008 Log_real_VA_by_In_Ita_2008, note("Data from the EEI", margin(b=1)) title("Distribution of the Log of relevant variables" "by industry in Italy, in 2008", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))

graph export "Graphs/Ia_Combined_Log_by_Industry_Ita_2008.png", replace
//NOTE wired pattern in capital distribution: triple-peaked!


*Similarly, we can show hot the variables themselves are distributed, so to maintain values of the x-axis more interpretable at face value, although the presence of outliers requires for plotting but cleaning for outliers rather than using the distributions cleaned of outliers.
foreach k in L W real_sales real_K real_M real_VA {
	sum `k', d
	replace `k'=. if !inrange(`k',r(p1),r(p99))
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

graph combine L_by_Industry_Ita_2008 W_by_Industry_Ita_2008 real_sales_by_Industry_Ita_2008 real_K_by_Industry_Ita_2008 real_M_by_Industry_Ita_2008 real_VA_by_Industry_Ita_2008, note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) title("Distribution of relevant variables" "by industry in Italy, in 2008", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1))

graph export "Graphs/Ia_Combined_by_Industry_Ita_2008.png", replace
}

qui{ //Summary table for relevant statistics in the two industries
matrix define R = J(6,6,.)
local i = 1

preserve
keep if  year==2008

foreach k in L W real_sales real_K real_M real_VA {
	 
	sum `k' if sector==29, d
		matrix R[`i',1]=r(mean)
		matrix R[`i',3]=r(sd)
		scalar m1=r(mean)
		scalar s1=r(sd)
	
	sum `k' if sector==13, d
		matrix R[`i',2]=r(mean)
		matrix R[`i',4]=r(sd)
		scalar m0=r(mean)
		scalar s0=r(sd)
			
	matrix R[`i',5]=m1-m0
	matrix R[`i',6]=s1-s0
		
	local i=`i'+1 
}

matrix colnames R = Mean_29 Mean_13 StDev_29 StDev_13 Mean_Diff StDev_Diff
matrix rownames R = L W_costs real_sales real_K real_M real_VA

matrix list R

putexcel set "Output/TABLE_P1a.xlsx", replace
putexcel A1=matrix(R), names
local i = 2
foreach k in  L W real_sales real_K real_M real_VA {
    local varlabel : variable label `k'
    putexcel  A`i'=" `varlabel' "
	local ++i
	}

restore
}

if 1 == 0 { // extra, but hightly time-consuming to run

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


qui { //producing a transition matrix from 2008 to 2017
	
preserve
keep if country=="Italy"
keep if inrange(year, 2008, 2017)
xtset id_n year
xttab sizeclass if sector==13
xttab sizeclass if sector==29 
xttrans2 sizeclass if sector==13, freq matcell(M)
xttrans2 sizeclass if sector==29, freq matcell(W)

putexcel set "Output/TABLE_P1b_08_to_17.xlsx", replace
putexcel A1=matrix(M), names
putexcel A1= "Sector 13"
putexcel A8=matrix(W), names
putexcel A8= "Sector 29"
restore

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
	replace `k'=. if !inrange(`k',r(p1),r(p99))	
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

graph combine L13_series_08_17 real_sales13_series_08_17 real_K13_series_08_17 real_M13_series_08_17 real_VA13_series_08_17, title("Time Series of relevant variables" "in Italy, from 2008 to 2017" "Textile Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI", margin(b=2)) 

graph export "Graphs/Ib_Combined_Time_Series_13.png", replace

//Sector 29
foreach k in L real_sales real_K real_M real_VA {
	local varlabel : variable label `k'
	
	preserve
	sum `k', d
	replace `k'=. if !inrange(`k',r(p1),r(p99))	
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

graph combine L29_series_08_17 real_sales29_series_08_17 real_K29_series_08_17 real_M29_series_08_17 real_VA29_series_08_17, title("Time Series of relevant variables" "in Italy, from 2008 to 2017" "Motor vehicles, trailers and semi-trailers Industry", size(4) margin(b=1)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) note("Data from the EEI", margin(b=2)) 

graph export "Graphs/Ib_Combined_Time_Series_29.png", replace
}


qui{ //Summary table of relevant statistics by sector

*** Sector 29
matrix define R = J(6,6,.)
local i = 1

preserve
keep if sector==29
keep if  year==2008 | year==2017

foreach k in L W real_sales real_K real_M real_VA {
	
qui sum `k' if year==2017, d
		matrix R[`i',1]=r(mean)
		matrix R[`i',3]=r(sd)
		scalar m1=r(mean)
		scalar s1=r(sd)
	
	qui sum `k' if year==2008, d
		matrix R[`i',2]=r(mean)
		matrix R[`i',4]=r(sd)
		scalar m0=r(mean)
		scalar s0=r(sd)	
		
	matrix R[`i',5]=m1-m0
	matrix R[`i',6]=s1-s0
		
	local i=`i'+1 
}

matrix colnames R = Mean_2017 Mean_2008 StDev_2017 StDev_2008 Diff StDev_Diff
matrix rownames R = L W_costs real_sales real_K real_M real_VA

matrix list R

putexcel set "Output/TABLE_P1b.xlsx", replace
putexcel A1=matrix(R), names
putexcel A1 = "Sector 29"
local i = 2
foreach k in  L W real_sales real_K real_M real_VA {
    local varlabel : variable label `k'
    putexcel  A`i'=" `varlabel' "
	local ++i
	}

restore

***Sector 13
matrix define R = J(6,6,.)
local i = 1

preserve
keep if sector==13
keep if  year==2008 | year==2017

foreach k in L W real_sales real_K real_M real_VA {
	
qui sum `k' if year==2017, d
		matrix R[`i',1]=r(mean)
		matrix R[`i',3]=r(sd)
		scalar m1=r(mean)
		scalar s1=r(sd)
	qui sum `k' if year==2008, d
		matrix R[`i',2]=r(mean)
		matrix R[`i',4]=r(sd)
		scalar m0=r(mean)
		scalar s0=r(sd)
			
	matrix R[`i',5]=m1-m0
	matrix R[`i',6]=s1-s0
		
	local i=`i'+1 
}

matrix colnames R = Mean_2017 Mean_2008 StDev_2017 StDev_2008 Diff StDev_Diff
matrix rownames R = L W_costs real_sales real_K real_M real_VA

matrix list R

putexcel set "Output/TABLE_P1b.xlsx", modify
putexcel A9=matrix(R), names
putexcel A9 = "Sector 13"
local i = 10
foreach k in  L W real_sales real_K real_M real_VA {
    local varlabel : variable label `k'
    putexcel  A`i'=" `varlabel' "
	local ++i
	}

restore

}



********************************************************************************
**#** Problem II - Italy, Spain and France ****
use "Datasets/EEI_TH_2022.dta", clear

**# (II.a)

/* note:
We estimate the pruduction function coefficients including the TFP (residual), which we store in a variable. Morover, we set up an output table with outreg2 and progressively add estimates for the coefficients of interest
*/ 

qui { //Production function estimations

//generate logs vars
foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
 }

***OLS REGRESSION - VALUE ADDED

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13
predict ln_TFP_OLS_13 if sector==13
outreg2 using "Output/TABLE_P2.xls", excel replace keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) title (Production Function Coefficients Estimates) cttop(OLS Nace-13)  

xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29
predict ln_TFP_OLS_29 if sector==29
outreg2 using "Output/TABLE_P2.xls", excel append keep (ln_real_VA ln_L ln_real_K ) nocons addtext (Country FEs, YES, Year FEs, YES) cttop(OLS Nace-29)


***WOOLDRIDGE - VALUE ADDED

xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
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

}

********************************************************************************
**# Problem III - Theoretical comments ***


********************************************************************************
**# Prob IV

**# (IV.a)
use "Datasets/EEI_TH_2022_TFP.dta", clear
*** NOTE: we are using the TFP and LOG TFP estimates generated in Problem II.a

***Visualizing and cleaning for Extreme values***

foreach t in OLS WRDG LP {

*looking for outliers in the distribution by comparing values at different percentiles
sum TFP_`t'_13, d
sum TFP_`t'_29, d

qui{ //visualising outliers by plotting the kdensity 
*of the computed TPF and Log TFP in both industries (for the estimation method under consideration at each stage of the loop)

*Sector 13
qui kdensity TFP_`t'_13, ///
	lw(medthick) lcolor(blue) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_`t'_TFP_13, replace

qui kdensity ln_TFP_`t'_13, ///
	lw(medthick) lcolor(blue) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_LOG_`t'_TFP_13, replace

qui graph combine IVa_`t'_TFP_13 IVa_LOG_`t'_TFP_13, title("Textile Industry", size(4) margin(b=.5))
graph rename IVa_Com_`t'_TFP_13, replace

*Sector 29
qui kdensity TFP_`t'_29, ///
	lw(medthick) lcolor(red) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_`t'_TFP_29, replace

qui kdensity ln_TFP_`t'_29, ///
	lw(medthick) lcolor(red) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_LOG_`t'_TFP_29, replace

qui graph combine IVa_`t'_TFP_29 IVa_LOG_`t'_TFP_29, title("Motor vehicles, trailers and semi-trailers", size(4) margin(b=.4))
graph rename IVa_Com_`t'_TFP_29, replace

*combining the two sectors
qui graph combine IVa_Com_`t'_TFP_13 IVa_Com_`t'_TFP_29, title("Extreme values in the `t'-computed TFP", size(4) margin(b=1)) subtitle("Before cleaning for outliers", size(3.5)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) rows(2) 

graph export "Graphs/IVa_Combined_`t'_TFP.png", replace
}

*CLEANING for extreme values in the computed TFP
foreach k in 13 29 {
	qui sum TFP_`t'_`k', d
	replace TFP_`t'_`k'=. if !inrange(TFP_`t'_`k',r(p1),r(p99))
	qui sum ln_TFP_`t'_`k', d
	replace ln_TFP_`t'_`k'=. if !inrange(ln_TFP_`t'_`k',r(p1),r(p99))
}
*looking at the same summary statistics again, but with cleaned TFP
sum TFP_`t'_13, d
sum TFP_`t'_29, d

qui{ //visualising outliers in the CLEANED TFP by plotting kdensity of the computed TPF and Log TFP in both industries
*Note: same graph as the previous one, but with cleaned TFP and Log TFP

*Sector 13
qui kdensity TFP_`t'_13, ///
	lw(medthick) lcolor(blue) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_C_`t'_TFP_13, replace

qui kdensity ln_TFP_`t'_13, ///
	lw(medthick) lcolor(blue) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_C_LOG_`t'_TFP_13, replace

qui graph combine IVa_C_`t'_TFP_13 IVa_C_LOG_`t'_TFP_13, title("Textile Industry", size(4) margin(b=.5))
graph rename IVa_Com_C_`t'_TFP_13, replace

*Sector 29
qui kdensity TFP_`t'_29, ///
	lw(medthick) lcolor(red) ///
	xtitle("TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP", size(4) margin(b=3))
graph rename IVa_C_`t'_TFP_29, replace

qui kdensity ln_TFP_`t'_29, ///
	lw(medthick) lcolor(red) ///
	xtitle("Log TFP Estimate") xscale(titlegap(*5)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP", size(4) margin(b=3))
graph rename IVa_C_LOG_`t'_TFP_29, replace

qui graph combine IVa_C_`t'_TFP_29 IVa_C_LOG_`t'_TFP_29, title("Motor vehicles, trailers and semi-trailers", size(4) margin(b=.4))
graph rename IVa_Com_C_`t'_TFP_29, replace

*combining the two sectors
qui graph combine IVa_Com_C_`t'_TFP_13 IVa_Com_C_`t'_TFP_29, title("Extreme values in the `t'-computed TFP", size(4) margin(b=1)) subtitle("After cleaning for outliers", size(3.5)) note("Data from the EEI for Italy, France, and Spain", margin(b=2)) rows(2) 

graph export "Graphs/IVa_C_Combined_`t'_TFP.png", replace
}

}

qui { //summary graph of cleaned TFP comparison across estimation methods and industries

foreach k in OLS WRDG LP {

tw (kdensity TFP_`k'_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity TFP_`k'_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textiles") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") ///
	size(2.5) symxsize(2)) ///
	xtitle("TFP Estimate") xscale(titlegap(*4)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("TFP") ///
	scale(.7)
graph rename VIa_C_`k', replace

tw (kdensity ln_TFP_`k'_13, ///
	lw(medthick) lcolor(blue)) ///
	(kdensity ln_TFP_`k'_29,  ///
	lw(medthick) lcolor(red)), ///
	legend(label(1 "Textiles") ///
	label(2 "Motor vehicles, trailers" "and semi-trailers") ///
	size(2.5) symxsize(2)) ///
	xtitle("log TFP Estimate") xscale(titlegap(*4)) ///
	ytitle("Density")	yscale(titlegap(*6)) ///
	title("Log TFP") ///
	scale(.7)
graph rename VIa_C_Log_`k', replace

qui graph combine VIa_C_`k' VIa_C_Log_`k', title("`k'-computed TFP", size(2.7) margin(b=1))

graph rename VIa_C_Com_`k', replace

}

*Combining all graphs
qui graph combine VIa_C_Com_OLS VIa_C_Com_WRDG VIa_C_Com_LP, title("Comparing TFP Estimation methods", size(3) margin(b=1)) subtitle("After cleaning for outliers", size(2.5)) note("Data from the EEI for Italy, France", margin(b=2)) rows(3) imargin(zero)    
//manual saving to correct for garphical properties like aspect ratio

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

qui{ //producing half violin plots to show the TFP distributions, over countries and by industry in an more concise way
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

**# (IV.c)

****OLS Comparison****
qui { //OLS TFP graphs
	
tw (kdensity ln_TFP_OLS_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity ln_TFP_OLS_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)) /// 
	(kdensity ln_TFP_OLS_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity ln_TFP_OLS_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "France 2001") label(2 "France 2008") /// 
	label(3 "Italy 2001") label(4 "Italy 2008")) ///
	xtitle("Log OLS TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("OLS TFP Comparison Between France and Italy for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2))
 
graph export "Graphs/IVc_LOG_OLS_TFP_FR_IT_01_08.png", replace	

sum TFP_OLS_29 if country=="France" & year==2001, d
sum TFP_OLS_29 if country=="France" & year==2008, d

tw (kdensity TFP_OLS_29 if country=="France" & year==2001,  /// 
	lw(medthick) lcolor(blue) lpattern(dash) range (0 50000)) /// 
	(kdensity TFP_OLS_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue) range (0 50000)), /// 
	legend(label(1 "France 2001") label(2 "France 2008")) ///
	xtitle("OLS TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("OLS TFP in France for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) 
	
	graph rename IVc_OLS_TFPc_FR_01_08, replace
	
graph export "Graphs/IVc_OLS_TFPc_FR_01_08.png", replace	

sum TFP_OLS_29 if country=="Italy" & year==2001, d
sum TFP_OLS_29 if country=="Italy" & year==2008, d

tw (kdensity TFP_OLS_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash) range (0 20000)) /// 
	(kdensity TFP_OLS_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red) range (0 20000)), /// 
	legend(label(1 "Italy 2001") label(2 "Italy 2008")) ///
	xtitle("OLS TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("OLS TFP in Italy for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	
	graph rename IVc_OLS_TFPc_IT_01_08, replace
 
graph export "Graphs/IVc_OLS_TFPc_IT_01_08.png", replace	

graph combine IVc_OLS_TFPc_IT_01_08 IVc_OLS_TFPc_FR_01_08, title("TFP OLS Estimates for Italy and France in 2001 and 2008 for sector 29", size(4) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last 5 percentiles", margin(b=2)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) 

graph rename IVc_ByCountry_OLSTFPcut_Combined, replace

graph export "Graphs/IVc_ByCountry_OLSTFPcut_Combined.png", replace
}

qui{ //Log OLS TFP graphs

tw (kdensity ln_TFP_OLS_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity ln_TFP_OLS_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)), /// 
	legend(label(1 "France 2001") label(2 "France 2008")) ///
	xtitle("Log OLS TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("Log OLS TFP in France for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) 

	graph rename IVc_LOG_OLS_TFP_FR_01_08, replace
 
graph export "Graphs/IVc_LOG_OLS_TFP_FR_01_08.png", replace	

tw  (kdensity ln_TFP_OLS_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity ln_TFP_OLS_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "Italy 2001") label(2 "Italy 2008")) ///
	xtitle("Log OLS TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("Log OLS TFP in Italy for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3))
 
graph rename IVc_LOG_OLS_TFP_IT_01_08, replace

graph export "Graphs/IVc_LOG_OLS_TFP_FR_IT_01_08.png", replace	

 
graph combine IVc_LOG_OLS_TFP_IT_01_08 IVc_LOG_OLS_TFP_FR_01_08, title("log TFP OLS Estimates for Italy and France in 2001 and 2008 for sector 29", size(4) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) 

graph rename IVc_ByCountry_logTFPOLS_combined, replace

graph export "Graphs/IVc_ByCountry_logTFP_OLS_Combined.png", replace
}


****LEVPET-Comparison**
*constructing a table to highlight the changes, both with LP and WRDG
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

**Graphs for LP comparison France and Italy 2001 vs 2008

qui{ //graph for LP comparison France 2001 vs 2008
	
tw (kdensity TFP_LP_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity TFP_LP_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)), /// 
	legend(label(1 "France 2001") label(2 "France 2008")) ///
	xtitle("LP TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("LP TFP 29 in France" ///
	"between 2001 and 2008", size(4) margin(b=3)) 
 
graph rename IVc_LP_TFP_FR_01_08, replace
 
graph export "Graphs/IVc_LP_TFP_FR_01_08.png", replace	

}
 
qui{ //graph for LP comparison Italy 2001 vs 2008
	
tw  (kdensity TFP_LP_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity TFP_LP_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "Italy 2001") label(2 "Italy 2008")) ///
	xtitle("LP TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("LP TFP 29 in Italy" ///
	"between 2001 and 2008", size(4) margin(b=3))
	
graph rename IVc_LP_TFP_IT_01_08, replace
 
graph export "Graphs/IVc_LP_TFP_FR_IT_01_08.png", replace	

graph combine IVc_LP_TFP_IT_01_08 IVc_LP_TFP_FR_01_08, title("TFP LP Comparison for Sector 29" "for France and Italy Between 2001 and 2008", size(4) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) 

graph rename IVc_ByCountry_TFPLP_combined, replace

graph export "Graphs/IVc_ByCountry_TFP_LP_Combined.png", replace

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

**Graphs for WRDG comparison France and Italy 2001 vs 2008

qui{ //graph for WRDG comparison France 2001 vs 2008
	
tw (kdensity TFP_WRDG_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity TFP_WRDG_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)), /// 
	legend(label(1 "France 2001") label(2 "France 2008")) ///
	xtitle("WRDG TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("WRDG TFP 29 in France" ///
	"between 2001 and 2008", size(4) margin(b=3)) 
 
graph rename IVc_WRDG_TFP_FR_01_08, replace
 
graph export "Graphs/IVc_WRDG_TFP_FR_01_08.png", replace	

}
 

qui{ //graph for WRDG comparison Italy 2001 vs 2008
	
tw  (kdensity TFP_WRDG_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity TFP_WRDG_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "Italy 2001") label(2 "Italy 2008")) ///
	xtitle("WRDG TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("WRDG TFP 29 in Italy" ///
	"between 2001 and 2008", size(4) margin(b=3))
	
graph rename IVc_WRDG_TFP_IT_01_08, replace
 
graph export "Graphs/IVc_WRDG_TFP_FR_IT_01_08.png", replace	

graph combine IVc_WRDG_TFP_IT_01_08 IVc_WRDG_TFP_FR_01_08, title("TFP WRDG Comparison for Sector 29" "for France and Italy Between 2001 and 2008", size(4) margin(b=1)) note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2)) subtitle("Manufacture classification based on NACE rev. 2", size(3) margin(b=1)) 

graph rename IVc_ByCountry_TFPWRDG_combined, replace

graph export "Graphs/IVc_ByCountry_TFP_WRDG_Combined.png", replace

}

//summary stats
foreach k in OLS WRDG LP {
	foreach t in "Italy" "France"{
sum TFP_`k'_29  if country=="`k'" & year==2001, d
sum TFP_`k'_29 if country=="`t'" & year==2008, d
	}
}



**# (IV.d)

qui{ //graph for LP comparison
	
tw (kdensity TFP_LP_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity TFP_LP_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)) /// 
	(kdensity TFP_LP_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity TFP_LP_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "France 2001") label(2 "France 2008") /// 
	label(3 "Italy 2001") label(4 "Italy 2008")) ///
	xtitle("LP TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("LP TFP Comparison Between France and Italy for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2))
 
graph export "Graphs/IVd_LP_TFP_FR_IT_01_08.png", replace	

}

qui{ //graph for WRDG comparison
	
tw (kdensity TFP_WRDG_29 if country=="France" & year==2001, /// 
	lw(medthick) lcolor(blue) lpattern(dash)) /// 
	(kdensity TFP_WRDG_29 if country=="France" & year==2008, /// 
	lw(medthick) lcolor(blue)) /// 
	(kdensity TFP_WRDG_29 if country=="Italy" & year==2001,  /// 
	lw(medthick) lcolor(red) lpattern(dash)) /// 
	(kdensity TFP_WRDG_29 if country=="Italy" & year==2008, /// 
	lw(medthick) lcolor(red)), /// 
	legend(label(1 "France 2001") label(2 "France 2008") /// 
	label(3 "Italy 2001") label(4 "Italy 2008")) ///
	xtitle("WRDG TFP Estimates") xscale(titlegap(*6)) ///
	ytitle("Density") yscale(titlegap(*6)) ///
	title("WRDG TFP Comparison Between France and Italy for Sector 29" ///
	"in 2001 and 2008", size(4) margin(b=3)) ///
	note("Data from the EEI cleaned for outliers at the first and last percentiles", margin(b=2))
 
graph export "Graphs/IVd_WRDG_TFP_FR_IT_01_08.png", replace	

}


**# (IV.e) 

use "Datasets/EEI_TH_2022_cleaned_IV.dta", clear

**Year 2001**
foreach k in "Italy" "France" {
	cumul TFP_WRDG_29 if(year == 2001 & country =="`k'"), generate(cum_distr_29_2001_`k')
	gen outcome_pareto29_2001_`k' = ln(1-cum_distr_29_2001_`k')
	
	reg outcome_pareto29_2001_`k' ln_TFP_WRDG_29 if country == "`k'" & year == 2001
	scalar b1_`k'_2001 = - _b[ln_TFP_WRDG_29]
	
	sum TFP_WRDG_29 if country == "`k'" & year==2001
	ksmirnov TFP_WRDG_29 = rpareto(b1_`k'_2001, r(min)) if country == "`k'" & year==2001
}

**Year 2008**
foreach k in "Italy" "France" {
	cumul TFP_WRDG_29 if(year == 2008 & country =="`k'"), generate(cum_distr_29_2008_`k')
	gen outcome_pareto29_2008_`k' = ln(1-cum_distr_29_2008_`k')
	
	reg outcome_pareto29_2008_`k' ln_TFP_WRDG_29 if country == "`k'" & year == 2008
	scalar b1_`k'_2008 = - _b[ln_TFP_WRDG_29]
	
	sum TFP_WRDG_29 if country == "`k'" & year==2008
	ksmirnov TFP_WRDG_29 = rpareto(b1_`k'_2008, r(min)) if country == "`k'" & year==2008
}

foreach k in "Italy" "France" {

preserve 
keep if year == 2001 | year == 2008

ksmirnov TFP_WRDG_29 if country== "`k'", by(year)

restore
}
