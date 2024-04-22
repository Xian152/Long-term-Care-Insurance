use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
//FRAhypert FRAstrok  FRAcopd FRAtb FRAulcer FRAulcer FRAdiabetes  FRAparkinson 	
	drop if deathstatus==1
	keep if age >=65
	keep if inrange(yearin,2005,2019)
	bysort id: egen minyear = min(yearin)
	/*keep if minyear == yearin
	
	drop if yearin >=2014
	
	bysort treated_id : sum bpl SBP DBP
	keep if 
	*/
	gen bpl_base1 = bpl if minyear == yearin
	bysort id: egen bpl_base = max(bpl_base1)
	keep if inlist(bpl_base,0,1,2,3)
	
	codebook id //7,970  
	
	* adjust for disable person
		* disease disable 
		gen disable_disase = .
		foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
			replace disable_disase = 1 if `k' == 1
		}
		egen diseasemiss = rowmiss(hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis)
		replace disable_disase = . if diseasemiss == 14
		recode disable_disase  (.=0)

		* disease disable 	轻度
		gen disable_ADL = adlSum >0  if adlSum!=.  
		gen disable_IADL = iadlSum >0  if iadlSum!=.
		
		* disable ci
		gen disable_ci = ciBi 
		replace disable_ci  = . if ciMissing >= 2	
	
		** disable general
		gen disable = disable_ci==1 | disable_ADL==1 |disable_IADL ==1 |disable_disase == 1 if disable_ci!=.  & disable_ADL!=.  & disable_IADL!=.  & disable_disase !=.  
	
		* 调整成处理前的全人群
		bysort id: egen sumdisable_ADL = sum(disable_ADL) 	
		keep if	sumdisable_ADL >0 
		
		foreach k in disable_disase disable_ci disable_IADL disable_ADL disable {
			gen `k'_2014 = `k' if wave ==2014 |wave ==2011
			bysort id: egen `k'_pre = sum(`k'_2014)
		}
		
		* 调整treatement 
		replace treated = 0 if disable ==0
	
	* drop 已经严重的人
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
		gen severe_`k' = inlist(`k', 2,.) & treated == 0 
		replace severe_`k' =  . if treated == 1
	}
	
	egen anysevere = rowtotal(severe*),mi
	
	codebook id if treated_id ==1 & anysevere==0  //703 288  
	codebook id if treated_id == 0 & anysevere == 0  //11,937   2,391       
	
	drop if severe_hypertension >0 & severe_hypertension!=.
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // 0.307   | 0.108   | 2.83    | 0.005***
//adl fine  0.463   | 0.099   | 4.69    | 0.000***	
//iadl fine 0.481   | 0.098   | 4.93    | 0.000***
//disable fine 0.478   | 0.080   | 5.94    | 0.000***
xx


// not significant in 1-2, i.e. not worse off 1-2: yes!	
use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
	keep if inrange(yearin,2005,2019)

	* age
	keep if age >=65
	
	* drop deseased sample
	drop if deathsample==1
	

	
	bysort treated_id : sum hypertension
	ttest hypertension if year_id ==0, by(treated_id)
	
	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==0,cluster(市) robust  // treated_id |   .0407211    .129168     0.32   0.753    -.2124436    .2938857 更接近认知一点,没有显著差异
	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==1,cluster(市) robust  // treated_id |  -.0690653   .3453461    -0.20   0.841    -.7459313    .6078007

xx	
	
	recode hypertension (1 2 = 1 )
	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==0,cluster(市) robust  // treated_id |   .0407211    .129168     0.32   0.753    -.2124436    .2938857 更接近认知一点,没有显著差异
	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==1,cluster(市) robust  // treated_id |  -.0690653   .3453461    -0.20   0.841    -.7459313    .6078007

	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==0,cluster(省) robust  //treated_id |   .0407211   .1464581     0.28   0.781    -.2463315    .3277736 更接近认知一点,没有显著差异
	logit hypertension treated_id age gender  marital edug coresidence residence if year_id ==1,cluster(省) robust  //treated_id |  -.0690653   .3373665    -0.20   0.838    -.7302916     .592161

	
	reg bpl treated_id age gender  marital edug coresidence residence if year_id ==0,cluster(市) robust  //treated_id |   .2862254   .1341651     2.13   0.034     .0215063    .5509444  血压本来就更高
	reg bpl treated_id age gender  marital edug coresidence residence if year_id ==1,cluster(市) robust  // treated_id |   .0674796   .0336602     2.00   0.073      -.00752    .1424791 下去了

	reg bpl treated_id age gender  marital edug coresidence residence if year_id ==0,cluster(省) robust  // treated_id |   .2862254   .1400943     2.04   0.054    -.0051166    .5775674
	reg bpl treated_id age gender  marital edug coresidence residence if year_id ==1,cluster(省) robust  // treated_id |   .0674796   .0345888     1.95   0.083    -.0107657    .1457248
	
	
	
use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
*********************************************************
**************** determine sample	**************
*********************************************************
	keep if inrange(yearin,2005,2019)
	* age
	keep if age >=65
	
	* drop deseased sample
	drop if deathsample==1

	* drop 已经严重的人
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
		gen severe_`k' = inlist(`k', 2,.) & treated == 0 
		replace severe_`k' =  . if treated == 1
	}
	
	egen anysevere = rowtotal(severe*),mi
	
	codebook id if treated_id ==1 & anysevere==0  //703
	codebook id if treated_id == 0 & anysevere == 0  //11,937 
	
	drop if severe_hypertension >0 & severe_hypertension!=.
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // 0.307   | 0.108   | 2.83    | 0.005***
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(省) robust  // 
 
 
// not significant in 1-2, i.e. not worse off 1-2: yes!	
use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
	keep if inrange(yearin,2005,2019)

	* age
	keep if age >=65
	
	* drop deseased sample
	drop if deathsample==1
	
	* adjust for disable person
		* disease disable 
		gen disable_disase = .
		foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
			replace disable_disase = 1 if `k' == 1
		}
		egen diseasemiss = rowmiss(hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis)
		replace disable_disase = . if diseasemiss == 14
		recode disable_disase  (.=0)

		* disease disable 	轻度
		gen disable_ADL = adlSum >0  if adlSum!=.  
		gen disable_IADL = iadlSum >0  if iadlSum!=.
		
		* disable ci
		gen disable_ci = ciBi 
		replace disable_ci  = . if ciMissing >= 2	
	
		** disable general
		gen disable = disable_ci==1 | disable_ADL==1 |disable_IADL ==1 |disable_disase == 1 if disable_ci!=.  & disable_ADL!=.  & disable_IADL!=.  & disable_disase !=.  
	
		* 调整成处理前的全人群
		bysort id: egen sumdisable_ADL = sum(disable_ADL) 	
		keep if	sumdisable_ADL >0 
		
		foreach k in disable_disase disable_ci disable_IADL disable_ADL disable {
			gen `k'_2014 = `k' if wave <=2014 
			bysort id: egen `k'_pre = sum(`k'_2014)
		}
		
		* 调整treatement 
		replace treated = 0 if disable_ADL_pre ==0
	
	* drop 没有的人
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
		gen severe_`k' = inlist(`k', 0,.) 
	}
	bysort id : egen max = max(severe_hypertension)
	drop if max >0 & max !=.
	
	codebook id if treated_id ==1 & severe_hypertension==0  // 532 
	codebook id if treated_id == 0 & severe_hypertension == 0  //7,784   

	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //   0.183   | 0.140   | 1.30    | 0.194
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(省) robust  //   0.183   | 0.168   | 1.09    | 0.289

