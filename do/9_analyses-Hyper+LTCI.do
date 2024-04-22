use "${OUT}/Full_CLHLS_covariants_comm.dta",clear
****************************************************	
**************** Outcome Variables ****************
****************************************************
/* Outcome variables includes: fraity index, conginition failure, ADL & IADL, physical functioning, Psycho */
******************* Frailty Index ********************
	* frailty 
	cap drop  FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma 
	recode hypertension heartdisea strokecvd copd tb ulcer diabetes cancer prostatetumor parkinson bedsore cataract glaucoma (1 2 = 1 ) ,gen(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma) 
    egen frailsumver1 = rowtotal(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma  FRAsrh  FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr),mi
	
	egen frailmissingver1 = rowmiss(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma FRAsrh  FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr)

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
************ Independent Variables: LTHC ***********
****************************************************	
	merge m:1 gbcode using "${SOURCE}/citylist.dta" // merge city name 
	drop if _m ==2
	drop _m
	
	gen treated_id = .
	replace treated_id = 1 if inlist(市,"承德市","齐齐哈尔市","宁波市","安庆市","上饶市","广州市","重庆市","成都市") & inlist(insurancePubMed,1,5)
	replace treated_id = 1 if inlist(市,"长春市","石河子市") & inlist(insurancePubMed,1,2,5)
	replace treated_id = 1 if inlist(市,"上海市","南通市","苏州市","青岛市","荆门市") & inlist(insurancePubMed,1,2,3,5)
	replace treated_id = 1 if inlist(省,"山东省") 
	
	recode treated_id (.=0) 
	
	gen year_id = .
	replace year_id = 1 if intdate>=mdy(11,1,2016) & inlist(市,"承德市")
	replace year_id = 1 if intdate>=mdy(5,1,2015) & inlist(市,"长春市")
	replace year_id = 1 if intdate>=mdy(10,1,2017) & inlist(市,"齐齐哈尔市")
	replace year_id = 1 if intdate>=mdy(1,1,2017) & inlist(市,"上海市")
	replace year_id = 1 if intdate>=mdy(1,1,2016) & inlist(市,"南通市")
	replace year_id = 1 if intdate>=mdy(6,1,2017) & inlist(市,"苏州市")
	replace year_id = 1 if intdate>=mdy(12,1,2017) & inlist(市,"宁波市")
	replace year_id = 1 if intdate>=mdy(1,1,2017) & inlist(市,"安庆市")
	replace year_id = 1 if intdate>=mdy(1,1,2017) & inlist(市,"上饶市")
	replace year_id = 1 if intdate>=mdy(7,1,2012) & inlist(市,"青岛市") 
	replace year_id = 1 if intdate>=mdy(11,1,2016) & inlist(市,"荆门市")
	replace year_id = 1 if intdate>=mdy(8,1,2017) & inlist(市,"广州市")
	replace year_id = 1 if intdate>=mdy(11,1,2017) & inlist(市,"重庆市")
	replace year_id = 1 if intdate>=mdy(7,1,2017) & inlist(市,"成都市")
	replace year_id = 1 if intdate>=mdy(1,1,2017) & inlist(市,"石河子市")
	recode  year_id  (.=0)
	
/*	吉林长春市、黑龙江齐齐哈尔市、上海市、江苏南通市和苏州市、浙江宁波市、安徽安庆市、江西上饶市、山东青岛市、湖北荆门市、广东广州市、重庆市、四川成都市、
新疆生产建设兵团石河子市 河北承德市 "安庆市","上饶市",市 上饶市
*/
	gen treated =  treated_id*year_id

save "${OUT}/analyses-Frailty Traj+LTHC.dta",replace
