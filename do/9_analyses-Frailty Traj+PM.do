 use "${OUT}/Full_CLHLS_covariants_comm.dta",clear
 ****************************************************	
**************** Outcome Variables ****************
****************************************************
/* Outcome variables includes: fraity index, conginition failure, ADL & IADL, physical functioning, Psycho */
******************* Frailty Index ********************
	* frailty 
    egen frailsumver1 = rowtotal(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma FRAseriousillness FRAsrh FRAirh FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr),mi
	
	egen frailmissingver1 = rowmiss(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma FRAseriousillness FRAsrh FRAirh FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr)

	gen frailID = frailsumver1/(37-frailmissingver1) 
	replace frailID = . if frailmissingver1 >= 10
	
******************** adl & iadl ********************
	recode FRAturn ( 0.25 0.5 = 0)
	
	drop adlSum adlMiss adl
	egen adlMiss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adlSum = rowtotal(bathing dressing toileting transferring continence feeding) 
	replace adlSum = . if adlMiss > 1
	
	gen adl = adlSum >0 if adlSum !=.
	
******************* physical functioning ********************	
	egen phys = anymatch(FRAturn FRAstandup FRAbook ),value(1)	
	egen phys_miss = rowmiss(FRAturn FRAstandup FRAbook )
	replace phys = . if phys_miss >=1
	

****************************************************	
************** Independent Variables :Air 10 **************
****************************************************	
	ren yearin year
	merge m:1 gbcode year using "${SOURCE}/pm25contain_county13-20yr.dta"
	
	drop if _m == 3
	drop _m
	
	bysort id: gen count = _N
	
	keep if count == 2
	
	foreach k in value_SO4 value_NO3 value_NH4 value_Cl {
		reg frailID 	`k'
	}	
	
	ren prov province 
	decode province,gen(prov)
	gen treat5 = 0 if inlist(prov,"jiangxi","fujian","guangxi","hainan","helongjiang")
	gen treat10 = 0 if inlist(prov,"jiangxi","fujian","guangxi","hainan","helongjiang") | inlist(prov,"anhui","hunan","sichuan","jilin","liaoning")
	recode treat5 treat10 (.=1)
	
	gen treat_pm = treat5==1| treat10==1 
	
	gen yeartreat = year>2014
	
	gen treat_id5 = treat5 * yeartreat 
	gen treat_id10 = treat10 * yeartreat 
	gen treat_idpm = treat_pm  * yeartreat 

	cls
	foreach k in value_SO4 value_NO3 value_NH4 value_Cl {
		reg 	`k' i.treat_id5 i.yeartreat i.treat5 
		reg 	`k' i.treat_id10 i.yeartreat i.treat10 
		reg 	`k' i.treat_idp i.yeartreat i.treat_pm
	}	
	
	// 是Cl
	
	reg frailID i.treat_id5 i.yeartreat i.treat5 
	reg frailID i.treat_id10 i.yeartreat i.treat10 
	reg frailID i.treat_idpm i.yeartreat i.treat_pm 
	
	gen cltreat =  treat_idpm*value_Cl
	gen SO4treat =  treat_idpm*value_SO4
	gen NO3treat =  treat_idpm*value_NO3
	gen NH4treat =  treat_idpm*value_NH4
	
	reg frailID cltreat i.yeartreat i.treat_pm 
	reg frailID SO4treat i.yeartreat i.treat_pm 
	reg frailID NO3treat i.yeartreat i.treat_pm 
	reg frailID NH4treat i.yeartreat i.treat_pm 

save "${OUT}/analyses-Frailty Traj+PM.dta",replace
	