clear
cd "$box/loglinear/loglinear DID/JOE-4th/imputation"
capture cls
*******Part 1: Some Data Cleaning******
	
use "watersheds_dataset.dta", clear //this is the original data from Alsan and Goldin (2019).
gen wateronly=water==1&sewerage==0  // dummy for only having water in that year
gen sewerageonly=water==0&sewerage==1 // dummy for only having sewerage in that year
egen startyear=rowmax(year_MSDjoin year_MWDjoin) if both==1 // the first year with both systems

gen refy=year-startyear // event time
tab refy
recode refy (-30/-10=-6) (-9/-8= -5) (-7/-6=-4) (-5/-4=-3) (-3 -2=-2) (-1=-1) (0 1=0) (2 3=1) (4 5=2) (6 7=3) (8 9 =4) (10/30=5),gen(refbin) // recode event time into bins as in Alsan and Goldin (2019).

gen treated=refbin>=0&refbin~=.
keep log_u5_MR wateronly sewerageonly percent_foreign percent_male percent_female_mfg log_pop_density nummunicipality year treated refbin startyear
save rep_AG,replace
*******Part 2: Estimation***************
******************Regression************
use rep_AG,clear

global controls percent_foreign percent_male percent_female_mfg log_pop_density // additional control variables

capture drop yhat te expte
regress log_u5_MR wateronly sewerageonly $controls i.nummunicipality i.year i.nummunicipality#c.year if treated==0, ///
vce(cluster nummunicipality) 

predict yhat,xb
gen te=log_u5_MR-yhat if treated==1
gen expte=exp(te)-1

**********************************Save and format the results table in Latex*******************************
tempname impest
local l=1
postfile `impest' modnum str20 aggtype ynum taubar_b rhoa_b rhob_b using AG2019_imputation, replace

*****ATET****
quietly summarize te if treated==1, meanonly
local taubar_b=r(mean)
local rhoa_b=exp(`taubar_b')-1
quietly summarize expte if treated==1, meanonly
local rhob_b=r(mean)
post `impest' (`l') ("all") (0) (`taubar_b') (`rhoa_b') (`rhob_b')
local l=`l'+1

*****For each event time
forvalues j=0/5{
	quietly summarize te if refbin==`j', meanonly
	local taubar_b=r(mean)
	local rhoa_b=exp(`taubar_b')-1
	quietly summarize expte if refbin==`j', meanonly
	local rhob_b=r(mean)
	post `impest' (`l') ("event") (`j') (`taubar_b') (`rhoa_b') (`rhob_b')
	local l=`l'+1
}

*****For each cohort
foreach j of numlist 1898 1899 1901 1902 1903{
	quietly summarize te if startyear==`j'&refbin>=0, meanonly
	local taubar_b=r(mean)
	local rhoa_b=exp(`taubar_b')-1
	quietly summarize expte if startyear==`j'&refbin>=0, meanonly
	local rhob_b=r(mean)
	post `impest' (`l') ("cohort") (`j') (`taubar_b') (`rhoa_b') (`rhob_b')
	local l=`l'+1
}

postclose `impest'

use AG2019_imputation,clear
gen taubar=strofreal(taubar_b*100,"%9.1fc")
gen rhoa=strofreal(rhoa_b*100,"%9.1fc")
gen rhob=strofreal(rhob_b*100,"%9.1fc")
tostring ynum, gen(rowlabel)
replace rowlabel="" if aggtype=="all"
order modnum aggtype ynum rowlabel taubar rhoa rhob taubar_b rhoa_b rhob_b
save AG2019_imputation,replace

local outfile "../AG2019_imputation.tex"
tempname tab
file open `tab' using "`outfile'", write replace
file write `tab' "  \begin{table}[h!] \begin{center} \small \caption{Imputation-Based Estimates for the Alsan and Goldin (2019) Application} \label{tab:AG2019_imputation}  \begin{threeparttable}  \begin{tabular}{cccc} \hline \hline &\hspace{20pt} $\hat{\bar{\tau}}^{imp} \hspace{20pt} $ & $ \hspace{20pt} \hat{\rho}_{a}^{imp} \hspace{20pt} $ & $\hspace{20pt} \hat{\rho}_{b}^{imp} \hspace{20pt} $ \\ \hline " _n
file write `tab' "\multicolumn{4}{c}{\textit{ATT for All Treated Units}} \\" _n
forvalues i=1/`=_N' {
	if aggtype[`i']=="all" {
		local tau=taubar[`i']
		local rhoa=rhoa[`i']
		local rho=rhob[`i']
		file write `tab' "&`tau'&`rhoa'&`rho'\\" _n
	}
}
file write `tab' "\multicolumn{4}{c}{\textit{ATT by Event Time}} \\" _n
forvalues i=1/`=_N' {
	if aggtype[`i']=="event" {
		local row=rowlabel[`i']
		local tau=taubar[`i']
		local rhoa=rhoa[`i']
		local rho=rhob[`i']
		file write `tab' "`row'&`tau'&`rhoa'&`rho'\\" _n
	}
}
file write `tab' "\multicolumn{4}{c}{\textit{ATT by Cohort}} \\" _n
forvalues i=1/`=_N' {
	if aggtype[`i']=="cohort" {
		local row=rowlabel[`i']
		local tau=taubar[`i']
		local rhoa=rhoa[`i']
		local rho=rhob[`i']
		file write `tab' "`row'&`tau'&`rhoa'&`rho'\\" _n
	}
}
file write `tab' " \hline \hline \end{tabular} \begin{tablenotes} \footnotesize" _n
file write `tab' "\item 1. This table reports imputation-based estimates for the Alsan and Goldin (2019) application. \item 2. Estimates are reported for $\hat{\bar{\tau}}^{imp}$, computed as the mean of $\widehat{\tau}_{it}^{imp}$; $\hat{\rho}_{a}^{imp}=\exp(\hat{\bar{\tau}}^{imp})-1$; and $\hat{\rho}_{b}^{imp}$, computed as the mean of $\exp(\widehat{\tau}_{it}^{imp})-1$ over the relevant treated post-treatment cells. All values are multiplied by 100. \item 3. Panel 1 presents ATT for all treated units. Panel 2 presents ATT by event time $0,1,\ldots,5$. Panel 3 presents ATT by cohort. Standard errors are not reported." _n
file write `tab' "\end{tablenotes} \end{threeparttable} \end{center} \end{table}" _n
file close `tab'


