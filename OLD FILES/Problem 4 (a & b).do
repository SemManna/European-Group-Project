use "/Users/filippo.bucchi/Documents/GitHub/European-Group-Project/European-Group-Project/Data/EEI_TH_2022_NoNeg.dta", clear

use EEI_TH_2022_NoNeg, clear

*** Prob 4.a ***
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

** We can note that, at the 95% of the distribution the correspondent value is 327% larger than the median TFP and according to the distribution of previous values it seems to be a reasonable value. We cannot affirm the same for the value of the 99th percentile. It can be observed a huge jump to 605% of the median TFP. Moreover, the largest value of TFP in 99th (417.728) is much larger than the same in 95th (235.423).
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

kdensity TFP_OLS_13, lw(medthick) lcolor(blue) ytitle("Density") ytitle("Values") yscale(range(0,1) titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Textile Industry" " ") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_13_t, replace)

kdensity TFP_OLS_29, lw(medthick) lcolor(red) ytitle("Density") ytitle("Values") xscale(titlegap(*5)) yscale(titlegap(*10)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "Log of the TFP") label(2 "TFP")) saving(TFP_OLS_29_t, replace)


gen ln_TFP_OLS_13_t=ln(TFP_OLS_13) 
gen ln_TFP_OLS_29_t=ln(TFP_OLS_29)

tw kdensity ln_TFP_OLS_13_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_13, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,1) titlegap(*3)) xscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 13 - Textile Industry" " ") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_13_t, replace)  //Qui forse il titolo dell'asse delle x è sbagliato? Metterei "TFP and Log(TFP)"

tw kdensity ln_TFP_OLS_29_t, lw(medthick) lcolor(blue) || kdensity TFP_OLS_29, lw(medthick) lcolor(red) , ytitle("Density") ytitle("Density Values")xtitle("Log of the TFP") xscale(titlegap(*5)) yscale(titlegap(*3)) title("OLS-Computed TFP ", margin(b=3)) subtitle("Sector 29 - Motor Vehicles, Trailers and" "Semi-trailers Industry") legend(label(1 "logTFP") label(2 "TFP")) saving(ln_TFP_OLS_29_t, replace)

graph combine ln_TFP_OLS_13_t.gph ln_TFP_OLS_29_t.gph , note("Data from the EEI, univariate kernel density estimates" , margin(b=2))

*sovrapporre i grafici dei due sectors in un unico: plottare overall mean + sect 13 + sect 29 (grafico slide 49 "Productivity & Markup")

/*Comment:
Expect graph of lnTFP13 has tails that are above the tails of lnTFP29, signalling higher productivity values for the Textile sector as compared to the Motor sector. Indeed, the summary statics of the TFP estimated from the sample cleaned for extreme values does show a higher overall mean value for sector 13 (1.24 vs 1.16). Interestingly, this reverses what has been noted previously when computing the TFP on the initial sample, which yielded an average TFP of 1.48 for sector 29 vs 1.32 for sector 13. (Commento Ale aggiunta: [...] This would point out to the fact that productivity in the Motor sector was mainly driven by firms at the extremes of the right tail, which have been cleaned for above)*/


graph export "Graphs/combined_kdensity_Log_TFP_OLS.png", replace
//Ale --> Error: could not find Graph window ?? //devi girare il comando prima di chiudere la finestra del grafico


//Compare LevPet & WRDRG
//LEVPET
*Sector 13
xi: levpet ln_real_VA if sector==13, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_13 if sector==13, omega    //Levpet predicts the coefs, already in exponential values
//why i.year as free? I know he does it too but what's the interpretation here? 
//Luisa: perchè year, insieme a labour, è una variable "free to vary" irrespective delle altre (= indep from materials and capital, obv).

sum TFP_LP_13, d //Again, here there are some outliers we should clean for. But how many?

replace TFP_LP_13=. if !inrange(TFP_LP_13,r(p1),r(p99))	
*3,236 real changes made, 3,236 to missing*

