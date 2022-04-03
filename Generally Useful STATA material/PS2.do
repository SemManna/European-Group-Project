
*****************************************************
*File Description:	Problem Set , Microeconometrics  				
*Date:				28-03-2022
*Authors:			Simone Boldrini 		3036229
*					Giovanni Ferrannini		3185432			 
*					Sem Manna				3087964
*					Luca Zanotti			3053796 	
*****************************************************



************
* Exercise 1
************




**# Question 1

use pset_2_q_1.dta, clear


*(a)

set scheme s1color


keep birthdate birthqtr Education

egen mean_educ = mean(Education), by(birthdate)

sort birthdate

drop Education

duplicates drop


twoway (connected mean_educ birthdate if inrange(birthdate, 1930, 1939.75), sort mcolor(black) msymbol(square) mlabel(birthqtr) mlabcolor(black) mlabposition(6) lcolor(black)), ytitle(Years of Completed Education)  xtitle(Year of Birth) title(" " "Figure I" "Years of Education and Season of Birth" "1980 Census" "{it: Note}. Quarter of birth is listed below each observation", position(6) size(9pt))
graph export Figure_I.png, as(png)  replace

twoway (connected mean_educ birthdate if inrange(birthdate, 1940, 1949.75), sort mcolor(black) msymbol(square) mlabel(birthqtr) mlabcolor(black) mlabposition(6) lcolor(black)), ytitle(Years of Completed Education)  xtitle(Year of Birth) title(" " "Figure II" "Years of Education and Season of Birth" "1980 Census" "{it: Note}. Quarter of birth is listed below each observation", position(6) size(9pt))
graph export Figure_II.png, as(png)  replace

twoway (connected mean_educ birthdate if inrange(birthdate, 1950, 1959.75), sort mcolor(black) msymbol(square) mlabel(birthqtr) mlabcolor(black) mlabposition(6) lcolor(black)), ytitle(Years of Completed Education)  xtitle(Year of Birth) title(" " "Figure III" "Years of Education and Season of Birth" "1980 Census" "{it: Note}. Quarter of birth is listed below each observation", position(6) size(9pt))
graph export Figure_III.png, as(png)  replace


* In the first two graphs, i.e. for cohorts of men born in 1930s and 1940s, there seems to be an effect of the instrument (i.e. quarter of birth) on the average number of years of education within each year. In other words, those who are born in the last quarters of the year have often a higher number of years of education compared with those born in the first quarter. This systematic decline in the average years of education for individuals born in the first quarter is preliminary evidence of a relevant first stage. Moreover, this seem to hold regardless of the ongoing overall trend in the period under consideration. In the first graph for example, where the trend is increasing, only in three years out of ten quarter 3 displays a higher average number of years of education than quarter 4, but it is still higher than quarter 1 and 2. This is not entirely the case for the last graph, i.e. for those born in the 1950s. Here, for those born in the late 1950s, the trend is downward. As Angrist and Krueger (1991) explain, because by the 1980s the younger men in this cohort had not completed their educational path, partly due to the Vietnam War. 



*(b)

*Exogeneity requires that the instrument considered, in this case the quarter of birth, is not correlated with unobservables that might affect the outcome variable, that is health status. However, as clearly stated by Bound and Jaeger (1996) and Bound et al. (1995) there is vast evidence that might void this exogeneity assumption. For example, quarter of birth is related to school attendance. Finally, there are regional patterns in birth seasonality, particularly in southern States, and there is evidence that those in families with high incomes are less likely to be born in the winter months. Yet, since the sub-population studied by the instrument is that of dropout students, this group is likely be comprised of students with similar socio-economic background, rising issues related more to external validity than to a lack of randomness. Despite this, the aforementioned evidence shows how we cannot neglect the possibility that there are unobservables correlated with quarter of birth and health status.

*Furthermore, exogeneity may be violated if parents can decide exactly in which period of the year they would like to have a child. Perhaps, career-oriented parents may want their children in summer because they are careful in choosing the best period to take some time off from work, minimizing the harm on their professional prospects. If this was the case, it would mean that the treatment assignment is not exogenous to potential outcome and to treatment potential outcomes, but it is correlated with them given the endogenous choice of the parents. For example, these kinds of parents will be more likely to pay a lot of attention to education, health status, and career also of their children, thus affecting the dependent variable.


*Bound and Jaeger (1996) and Bound et al. (1995) also state that there is substantial evidence that individuals born early in the year are more likely to suffer from schizophrenia, autism, multiple sclerosis, and manic depression. Moreover, the quarter of birth might also affect the likelihood that a student will be assessed as having behavioral difficulties and ultimately the likelihood that a student will be referred for mental health services. This clearly has a direct impact on health status, without necessarily moving through the endogenous variable (Education). Therefore, all of these ekements threaten the assumption of exclusion restriction and thus the validity of the instrument in this setting.

*When considering Angrist and Krueger's setting where the outcome variable is earning, similar results apply. Indeed, we have said that the quarter of birth is, for example, related to school attendance. Higher attendance might help student to acquire more knowldege, for a given level of education, which in turn might result in greater skills and thus earnings. Similarly, we said that quarter of birth might relate to the health status, without necessarily passing through education. In turn, health status is likely to impact future earnings.

