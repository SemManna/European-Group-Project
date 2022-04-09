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


*** Prob 4.b ***