kdensity TFP_LP_13
gen ln_TFP_LP_13=ln(TFP_LP_13)        //generate log values
sum ln_TFP_LP_13, d					
kdensity TFP_LP_13
kdensity ln_TFP_LP_13        //not bad

/*replace ln_TFP_LP_13=. if !inrange(ln_TFP_LP_13, r(p1),r(p99)) 
sum ln_TFP_LP_13, d
kdensity ln_TFP_LP_13       
//we already dropped those for the non-log, trimming again would further reduce the sample
							useless */ 

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
sum ln_TFP_WRDG_13, d
kdensity ln_TFP_WRDG_13

/* g TFP_WRDG_13=exp(ln_TFP_WRDG_13)      //fa molto schifo, ma va fatta l'esponenziale...? Sec me no, a giudicare dal dofile del tutorial (Luisa)
sum TFP_WRDG_13, d */

replace TFP_WRDG_13=. if !inrange(TFP_WRDG_13,r(p1),r(p99))	
//(3,236 real changes made, 3,236 to missing)//

kdensity TFP_WRDG_13
kdensity TFP_OLS_13

*Sector 29
xi: prodest ln_real_VA if sector==29, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_29, resid
sum ln_TFP_WRDG_29, d

g TFP_WRDG_29=exp(ln_TFP_WRDG_29)      //fa molto schifo, ma va fatta l'esponenziale...? Sec me no, a giudicare dal dofile del tutorial (Luisa)
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

*** Prob 4.b: plot the TFP distribution for each country ***

use EEI_TH_2022_cleaned_IV_a.dta, replace


//OLS
**IT
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "Italy"
predict ln_TFP_OLS_IT if country == "Italy", residuals 
sum ln_TFP_OLS_IT, d

gen TFP_OLS_IT= exp(ln_TFP_OLS_IT) 
kdensity TFP_OLS_IT 
sum TFP_OLS_IT, d
replace TFP_OLS_IT=. if !inrange(TFP_OLS_IT,r(p5),r(p99)) 
kdensity TFP_OLS_IT
gen ln_TFP_OLS_IT_t=ln(TFP_OLS_IT) 
sum ln_TFP_OLS_IT_t, d
kdensity ln_TFP_OLS_IT_t 

**FR
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "France"
predict ln_TFP_OLS_FR if country == "France", residuals 
sum ln_TFP_OLS_FR, d

gen TFP_OLS_FR= exp(ln_TFP_OLS_FR) 
kdensity TFP_OLS_FR 
sum TFP_OLS_FR, d
replace TFP_OLS_FR=. if !inrange(TFP_OLS_FR,r(p5),r(p99)) 
kdensity TFP_OLS_FR
gen ln_TFP_OLS_FR_t=ln(TFP_OLS_FR) 
sum ln_TFP_OLS_FR, d
kdensity ln_TFP_OLS_FR_t 

**SP
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if country == "Spain"
predict ln_TFP_OLS_SP if country == "Spain", residuals 
sum ln_TFP_OLS_SP, d

gen TFP_OLS_SP= exp(ln_TFP_OLS_SP) 
kdensity TFP_OLS_SP 
sum TFP_OLS_SP, d
replace TFP_OLS_SP=. if !inrange(TFP_OLS_SP,r(p5),r(p99)) 
kdensity TFP_OLS_SP
gen ln_TFP_OLS_SP_t=ln(TFP_OLS_SP) 
sum ln_TFP_OLS_SP, d
kdensity ln_TFP_OLS_SP_t 

tw kdensity ln_TFP_OLS_IT || kdensity ln_TFP_OLS_SP|| kdensity ln_TFP_OLS_FR


//LevPet
**IT
xi: levpet ln_real_VA if country == "Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_IT if country == "Italy", omega
sum TFP_LP_IT, d
kdensity TFP_LP_IT 
gen ln_TFP_LP_IT=ln(TFP_LP_IT)
sum ln_TFP_LP_IT, d				
kdensity ln_TFP_LP_IT 