*(c)

* With regards to the model on health, we would expect the OLS estimates to be biased, as the exogeneity condition is likely to fail. Education is likely to be correlated positively to unobserved characteristics that might affect health positively, for example self-care or parents care. Therefore, when performing a 2SLS with a valid instrument, we would be able to estimate the sole effect of education. This effect would thus be lower than the one estimated using the OLS since the latter would attribute to education also the effects of the observed variables. 

* Similarly, for the earnings-education framework, we would expect an upward bias in OLS since this will not control for unobservables characteristics such as motivation or ability, that drive both education and earnings.

*In this case, the control is the quarter of birth while the treatment is spending a year more in school. In this context, a complier is both:

*- individuals who were forced to spend an additional year in school bacause they were born late in the year and thus started school earlier, reaching the legal dropout age almost one year older than those born in the first quarter. And,
*- individuals who dropped out of school immediately after reaching the required age and thus spent almost a year less in school.

*Therefore, the compliers are those individuals who would not have left school early had they not been born early in the year, but also those who would have stayed in education had they been born later in the year.


**# Question 2

use pset_2_q_2_and_3.dta, clear

*(a)

quiet sum Healthy
scalar mu_y = r(mean)

quiet sum Education
scalar mu_x = r(mean)


*(b)

tab birthqtr, gen(Quarter)

tab region, gen(Region)

local Controls "Central Married Region1 Region2 Region3 Region4 Region5 Region6 Region7 Region8 Region9"

tab birthyear, gen(birth_year_dummy)

local Birth_Year_FEs "birth_year_dummy1 birth_year_dummy2 birth_year_dummy3 birth_year_dummy4 birth_year_dummy5 birth_year_dummy6 birth_year_dummy7 birth_year_dummy8 birth_year_dummy9 birth_year_dummy10"

*(c) and (d)

reg Healthy Education, robust
outreg2 using "Table_Q_2.xls", excel nocon bdec(5) sdec(5) keep(Education) replace addtext(Controls, NO, Year of Birth FEs, NO) addstat("Mean y", mu_y, "Mean x", mu_x) ctitle("OLS") title("OLS and IV")

reg Healthy Education `Controls', robust
outreg2 using "Table_Q_2.xls", excel nocon dec(5) keep(Education) append addtext(Controls, YES, Year of Birth FEs, NO) addstat("Mean y", mu_y, "Mean x", mu_x) ctitle("OLS") title("OLS and IV")

reg Healthy Education `Controls' `Birth_Year_FEs', robust
outreg2 using "Table_Q_2.xls", excel nocon dec(5) keep(Education) append addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y, "Mean x", mu_x) ctitle("OLS") title("OLS and IV")





*(e) and (f)

if 1==0{
ssc install ivreg2
ssc install ranktest
}

ivreg2 Healthy (Education = Quarter1 Quarter2 Quarter3), first savefirst robust
scalar F_inst = e(widstat)
outreg2 using "Table_Q_2.xls", excel nocon bdec(5) sdec(5) keep(Education) append addtext(Controls, NO, Year of Birth FEs, NO) addstat("Mean y", mu_y, "Mean x", mu_x, "F-statistic IVs", F_inst) ctitle("IV") title("OLS and IV")


ivreg2 Healthy (Education = Quarter1 Quarter2 Quarter3) `Controls', first savefirst robust
scalar F_inst = e(widstat)
outreg2 using "Table_Q_2.xls", excel nocon bdec(5) sdec(5) keep(Education) append addtext(Controls, YES, Year of Birth FEs, NO) addstat("Mean y", mu_y, "Mean x", mu_x,"F-statistic IVs", F_inst) ctitle("IV") title("OLS and IV")


ivreg2 Healthy (Education = Quarter1 Quarter2 Quarter3) `Controls' `Birth_Year_FEs', first savefirst robust
scalar F_inst = e(widstat)
outreg2 using "Table_Q_2.xls", excel nocon bdec(5) sdec(5) keep(Education) append addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y, "Mean x", mu_x, "F-statistic IVs", F_inst) ctitle("IV") title("OLS and IV")



**# Question 3

*(a)

reg Healthy Education `Controls' `Birth_Year_FEs', robust

outreg2 using "Table_Q_3.xls", excel nocon dec(5) keep(Education) replace addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y, "Mean x", mu_x) ctitle("OLS") title("OLS and IV")


*(b)
ivreg2 Healthy (Education = Quarter1 Quarter2 Quarter3)  `Controls' `Birth_Year_FEs', robust first savefirst
scalar F_inst = e(widstat)
est restore _ivreg2_Education
outreg2 using "Table_Q_3.xls", excel nocon dec(5) keep(Quarter1 Quarter2 Quarter3) append addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y, "Mean x", mu_x, "F-statistic IVs", F_inst) title("OLS and IV") ctitle("First Stage")


*(c)

reg Healthy Quarter1 Quarter2 Quarter3 `Controls' `Birth_Year_FEs', robust

outreg2 using "Table_Q_3.xls", excel nocon dec(5) keep(Quarter1 Quarter2 Quarter3) append addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y) title("OLS and IV") ctitle("Reduced Form")

