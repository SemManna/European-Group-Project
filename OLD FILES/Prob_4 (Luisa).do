use "/Users/filippo.bucchi/Documents/GitHub/European-Group-Project/European-Group-Project/Data/EEI_TH_2022_NoNeg.dta", clear

*** Prob 4.a ***
foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
    }
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
predict ln_TFP_OLS_13 if sector==13, residuals 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 
predict ln_TFP_OLS_29 if sector==29, residuals 
gen TFP_OLS_13= exp(ln_TFP_OLS_13) 
gen TFP_OLS_29= exp(ln_TFP_OLS_29) \\preliminary

** We perform the OLS regression, we obtain residuals and then we can plot:**

kdensity TFP_OLS_13 
kdensity TFP_OLS_29

** Both distributions do not follow a desirable pattern, we would like to work with a Pareto parametrisation and in both distribution the plot evidences the possibility of outliers in the right tail. Thus, we inquire the percentiles distribution of both TFPs. **

sum TFP_OLS_13, d

/*                          TFP_OLS_13
\\-------------------------------------------------------------
\\      Percentiles      Smallest
\\ 1%     .1036084       .0004825
\\ 5%     .3202016       .0005332
\\10%     .4456787       .0005724       Obs             112,713
\\25%     .6738467       .0006932       Sum of wgt.     112,713
\\
\\50%     1.000344                      Mean           1.324488
\\                       Largest       	Std. dev.      2.082985
\\75%     1.522312       125.9585
\\90%     2.407329       168.2916       Variance       4.338826
\\95%     3.278888       235.4233       Skewness       93.46053
\\99%     6.054921       417.7288       Kurtosis        16138.1

** We can note that, at the 95% of the distribution the correspondent value il 327% larger than the median TFP and according to the distribution of previous values it seems to be a reasonable value. We cannot affirm the same for the value of the 99th percentile. It can be observed a huge jump to 605% of the median TFP. Moreover, the largest value of TFP in 99th (417.728) is plenty larger than the same in 95th (235.423).
**After these considerations we can assume the presence of outliers in TFP_OLS_13 distribution.
**Hence, if we restrict the range to 1st-99th percentiles we expect obviously a reduction in standard deviation and also a decrease of TFP mean.*/

sum TFP_OLS_29, d
/*                        TFP_OLS_29
\\-------------------------------------------------------------
\\      Percentiles      Smallest
\\ 1%     .1284372        .000362
\\ 5%     .3884693       .0003756
\\10%     .5214484       .0006692       Obs              49,104
\\25%     .7321793       .0016536       Sum of wgt.      49,104
\\
\\50%     .9974564                      Mean           1.482609
\\                        Largest       Std. dev.       15.8569
\\75%     1.399009       1285.042
\\90%     2.007187       1324.667       Variance       251.4411
\\95%     2.639879       1326.496       Skewness        75.5358
\\99%     5.683885       1336.535       Kurtosis       5892.526


**Also in this case the observe that the perceptual increase in TFP of the 99th is sensibly larger than the analogous value in the 95th percentile (568% vs 263%).  Anyway, we can also note the absolute values of the considered percentiles are not so different.
**Consequently, we can assume the presence of outliers, we expect obviously a reduction in standard deviation and also a decrease of TFP mean.*/


** Data cleaning**
sum TFP_OLS_13, d
replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p1),r(p99)) 
sum TFP_OLS_13, d
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

kdensity TFP_OLS_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_13_t, replace)

kdensity TFP_OLS_29, lw(medthick) lcolor(red) ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_29_t, replace)


gen ln_TFP_OLS_13_t=ln(TFP_OLS_13) 
gen ln_TFP_OLS_29_t=ln(TFP_OLS_29)

tw kdensity ln_TFP_OLS_13_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry" " ") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_13_t, replace)

tw kdensity ln_TFP_OLS_29_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values")xtitle("Log of the TFP") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 29 - Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_29_t, replace)

graph combine ln_TFP_OLS_13_t.gph ln_TFP_OLS_29_t.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))