**FR
xi: levpet ln_real_VA if country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_FR if country == "France", omega
sum TFP_LP_FR, d
kdensity TFP_LP_FR

gen ln_TFP_LP_FR=ln(TFP_LP_FR)
sum ln_TFP_LP_FR, d				
kdensity ln_TFP_LP_FR


**SP
xi: levpet ln_real_VA if country == "Spain", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_SP if country == "Spain", omega
sum TFP_LP_SP, d
kdensity TFP_LP_SP
gen ln_TFP_LP_SP=ln(TFP_LP_SP)
sum ln_TFP_LP_SP, d				
kdensity ln_TFP_LP_SP

tw kdensity TFP_LP_IT || kdensity TFP_LP_SP|| kdensity TFP_LP_FR   //no rick non si può, usare ln

tw kdensity ln_TFP_LP_IT || kdensity ln_TFP_LP_SP|| kdensity ln_TFP_LP_FR

/*tw kdensity ln_TFP_LP_13, lw(medthick) lcolor(blue) || kdensity ln_TFP_LP_29, lw(medthick) lcolor(green) , ytitle("Density") ytitle("Density Values") xtitle("Log of the TFP") yscale(range(0,0.6) titlegap(*3)) title("LevPet-Computed TFPs", margin(b=3)) subtitle("lnTFP in Sector 13 and Sector 29") legend(label(1 "Sector 13") label(2 "Sector 29")) saving(ln_TFP_LP_13_29_joint, replace)*/


//Wooldridge
**IT
xi: prodest ln_real_VA if country == "Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_IT, resid        //WRDG genera la TFP in log
sum ln_TFP_WRDG_IT, d
kdensity ln_TFP_LP_IT

gen TFP_WRDG_IT = exp(ln_TFP_WRDG_IT)

**FR
xi: prodest ln_real_VA if country == "France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_FR, resid        //WRDG genera la TFP in log
sum ln_TFP_WRDG_FR, d
kdensity ln_TFP_LP_FR

gen TFP_WRDG_FR = exp(ln_TFP_WRDG_FR)


**SP
xi: prodest ln_real_VA if country == "Spain", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_SP, resid        //WRDG genera la TFP in log
sum ln_TFP_WRDG_SP, d
kdensity ln_TFP_LP_SP

gen TFP_WRDG_SP = exp(ln_TFP_WRDG_SP)


tw kdensity TFP_WRDG_IT || kdensity TFP_WRDG_SP|| kdensity TFP_WRDG_FR   //no rick non si può, usare ln
tw kdensity ln_TFP_WRDG_IT || kdensity ln_TFP_WRDG_SP|| kdensity ln_TFP_WRDG_FR

/*Comments:
From plotting the three countries, we can make the following observations:
- Italy appears to be more productive than Spain, under both LevPet and Wooldridge
- Italy appears to be more productive than France under Levpet, but slighlty less
productive (4.822 vs 4.837) under Wooldridge.
- French TFP appears closer to Italian TFP under Wooldridge, while closer to Spain 
under Levpet.
(Other comments?)
*/

*** Prob 4.c: plot the TFP distribution for Italy_29 and France_29 2001vs2008; compare LP and WRDG ***

***!!!I just want to add that levpet works with panel data. As you may know, you need to have observations for the study subject, a firm for example, at least in two years (or points in time). Then, before running the command you should use the xtset command or specify i() t().Nevertheless, I experienced that after checking that variables are numeric, the behavior of missing values and declaring the panel data, among others, the message "r(2000) no observations" kept appearing. What worked for me is to have consecutive years in the variable that sets the time for the panel data (xtset panelid year). My "year" variable was 2003 and 2009. When I changed this to consecutive values, for example, 1 and 2, the program worked. I wanted to share this just in case. If you can, please let us know if it works or how you solved the problem.***

