clear

*******Part 1: Some Data Cleaning******
	
use "watersheds_dataset.dta", clear //this is the original data from Alsan and Goldin (2019).
gen wateronly=water==1&sewerage==0  // dummy for only having water in that year
gen sewerageonly=water==0&sewerage==1 // dummy for only having sewerage in that year
egen startyear=rowmax(year_MSDjoin year_MWDjoin) if both==1 // the first year with both systems

gen refy=year-startyear // event time
tab refy
recode refy (-30/-10=-6) (-9/-8= -5) (-7/-6=-4) (-5/-4=-3) (-3 -2=-2) (-1=-1) (0 1=0) (2 3=1) (4 5=2) (6 7=3) (8 9 =4) (10/30=5),gen(refbin) // recode event time into bins as in Alsan and Goldin (2019).


// Genearge dummies for cohort-time 
foreach c of numlist 1898 1899 1901 1902 1903{
	foreach r of numlist 2/6{ // 					-1 year is omitted as reference year
		gen g`c'pre`r'=startyear==`c'&refbin==-`r'  
	}
		foreach r of numlist 0/5{
		gen g`c'post`r'=startyear==`c'&refbin==`r'
	}
}
keep log_u5_MR wateronly sewerageonly g*post* g*pre* percent_foreign percent_male percent_female_mfg log_pop_density nummunicipality year
save rep_AG,replace
*******Part 2: Estimation***************
******************Regression************
use rep_AG,clear

global controls percent_foreign percent_male percent_female_mfg log_pop_density // additional control variables

* g*post* are cohort-time dummies for post-treatment periods, e.g. g1898post0 is the dummy for cohort 1898 in post treatment period 0.
* g*pre* are cohort-time dummies for pre-treatment periods. pre1 is omitted as -1 period is the reference period.

reghdfe log_u5_MR wateronly sewerageonly g*post* g*pre* $controls, vce(cluster nummunicipality) absorb(nummunicipality year nummunicipality#c.year)


*********ATET***************
qui	des g*post*,varlist
global groupvars=r(varlist) 
ate_pct $groupvars,truew

************Treatment Eeffect By Event Time***********

forvalues r=0/5{
global groupvars "g*post`r'"
ate_pct $groupvars,truew
}

************Treatment Eeffect By Cohort***********
foreach g of numlist 1898 1899 1901 1902 1903{
global groupvars "g`g'post*"
ate_pct $groupvars,truew
}


