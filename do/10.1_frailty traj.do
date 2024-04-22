*** traj
* edit based on the latest dataset
use "${OUT}/analyses.dta",clear

	drop if deathstatus == 1
	
	keep id wave  frailID frailmissingver1 

	replace frailID = . if frailmissingver1  >=10
	
	drop frailmissingver1
	
	reshape wide frailID,i(id ) j(wave)
	
save "${OUT}/analyses_frailty.dta",replace	
export delimited using "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses_frailty.csv", replace