**LEVPET-FR**
use EEI_TH_2022_cleaned_IV.dta,clear
xi: levpet ln_real_VA if sector==29 & country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_FR_29 if sector==29 & country == "France", omega
gen ln_TFP_LP_FR_29=ln(TFP_LP_FR_29)
sum TFP_LP_FR_29 if year==2001
sum TFP_LP_FR_29 if year==2001, d
kdensity ln_TFP_LP_FR_29 if year==2001 

sum TFP_LP_FR_29 if year==2008
sum TFP_LP_FR_29 if year==2008, d
kdensity ln_TFP_LP_FR_29 if year==2008 // We perform levpet procedure for France and sec.29, then we mantain only year==2001 or year==2008

**LEVPET-IT**

use EEI_TH_2022_cleaned_IV.dta,clear
xi: levpet ln_real_VA if sector==29 & country == "Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_IT_29 if sector==29 & country == "Italy", omega
gen ln_TFP_LP_IT_29=ln(TFP_LP_IT_29)
sum TFP_LP_IT_29 if year==2001
sum TFP_LP_IT_29 if year==2001, d
kdensity ln_TFP_LP_IT_29 if year==2001 

sum TFP_LP_IT_29 if year==2008
sum TFP_LP_IT_29 if year==2008, d
kdensity ln_TFP_LP_IT_29 if year==2008 // We perform levpet procedure for Italy and sec.29, then we mantain only year==2001 or year==2008

**WRDG-FR**

xi: prodest ln_real_VA if sector==29 & country == "France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_FR_29, resid        //WRDG genera la TFP in log
sum ln_TFP_WRDG_FR_29 if year==2001
sum ln_TFP_WRDG_FR_29 if year==2001, d
kdensity ln_TFP_WRDG_FR_29 if year==2001

sum ln_TFP_WRDG_FR_29 if year==2008
sum ln_TFP_WRDG_FR_29 if year==2008, d
kdensity ln_TFP_WRDG_FR_29 if year==2008

**WRDG-IT**

xi: prodest ln_real_VA if sector==29 & country == "Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_IT_29, resid        //WRDG genera la TFP in log
sum ln_TFP_WRDG_IT_29 if year==2001
sum ln_TFP_WRDG_IT_29 if year==2001, d
kdensity ln_TFP_WRDG_IT_29 if year==2001

sum ln_TFP_WRDG_IT_29 if year==2008
sum ln_TFP_WRDG_IT_29 if year==2008, d
kdensity ln_TFP_WRDG_IT_29 if year==2008

**PLOTS**

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

*** 4.c: alternative procedure with LEVPET cleaning***

**LEVPET-FR**
use EEI_TH_2022_cleaned_IV.dta,clear
xi: levpet ln_real_VA if sector==29 & country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_FR_29 if sector==29 & country == "France", omega
sum TFP_LP_FR_29 if year==2001
sum TFP_LP_FR_29 if year==2001, d 
kdensity TFP_LP_FR_29 if year==2001 // not a suitable distirbutions hence we try at least to clean for outliers

sum TFP_LP_FR_29 if year==2008
sum TFP_LP_FR_29 if year==2008, d 
kdensity TFP_LP_FR_29 if year==2008// high concentrated pareto distribution, outliers seem to be absent from graph but sum ..., d suggest them

sum TFP_LP_FR_29, d 
replace TFP_LP_FR_29=. if !inrange(TFP_LP_FR_29,r(p5),r(p99)) // is it right to clean without if year=... ???

kdensity TFP_LP_FR_29 if year==2001
kdensity TFP_LP_FR_29 if year==2008 // We perform levpet procedure for France and sec.29, then we mantain only year==2001 or year==2008

// Cleaning for outliers (which seem to be present from sum ..., d) we obtain suitble TFP without the need to rely on ln_TFP

**LEVPET-IT**

