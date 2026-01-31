clear
clear all
set more off
cls
capture log close
cd "$box/loglinear/loglinear DID/code_logdid/Code for ATE in pct/Empirical Applications"

*******************Some data cleaning following Atkin et al.(2017)*******************
/*
use "analysis.dta", clear // this is the orignal data from Atkin et al.(2017)
gen dub=0
/*round 100 and round 200 are baseline rounds for sample 1 and 2 resepctvily */
replace dub=1 if inlist(strata,21,22,23,24) & !inlist(round,100,200) // sample 1 
replace dub=2 if inlist(strata,1,2,3,4) & !inlist(round,100,200) // sample 2

keep if dub>0 // focus on the joint sample of dub firms
keep if round<300 // rounds>=300 are not experiments For rounds>=300, profit measures are missing.

drop if round==110|round==105
save rep_atk,replace
*/
*************************Generate Dummies for Treatment Group*************************
use rep_atk,clear
qui tab strata,gen(dstrata) // strata dummies
	
foreach v of varlist dstrata*{
  gen gr_`v'=tp*`v' // treatment group dummies are interaciton term between treatment dummy "tp" and strata dummy
}
qui des gr_*,varlist
local groupvars=r(varlist) // dummies for 8 sub-treatment groups.

local ylist="profit_rug_business rug_profits m2_month_profits hypo_profits profit_rug_business_hr rug_profits_hr m2_month_profits_hr hypo_profits_hr meter_profits lwlm hours_last_month capital_clean5 weight_sidda "

foreach y of local ylist{
	
*(1) First run regression allowing for treatment effect heterogenity by Stata.
qui reg log_`y' i.strata i.round gr_* log_`y'_b, cluster(id) 

*(2) Next calculate the ATE in percentage points.
ate_pct `groupvars'
}
