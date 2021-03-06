**CHANGES IN TFP between LEVPET, LEVPET+replace, WRDG**

ssc install vioplot, replace
ssc install prodest, replace
ssc install outreg2, replace
use EEI_TH_2022.dta, clear
foreach var in L sales M W K {
        replace `var'=. if  `var'<0
        }
preserve
foreach var in real_sales real_M real_K L real_VA {
    gen ln_`var'=ln(`var')
 }
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==13 
predict ln_TFP_OLS_13 if sector==13, residuals 
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==29 
predict ln_TFP_OLS_29 if sector==29, residuals 
gen TFP_OLS_13= exp(ln_TFP_OLS_13) 
gen TFP_OLS_29= exp(ln_TFP_OLS_29) 
kdensity TFP_OLS_13 
kdensity TFP_OLS_29 \\ preliminary operations
sum TFP_OLS_13, d
replace TFP_OLS_13=. if !inrange(TFP_OLS_13,r(p1),r(p99)) \\ here outliers replace for sector == 13
sum TFP_OLS_29, d
replace TFP_OLS_29=. if !inrange(TFP_OLS_29,r(p1),r(p99)) \\ here outliers replace for sector == 29
save EEI_TH_2022_cleaned_IV.dta
use EEI_TH_2022_cleaned_IV.dta, clear
kdensity TFP_OLS_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_13_t, replace)

kdensity TFP_OLS_29, lw(medthick) lcolor(red) ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_29_t, replace)
** here we can check if the replace worked, it works**

** We start with LEVPET*
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_13 if sector==13, omega \\ now we perform LP
sum TFP_LP_13
**     Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
**   TFP_LP_13 |    161,817    170.1148    886.9073   .0541704   159793.9    **
sum TFP_LP_13, d
kdensity TFP_LP_13 \\ not satisfying but improves with logs

g ln_TFP_LP_13=ln(TFP_LP_13)
sum ln_TFP_LP_13

kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("LP--Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(ln_TFP_LP_13_13, replace) 
**we plot ln_TFP_LP_13 and we obtain the desired distribution**

** What happens if WE CLEAN TWICE?**
preserve
sum TFP_LP_13, d											
replace TFP_LP_13=. if !inrange(TFP_LP_13, r(p1),r(p99)) \\ (3,236 real changes made, 3,236 to missing)

sum TFP_LP_13
** 
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
**  TFP_LP_13 |    158,581    153.2647    128.7298   8.050853   824.0478 **

** 3000 observations less, much less variance (not surprisingly), decrease of the mean**

sum TFP_LP_13, d
kdensity TFP_LP_13 \\ nice distribution

g ln_TFP_LP_13=ln(TFP_LP_13)
kdensity ln_TFP_LP_13 \\ very similar to that one before second replace \\ no significant difference in distribution plot

** Now we focus on PRODEST (LP) **
use EEI_TH_2022_cleaned_IV.dta, clear
xi: prodest ln_real_VA if sector==13, met(lp) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_PRLP_13 if sector==13, resid

kdensity ln_TFP_PRLP_13 \\ same distribution as in LEVPET

gen TFP_PRLP_13 = exp(ln_TFP_PRLP_13)
sum TFP_PRLP_13, d
sum TFP_PRLP_13

 **   Variable |        Obs        Mean    Std. dev.       Min        Max 
-------------+---------------------------------------------------------
** TFP_PRLP_13 |    112,713    166.7079    304.2271   .0749899   77979.49 **

** Many less observations than in LEVPET, mean consistent with previous results*

** WRDG **
use EEI_TH_2022_cleaned_IV.dta, clear
xi: prodest ln_real_VA if sector==13, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_13 if sector==13, resid

kdensity ln_TFP_WRDG_13 \\ same distribution as in LEVPET and prodest (lp)

gen TFP_WRDG_13 = exp(ln_TFP_WRDG_13)
sum TFP_WRDG_13, d
sum TFP_WRDG_13

**    Variable |        Obs        Mean    Std. dev.       Min        Max **
-------------+---------------------------------------------------------
** TFP_WRDG_13 |    112,713    171.1621    347.8529   .0722549   93870.88 **

