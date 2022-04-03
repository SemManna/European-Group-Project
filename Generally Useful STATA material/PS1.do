
*****************************************************
*File Description:	Problem Set 1, Microeconometrics  				
*Date:				07-03-2022
*Authors:			Simone Boldrini 		3036229
*					Giovanni Ferrannini		3185432			 
*					Sem Manna				3087964
*					Luca Zanotti			3053796 	
*****************************************************



**# ------------ Question 1 ------------**

use "jtrain2.dta", clear


qui describe




/*
(a) Construct a table checking for balance across treatment and control for the following covariates: age educ black hisp nodegree re74 re75.
Name it TABLE 1.
Present for each variable: mean for treated, mean for controls, standard deviations
for treated, standard deviations for control, difference in means between control
and treatment, appropriate standard errors for difference in means.
Comment on how many variables are balanced or not. Is it what you expected?
*/

balancetable train age educ black hisp nodegree re74 re75 using "TABLE_1.xlsx", wide(mean1 sd1 mean2 sd2 diff3 se3) ctitles("Control group" "SD for Control" "Treatment group" "SD for Treatment" "Difference Treatment-Control" "SE for difference") replace

if 1==0{
*Alternative version - constructing a matrix	
	matrix balcheck=(.,.,.,.,.,.)

local i=1

foreach var of varlist age educ black hisp nodegree re74 re75 {
	qui sum `var' if train == 1, d
		matrix balcheck[`i',1]=r(mean)
		matrix balcheck[`i',3]=r(sd)
		scalar m1=r(mean)
	
	qui sum `var' if train == 0, d
		matrix balcheck[`i',2]=r(mean)
		matrix balcheck[`i',4]=r(sd)
		scalar m0=r(mean)
			
	matrix balcheck[`i',5]=m1-m0
		
	qui ttest `var', by (train)
		matrix balcheck[`i',6]=r(se)
		
	local i=`i'+1 
	
	if `i'<=7 matrix balcheck=(balcheck \ .,.,.,.,.,.)
}

matrix colnames balcheck = Mean_Trea Mean_Cont StDev_Cont StDev_Trea Mean_Diff StDev_Diff
matrix rownames balcheck = age educ black hisp nodegree re74 re75

matrix list balcheck

putexcel set "TABLE_1.xlsx", sheet("Balance_Matrix") replace
putexcel A1="jtrain3.dta" A2="Age" A3="Education" A4="Black" A5="Hispanic" A6="No HS degree"  A7="Real Earnings 1974" A8="Real Earnings 1975" 
putexcel B1="Mean Treated" C1="Mean Control" D1="StdDev Control" E1="StdDev Treated" F1="Difference" G1="StdDev Difference" B2=matrix(balcheck)
	
}
	

*The two groups, treatment and control, are not perfectly balanced since we are using a restricted dataset. Indeed, we can see that both the percentange of hispanic in the two groups and the percentage of people without degree are statistically different (at a significance of 90% and 99% respectively). The strong significant difference, particularly in non degree holders, might suggest a dependence between having a college degree and partecipating at the traineeship. 




/*
(b) Regress re78 on train.
Save the estimate and the standard error of the coefficient on train as scalars.
Interpret the coefficient.
*/

reg re78 train

scalar train_coef = _b[train]
scalar train_se = _se[train]



display train_coef
display train_se




*The coefficient is strongly statistically significant with a p-value smaller than 1%. This simple regression suggests that the effect of taking part in the job training program is on average a wage increase of 1,794 US1982 dollars relative to not taking part in the program.



/*
 (c) Construct a table by sequentially adding the output of the following regressions
to each column:
(1) re78 on train;
(2) re78 on train age educ black hisp;
(3) re78 on train age educ black hisp re74 re75;
Add rows to the table with the number of controls and treated in each regression.
Name it TABLE 2.
Are your results sensitive to the introduction of covariates?
*/

qui tab train if train==1 		
scalar n_treated=r(N) 			
qui tab train if train==0
scalar n_control=r(N)



qui reg re78 train
outreg2 using TABLE_2.xls, replace addtext(Number of Control, `=n_control', Number of Treated, `=n_treated') title ("Comparing Experimental and Non-experimental Methods")


qui reg re78 train age educ black hisp
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 train age educ black hisp re74 re75 
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


*We can see that adding covariates to the model does not impact the significance of the train coefficient, but changes its magnitude. Indeed, we can see that the estimated average treatment effect changes from 1,794 US1982 dollars to 1,686 US1982 dollars or 1,680 US1982 dollars depending on the covariates considered. This suggests that, even though a small part of the effect is captured by the covariates (particularly added from the second specification), the overall magnitude is quite stable and the significance remains unaltered at 99% confidence level.

*Particularly interesting is the fact that in the third regression, neither the real earnings in 1974 nor the ones in 1975 are significant. As expected, adding regressors increases the R^2, in this case we would be better considering the adjusted counterpart.






/*
 (d) dfbeta is a statistic that measures how much the regression coefficient of a certain
variable changes in standard deviations if the i-th observation is deleted.
Type help dfbeta and discover how to estimate this statistic after a regression.
Generate a variable named influence train storing the dfbetas of train of the
last regression you did in point (c).
Redo the last regression you did in point (c) but removing the observations with
the 3, 5, and 10 lowest and largest values in influence train.
Are your results sensitive to influential observations?
*/

dfbeta (train)

rename _dfbeta_1 influence_train 


egen rank_asc = rank(influence_train)
egen rank_desc = rank(-influence_train)


gen flag_3 = 1 if inrange(rank_asc, 1, 3) |  inrange(rank_desc, 1,3) 
gen flag_5 = 1 if inrange(rank_asc, 1, 5)  |  inrange(rank_desc, 1,5) 
gen flag_10 = 1 if inrange(rank_asc, 1, 10)  | inrange(rank_desc, 1,10) 


reg re78 train age educ black hisp re74 re75
reg re78 train age educ black hisp re74 re75 if flag_3 != 1
reg re78 train age educ black hisp re74 re75 if flag_5 != 1
reg re78 train age educ black hisp re74 re75 if flag_10 != 1




*As expected, our results are indeed sensitive to influential observations, mainly the one concerning the variable train. Indeed, we can clearly see a decrease in the significance of the variable manifested in an increase in p-value. In the baseline regression the p-value was 0.008, while after removing the 3 observations with the lowest and largest values of the dfbeta statistic, the p-value increases to 0.009. The increase is more evident when removing the 5(10) observation with the lowest and largest influence_train [p-value of 0.015(0.029)], in this case, we lose the significance of the coefficient at 1%. It is worth noticing that education is not significant in the first and third regressions, while it is only at 90% in the second one.

*Compared to the baseline, when removing the 3 lowest and 3 largest values of influence_train, the coefficient of the treatment dummy drops by 0.321886, which is roughly a 20% drop. Moreover, the coefficient of the treatment effect drops considerably from the first regression to the third regression (in which we leave out the 10 lowest and 10 largest observations of influence_train, i.e. the most relevant observations in the regression for the treatment variable train in terms of impact on the outcome variable). Once again, this shows that results are sensitive to influential observations.







**# ------------ Question 2 ------------**

use "jtrain3.dta", clear

/*
(a) Do a table with the same structure of TABLE 1 of item (a) in question 1 for the
following covariates: age educ black hisp re74 re75 (note that nodegree is
not present in the current dataset.)
Add the corresponding columns to TABLE 1.
*/


balancetable train age educ black hisp re74 re75 using "TABLE_1.xlsx", wide(mean1 sd1 mean2 sd2 diff3 se3) ctitles("Control group" "SD for Control" "Treatment group" "SD for Treatment" "Difference" "SE for difference") modify cell("I1")

if 1==0{
**Alternative method by constructing matrix
matrix balcheck2=(.,.,.,.,.,.)

local i=1

foreach var of varlist age educ black hisp re74 re75 {
	qui sum `var' if train == 1, d
		matrix balcheck2[`i',1]=r(mean)
		matrix balcheck2[`i',3]=r(sd)
		scalar m1=r(mean)
	
	qui sum `var' if train == 0, d
		matrix balcheck2[`i',2]=r(mean)
		matrix balcheck2[`i',4]=r(sd)
		scalar m0=r(mean)
			
	matrix balcheck2[`i',5]=m1-m0
		
	qui ttest `var', by (train)
		matrix balcheck2[`i',6]=r(se)
		
	local i=`i'+1 
	
	if `i'<=6 matrix balcheck2=(balcheck2 \ .,.,.,.,.,.)
	}

matrix colnames balcheck2 = Mean_Trea Mean_Cont StDev_Cont StDev_Trea Diff StDev_Diff
matrix rownames balcheck2 = age educ black hisp re74 re75

matrix list balcheck2

putexcel set "TABLE_1.xlsx", sheet("Balance_Matrix") modify
putexcel A10="jtrain3.dta" A11="Age" A12="Education" A13="Black" A14="Hispanic" A15="Real Earnings 1974" A16="Real Earnings 1975" B11=matrix(balcheck2)
}


*Given the nature of the data, we can clearly see strong imbalances between the control and treated groups. Indeed, we have differences statistically different from zero for all the variables considered in the balance test. On average, individuals in the control group are older, more educated, and with higher past earnings. Furthermore, the percentage of black and Hispanic individuals in the treatment group is far greater than in the control group. 

*Even if the randomization was performed correctly in the experiment, it was performed among candidate recipients of the subsidized employment program (unemployed at the time of the randomization, with no more than 3 months of work in the previous 6 months, ex-drug addicts, ex-offenders, young school dropouts), certainly not representative of the US population, which should be reflected in the national surveys. It is therefore natural to expect imbalances in covariates among treated units and controls from the surveys.




/*
(b) Generate a variable named treated that randomly allocates half of observations
to a (fake) treatment group and the other half to a (fake) control group.
Fix a seed of 5 digits using the command set seed. 
See HINT PDF
*/

gen treated = .

set seed 12345

gen random = uniform()

egen rank_random = rank(random)

qui sum 

replace treated = 1 if rank_random <= r(N)/2
replace treated = 0 if rank_random > r(N)/2

if 1==0{
	egen treated_ = cut(random), group(2)
	drop random
}

drop rank_random
drop random



/*
(c) Type ssc install randtreat. Then, read randtreat help file.
Redo point (b) using the command randtreat.
Name treated 2 your new (fake) treatment variable.
Check whether the correlation between treated 2 and treated is statistically
significant or not. (Hint: use pwcorr X Y, sig)
*/

ssc install randtreat

randtreat, generate(treated_2) misfits(global)

pwcorr treated treated_2, sig star(.05)


*As expected, the correlation is not statistically different from 0 given that both assignments occurred completely at random.

/*
(d) Do a table with the same structure of TABLE 1 of item (a) in question 1., but
using treated instead of train.
Use the same list of covariates of item (a) of this question.
Add the corresponding columns to TABLE 1.
What you find corresponds to your expectations?
*/


balancetable treated age educ black hisp re74 re75 using "TABLE_1.xlsx", wide(mean1 sd1 mean2 sd2 diff3 se3) ctitles("Control group" "SD for Control" "Treatment group" "SD for Treatment" "Difference" "SE for difference") modify cell("Q1")


if 1==0{
**Alternative method by constructing matrix		
matrix balcheck3=(.,.,.,.,.,.)

local i=1

foreach var of varlist age educ black hisp re74 re75 {
	qui sum `var' if treated==1, d
		matrix balcheck3[`i',1]=r(mean)
		matrix balcheck3[`i',3]=r(sd)
		scalar m1=r(mean)
	
	qui sum `var' if treated==0, d
		matrix balcheck3[`i',2]=r(mean)
		matrix balcheck3[`i',4]=r(sd)
		scalar m0=r(mean)
			
	matrix balcheck3[`i',5]=m1-m0
		
	qui ttest `var', by (treated)
		matrix balcheck3[`i',6]=r(se)
		
	local i=`i'+1 
	
	if `i'<=6 matrix balcheck3=(balcheck3 \ .,.,.,.,.,.)
}

matrix colnames balcheck3 = Mean_Trea Mean_Cont StDev_Cont StDev_Trea Diff StDev_Diff
matrix rownames balcheck3 = age educ black hisp re74 re75

matrix list balcheck3

putexcel set "TABLE_1.xlsx", sheet("Balance_Matrix") modify
putexcel A18="Random T" A19="Age" A20="Education" A21="Black" A22="Hispanic" A23="Real Earnings 1974" A24="Real Earnings 1975" B19=matrix(balcheck3)
}


*As expected, differently from the point 2a, here the fully random assigment of the treatment generates a perfectly balanced control and treatment group.


/*
(e) Sequentially add the output of the following regressions to TABLE 2:
(1) re78 on treated;
(2) re78 on treated age educ black hisp;
(3) re78 on treated age educ black hisp re74 re75.
Add lines in the table with the number of controls and treated in each regression.
Comment on what you find. Is it what you expected?
*/

qui tab treated if treated==1 		
scalar n_treated=r(N) 			
qui tab treated if treated==0
scalar n_control=r(N)



qui reg re78 treated
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 treated age educ black hisp
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 treated age educ black hisp re74 re75 
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


*Given that we have assigned randomly the treatment to the sample, as expected, we find that the treatment dummy is never significant, notwithstanding the covariates considered in the regression. Therefore, as a consequence of the exclusion of the treatment dummy, other covariates (age, educ, hisp, past earnings) became explanatory of the outcome.




**# ------------ Question 3 ------------**

use "jtrain3.dta", clear



/*
(a) Sequentially add the output of the following regressions to TABLE 2:
(1) re78 on train;
(2) re78 on train age educ black hisp;
(3) re78 on train age educ black hisp re74 re75.
Add lines in the table with the number of controls and treated in each regression.
Compare the results with the first three columns of TABLE 2.
Comment on what you find. Is it what you expected? Are your results sensitive
to the introduction of covariates?
*/


qui tab train if train==1 		
scalar n_treated=r(N) 			
qui tab train if train==0
scalar n_control=r(N)



qui reg re78 train
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 train age educ black hisp
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 train age educ black hisp re74 re75 
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


*When comparing the two sets of regression, we need first to understand the main differences in the two datasets. jtrain2 is a subsample of experimental data, while jtrain3 represents a dataset with an observational control (non-experimental control). Indeed, we can clearly see that in these regressions the total sample and in particular, the number of control units is far greater. This should help with the power of the regression.

*In particular, we have that train coefficient is strongly and significantly (99%) negative in the first two regressions and positive, but not significantly different from zero, in the third one. This could be expected, given the fact that the dataset jtrain3.dta contains, as a control group, individuals from national surveys, whose average earning is expected to be higher than that of individuals in need of subsidized employment, selected for the NSW program. Using such non-experimental control, selection into treatment becomes negatively correlated with outcome. 

*Notwithstanding that, the results are far more sensitive to the introduction of covariates. In particular, in the first two regressions (7) and (8) the estimated treatment effect is negative and highly significant, thus very different from the experimental estimate. On the other hand, adding the past earnings inverts the sign of the effect and push it relatively closer to the one of the experiment. This suggests that indeed the assignment of the treatment was not random and that the covariates (particularly the lagged outcomes, re74 and re75) are correlated with the potential outcome. Controlling for them will thus drastically improve our estimates and makes the CIA more plausible. 

*For example, looking at the covariates more closely, age and educ become significant in both the regressions in which they are included. Black ceases to be significant after the introduction of previous earnings as covariates. These lasts have positive, significant effects. Once again, we can conclude that results are sensitive to the introduction of covariates.







/*
(b) Estimate a logit model using:
(1) train as a dependent variable;
(2) age educ black hisp re74 re75 as covariates.
Predict the value of the propensity score.
Construct the common support of the propensity score (the intersection of estimated pscores for treated and control observations).
*/



logit train age educ black hisp re74 re75

predict pscore

qui sum pscore if train == 0
gen control_lower = r(min)
gen control_upper = r(max)

qui sum pscore if train == 1
gen treated_lower = r(min)
gen treated_upper = r(max)


gen common_support = 1 if pscore >= max(control_lower, treated_lower) & pscore <= min(control_upper, treated_upper)

replace common_support = 0 if missing(common_support)


/*
(c) Replicate the regressions of item (a) but restricting the sample to the common
support.
Add the output to TABLE 2, including a row for the number of controls and treated
used in the regression.
Do results change significantly? Why do you think it makes sense to restrict the
sample in the regressions to the common support?
*/



qui tab train if common_support==1 & train == 1
scalar n_treated=r(N) 			
qui tab train if common_support==1 & train == 0
scalar n_control=r(N)



qui reg re78 train if common_support==1 	
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 train age educ black hisp if  common_support==1 	
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


qui reg re78 train age educ black hisp re74 re75 if  common_support==1 	
outreg2 using TABLE_2.xls, append addtext(Number of Control, `=n_control', Number of Treated, `=n_treated')


*We can see that when considering only the observations in the common support the estimates get closer to the one obtained in the experimental setting. Indeed, we can see that also the numerosity and the composition of the observation used are closer to the one of the experiment. Indeed, in this case, we have 1166 control units and 157 treatment ones. 

*We thus believe that restricting to the common support makes sense in this framework, as we are gaining in terms of internal validity. Indeed, we are comparing units that should be more similar than before and thus we are moving away from always- and never-takers. All in all, this should lead to more accurate estimates.

*However, trimming the sample inevitably generates losses in terms of external validity. Indeed, we are no longer estimating the average treatment effect on all the treatment group.


/*
(d) Provide the histogram of the propensity score in the treated and in the control
group.
Comment on what you see. 
See HINTS PDF
*/
set scheme s1color

twoway(hist pscore if train == 1, bin(10) fraction lcolor(blue) color(blue%30))(hist pscore if train == 0, bin(10) fraction lcolor(red) color(red%30) ), legend(label(1 "Treated Group") label(2 "Control Group")) ///
xtitle("Propensity Score") ytitle("Distribution") ///
xscale(titlegap(*15)) yscale(titlegap(*15)) ///
title("Propensity Score Distribution across Groups", margin(b=4))



graph export hist_ps.png, replace		




*We can clearly see that we have a bigger mass of the pscore distribution at the lowest values when considering the control group. On the other hand, the distribution of the pscore is more concentrated to the larger values in the treated group.



**# ------------ Question 4 ------------**

use "jtrain3.dta", clear

/*
(a) Type findit pscore, click on st0026 2 to install the updated version of the ado
file, and read pscore's help.
Replicate the authors' estimation of the propensity score model using the command pscore in page 369.
Hint: You will need to generate extra variables: square terms (educ2, age2,
RE742, RE752) and interaction (blackU74). Hint (2): Use the option logit.
*/


gen age2 	 = age^2
gen educ2 	 = educ^2
gen RE742	 = re74^2
gen RE752	 = re75^2
gen blackU74 = black * unem74





pscore train age age2 educ educ2 married black hisp re74 re75 RE742 RE752 blackU74, pscore(pscore_fit) blockid(myblock) comsup numblo(5) level(0.005) logit



/*
(b) Construct the common support on the basis of the estimated pscore as they define
it in the text of the paper (the intersection of pscores for treated and controls).
Do you find the same values as Becker and Ichino (2002) present in page 370?
What are the authors doing to construct the common support?
Hint: Read pages 370-371
*/

qui sum pscore_fit if train == 1
scalar min_treated_pscore=r(min)
scalar max_treated_pscore=r(max)


matrix support_treated = (min_treated_pscore, max_treated_pscore)



qui sum pscore_fit if train == 0
scalar min_control_pscore=r(min)
scalar max_control_pscore=r(max)

matrix support_control = (min_control_pscore, max_control_pscore)

matrix common_support = (max(min_treated_pscore, min_control_pscore), min(max_treated_pscore, max_control_pscore))


matrix list support_treated
matrix list support_control
matrix list common_support


*We can see that the authors in the algorithm are using only the support of the treated group, when they specify the option comsup in the pscore function. Indeed, looking at the help file we can see that:

*comsup restricts the analysis of the balancing property to all treated plus those controls in the region of common support. A dummy variable named comsup is added to the dataset to identify the observations in the common support.

*Therefore, our definition of common support, intended as the intersection between the supports of the control and the treatment group, is slightly different and thus yields different results since the upper limit of the control support is smaller.




/*
(c) What is the average pscore in the treated and in the control group before and
after imposing the common support condition?
*/


sum pscore_fit if train == 1
scalar mean_pscore_treat_nocs = r(mean)


sum pscore_fit if train == 0
scalar mean_pscore_control_nocs = r(mean)

matrix mean_pscore_nocs = (mean_pscore_treat_nocs, mean_pscore_control_nocs)


gen in_cs = 1 if pscore_fit >= common_support[1,1] & pscore_fit <= common_support[1,2] 

sum pscore_fit if train == 1 & in_cs == 1 
scalar mean_pscore_treat_cs = r(mean)


sum pscore_fit if train == 0 & in_cs == 1 
scalar mean_pscore_control_cs = r(mean)

matrix mean_pscore_cs = (mean_pscore_treat_cs, mean_pscore_control_cs)


matrix list mean_pscore_nocs
matrix list mean_pscore_cs




/*
(d) Read the help of the command attnd.
Replicate the attnd command in page 371.
Read the help of the command attr.
Estimate a radius matching estimator using the model in pages 372-373 but using
0.05 as radius. Are results consistent across the two methods?
*/


attnd re78 train age age2 educ educ2 marr black hisp re74 re75 RE742 RE752 blackU74, comsup boot reps(100) dots logit


attr re78 train age age2 educ educ2 marr black hisp re74 re75 RE742 RE752 blackU74, comsup boot reps(100) dots logit radius(0.05)

/*
The two methods do not give the same estimates: they are very different in magnitude and also in sign. In the nearest neighbor matching performed with attnd, not all controls are used in the computation of the ATT. As we can see, the number of controls is only 57, compared to 1157 for the radius matching estimation. Of course, since this is a nearest neighbor matching, it is not necessarily the case that the pscores of treated and controls are similar. Rather, for every observation in the treated, one in the controls is found to have a pscore as close as possible. Nothing thus says that the pscores are indeed similar, and they could potentially be very different and thus could lead to very imprecise estimates. With the radius matching estimator, we are ensuring that the pscores are close (i.e. we avoid "bad" matches), by imposing the length of the radius. However, in the estimation treated units may be not matched with controls, and this potentially creates a problem of extending the results to the overall population. Moreover, the choice of the radius is completely arbitrary. 

Abadie and Imbens (2005) claim that bootstrap techniques to compute standard errors are not valid when one uses the nearest neighbor matching estimator. Therefore, the first estimation using the STATA command attnd as done by Becker and Ichino should ignore the estimation using bootstrap. Finally, in general it is better to estimate the two stages, i.e. the estimation of the propensity score and of the ATT, simultaneously and not in two steps. This could be done directly with the command attnd, without specifying the already-estimated propensity score. 
*/




/*
(e) In the end, what are your conclusions about the controversy about the performance of propensity score matching estimators?
Do you agree with Dehejia (2005)'s defense of propensity score methods? Or do
you agree with Smith and Todd (2005a,b) in their criticism?
Or, contrary to the previous studies, do you agree with Angrist and Pischke (2008)
who argue that is better to do simple a OLS regression instead of using pscores?
*/

*We tried with probit estimation of pscore to see if results change 

if 1==0 {pscore train age agesq educ educ2 married black hisp re74 re75 re742 re752 blacku74, pscore(pscore_prob) blockid(myblock_2) comsup numblo(5) level(0.005) 

attnd re78 train age agesq educ educ2 married black hisp re74 re75 re742 re752 blacku74, pscore(pscore_prob )comsup boot reps(100) dots   
}

*In the previous point we just saw how sensible is the estimate of the treatment effect using propensity score matching techniques. In particular, since there is no solid theory behind these techniques, different identification and parametrization might lead to completely different estimates using the same covariates and data. This leans our evaluation more towards the position of Smith and Todd (2005a,b) of careful employment of p-score matching conditional on the available data and on the ability of observable covariates to predict treatment assignment, perhaps accounting for the institutions governing selection into the program and tailoring the methods employed to the context at hand. Therefore, p-score matching seems to be reliable only when we can confidently rely on the assumption that the relevant variables determining treatment status are observable, and matching is justified over the common support region, where p-scores overlap between the treatment and the control group. Yet, while this may increase the internal and statistical validity of the model, the results are not generalizable as external validity is reduced by the scrapping of observations outside the common support.

*It is worth noticing that Dehejia and Wahba (1999) acknowledged other important limitations of these techniques.

*	-First, using matching techniques generates higher standard errors compared to the experimental framework. Indeed, by the nature of the techniques, the number of matched observations used to estimate the ATT will be lower compared to in a standard regression analysis. This is because the unmatched observations will not be considered in the estimation.

*	-Second, if there is a relevant unobservable covariate that influences the treatment assignment, we cannot use these techniques since we cannot consider it in the computation of the pscore.

*Finally, we recognize the value of using the propensity score to select the sample of analysis in line with Angrist and Pischke (2008), particularly in non-experimental settings characterized by a high degree of unbalances. Indeed, we can see how limiting our regression to the common support observations in the jtrain3 datasets, drastically improves the quality of the estimates that get very close to the ones in the experimental setting.

*In particular, using the propensity score to select the sample of analysis would make the selection of a non-experimental sample more systematic, compared to an ad-hoc selection of the sample like in LaLonde (1986).






**# ------------ Question 5 ------------**


use "jtrain2.dta", clear

/*
(a) Under which conditions, allowing for heterogeneous treatment effects, is Neyman's inference unbiased?
*/


/*
The first assumption in Neyman's inference is to keep the potential outcomes fixed. In Section 4.2 of Athey and Imbens (2017), it is shown what happens if we start from a finite sample, and therefore we do not assume that we have a random sample from an infinite population. 

It is demonstrated that the estimator is indeed unbiased for the average treatment effect for the sample at hand. However, it is shown that, when we want to estimate the sampling variance of the estimator, we are only able to estimate the first two terms, i.e. the variances related to the treated and the controls in the sample, but not the sample variance of the unit-level treatment effects. This is clearly because, at the unit level, we never observe the outcome both when the unit is treated and when the unit is controlled. 

Following Neyman, usually an estimator for the variance of the estimator of the average treatment effect based only on the first two terms is used. This clearly implies that the estimator is upwardly biased, and this leads to overly conservative confidence intervals. If we allow for heterogeneous treatment effects (disregarding constant treatment effect), then the only way to solve the bias is to view the sample at hand as a random sample drawn from an infinite population, rather than a finite sample. The estimator would thus be interpreted as an estimator of the ATE in the population, and not in the finite sample only (Imbens and Rubin (2015)). One could then use the Central Limit Theorem for iid random variables to construct confidence intervals. 

Therefore, by using random sampling and exploiting the CLT (which can be applied in large samples), we are able to retrieve an unbiased estimator for the ATE at the population level.  
*/


/*
(b) Describe Fisher's inference and replicate section 4.1 of Athey and Imbens (2017)
in Stata. Do not use any third-party Stata package. Do you arrive at their same
p-value? If not, why? Hint: Note that you can take reference on a third-party
code to write your own algorithm; read Heß (2017) to draw motivation.
*/


tab train

qui sum re78 if train == 1
scalar sample_treated_re78 = r(mean)

qui sum re78 if train == 0
scalar sample_control_re78 = r(mean)

scalar sample_diff_re78 = sample_treated_re78 - sample_control_re78


scalar list sample_diff_re78


set seed 12345


mat M=(.,.)


if 1==0{

_dots 0, title(Loop running) reps(10000)

forvalue i = 1(1)10000{
	cap drop select rank_sel train_iteration
	_dots `i' 0
	
	gen select=runiform()
	egen rank_sel = rank(select)
	gen train_iteration=inrange(rank_sel,0,185)


	qui sum re78 if train_iteration == 1
	scalar iter_treat_re78 = r(mean)

	qui sum re78 if train_iteration == 0
	scalar iter_control_re78 = r(mean)

	scalar iter_diff = iter_treat_re78 - iter_control_re78

	matrix M = M \ (scalar(`i'),iter_diff)
		
}



mat list M

svmat M

keep M1 M2

drop if missing(M1)

gen p = abs(M2) >= sample_diff_re78

*save "p-value.dta"
}

use "p-value.dta", replace

qui sum p

scalar p_value = r(mean)

scalar list p_value

/* 
The idea behind Fisher's inference is to test the sharp hypothesis of the existence of a treatment effect in the population. The null hypothesis, in this case, is that the treatment has not effect whatsoever and thus allows us to infer all the missing potential outcomes from the observed ones. In other words, under the null, we could hypothetically change randomly the assignment of the treatment without generating differences in a predetermined statistic. In our case, this statistic will be the difference between the sample average in the treatment and control group of the real earnings in 1978. 

The procedure to obtain the p-value is the following. In the data, we observe a value of this statistic T = 1.79. The p-value is the probability of observing this value or a value more extreme under H0. Hence, under H0 we can generate the exact distribution of the statistic by randomly re-assigning the treatment, keeping constant the numbers of treated and controls, to the sample and see how many times we obtain a value greater on equal to 1.79 in absolute value. Indeed, the lower will be the occurrences the lower will be the p-value and thus the probability of observing this particular value of T in the samples under H0. In other words, the fact that with a low probability we find a difference that is larger than the observed one implies that the observed one is already high enough to justify the presence of treatment effect. Therefore, as in any other statistical test low levels of the p-value suggest the rejection of the null hypothesis and thus of the absence of treatment effect. 

In our particular case, we have that in 10,000 iterations, the difference between the sample averages is greater than 1.79 in absolute value only 41 times. This, therefore, indicates a p-value of 0.0041 which is close to the one obtained by the authors (0.0044). Therefore, we clearly reject the null hypothesis that the program had no effect on earnings. 

Finally, we can notice that the slight difference between our results might be due to two factors. First, we are considering a slightly different sample. In particular, we have 260 control units instead of the 240 the authors considered. Moreover, the fact that the procedure used to estimate is inherently stochastic in finite samples, justify having slightly different values.


*/


/*
(c) The experiment implemented in LaLonde (1986) was stratified at a city level.
With this in mind, would you say that Athey and Imbens (2017)'s illustration of
Fisherian inference on LaLonde (1986)'s paper is incorrect and/or incomplete?
*/

*Stratification, like the one at a city level performed in the NSW program, reduces the risk that the random assignment of the treatment would still generate an unbalanced sample. Indeed, it is possible that the city you live in correlates with the outcome and thus your real earnings. Therefore, by not stratifying by city one could have treated and control group not evenly distributed across cities (e.g. 90% of the treatment group is assigned in just 2 cites). This could create an unbalance in the observable covariates but also does not take into account possible unobservables related to the city itself (e.g. the easiness to find a job).

*Therefore, stratification in randomization ex-ante is indeed desirable, as Athey and Imbens (2017) claim, on top of adding covariates ex-post in the regression specification. The reason why stratification (blocking) may be useful in this program is that the economic environment may be different across sites. Therefore, comparing treated and controls across sites may fail to consider different contexts which can have a strong effect on the treatment effect. Finally, the authors also explain that stratification with the same treatment probabilities in each stratum cannot be worse than complete randomization, even when the variables according to which one stratifies are not very much correlated with the outcome.

*In Fisherian's inference, the problem is that the treatment is randomly reassigned without considering which site the individuals belonged to. In other words, blocking is not performed in this type of inference. This creates the problems highlighted above and could lead to unprecise estimates. Indeed, if we want to perform re-randomization a la Fisher, we would need to know exactly the strata considered so as to replicate the randomization effort of the experiment. This, however, would be costly and complex overall.