//disable	fine  0.140   | 0.126   | 1.11    | 0.268
	
//血压确实得下降
use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
	drop if deathstatus==1
	keep if inrange(yearin,2005,2019)
	keep if age >=65
	
	diff bpl, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // -0.380  | 0.147   | 2.60    | 0.010** yes,下降！
	diff SBP, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //  5.663   | 3.079   | 1.84    | 0.067*
	diff DBP, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //  -4.711  | 3.947   | 1.19    | 0.234
		
	
// why? OP visit cheaper? 



// caregiver remind them?
use "${OUT}/analyses-Frailty Traj+LTHC.dta",clear
	keep if inrange(yearin,2005,2019)

	* age
	keep if age >=65
	
	* drop deseased sample
	drop if deathsample==1
	
	* adjust for disable person
		* disease disable 
		gen disable_disase = .
		foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
			replace disable_disase = 1 if `k' == 1
		}
		egen diseasemiss = rowmiss(hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis)
		replace disable_disase = . if diseasemiss == 14
		recode disable_disase  (.=0)

		* disease disable 	轻度
		gen disable_ADL = adlSum >0  if adlSum!=.  
		gen disable_IADL = iadlSum >0  if iadlSum!=.
		
		* disable ci
		gen disable_ci = ciBi 
		replace disable_ci  = . if ciMissing >= 2	
	
		** disable general
		gen disable = disable_ci==1 | disable_ADL==1 |disable_IADL ==1 |disable_disase == 1 if disable_ci!=.  & disable_ADL!=.  & disable_IADL!=.  & disable_disase !=.  
	
		* 调整成处理前的全人群
		bysort id: egen sumdisable_ADL = sum(disable_ADL) 	
		keep if	sumdisable_ADL >0 
		
		foreach k in disable_disase disable_ci disable_IADL disable_ADL disable {
			gen `k'_2014 = `k' if wave <=2014 
			bysort id: egen `k'_pre = sum(`k'_2014)
		}
		
		* 调整treatement 
		replace treated = 0 if disable_ADL_pre ==0
	
	* drop 没有的人
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
		gen severe_`k' = inlist(`k', 0,.) 
	}
	bysort id : egen max = max(severe_hypertension)
	drop if max >0 & max !=.
	
	codebook id if treated_id ==1 & severe_hypertension==0  // 532 
	codebook id if treated_id == 0 & severe_hypertension == 0  //7,784   

	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //   0.183   | 0.140   | 1.30    | 0.194
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(省) robust  //   0.183   | 0.168   | 1.09    | 0.289