xi: levpet ln_real_VA if sector==29 & country == "Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_IT_29 if sector==29 & country == "Italy", omega
sum TFP_LP_IT_29 if year==2001
sum TFP_LP_IT_29 if year==2001, d 
kdensity TFP_LP_IT_29 if year==2001 // not a suitable distirbutions hence we try at least to clean for outliers

sum TFP_LP_IT_29 if year==2008
sum TFP_LP_IT_29 if year==2008, d 
kdensity TFP_LP_IT_29 if year==2008// not a suitable distirbutions hence we try at least to clean for outliers

sum TFP_LP_IT_29, d 
replace TFP_LP_IT_29=. if !inrange(TFP_LP_IT_29,r(p5),r(p99)) // is it correctrect to clean without if year=... ???, is it correct to clean one more time also for ITALY?? (I suppose yes since the previous clean should involve only French TFP)

kdensity TFP_LP_IT_29 if year==2001
kdensity TFP_LP_IT_29 if year==2008 // We perform levpet procedure for Italy and sec.29, then we mantain only year==2001 or year==2008

// Cleaning for outliers (which seem to be present from sum ..., d) we obtain suitble TFP without the need to rely on ln_TFP
// Note: both predict generate 161,817 obs and then both replace drop 9708

*** 4.c: alternative procedure with LEVPET cleaning by year***

***LEVPET-FR**
use EEI_TH_2022_cleaned_IV.dta,clear
xi: levpet ln_real_VA if sector==29 & country == "France", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_FR_29 if sector==29 & country == "France", omega
sum TFP_LP_FR_29 if year==2001
sum TFP_LP_FR_29 if year==2001, d 
kdensity TFP_LP_FR_29 if year==2001 // not a suitable distirbutions hence we try at least to clean for outliers

sum TFP_LP_FR_29 if year==2008
sum TFP_LP_FR_29 if year==2008, d 
kdensity TFP_LP_FR_29 if year==2008// high concentrated pareto distribution, outliers seem to be absent from graph but sum ..., d suggest them

sum TFP_LP_FR_29, d 
replace TFP_LP_FR_29=. if !inrange(TFP_LP_FR_29,r(p5),r(p99)) &  year==2001 // 413 real changes made
sum TFP_LP_FR_29, d 
replace TFP_LP_FR_29=. if !inrange(TFP_LP_FR_29,r(p5),r(p99)) &  year==2008 // 611 real changes made

kdensity TFP_LP_FR_29 if year==2001
kdensity TFP_LP_FR_29 if year==2008 // We perform levpet procedure for France and sec.29, then we mantain only year==2001 or year==2008
//Same procedure but adding if year=... in replace leads to less data reduction

***LEVPET-IT**
xi: levpet ln_real_VA if sector==29 & country == "Italy", free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_IT_29 if sector==29 & country == "Italy", omega
sum TFP_LP_IT_29 if year==2001
sum TFP_LP_IT_29 if year==2001, d 
kdensity TFP_LP_IT_29 if year==2001 // not a suitable distirbutions hence we try at least to clean for outliers

sum TFP_LP_IT_29 if year==2008
sum TFP_LP_IT_29 if year==2008, d 
kdensity TFP_LP_IT_29 if year==2008// high concentrated pareto distribution, outliers seem to be absent from graph but sum ..., d suggest them

sum TFP_LP_IT_29, d 
replace TFP_LP_IT_29=. if !inrange(TFP_LP_FR_29,r(p5),r(p99)) &  year==2001 // 521 real changes made
sum TFP_LP_IT_29 if year==2008, d 
replace TFP_LP_IT_29=. if !inrange(TFP_LP_FR_29,r(p5),r(p99)) &  year==2008 // 653 real changes made

kdensity TFP_LP_IT_29 if year==2001
kdensity TFP_LP_IT_29 if year==2008 // We perform levpet procedure for Italy and sec.29, then we mantain only year==2001 or year==2008
//Same procedure but adding if year=... in replace leads to less data reduction; we continue on WRDG preferring this specific cleanin data

