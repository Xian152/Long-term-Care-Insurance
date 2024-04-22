/*ID householdID communityID hhid hhidc pnc pn
inw1 inw2 inw3 inw4
r1hlthlm_c r2hlthlm_c r3hlthlm_c r4hlthlm_c
?
r1wthh r2wthh r3wthh r4wthh r2wthhl r1wthha r2wthha r3wthha r4wthha r1wtresp r2wtresp r3wtresp r4wtresp
s1wtresp s2wtresp s3wtresp s4wtresp r2wtrespl s2wtrespl r1wtrespa r2wtrespa r3wtrespa s1wtrespa s2wtrespa s3wtrespa r1wtrespb r2wtrespb r3wtrespb r4wtrespb s1wtrespb s2wtrespb s3wtrespb s4wtrespb
*/

use "/Volumes/expand/Data/HRS 系列/CHARLS/H_CHARLS_D_Data.dta",clear
* demograph
	foreach k in 1 2 3 4{
		ren r`k'agey age_`k'
	}
	ren ragender gender

* interview //r1iwy r2iwy r3iwy r4iwy s1iwy s2iwy s3iwy s4iwy r1iwm r2iwm r3iwm r4iwm s1iwm s2iwm s3iwm s4iwm
	foreach k in 1 2 3 4{
		ren r`k'iwy yearin_`k'
		ren r`k'iwm monthin_`k'
	}
	ren radyear deathyeaerin 
	ren radmonth deathmonthin
	ren rabplace_c intplace
* social economics
	ren raeducl educ
	foreach k in 1 2 3 4{
		recode r`k'mstat (8=1 "never married") (1 3 = 2 "married/partnered") (4 5 7 = 3 "SDW"),gen(marital_`k') label(marital_`k')
	}
	
	foreach k in 1 2 3 4{
		ren r`k'hukou hukou_`k'
	}
	foreach k in 1 2 3 4{ //h1rural h2rural h3rural h4rural
		recode r`k'rural2 (1=0) (0=1),gen(residence_`k')
	}		
	foreach k in 2 3 4{ //
		recode r`k'nhmliv (.=.),gen(coresidence_`k')
	}		
* SRH
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		recode r`k'shlta (.=.),gen(srh_`k')
	}		

* ADL
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'adlab_c adl_sum_`k'
		replace adl_sum_`k' = . if r`k'adlabm_c >=1
	}	  
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'dressa dressing_`k'
		ren r`k'batha bathing_`k'
		ren r`k'eata eating_`k'
		ren r`k'beda beding_`k'
		ren r`k'toilta tolite_`k'
		ren r`k'urina urin_`k'
	}	 
	
	
*IADL 
	foreach k in 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'iadlza iadl_sum_`k'
		replace iadl_sum_`k' = . if r`k'iadlzam >=1
	}

//  r2phonea r3phonea r4phonea s2phonea s3phonea s4phonea 
//  r1moneya r2moneya r3moneya r4moneya s1moneya s2moneya s3moneya s4moneya 
//  r1medsa r2medsa r3medsa r4medsa s1medsa s2medsa s3medsa s4medsa 
//  r1housewka r2housewka r3housewka r4housewka s1housewka s2housewka s3housewka s4housewka 
//  r1joga r2joga r3joga r4joga s1joga s2joga s3joga s4joga 
//  r1walk100a r2walk100a r3walk100a r4walk100a s1walk100a s2walk100a s3walk100a s4walk100a 
//  r1chaira r2chaira r3chaira r4chaira s1chaira s2chaira s3chaira s4chaira 
//  r1climsa r2climsa r3climsa r4climsa s1climsa s2climsa s3climsa s4climsa 
//  r1stoopa r2stoopa r3stoopa r4stoopa s1stoopa s2stoopa s3stoopa s4stoopa 
//  r1dimea r2dimea r3dimea r4dimea s1dimea s2dimea s3dimea s4dimea 
//  r1armsa r2armsa r3armsa r4armsa s1armsa s2armsa s3armsa s4armsa
  
*health expenditure
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'oophos1y HexpOOPIPInd_`k'	
		ren r`k'tothos1y HexpIPInd_`k'	
		gen HexpOOPOPInd_`k' = r`k'oopdoc1m * 12
		gen HexpOPInd_`k' = r`k'totdoc1m * 12
	} 	
 	foreach k in 2 3 { //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPDentInd_`k' = r`k'oopden1y
		gen HexpDentInd_`k' = r`k'totden1y	
	}  
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren s`k'oophos1y SHexpOOPIPInd_`k'	
		ren s`k'tothos1y SHexpIPInd_`k'	
		gen SHexpOOPOPInd_`k' = s`k'oopdoc1m * 12
		gen SHexpOPInd_`k' = s`k'totdoc1m * 12
	} 	
 	foreach k in 2 3 { //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen SHexpOOPDentInd_`k' = s`k'oopden1y
		gen SHexpDentInd_`k' = s`k'totden1y	
	}   
*insurance
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'itearn InsurancePubMed_`k'	
		ren r`k'hipriv InsuranceComMed_`k'	
		ren r`k'hiothp InsuranceOthMed_`k'	
		ren s`k'itearn SInsurancePubMed_`k'	
		ren s`k'hipriv SInsuranceComMed_`k'	
		ren s`k'hiothp SInsuranceOthMed_`k'	
	}