*sovrapporre i grafici dei due sectors in un unico: plottare overall mean + sect 13 + sect 29 (grafico slide 49 "Productivity & Markup")

/*Comment:
Expect graph of lnTFP13 has tails that are above the tails of lnTFP29, signalling higher productivity values for the Textile sector 
as compared to the Motor sector. Indeed, the summary statics of the TFP estimated from the sample cleaned for extreme values does show
a higher overall mean value for sector 13 (1.24 vs 1.16). Interestingly, this reverses what has been noted previously when computing the TFP
on the initial sample, which yielded an average TFP of 1.48 for sector 29 vs 1.32 for sector 13.*/


graph export "Graphs/combined_kdensity_Log_TFP_OLS.png", replace


//Compare LevPet & WRDRG
//LEVPET
*Sector 13
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_13 if sector==13, omega    //Levpet predicts exponential values
sum TFP_LP_13, d
gen ln_TFP_LP_13=ln(TFP_LP_13).   //generates log values
sum ln_TFP_LP_13, d					
/*check extreme values => no need to clean! makes sense bc supposedly using dataset previosly cleaned!*/
kdensity ln_TFP_LP_13        //not bad

/*replace ln_TFP_LP_13=. if !inrange(ln_TFP_LP_13, r(p1),r(p99)) 
sum ln_TFP_LP_13, d
kdensity ln_TFP_LP_13       useless */ 

*Sector 29
xi: levpet ln_real_VA if sector==29, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_29 if sector==29, omega
sum TFP_LP_29, d
gen ln_TFP_LP_29=ln(TFP_LP_29)
sum ln_TFP_LP_29, d				
kdensity ln_TFP_LP_29        //not bad        

/*replace ln_TFP_LP_29=. if !inrange(ln_TFP_LP_29, r(p1),r(p99))  
sum ln_TFP_LP_29, d
kdensity ln_TFP_LP_29     useless */ 

tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity TFP_LP_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) title("LevPet-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_LP_13, replace)

*** problems with the plotting the tw densities: the range of values of ln_TFP and TFP are too different to be plotted together
//Plot instead the logarithms of both sectors together:

tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)


//graph combine ln_TFP_LP_13.gph ln_TFP_LP_29.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))



***problems with tw kdensity plot; but desirable results in sum (...), d *** 

//WRDG
*Sector 13
xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13, resid
sum ln_TFP_WRDG_13, d
kdensity ln_TFP_WRDG_13

g TFP_WRDG_13=exp(ln_TFP_WRDG_13)      //fa molto schifo, ma va fatta l'esponenziale...? Sec me no (Luisa)
sum TFP_WRDG_13, d
kdensity TFP_WRDG_13

*Sector 29
xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29, resid
sum ln_TFP_WRDG_29, d
g TFP_WRDG_13=exp(ln_TFP_WRDG_13)
sum TFP_WRDG_13, d
kdensity TFP_WRDG_13

tw kdensity ln_TFP_WRDG_13, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry" " ") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_WRDG_13, replace)

tw kdensity ln_TFP_WRDG_29, lw(medthick) lcolor(blue) || kdensity TFP_WRDG_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values")xtitle("Log of the TFP") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 29 - Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_WRDG_29, replace)

graph combine ln_TFP_WRDG_13.gph ln_TFP_WRDG_29.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))


tw kdensity ln_TFP_LP_13 || kdensity ln_TFP_WRDG_13|| kdensity ln_TFP_OLS_13
tw kdensity ln_TFP_LP_29 || kdensity ln_TFP_WRDG_29|| kdensity ln_TFP_OLS_29


***problems with tw kdensity plot; but desirable results in sum (...), d *** 

*** Prob 4.b ***
Plot the TFP distribution for each country

//OLS
**IT
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "Italy"
predict ln_TFP_OLS_IT if country == "Italy", residuals 

gen TFP_OLS_IT= exp(ln_TFP_OLS_IT) 
kdensity TFP_OLS_IT 
sum TFP_OLS_IT, d
replace TFP_OLS_IT=. if !inrange(TFP_OLS_IT,r(p5),r(p99)) 
kdensity TFP_OLS_IT
gen ln_TFP_OLS_IT_t=ln(TFP_OLS_IT) 
kdensity ln_TFP_OLS_IT_t 

