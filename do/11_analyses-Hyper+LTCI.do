use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
*****************************
**# Sample Determine
*****************************
**# Hypertension Diagnose : by four class
	tab hypertension,gen(hyper)
	
**# Blood Pressure 
	tab bpl,gen(BPL)
**# Mendatory Drop: determine sample from baseline cases 
	keep if inrange(yearin,2005,2019)
	keep if age >=65
	drop if deathstatus==1 	
	drop if gbcode ==.
	drop if wave_baseline >=18
	
	// 至少有一次处理后的观测
	gen have18 = (wave == 2018 & !inlist(市,"青岛市"))|(wave == 2014 & inlist(市,"青岛市"))
	
	bysort id: egen total18 = max(have18) 	 
	drop if total18 !=1
	
	// 至少有三次观测：repeat
	bysort id: gen count = _N
	drop if count == 1  
	
	codebook id // 3,461
	
	drop if hypertension == . |  bpl  == .
	cap drop count
	bysort id: gen count = _N
	drop if count == 1  
	
	codebook id // 2,515
			
	codebook id if treated_id == 1  //   660
	codebook id if treated_id == 0 //  2,011
	codebook id if treated == 1  //  387
	
**# hypertension group 
	gen have_hyper = hypertension >=1 if (treated_id == 1 &treated == 0) |(treated_id == 0 & yearin < 2014 )
	gen have_severehyper = hypertension >=2 if (treated_id == 1 & treated == 0) |(treated_id == 0 & yearin < 2014 )
	gen no_hyper = hypertension ==0 if (treated_id == 1 &treated == 0) |(treated_id == 0 & yearin < 2014 )
		
save	"${OUT}/analyses-Frailty Traj+LTHC_sample.dta",replace

*****************************
**# PSM by baseline situation 
*****************************
use "${OUT}/analyses-Frailty Traj+LTHC_sample.dta",clear
	bysort id: egen minwave = min(wave)
	keep if minwave == wave
// ssc install psmatch2,replace
// ssc install psestimate, replace 
**# Test adding variables  #1
psestimate treated_id gender age, totry(residence  edug marital coresidence  residence    insurancePubMed insurancePubRetire )

/* 虽然测出这种情况，但是感觉属实没有必要，因为简单模型已经通过假设了
Selected first order covariates are: insurancePubMed residence edug marital coresidence insurancePubRetire

Selected second order covariates are: c.insurancePubMed#c.insurancePubMed c.insurancePubRetire#c.insurancePubMed c.insurancePubRetire#c.insurancePubRetire c.age#c.age c.insurancePubRetire#c.age c.marital#c.marital c.coresidence#c.insurancePubMed c.marital#c.residence c.marital#c.edug c.marital#c.age
Final model is: gender age insurancePubMed residence edug marital coresidence insurancePubRetire c.insurancePubMed#c.insurancePubMed c.insurancePubRetire#c.insurancePubMed c.insurancePubRetire#c.insurancePubRetire c.age#c.age c.insurancePubRetire#c.age c.marital#c.marital c.coresidence#c.insurancePubMed c.marital#c.residence c.marital#c.edug c.marital#c.age
*/

**# PS value & common support assumption  #1
global match 	gender age  residence  edug marital coresidence   insurancePubMed insurancePubRetire 
psmatch2 treated_id $match , kernel out(hypertension ) comm logit
psmatch2 treated_id $match , kernel out(hypertension bpl) comm logit

**# test balancing assumption #2
pstest $match , t(treated_id)
**# visualization: common support #3
psgraph

**# regression comparasion #4
reg hypertension treated_id $match 
reg hypertension treated_id $match [pw=_w]


*****************************
**# Descriptive Analyses
*****************************	
use "${OUT}/analyses-Frailty Traj+LTHC_sample.dta",clear	
**# Table1: Baseline year charactistics by treatment status
	bysort id: egen minwave = min(wave)
	keep if minwave == wave

	table1,  by(treated_id) vars(gender cat\ age contn \  hypertension cat\ bpl  cat\ SBP contn \ DBP  contn \ ///
\ residence cat \ edug cat\ marital cat\ coresidence cat\  residence  cat\   insurancePubMed cat\ insurancePubRetire  cat\) format(%2.1f) one mis saving("${RSL}/DS1.xls", replace) 

**# Check if hypertension have pre-treatment baseline difference -- Logit regression
	logit hypertension treated_id age gender  marital edug coresidence residence  insurancePubMed  insurancePubRetire  if year_id ==0,cluster(省)  robust  // treated_id |   .0407211    .129168     0.32   0.753    -.2124436    .2938857 更接近认知一点,没有显著差异
	logit bpl treated_id age gender  marital edug coresidence residence  insurancePubMed  insurancePubRetire  if year_id ==0,cluster(省)  robust  // treated_id |   .0407211    .129168     0.32   0.753    -.2124436    .2938857 更接近认知一点,没有显著差异
	
**# PSM matching 


**# Check if hypertension have pre-treatment baseline difference -- 

**# Figure 
	
*****************************
**# First Regression 
*****************************	
use "${OUT}/analyses-Frailty Traj+LTHC_sample.dta",clear	
**# Adjust treated by ADL, disable
	


**# Test baseline year charactistics



**# SDID matching 

**# Bookmark #10


**# 0 regression: phenomenon  hypertension worse off?? no 
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  
	diff bpl, t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  // 0.114   | 0.057   | 2.00    | 0.047** 
**# First regression part one: the newly diagnose of hypertension 
	preserve
		bysort id: egen maxhave_hyper= max(have_hyper) 
		bysort id: egen maxhave_severehyper= max(have_severehyper) 
		bysort id: egen maxno_hyper= max(no_hyper) 
		drop if maxhave_hyper== 1
		recode hypertension (1/4 = 1)
		
		diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  
	restore
	
**# First regression part one: the newly diagnose of hypertension 
	preserve
		bysort id: egen maxhave_hyper= max(have_hyper) 
		bysort id: egen maxhave_severehyper= max(have_severehyper) 
		bysort id: egen maxno_hyper= max(no_hyper) 
		drop if maxhave_hyper== 1
		recode bpl (1 2 3 = 0) ( 4 5 =1)
		diff bpl, t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  
	restore	
	
**# First regression part two: the severe diagnose of hypertension
	preserve
		bysort id: egen maxhave_hyper= max(have_hyper) 
		bysort id: egen maxhave_severehyper= max(have_severehyper) 
		bysort id: egen maxno_hyper= max(no_hyper) 
		
		drop if maxno_hyper== 1
		diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  
	restore
	
	preserve
		bysort id: egen maxhave_hyper= max(have_hyper) 
		bysort id: egen maxhave_severehyper= max(have_severehyper) 
		bysort id: egen maxno_hyper= max(no_hyper) 
		drop if maxno_hyper== 1
		recode bpl (1 2 3 = 0) ( 4 5 =1)
		
		diff bpl,t(treated_id) p(year_id) kernel id(id)  cov(age  marital     insurancePubMed insurancePubRetire ) cluster(省) robust  
	restore	
		
**# First regression part one: the work to 



	
*****************************
**# Sensitivity Analyses
*****************************	
**# Test different definition of disabled
**# Test different diagnose of hypertension (if eco)

**# Test different diagnose of hypertension (if eco)


*****************************
**# Mechanism Analyses
*****************************	