* The expected signs of the coefficients are negative, i.e., being born in earlier quarters is associated with worse health status. This is in line with the reasoning that education has a positive effect on health and that the later the quarter leads to the higher education. Moreover, since the reference category is Quarter 4, we expected negative and decreasing coefficients for the instruments.

*Empirically, we can see that the coefficients of Quarter1 and Quarter2 are indeed negative and statistically different from 0 at 99% confidence level, while the coefficient of Quarter3 is positive but not statistically different from 0. Therefore, these results are in line with expectations and with the reasoning of Angrist and Krueger (1991) that being born earlier allow you to leave school one year earlier.

*(d)


ivreg2 Healthy (Education = Quarter1 Quarter2 Quarter3) `Controls' `Birth_Year_FEs', robust

outreg2 using "Table_Q_3.xls", excel nocon dec(5) keep(Education) append addtext(Controls, YES, Year of Birth FEs, YES) addstat("Mean y", mu_y, "Mean x", mu_x) title("OLS and IV") ctitle("Second Stage")

*(e)

reg Education Quarter1 Quarter2 Quarter3 `Controls' `Birth_Year_FEs'



* R-squared is 0.0004 in the first stage is very low, showing that the instruments used above are weak. As explained by Bound et al. (1995), a weak instrument, i.e. one which is weakly correlated with the endogenous regressor, may exacerbate the bias relative to OLS. Indeed, if the R-squared is too small, the inconsistency of the IV estimate is even larger. The idea is that if the correlation is weak, then even if there is a small correlation between the instrument and the error term in the regression of Y on D, then this weak correlation can amplify the inconsistency due to the (partial) endogeneity of the instrument. For example, if we believe that the instrument is not completely exogenous to health outcome, because parents may choose the exact period of the year to have a child to safeguard their career development, then a weak instrument will do nothing but increase the bias relative to OLS. Another example is cited in Bound et al. (1995), who claim that there is some evidence that there are identifiable differences in physical and mental health of people born in different periods of the year. For example, being born earlier in the year is associated with a higher likelihood of schizophrenia; also, which quarter of birth you are born in is associated with the incidence of mental retardation, dyslexia, autism, multiple sclerosis, etc. Finally, high income families tend to have kids in warm months, avoiding winter. All of this suggests that the instruments may not be exogenous, and they could be correlated to Y through channels different from the treatment into education. If this is true, then a weak instrument will exacerbate the bias in the IV estimates relative to OLS ones. 

* The idea of finite-sample bias is that, even though we assume that the instrument is completely unrelated to the error term in the main regression of interest, if the sample is finite, a bias can be generated in relation to the uncertainty in the estimation of the first stage. More in detail, if the instruments are completely unrelated to the endogenous regressors, in finite samples the estimation of the first stage will not give us exactly 0. Therefore, this leads the IV estimate to have the bias in the direction of the OLS one. 

*** Although consistent, 2SLS estimator is biased. Therefore, in small samples it can significantly diverge from the actual population parameter of interest. This is exacerbated in the case of a weak instrument, i.e. in case of low correlation between the instruments and the endogenous regressors, or if there are many overidentifying restrictions. When this correlation goes to zero, the sampling distribution of the 2SLS is centred around that of OLS probability limit and then 2SLS will reproduce, through the first stage, the same exact bias of the OLS estimator. This is due to the fact that, if the first-stage is null, then the variation in the first stage is due to endogenous variables in the model, which correlate with the second-stage errors for the same reasons related to endogeneity which make the OLS estimator biased. 

* For finite-sample bias, Bound et al. (1995) argue that it is useful to examine the F-stat from the First Stage. In particular, they claim that the bias of the IV relative to OLS is inversely related to the F-statistic of the excluded instruments from the first stage. In our estimation, we get an F-statistic of 62.09. Since, as Bound et al. (1995) claim, an F-statistic close to 1 is cause of concern, we are confident in saying that finite-sample bias is not an issue in this case. Indeed, the bias of IV estimates relative to OLS estimates is an inverse function of the F-statistic (Staiger and Stock (1994) argue that the bias of OLS relative to IV could be approximated with 1/F). If this statistic is large, as in our case, the bias is likely to be very small. 

* We can reject the null of no joint significance of our instruments as the p-value of the F-test is approximately 0.

*(f)

tab bpl, gen(State)

local State_FEs State1-State50

tab birthdate, gen(yearquarter)

local Year_Quarter_FEs yearquarter1-yearquarter39

egen statequarter = concat(bpl birthqtr), decode punct(-)  
tab statequarter, gen(yearquarter_d)
local State_Quarter_FEs yearquarter_d1-yearquarter_d203

*(g)