**WRDG-FR (focus on TFP)**

xi: prodest ln_real_VA if sector==29 & country == "France", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_FR_29, resid        //WRDG genera la TFP in log
gen TFP_WRDG_FR_29=exp(ln_TFP_WRDG_FR_29)
sum TFP_WRDG_FR_29 if year==2001
sum TFP_WRDG_FR_29 if year==2001, d
kdensity TFP_WRDG_FR_29 if year==2001

sum TFP_WRDG_FR_29 if year==2008
sum TFP_WRDG_FR_29 if year==2008, d
kdensity TFP_WRDG_FR_29 if year==2008
//We obtain perfectly same densities that we observed in Levpet before replacing; the previous replace involved the LP obtained TFP, so now we clean involving the WRDG obtained TFP

sum TFP_WRDG_FR_29, d 
replace TFP_WRDG_FR_29=. if !inrange(TFP_WRDG_FR_29,r(p5),r(p99)) &  year==2001 // 475 real changes made
sum TFP_WRDG_FR_29, d 
replace TFP_WRDG_FR_29=. if !inrange(TFP_WRDG_FR_29,r(p5),r(p99)) &  year==2008 // 565 real changes made

kdensity TFP_WRDG_FR_29 if year==2001
kdensity TFP_WRDG_FR_29 if year==2008 
//As we expected

**WRDG-IT (focus on TFP)**

xi: prodest ln_real_VA if sector==29 & country == "Italy", met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va
predict ln_TFP_WRDG_IT_29, resid        //WRDG genera la TFP in log
gen TFP_WRDG_IT_29=exp(ln_TFP_WRDG_IT_29)
sum TFP_WRDG_IT_29 if year==2001
sum TFP_WRDG_IT_29 if year==2001, d
kdensity TFP_WRDG_IT_29 if year==2001

sum TFP_WRDG_IT_29 if year==2008
sum TFP_WRDG_IT_29 if year==2008, d
kdensity TFP_WRDG_IT_29 if year==2008
//We obtain perfectly same densities that we observed in Levpet before replacing; the previous replace involved the LP obtained TFP, so now we clean involving the WRDG obtained TFP

sum TFP_WRDG_IT_29, d 
replace TFP_WRDG_IT_29=. if !inrange(TFP_WRDG_IT_29,r(p5),r(p99)) &  year==2001 // 499 real changes made
sum TFP_WRDG_IT_29, d 
replace TFP_WRDG_IT_29=. if !inrange(TFP_WRDG_IT_29,r(p5),r(p99)) &  year==2008 // 555 real changes made

kdensity TFP_WRDG_IT_29 if year==2001
kdensity TFP_WRDG_IT_29 if year==2008 
// As we expected

***Comments:
//Ha senso cleannare anche in WRDG perchè la pulizia precedente era fatta solo sulle prediction di TFP_FP 
//Quanto più restringiamo l'osservazione, cioè ciò che accade nel punto 4c, tanto meglio sarebbe avere una rimozione degli outliers specifica per i dati che stiamo trattando (infatti siamo sicuri che la pulizia "generale" includa anche gli outliers del 2001 e 2008? potrebbero essere valori grandi ma meno grandi di altre osservazioni in altri anni). Potrebbe quindi avere senso al punto 4.c recuperare il data set cleannato degli OLS (quindi il canonico EEI_TH_2022_cleaned_IV) e poi fare i replace che vedi nel mio do. Così abbiamo meno data reduction; l'unica pecca è che i commenti che facciamo potrebbero essere meno consistenti per i punti precedenti (visto che stiamo cleannando in due modi diversi) ma è anche vero che le conclusioni che ci chiede al punto 4c sembrano piuttosto svincolate da quell che ci chiede nei punti precedenti.

**PLOTS** 

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