*********************************************************
**************** determine sample	**************
*********************************************************
	* age
	keep if age >=65
	
	* drop deseased sample
	drop if deathsample==1
	
	* drop 已经严重的人
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
		gen severe_`k' = inlist(`k', 2,.) & treated == 0 
		replace severe_`k' =  . if treated == 1
	}
	
	egen anysevere = rowtotal(severe*),mi
	
	codebook id if treated_id ==1 & anysevere==0  //703
	codebook id if treated_id == 0 & anysevere == 0  //11,937 
	
*********************************************
****************  Disease **************
*********************************************
	drop if severe_hypertension >0 & severe_hypertension!=.
	diff hypertension, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // 0.287   | 0.099   | 2.89    | 0.004***
	
*********************************************************
**************** Frailty	**************
*********************************************************
/*preserve
	sort treated wave
	egen av_dk = mean(hexpFampaid), by (treated wave)
	duplicates drop treated wave, force
	keep av_dk treated wave
	reshape wide av_dk, i(wave) j(treated)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "Treated"
	label variable Controled  "Controled"
	
	twoway connected Treated  Controled wave, ytitle("PM 2.5" ) xtitle(Year) xline(2014) ylabel(,nogrid)
restore	
*/

diff frailID, t(treated_id) p(year_id) kernel id(id)  cov(age   marital edug coresidence residence) cluster(市) robust  //-0.009  | 0.013   | 0.68    | 0.499
xx
diff adlSum, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //adl 肯定没问题：-0.674  | 0.263   | 2.56    | 0.011**
diff iadlSum, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //iadl 肯定没问题：-1.360  | 0.568   | 2.40    | 0.018**
	
gen caregiverfamily = caregiverSon==1 | caregiverDaughter==1 | caregiverDinL==1 |  caregiverSinL==1 | caregiverChild==1 | caregiverGrandC==1 | caregiverOthFamily==1 		if caregiverSon!=.
diff caregiverfamily, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // 0.016   | 0.034   | 0.47    | 0.639 不显著
gen caregivernonfamilygovern = caregiverSocial==1 |  caregiverCaregiver==1  if  caregiverSocial!=.
diff caregivernonfamilygovern, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  //0.002   | 0.017   | 0.11    | 0.913
	
gen ADLcaregiverfamily = ADLcaregiverSon==1 | ADLcaregiverDaughter==1 | ADLcaregiverDinL==1 |  ADLcaregiverSinL==1 | ADLcaregiverChild==1 | ADLcaregiverGrandC==1 | ADLcaregiverOthFamily==1 		 	if ADLcaregiverSon!=.
gen ADLcaregivernonfamilygovern = ADLcaregiverSocial==1 | ADLcaregiverhousekeeper==1  if ADLcaregiverSocial!=.
diff ADLcaregiverfamily, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // -0.079  | 0.102   | 0.78    | 0.437
diff ADLcaregivernonfamilygovern, t(treated_id) p(year_id) kernel id(id)  cov(age gender  marital edug coresidence residence) cluster(市) robust  // -0.112  | 0.123   | 0.92    | 0.361
	
	
	
	foreach k in  hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
	preserve
		reg `k'  i.treated i.treated_id i.year_id age   marital edug coresidence residence, cluster(市) r
	restore
	}			
*********************************************************
**************** health expenditure	**************
*********************************************************
/*preserve
	sort treated wave
	egen av_dk = mean(hexpFampaid), by (treated wave)
	duplicates drop treated wave, force
	keep av_dk treated wave
	reshape wide av_dk, i(wave) j(treated)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "Treated"
	label variable Controled  "Controled"
	
	twoway connected Treated  Controled wave, ytitle("PM 2.5" ) xtitle(Year) xline(2014) ylabel(,nogrid)
restore	
*/

	
hexpFampaidOP hexpFampaidIP hexpIndpaid hexpIndpaidOP hexpIndpaidIP  ADLhexpcare
caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern
 ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale ADLcaregiverfamily ADLcaregivernonfamilygovern
	
*********************************************************
**************** ADL caregiver	********
*********************************************************	

**** reghdfe

	reg ADLcaregiverSpouse treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市)
	outreg2 using "${OUT}/ADLcare_base.xls",replace stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	
	foreach k in {
		reg `k' treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市) 
		outreg2 using "${OUT}/ADLcare_base.xls",append stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}		
xx
**** reghdfe
	preserve
		drop if ADLcaregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
	
		reghdfe ADLcaregiverSpouse treated_id i.year_id i.treated age gender  coresidence residence, absorb(省 wave )   vce(robust)
		outreg2 using "${OUT}/ADLcare_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	
	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale ADLcaregiverfamily ADLcaregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender  coresidence residence, absorb(省 wave )   vce(robust)
		outreg2 using "${OUT}/ADLcare_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}			
	