* income & consumption	
  	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren hh`k'itot hhincome_`k'
		ren hh`k'cfood expfoodhh_`k'
		gen expnonfoodhh_`k' =  hh`k'cnf1m * 12
		ren hh`k'ctot exphh_`k'
		ren hh`k'cperc expperca_`k'
	}
* daughter son 
  	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren h`k'dau numdaughter_`k' 
		ren h`k'son numson_`k' 
	} 
	
	
* caregiver 
  	foreach k in  2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'rcaany r`k'rcany r`k'rfaany) (ADLinformalCare_`k' ADLCare_`k' ADLformalCare_`k') 
		ren (r`k'rccare r`k'rccaredpm r`k'rccarehr r`k'rccaren ) (ADLcaregiverChild_`k'  ADLcaregiverChildDays_`k'  ADLcaregiverChildHours_`k'  ADLcaregiverChildNum_`k' )
		
		ren (r`k'rfcare  ) (ADLcaregiverNonRela_`k'     )
		ren (r`k'rrcare r`k'rrcaren ) (ADLcaregiverRelative_`k'  ADLcaregiverRelativeNum_`k' )
		ren (r`k'rscare  ) (ADLcaregiverSpouse_`k'      )

		ren (s`k'rcaany s`k'rcany s`k'rfaany) (SADLinformalCare_`k' SADLCare_`k' SADLformalCare_`k') 
		ren (s`k'rccare s`k'rccaredpm s`k'rccarehr s`k'rccaren ) (SADLcaregiverChild_`k'  SADLcaregiverChildDays_`k'  SADLcaregiverChildHours_`k'  SADLcaregiverChildNum_`k' )
		
		ren (s`k'rrcare  s`k'rrcaren ) (SADLcaregiverRelative_`k'  SADLcaregiverRelativeNum_`k' )
		ren (s`k'rscare ) (SADLcaregiverSpouse_`k'      )
} 

  	foreach k in  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (  s`k'rfcare )  ( SADLcaregiverNonRela_`k' )
		ren (r`k'rrcaredpm r`k'rrcarehr s`k'rrcaredpm s`k'rrcarehr)  (ADLcaregiverRelativeDays_`k'  ADLcaregiverRelativeHours_`k'   SADLcaregiverRelativeDays_`k'  SADLcaregiverRelativeHours_`k')
		ren (r`k'rscaredpm s`k'rscaredpm  ) (ADLcaregiverSpouseDays_`k' SADLcaregiverSpouseDays_`k')
		ren (r`k'rscarehr s`k'rscarehr      ) (ADLcaregiverSpouseHours_`k'  SADLcaregiverSpouseHours_`k'    )

} 
  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen double interviewdate_`k' = mdy(monthin_`k',1, yearin_`k')
} 

* weight
  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'wtresp   r`k'wtrespb) (wtresp_`k'   wtrespb_`k')
} 

	keep ID communityID *_* gender  ID_w1
	drop *_c
	reshape long HexpDentInd_ HexpIPInd_ HexpOOPDentInd_ HexpOOPIPInd_ HexpOOPOPInd_ HexpOPInd_ InsuranceComMed_ InsuranceOthMed_ InsurancePubMed_ adl_sum_ age_ bathing_ beding_ coresidence_ dressing_ eating_ expfoodhh_ exphh_ expnonfoodhh_ expperca_ hhincome_ hukou_ marital_ monthin_ numdaughter_ numson_ residence_ srh_ tolite_ urin_ yearin_ ADLCare_ ADLcaregiverChildDays_ ADLcaregiverChildHours_ ADLcaregiverChildNum_ ADLcaregiverChild_ ADLcaregiverNonRela_ ADLcaregiverRelativeDays_ ADLcaregiverRelativeHours_ ADLcaregiverRelativeNum_ ADLcaregiverRelative_ ADLcaregiverSpouseDays_ ADLcaregiverSpouseHours_ ADLcaregiverSpouse_ ADLformalCare_ ADLinformalCare_ SADLCare_ SADLcaregiverChildDays_ SADLcaregiverChildHours_ SADLcaregiverChildNum_ SADLcaregiverChild_ SADLcaregiverNonRela_ SADLcaregiverRelativeDays_ SADLcaregiverRelativeHours_ SADLcaregiverRelativeNum_ SADLcaregiverRelative_ SADLcaregiverSpouseDays_ SADLcaregiverSpouseHours_ SADLcaregiverSpouse_ SADLformalCare_ SADLinformalCare_ iadl_sum_ interviewdate_ wtresp_  wtrespb_,i(ID) j(wave)
	
	recode wave (1=2011) (2=2013) (3=2015) (4=2018)
	gen ID_alt = ID
	replace ID = ID_w1 if wave == 2011
	xx
save "/Users/x152/Desktop/charls_harm.dta",replace



  r1rpfcare s1rpfcare r1rpfcaredpm s1rpfcaredpm r1rpfcarehr s1rpfcarehr r1rufcare s1rufcare r1rufcaredpm s1rufcaredpm r1rufcarehr s1rufcarehr
  
  
  
  r1rccaren r3rccaren r4rccaren s1rccaren s3rccaren s4rccaren
   