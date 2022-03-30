clear all

cd "C:\Users\Altomonte\Dropbox\Didattica\EEI\Course 2018\TH1

*Use dataset in my desktop use "C:\Users\pulvi\Desktop\European Stata Tutorial\STATA_Tutorial.dta"*

use Productivity_TH1_2017_master, clear

set more off, perm

keep if country=="ITA" | country=="GER" | country=="FRA"

rename d4 exp_intensity
rename operatingrevenueturnovertheu TO
rename totalassetstheur K //Proxy for nominal capital//
rename materialcoststheur M
rename employees L
rename costsofemployeestheur W
rename salestheur sales //Proxy for revenues//
rename Exporter exporter
rename sec sector

*** cleaning negative values. Here we use a LOOP! Remember to code the variable

foreach var in K M L W sales TO {
        drop if  `var'<=0  //put the iphen and the vertical "bar"
        }
*We clean for "Mistakes", i.e., measurement errors. We could have replaced the variable with a missing. Instead, we drop as we want to drop the whole line, the whole observation. Replace changes just the individual information, but keeps the line. Why dropping rather than replacing? Because since I am interesting in computing productivity, every missing will make it impossible to compute productivity, so in this case writing replace or drop is ok. If we are using only part of the data for TFP but we are dropping the whole observation, we might lose useful information. Thus, use REPLACE to be sure! 

*** deflated variables. We want to "purge" variables from the price effect. I want to get rid of inflation, the nominal variable has to be deflated. I have to choose between 2 or 3 factors as input. Here, we are estimating a 3-factor production function (Labour, capital and material), identifying three coefficient, which is more cumbersome than using only labour and capital. Moreover, here I am using a Cobb-Doubglas production function and I am log-linearising it. So we assume that the three components can be divided and can substitute each other. But can material substitute workers? The substitutability between factors enters into play. We prefer to work with value-added production function rather than turnover. Therefore, I take material and I subtract it to my independent variable (obtaining a value-added prodyction function)

gen VA=sales-M //Generate value added variable
gen real_K=(K/gdp_defl)*100 //Deflate capital by the GDP deflator in a country for every year
gen real_M=(M/ppi)*100 //Deflate material, using the energy price deflator
gen real_sales=(sales/ppi)*100 //Deflate sales by the industry deflator, using industry-specific price deflator. Make sure to associate the right industry deflator to each year
gen real_VA=(VA/ppi)*100 //
** In the assignment, we will be given already-deflated variables!

keep year country sector mark K real_K M real_M L W sales real_sales real_VA VA exporter FDI  exp_intensity

keep if country=="ITA" 

save STATA_Tutorial.dta, replace
save12 STATA_Tutorial_Stata12.dta

*NOTE: THIS IS THE FILE SHARED ON BLACKBOARD

log using tutorial_2022 //either you open a log file that records everything that you do, or you work a lot with comments in the do.file

use STATA_Tutorial.dta, replace

*create logarithms, either line by line or create a loop

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
******Through OLS I will estimate the coefficients of labour and capital*******
*sector 24 (Chemicals)
xi: reg ln_real_VA ln_L ln_real_K i.country i.year if sector==24 //we add x.i to tell Stata that I am running an OLS regression with fixed effects
predict ln_TFP_OLS_24 if sector==24, residuals //Solow residual. After every regression, use the predict command (post-estimation command), to generate the variable, called the name you want and put, and predict, say, the residuals of the previously run regression. This vector of residuals is the residual of a Cobb-Doubglas production function, so it is TFP, it is in log and for chemicals (look at the name). 

*Note: the marginal productivity of labour and capital can be different for different industries. So you might want to run restricted regressions clustering for industry. At least two-digits aggregation of industries (here, we regress industry by industry). moreover, remember that this is a panel estimation. What you want to do is to consider the fact that marginal productivities might change over time, and taking all of them together is equivalent to take the average across time. What we want to do is to add year FIXED EFFECTS. Moreover, had we consider add also country FIXED EFFECTS.

gen TFP_OLS_24= exp(ln_TFP_OLS_24) //Note that TFP is a multiplicative factor (The A in the production function, so I have to take the exponential of its log)

kdensity TFP_OLS_24 //This command draws the density distribution of TFP. As you can see after running the command, this is pretty skewed! What is the graph telling us? We have an observation at TFP = 100 and one at TFP = 15. Plausible? No, we have to clean the distribution for outliers. 

sum TFP_OLS_24, d
replace TFP_OLS_24=. if !inrange(TFP_OLS_24,r(p5),r(p99)) //Inrange comma, with !, allows us to replace to missing the information of TFP if the value of productivity is outside the bottom 5% or above the top 99%. We are trimming the top 1% of the distribution and the bottom 5%, because I a interested in the right tail of the distribution. This way of cleaning for outliers allows  

sum TFP_OLS_24, d
kdensity TFP_OLS_24

/*Simultaneity bias: are we sure that the residual is unbiased? It might be that because of a productivity shock, a firm might hire/layoff workers (our regressor). So, our regressors might be correlated with productivity (error term). This is a violation of LRM.3! I would thus get a BIASED estimate of the coefficients (in particular, an upward bias). Then my predicted output would be upward biased, and thus my error term would be downward biased. Solution? Clean using fixed effects - but problems with this. The first problem ... (see slides) The second problem is given by TFP being variable over time.*/

/*How to solve this issue: I decompose the error term into: part of the error term iid (uncorrelated with the input) and the part correlated with the input (the problematic one). I know that most of the correlation will happen at the level of the labour coefficient and avoid the consequently bias. I can use a semi-parametric technique which exploits the correlation between the productivity shock and the quantity of input used. So I can thus express productivity as a function of a sort of instrumental variable which is a non-parametric unknown of capital and material

*/

*** LEVINSOHN-PETRIN - VALUE ADDED

***INSTALL PACKAGE FIRST! (search levpet => install package st0060)

xi: levpet ln_real_VA if sector==24, free(ln_L i.year) proxy(ln_real_M) capital(ln_real_K) reps(50) level(99)
predict TFP_LP_24, omega

sum TFP_LP_24, d
replace TFP_LP_24=. if !inrange(TFP_LP_24, r(p1),r(p99))

sum TFP_LP_24, d
kdensity TFP_LP_24

g ln_TFP_LP_24=ln(TFP_LP_24)
kdensity ln_TFP_LP_24

*** PRODEST - VALUE ADDED

***INSTALL PACKAGE FIRST! (search prodest => install package prodest)

xi: prodest ln_real_VA if sector==24, met(lp) free(ln_L i.year) proxy(ln_real_M) state(ln_real_K) va acf

predict ln_TFP_LP_ACF_24, resid

xi: prodest ln_real_VA if sector==24, met(wrdg) free(ln_L) proxy(ln_real_M) state(ln_real_K) va

predict ln_TFP_WRDG_24, resid

tw kdensity ln_TFP_LP_24 || kdensity ln_TFP_LP_ACF_24 || kdensity ln_TFP_WRDG_24 || kdensity ln_TFP_OLS_24

*** Export/FDI premium

twoway (kdensity ln_TFP_LP_24 if exporter==1 & FDI==1, lw(medthick) lcolor(green)) ///
|| (kdensity ln_TFP_LP_24 if exporter==1 & FDI==0,lw(medthin) lcolor(sienna)) ///
|| (kdensity ln_TFP_LP_24 if exporter==0 & FDI==0, lw(medthin) lcolor(blue) lp(dash)), ///
title("Productivity distributions by export status") legend(label(1 "exporters & FDI ") label(2 "exporters only ") label(3 "domestic only "))

g export_status=.
replace export_status=0 if exporter==0 & FDI==0
replace export_status=1 if exporter==1 & FDI==0
replace export_status=2 if exporter==1 & FDI==1  


xi: reg ln_TFP_LP_24 exporter i.year i.sector  if export_status==0 | export_status==1, robust

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
replace PCM=. if !inrange(PCM,r(p1),r(p99)) //Clean for outliers here
kdensity PCM
reg PCM ln_TFP_OLS_24 //regress markup on total factor productivity. They are positively correlated!