**FR
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "France"
predict ln_TFP_OLS_FR if country == "France", residuals 

gen TFP_OLS_FR= exp(ln_TFP_OLS_FR) 
kdensity TFP_OLS_FR 
sum TFP_OLS_FR, d
replace TFP_OLS_FR=. if !inrange(TFP_OLS_FR,r(p5),r(p99)) 
kdensity TFP_OLS_FR
gen ln_TFP_OLS_FR_t=ln(TFP_OLS_FR) 
kdensity ln_TFP_OLS_FR_t 

**SP
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "Spain"
predict ln_TFP_OLS_SP if country == "Spain", residuals 

gen TFP_OLS_SP= exp(ln_TFP_OLS_SP) 
kdensity TFP_OLS_SP 
sum TFP_OLS_SP, d
replace TFP_OLS_SP=. if !inrange(TFP_OLS_SP,r(p5),r(p99)) 
kdensity TFP_OLS_SP
gen ln_TFP_OLS_SP_t=ln(TFP_OLS_SP) 
kdensity ln_TFP_OLS_SP_t 

//LevPet
**IT
xi: levpet ln_real_VA if country == "Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_IT if country == "Italy", omega
gen TFP_LP_IT=exp(ln_TFP_LP_IT)
sum TFP_LP_IT, d				
replace TFP_LP_IT=. if !inrange(TFP_LP_IT, r(p1),r(p99))
sum TFP_LP_IT, d
kdensity TFP_LP_IT

g ln_TFP_LP_IT_t=ln(TFP_LP_IT)
kdensity ln_TFP_LP_IT_t

**FR
xi: levpet ln_real_VA if country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_FR if country == "France", omega
gen TFP_LP_FR=exp(ln_TFP_LP_FR)
sum TFP_LP_FR, d				
replace TFP_LP_FR=. if !inrange(TFP_LP_FR, r(p1),r(p99))
sum TFP_LP_FR, d
kdensity TFP_LP_FR

g ln_TFP_LP_IT_t=ln(TFP_LP_IT)
kdensity ln_TFP_LP_IT_t

**SP
xi: levpet ln_real_VA if country == "Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_SP if country == "Spain", omega
gen TFP_LP_SP=exp(ln_TFP_LP_SP)
sum TFP_LP_SP, d				
replace TFP_LP_SP=. if !inrange(TFP_LP_SP, r(p1),r(p99))
sum TFP_LP_SP, d
kdensity TFP_LP_SP

g ln_TFP_LP_SP_t=ln(TFP_LP_SP)
kdensity ln_TFP_LP_SP_t



//Wooldridge
**IT
xi: prodest ln_real_VA if country == "Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_IT, resid
sum ln_TFP_WRDG_IT, d

g ln_TFP_WRDG_IT_t=ln(TFP_WRDG_IT)
kdensity ln_TFP_WRDG_IT_t

**FR
xi: levpet ln_real_VA if country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_FR if country == "France", omega
gen TFP_LP_FR=exp(ln_TFP_LP_FR)
sum TFP_LP_FR, d				
replace TFP_LP_FR=. if !inrange(TFP_LP_FR, r(p1),r(p99))
sum TFP_LP_FR, d
kdensity TFP_LP_FR

g ln_TFP_LP_IT_t=ln(TFP_LP_IT)
kdensity ln_TFP_LP_IT_t

**SP
xi: levpet ln_real_VA if country == "Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict ln_TFP_LP_SP if country == "Spain", omega
gen TFP_LP_SP=exp(ln_TFP_LP_SP)
sum TFP_LP_SP, d				
replace TFP_LP_SP=. if !inrange(TFP_LP_SP, r(p1),r(p99))
sum TFP_LP_SP, d
kdensity TFP_LP_SP

g ln_TFP_LP_SP_t=ln(TFP_LP_SP)
kdensity ln_TFP_LP_SP_t
