clear all

/*use Productivity_TH1_2017_master, clear

//panel data on firms with data relevant for our trade models
set more off, perm

keep if country=="ITA" | country=="GER" | country=="FRA"

rename d4 exp_intensity
rename operatingrevenueturnovertheu TO
rename totalassetstheur K //proxy for nominal capital
rename materialcoststheur M
rename employees L
rename costsofemployeestheur W
rename salestheur sales 
rename Exporter exporter
rename sec sector

*dataset may have mistakes, such as negative labour, we may want to clean for those
*** cleaning negative values

foreach var in K M L W sales TO {
        drop if  `var'<=0

		}
 *we could have replaced the missing value alone, but doing this we are erasing the whole observation, the whole line, not just correcting the information. This because in any way if one of those is missing we cannot calculate productivity as we defined it and so we might as well drop it

*** deflated variables
*fixing nominal variables 

gen VA=sales-M
gen real_K=(K/gdp_defl)*100
gen real_M=(M/ppi)*100
gen real_sales=(sales/ppi)*100
gen real_VA=(VA/ppi)*100

keep year country sector mark K real_K M real_M L W sales real_sales real_VA VA exporter FDI  exp_intensity

keep if country=="ITA" 

save STATA_Tutorial.dta, replace
save12 STATA_Tutorial_Stata12.dta
*/
*NOTE: THIS IS THE FILE SHARED ON BLACKBOARD

log using tutorial_2022
set scheme s1color

use STATA_Tutorial.dta, replace

*create logarithms 

*gen ln_real_sales=ln(real_sales)
*gen ln_real_M=ln(real_M)
*gen ln_real_K=ln(real_K)
*gen ln_L=ln(L)
*gen ln_real_VA=ln(real_VA)

*OR

foreach var in real_sales real_M real_K L real_VA {
        gen ln_`var'=ln(`var')
        }

	
***OLS REGRESSION - VALUE ADDED
*productivity may vary across industries, so we may want to run regressions within those, but there is a tradeoff between efficiency and ???
*note, we are working with panel data!

*sector 24 (Chemicals)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==24
*xi tells stata that we have fixed effects, must put it before every estimation if we want dummies for fixed effects
predict ln_TFP_OLS_24, residuals 
//postestimation command to get the vector of residuals of the previous regression - naming a vector: residual of a cobb douglas production function so it's a TFP, this is OLS and sector is 24


gen TFP_OLS_24= exp(ln_TFP_OLS_24) 

kdensity TFP_OLS_24
//right tail is very long, some obs has 100x the mean.. outliers
//also 'zombie firms' at the bottom, since we want to study mostly the dynamic for more productive firms, we do not want out estimates to be too driven by those
sum TFP_OLS_24, d
replace TFP_OLS_24=. if !inrange(TFP_OLS_24,r(p5),r(p99))
//if the value is outside the bottom 5 percent or above the 99, we replace the value with a missing value
sum TFP_OLS_24, d
kdensity TFP_OLS_24


sum ln_TFP_OLS_24, d
replace ln_TFP_OLS_24=. if !inrange(ln_TFP_OLS_24,r(p5),r(p99))
kdensity ln_TFP_OLS_24
//work with logs, whose distributions look more like a normal, better for OLS as we have less outliers 

*** LEVINSOHN-PETRIN - VALUE ADDED

//simultaneity bias, all data is recorded as the end of the year BUT if we had a shock mid-year, say apositive one leading to increase the number of workers, then we have a bias estimation, input correlated with the error term, violating OLS assumptions
*to solve:
**fixed effect (but we 'throw away' loads of free data and have identification issues). Moreover, by definition FTP is not fixed over time

/*
we decompose the errore term in an iid part and in one which we want 

look at equation on handnotes

*/
***INSTALL PACKAGE FIRST! (search levpet => install package st0060)

*search levpet
xi: levpet ln_real_VA if sector==24, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_24, omega

sum TFP_LP_24, d
replace TFP_LP_24=. if !inrange(TFP_LP_24, r(p1),r(p99))

sum TFP_LP_24, d
kdensity TFP_LP_24

g ln_TFP_LP_24=ln(TFP_LP_24)
kdensity ln_TFP_LP_24

*** PRODEST - VALUE ADDED *alternative methods 

***INSTALL PACKAGE FIRST! (search prodest => install package prodest)


xi: prodest ln_real_VA if sector==24, met(lp) free(ln_L i.year) proxy(ln_real_M) state(ln_real_K) va acf
*i.year accounts for fixed effects
*acf correction that labour is not freely adjustable but there are frictions

predict ln_TFP_LP_ACF_24, resid

xi: prodest ln_real_VA if sector==24, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va

predict ln_TFP_WRDG_24, resid


***let's compare all those productivity estimators!***
tw kdensity ln_TFP_LP_24 || kdensity ln_TFP_LP_ACF_24 || kdensity ln_TFP_WRDG_24 ||kdensity ln_TFP_OLS_24

**which one to use? depends on research quesition
*to compare relative position of firms, it does not matter, distributions have the same shape, are mostly just shaped

*graph and notes on handnotes

*** Export/FDI premium

*combine 3 graphs for 3 sets of firms! based on exporting and domestic or multinational
twoway (kdensity ln_TFP_LP_24 if exporter==1 & FDI==1, lw(medthick) lcolor(green)) ///
|| (kdensity ln_TFP_LP_24 if exporter==1 & FDI==0,lw(medthin) lcolor(sienna)) ///
|| (kdensity ln_TFP_LP_24 if exporter==0 & FDI==0, lw(medthin) lcolor(blue) lp(dash)), ///
title("Productivity distributions by export status") legend(label(1 "exporters & FDI ") label(2 "exporters only ") label(3 "domestic only "))

*graphic intuition is clear, but we want to show significance throgh a regressino
g export_status=.
replace export_status=0 if exporter==0 & FDI==0
replace export_status=1 if exporter==1 & FDI==0
replace export_status=2 if exporter==1 & FDI==1  


xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust
*robust needed, control group; no FDI 
xi: reg ln_TFP_LP_24 FDI i.year i.sector, robust

xi: reg ln_TFP_LP_24 exporter i.sector if year==2008 & export_status==0 | year==2008 & export_status==1, robust

xi: reg ln_TFP_LP_24 FDI i.sector if year==2008, robust

*Now I produce a nice table in Excel

***INSTALL PACKAGE FIRST! (search outreg2 => install package outreg2)

xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust
outreg2 using Exporter.xls, append title("Export premium") ctitle("export") addtext(year FE, YES, sector FE, YES) 

*Now I produce an even nicer table in Excel...
xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust
outreg2 using Exporter.xls, replace title("Export premium") ctitle("export") addtext(year FE, YES, sector FE, YES) drop (_Isector_* _Iyear*)

log close

*****Non-Parametric Markup

gen PCM=(sales-W-M)/sales
sum PCM,de
replace PCM=. if !inrange(PCM,r(p1),r(p99))
kdensity PCM