ivreg2 Healthy (Education = `Year_Quarter_FEs') `Controls' `Birth_Year_FEs', first savefirst robust  partial(`Birth_Year_FEs') 
scalar F_inst_1 = e(widstat)


ivreg2 Healthy (Education = `State_Quarter_FEs') `Controls' `Birth_Year_FEs' `State_FEs', first savefirst robust partial(`Birth_Year_FEs' `State_FEs') 
scalar F_inst_2 = e(widstat)

scalar list F_inst_1 F_inst_2



* The rule of thumb to assess that our instruments are not weak is to have an F-test for excluded instruments above 10 (Staiger and Stock (1997)). In the first regression is 7.96, while in the second is 3.17. These numbers are much smaller than 60, and are way closer to 1, the value which is a cause of concern. Since a value close to 1 means that there may be a finite-sample bias, both regressions are likely to suffer from finite sample bias. 



************
* Exercise 2
************

*Question 1


* (a) First of all, Autor et al. (2013) emphasize exogeneity of the shocks compared to exogeneity of the shares (as done instead by Goldsmith-Pinkham et al. (2020)). In fact, their empirical model features both the endogenous regressor and the instrument as Bartik-like variables. Indeed, the endogenous regressor, a measure of import penetration from China in the US, is already in a Bartik-like format. Since the relation between change in labor market outcomes and import shocks from China is potentially affected by endogeneity issues, given that both the dependent variable and the regressor may be correlated with unobserved demand shocks in the US, OLS is not a good estimation strategy. Therefore, the instrument the main regressor of labor market exposure to import competition from China with a very similar measure which differs in two respects: the change in imports from China refers to other advanced economies; the initial shares of employment refer to the previous decade. While the second feature allows to net out simultaneity bias (i.e. the possibility that labor market outcomes may respond in anticipation to a trade shock), the first emphasizes exogeneity of the shocks. The claim is that, by focusing on other advanced economies, the part of the rise in US imports from China that is captured is one which is really due to exogeonus supply shocks in China (e.g., Chinese rising competitiveness, WTO accession and lower tariffs). This approach differs from Goldsmith-Pinkham et al. (2020), which instead claim that in Autor et al. (2013) setting, one should put emphasis on exogeneity of the shares rather than of the shocks. 

* Following Autor et al. (2013) identification strategy and its justification, assuming constant effect there are two assumptions that allow IV estimates to be consistent. First, one needs to assume relevance, i.e., that the instrument explains a sufficiently large part of the variation in the endogenous regressor. In particular, the measure of import penetration based on changes in imports in other advanced economies should be helpful in predicting changes in imports from China in the US. The intuition is to capture the part of rise in imports from China which is related to China's rising competitiveness and open market reforms. 

* The second assumption is exogeneity of the instrument, which comprises randomness and exclusion restriction. Regarding randomness, the instrument must be uncorrelated with the error in the structural equation. This means that the rise in Chinese imports in advanced economies is not correlated with possible unobservables explaining change in manufacturing labour market outcomes at a local level. Additionally, the authors take the lagged local shares of employment as a way to net out simultaneity bias and try to get a measure of the shares which as exogenous as possible. Exclusion restriction holds that the instrument must affect the labour market outcomes only through the changes in Chinese imports in the US. 

* Autor et al (2013) also discuss how they can tackle some potential threats to their IV strategy. Although this discussion is not strictly speaking related to identifying assumptions, it is still important to provide a rationale for their instrument. One key assumption for identification is that the common within-industry component of the rise in Chinese imports to advanced economies (US included) is due to lower trade costs in these sectors or China's rising comparative advantage. To put it simply, this rise in imports from China must be due to factors which are exogenous to conditions specific to US and other advanced economies, such as demand or productivity shocks. In this respect, Autor et al. (2013) claim there are three threats to their IV strategy. First, product demand shocks may be correlated across high-income countries. If this is the case, that is if demand conditions are correlated with import growth, then the IV (as well as the OLS) estimates will be downwardly biased. In other words, the estimated effect of rising import competition on labor market outcomes will be smaller than what they actually are, since we cannot net out the effect of demand conditions on labor market outcomes. The authors rule out this problem by estimating a gravity model which nets out demand conditions. Second, productivity shocks in the United States may be an important driver of Chinese imports from other countries. Similarly to the first point, this would be a problem since American market conditions would be correlated with the rise in imports from China, and would be of course correlated with US labor market outcomes. Third, technology shocks common to high-income countries may adversely affect labor markets, making them vulnerable to import competition from China. For the second and the third problems, the authors claim they cannot rule out empirically these hypotheses. However, they argue that much literature has documented that a strong driver of the rise in imports from China is related to Chinese impressive productivity growth. 

* As said above, Autor et al. (2013) emphasize exoegeneity of the shocks more than exogeneity of the shares. However, Goldsmith-Pinkham et al. (2020) argue that in the setting analyzed in the 2013 paper, an identification strategy that relies more on the exogeneity of the shares is best suited. First of all, they highlight that, although shares are equilibrium objects related to the levels of the dependent variable, as long as they are exogenous to changes in the outcomes, their exogeneity can be leveraged to explain identification. In their paper, they first show that a TSLS instrument based on exogeneity of the shares is equivalent to a GMM estimator in which the local shares are the instruments and the weight matrix is constructed with the national growth rates. Moreover, they claim that in a context in which the research design emphasizes differential exogenous exposure to common shocks and in which shocks to specific industries are very important the exogeneity of the shares seems more important than the shocks. These two features, they claim, are exactly present in Autor et al. (2013) paper. Their estimation strategy is a bit different as they estimate k-level 2SLS estimates, using for each industry k the share of employment as an instrument. They then aggregate these estimates with a convex combination to obtain the Bartik instrument, where weights are Rotemberg weights and sum to 1. If one were to interpret Autor et al. (2013) paper in light of this strategy, the assumptions for identification would slightly change. Relevance would mean that there must be an industry k and a period when the share of employment in industry k predicts the endogenous regressor (i.e. measure of local import penetration from China), conditional on controls. The growth rates in this case, acting as weights in the covariances, must not cancel out these effects. About exogeneity, which as usual comprises randomness and exclusion restriction, states that the industry share for industries that have nonzero national growth rates must not correlate with unobservables in the regression, conditional on controls. 

* Finally, to conclude the discussion, Goldsmith-Pinkham et al. (2020) argue that there are several reasons to construct identification on exogeneity of the shares in Autor et al. (2013) setting. First of all, when unpacking the estimator into k-level estimates, they noticed that the industries whose weights are larger are different than the ones emphasized by the authors in the 2013 paper. In particular, these are industries which are highly technology-intensive, rather than being the low-skilled employing ones. Second, the growth rates explain less than 20 percent of the variation in the Rotemberg weights, suggesting that these are an imperfect way to understand which industries drive the estimate. Third, the paper is about a common exogenous shock, not about many independent shocks. Fourth, it focuses on specific industries. However, the authors recognize that instrumenting the change in US imports from China with the change in imports from China in other advanced economies is a good way to isolate the industries in which China experienced the most rapid productivity gains. All in all, depending on the arguments proposed, one could say that it is better to ground the justification of the Bartik instrument on the exogeneity of the shares or of the shocks. Depending on this choice, the identifying assumptions would be slightly different, even though the logic of both would remain the same. 



* (b) In case of heterogenous effects (effects that vary across location or time), we need extra assumptions. Again, as in point (a), we start by considering the assumptions from the viewpoint of Autor et al. (2013) identification strategy. In this case, we would have the structural equation at the location level, thus allowing for different treatment effects across locations. As a consequence, the first stage equation would also be at the location level. In other words, we will have, for both the structural and the FS regressions, as many equations as regions. First of all, as highlighted by Goldsmith-Pinkham et al. (2020), we can only talk about a "restricted" heterogeneity, i.e. we need to assumme that identically sized shocks have the same effect across locations (constant linear effects), regardless of the employment level in each commuting zone. The assumption we need in this setting is one equivalent to "monotonicity". In particular, we need to assume that the coefficients of the first stage all have (weakly) the same sign. This means that each region should respond in the same direction as all the others to the same common exogenous shock to import competition from China. Moreover, we also need that, conditional on controls, the expecation of the product between the location-specific instrument, the error term of the FS and the location-specific treatment effect is equal to 0. 

* However, the framework presented by Goldmsith-Pinkham et al. (2020) is probably best suited to study heterogeneity in treatment effects in the setting proposed by Autor et al. (2013). Therefore, it is worth discussing which assumptions would be needed if one were to adopt their identification strategy. Goldsmith-Pinkham et al. (2020), as said above, rely on exogeneity of the shares to justify identification. Therefore, all the discussions are at the industry k level. When looking at heterogeneity, they indeed propose industry-location specific instruments. According to the authors, identification is guaranteed if the Bartik coefficient is the result of a convex combination of each region-specific treatment effect. The additional assumptions they need to make are: (i) for every industry, the coefficients of each industry-location specific FS are all (weakly) of the same sign across all locations; (ii) conditional on controls, the expecation of the product between the industry-location specific instrument, the error term of the FS and the location-specific treatment effect is equal to 0. 

* The authors prove that the IV estimates represent a convex combination of location-specific treatment effect coefficients. Indeed, each instrument will estimate a parameter (\beta_k) which is a weighted average of location-specific parameters (where weights are \omega_lk and coefficients are location-specific \beta_l). To get the Bartik estimate when we account for heterogeneity, we need to aggregate the different \beta_k across different industries with weights equal to the Rotemberg weights (\alpha_k). If the inner product between the location-industry specific weights (\omega_lk) and the Rotemberg weights (\alpha_k) is nonnegative, the Bartik is a convex combination of the location-specific parameters and can thus preserve a LATE-like interpretation. While the assumptions above guarantee that the industry-location specific weights are all positive, Rotemberg weights are allowed to be negative. If however these are such that they make the aggregation a non-convex combination, then one would lose, in case of heterogenous treatment effects, the interpreation of the Bartik estimate as a LATE. If the \beta_k are all very similar, it is unlikely to get negative industry-location specific weights. If instead they are very different, this is potentially concerning since it could lead to negative final weights. 

* As explained above, the framework employed by Goldmsith-Pinkham et al. (2020) is well suited to study treatment effects across locations in a setting such as the one in Autor et al. (2013). Clearly, one need to reason in terms of industry-location specific instrument, as their analysis always relies on exogeneity of the shares and it is thus always at the industry k level.



* Question 2



set scheme s1color



set matsize 2000


/*** AKM ADH Data **/
insheet using "exercise_2/ADHdata_AKM.csv", clear
gen year = 1990 + (t2=="TRUE")*10
drop t2

/*** BHJ SHARES **/
merge 1:m czone year using exercise_2/Lshares.dta, gen(merge_shares)
/*** BHJ SHOCKS **/
merge m:1 sic87dd year using "exercise_2/shocks.dta", gen(merge_shocks)

rename ind_share share_emp_ind_bhj_
gen z_ = share_emp_ind_bhj_ * g
rename g g_
drop g_emp_ind-g_importsUSA
reshape wide share_emp_ind_bhj_ g z_, i(czone year) j(sic87dd)
egen z = rowtotal(z_*)


local controls reg_* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource l_shind_manuf_cbp t2
local weight weight

local y d_sh_empl_mfg 
local x shock
local z z


local ind_stub share_emp_ind_bhj_
local growth_stub g_

local time_var year
local cluster_var czone

levelsof `time_var', local(years)

/** g_2141 and g_3761 = 0 for all years **/
drop g_2141 `ind_stub'2141
drop g_3761 `ind_stub'3761

forvalues t = 1990(10)2000 {
	foreach var of varlist `ind_stub'* {
		gen t`t'_`var' = (year == `t') * `var'
		}
	foreach var of varlist `growth_stub'* {
		gen t`t'_`var'b = `var' if year == `t'
		egen t`t'_`var' = max(t`t'_`var'b), by(czone)
		drop t`t'_`var'b
		}
	}

tab division, gen(reg_)
drop reg_1
tab year, gen(t)
drop t1

drop if czone == .

foreach var of varlist `ind_stub'* {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	qui regress `x' `temp' `controls' [aweight=`weight'], cluster(czone)
	local pi_`ind' = _b[`temp']
	qui test `temp'
	local F_`ind' = r(F)
	qui regress `y' `temp' `controls' [aweight=`weight'], cluster(czone)
	local gamma_`ind' = _b[`temp']
	drop `temp'
	}

foreach var of varlist `ind_stub'3571 `ind_stub'3944 `ind_stub'3651 `ind_stub'3661 `ind_stub'3577 {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	ch_weak, p(.05) beta_range(-10(.1)10)   y(`y') x(`x') z(`temp') weight(`weight') controls(`controls') cluster(czone)
	disp r(beta_min) ,  r(beta_max)
	local ci_min_`ind' =string( r(beta_min), "%9.2f")
	local ci_max_`ind' = string( r(beta_max), "%9.2f")
	disp "`ind', `beta_`ind'', `t_`ind'', [`ci_min_`ind'', `ci_max_`ind'']"
	drop `temp'
	}


preserve
keep `ind_stub'* czone year `weight'
reshape long `ind_stub', i(czone year) j(ind)
gen `ind_stub'pop = `ind_stub'*`weight'
collapse (sd) `ind_stub'sd = `ind_stub' (rawsum) `ind_stub'pop `weight' [aweight = `weight'], by(ind year)
tempfile tmp
save `tmp'
restore

bartik_weight, z(t*_`ind_stub'*)    weightstub(t*_`growth_stub'*) x(`x') y(`y') controls(`controls'  ) weight_var(`weight')

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)
qui desc t*_`ind_stub'*, varlist
local varlist = r(varlist)



clear
svmat beta
svmat alpha
svmat gamma
svmat pi
svmat G

gen ind = ""
gen year = ""
local t = 1
foreach var in `varlist' {
	if regexm("`var'", "t(.*)_`ind_stub'(.*)") {
		qui replace year = regexs(1) if _n == `t'
		qui replace ind = regexs(2) if _n == `t'
		}
	local t = `t' + 1
	}


total alpha1 if year == "1990"
mat b = e(b)
local sum_1990_alpha = string(b[1,1], "%9.3f")
total alpha1 if year == "2000"
mat b = e(b)
local sum_2000_alpha = string(b[1,1], "%9.3f")

sum alpha1 if year == "1990"
local mean_1990_alpha = string(r(mean), "%9.3f")
sum alpha1 if year == "2000"
local mean_2000_alpha = string(r(mean), "%9.3f")

destring ind, replace
destring year, replace
merge 1:1 ind year using `tmp'
gen beta2 = alpha1 * beta1
gen indshare2 = alpha1 * (`ind_stub'pop/`weight')
gen indshare_sd2 = alpha1 * `ind_stub'sd
gen G2 = alpha1 * G1
collapse (sum) alpha1 beta2 indshare2 indshare_sd2 G2 (mean) G1 , by(ind)
gen agg_beta = beta2 / alpha1
gen agg_indshare = indshare2 / alpha1
gen agg_indshare_sd = indshare_sd2 / alpha1
gen agg_g = G2 / alpha1
rename ind sic
merge 1:1 sic using "exercise_2/sic_code_desc"
rename sic ind
keep if _merge == 3
gen ind_name = subinstr(description, "Not Elsewhere Classified", "NEC", .)
replace ind_name = subinstr(ind_name, ", Except Dolls and Bicycles", "", .)

gsort -alpha1



* (a) Distributions of the Rotemberg weights

hist alpha1, normal xtitle("Rotemberg Weights")
graph export "FigureA1.png", replace






gen F = .
gen agg_pi = .
gen agg_gamma = .
levelsof ind, local(industries)
foreach ind in `industries' {
	capture replace F = `F_`ind'' if ind == `ind'
	capture replace agg_pi = `pi_`ind'' if ind == `ind'
	capture replace agg_gamma = `gamma_`ind'' if ind == `ind'		
	}




/** Figures **/
gen omega = alpha1*agg_beta
total omega
mat b = e(b)
local b = b[1,1]

gen label_var = ind 
gen beta_lab = string(agg_beta, "%9.3f")


gen abs_alpha = abs(alpha1) 
gen positive_weight = alpha1 > 0
gen agg_beta_pos = agg_beta if positive_weight == 1
gen agg_beta_neg = agg_beta if positive_weight == 0
twoway (scatter agg_beta_pos agg_beta_neg F if F >= 5 [aweight=abs_alpha ], msymbol(Oh Dh) ), legend(label(1 "Positive Weights") label( 2 "Negative Weights")) yline(`b', lcolor(black) lpattern(dash)) xtitle("First stage F-statistic")  ytitle("{&beta}{subscript:k} estimate")
graph export "FigureA2.png", replace

gsort -alpha1
twoway (scatter F alpha1 if _n <= 5, mcolor(dblue) mlabel(ind_name  ) msize(0.5) mlabsize(2) ) (scatter F alpha1 if _n > 5, mcolor(dblue) msize(0.5) ), name(a, replace) xtitle("Rotemberg Weight") ytitle("First stage F-statistic") yline(10, lcolor(black) lpattern(dash)) legend(off)
graph export "FigureA3.png", replace




* (c)
*First of all, Goldsmith-Pinkham et al. (2020) show that there is a difference in the estimates between two-step estimators and ML, OLS and other estimators. This is potentially concerning and may be evidence of misspecification. However, one could also think that this is due to underlying heterogeneity across industries in the treatment effect, as explained in section IV of their paper. In this respect, looking at the two figures we see heterogeneity in the treatment effect in the different industries. However, even though the variability is indeed present, this type of heterogeneity is less worrisome. In particular, less dispersion in point estimates among high-powered industries seems to be present. Also, industries with higher weights are clustered closely to the overall point estimate. This means that, although present, the heterogeneity does not preclude us to interpret the coefficient as a LATE. Finally, one needs also to check if there are negative Rotemberg weights and if these are important in the overall computation of the Bartik estimate. In this respect, the authors claim that, while there are negative weights, these industries account for a relatively small share of the overall weight, suggesting that it is unlikely to get negative weights on some location-specific parameters. 







/** Panel A:  Weighted Betas by alpha weights **/
preserve
	gen agg_beta_weight = agg_beta * alpha1

	collapse (sum) agg_beta_weight alpha1 (mean)  agg_beta, by(positive_weight)
	egen total_agg_beta = total(agg_beta_weight)
	gen share = agg_beta_weight / total_agg_beta
	gsort -positive_weight
	local agg_beta_pos = string(agg_beta_weight[1], "%9.3f")
	local agg_beta_neg = string(agg_beta_weight[2], "%9.3f")
	local agg_beta_pos2 = string(agg_beta[1], "%9.3f")
	local agg_beta_neg2 = string(agg_beta[2], "%9.3f")
	local agg_beta_pos_share = string(share[1], "%9.3f")
	local agg_beta_neg_share = string(share[2], "%9.3f")
restore


/** Panel B:  Weighted Betas by alpha weights **/


gen agg_beta_weight = agg_beta * alpha1
egen total_agg_beta = total(agg_beta_weight)
gen beta_share = agg_beta_weight / total_agg_beta


foreach ind in 3571 3944 3651 3661 3577 {
	
	*Mean of the alpha for a given Industry
	qui sum alpha1 if ind == `ind'
    local alpha_`ind' = string(r(mean), "%9.3f")
	*Mean of g for a given Industry
	qui sum agg_g if ind == `ind'	
	local g_`ind' = string(r(mean), "%9.3f")
	*Mean of beta for a given Industry
	qui sum agg_beta if ind == `ind'	
	local beta_`ind' = string(r(mean), "%9.3f")
	*Industry Share
	qui sum agg_indshare if ind == `ind'
	local share_`ind' = string(r(mean)*100, "%9.3f")
	*Beta Share
	qui sum beta_share if ind == `ind'
	local beta_share_`ind' = string(r(mean)*100, "%9.3f")
	* Save the name of the Industry
	tempvar temp
	qui gen `temp' = ind == `ind'
	gsort -`temp'
	local ind_name_`ind' = ind_name[1]
	drop `temp'
	}

/*** Create final table **/

capture file close fh
file open fh  using "ex_2_table.tex", write replace
file write fh "\begin{table}[]" _n
file write fh "\centeringe" _n

file write fh "\begin{tabular}{lllllll}" _n

/** Panel A **/
file write fh "\multicolumn{5}{l}{\textbf{Panel A: Estimates of $\beta_{k}$ for positive and negative weights} }\\" _n
file write fh  " &  &  &  & \multicolumn{1}{c}{$\alpha$-weighted Sum} & \multicolumn{1}{c}{Share of overall $\beta$} & \multicolumn{1}{c}{Mean} \\ \cline{5-7} " _n
file write fh  "Negative &  &  &  & `agg_beta_neg' & `agg_beta_neg_share'  & `agg_beta_neg2' \\" _n
file write fh  "Positive &  &  &  & `agg_beta_pos' & `agg_beta_pos_share' & `agg_beta_pos2' \\" _n



/** Panel B **/
file write fh "\multicolumn{7}{l}{\textbf{Panel B: Top 5 Rotemberg weight industries}} \\" _n
file write fh  " & \multicolumn{1}{c}{$\hat{\alpha}_{k}$} & \multicolumn{1}{c}{$ g_{k}$} & \multicolumn{1}{c}{$\hat{\beta}_{k}$} & \multicolumn{1}{c}{95 \% CI} & \multicolumn{1}{c}{Ind Share %} & \multicolumn{1}{c}{Share of overall $\beta$ %} \\ \cline{2-7} " _n
foreach ind in 3571 3944 3651 3661 3577 {
	if `ci_min_`ind'' != -10 & `ci_max_`ind'' != 10 {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & (`ci_min_`ind'',`ci_max_`ind'')  & `share_`ind'' & `beta_share_`ind''\\ " _n
		}
	else  {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & \multicolumn{1}{c}{N/A}  & `share_`ind'' & `beta_share_`ind'' \\ " _n
		}
	}
	
	
	
	
file write fh  "\end{tabular}" _n
file write fh  "\end{table}" _n
file close fh



* Question 3

* (a) Assuming constant treatment effects, there are two assumptions that must hold in order to get identification. The first one is relevance, which is related to the first stage. In particular, we require that the instrument is able to predict a large enough part of the variation in the endogenous regressor. In other words, non-US change in import penetration from China predicts the same measure computed in the US. Notice also that, as in the 2013 paper, the instrument is constructed using the lagged measure of local industry employment share, to net out simultaneity bias concerns. The second assumption is exogeneity. This requires that the instrument is exogenous to unobservables determining political outcomes and that the only channel through which the instrument affects the political outcomes in the US is through a change in import penetration from China (the latter is the exclusion restriction).


* One concern, as with Autor et al. (2013) is that the import penetration from China measure may be correlated with import-demand shocks in the US. If this were the case, the OLS estimates will be biased. That is why the authors instrument the change in import penetration using the change in import penetration in other advanced countries. In the sample period they consider the rise in Chinese imports that is mostly due to rising competitiveness, lower trade tariffs, and the 2001 China accession to the WTO. This shows that the cause of the rise in US Chinese imports is exogenous to the US import-demand component. As in Autor et al. (2013), two other threats to the identification are: US productivity shocks and technology shocks common to all the advanced economies may drive Chinese imports, rather than supply-side elements in China. Again, they present a lot of literature documenting the fact that the stronger reasons behind the rise in imports from China are related to Chinese rise in competitiveness and improvement in productivity.


* When comparing this paper to Autor et al. (2013), we can think about whether the IV strategy is more likely to yield consistent estimates in this case or in the 2013 paper. In Autor et al. (2013), the dependent variables are labor market outcomes such as changes in unemployment, in labor force participation and in wages. In this case, it could be that there is an omitted variable, such as a productivity shock in the US, that is driving the rise in imports from China in other advanced economies and that is also correlated to labor market outcomes in the US. In the same vein, technology shocks common to the US and high-income countries could, for instance, make labor markets more exposed to import competition from China. To the extent that again these shocks are correlated to domestic labor market conditions, this would create an identification problem. In Autor et al. (2020), this can still be seen as a concern if labor market outcome changes are correlated with how people vote in congressional and presidential elections. 


* We can also try to think in which case the exclusion restriction is more likely to hold. In Autor et al. (2013), it could be that the rise in imports from China in other advanced economies affects local labor market outcomes in the US through other channels. For example, to the extent that a rise in imports from China in Europe means a decrease in imports in Europe from the United States, labor market outcomes will be affected by a different trade flow, and not by trade coming from China. This is important because different industries will be affected by this different trade flow, having thus different effects on labor markets. 


* When looking at exclusion restriction in Autor et al. (2020), one may think that the rise in imports from China in Europe may affect political preferences in these advanced economies. To the extent that communication and exchanges among these countries and US are frequent, American voters may form beliefs that lean towards conservatism because of trends already taking place in other advanced economies at the same time. If this were the case, then the instrument will be influencing political outcomes in the United States through a channel different from trade exposure. For instance, there is evidence of a wave of populism in the last 15 years in Western democracies. One could indeed claim that the success of right-wing parties was in part due to the rise of imports from China in these advanced economies and if this was, to a certain extent, pushing American voters more towards more conservatism, then the exclusion restriction would be violated. However, this channel seems implausible or at least affecting political outcomes exclusively in the long run.

* Overall, the concerns related to the exclusion restriction and exogeneity do not seem to be too worrisome in both papers. In both cases, the identification scheme seems overall strong.









