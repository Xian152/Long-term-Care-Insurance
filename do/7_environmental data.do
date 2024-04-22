**************** 处理成dta数据
import delimited "/Users/x152/Downloads/county2013.csv", varnames(1) clear 
	keep if strmatch(省,"*市*") | strmatch(省,"*省*") | strmatch(省,"*区*")
	gen id = _n
	keep 省代码 省 市代码 市 县代码 县 id
save "${root}raw/环境/county2013.dta",replace

import delimited "/Users/x152/Downloads/county2014.csv", varnames(1) clear 
	keep if strmatch(省,"*市*") | strmatch(省,"*省*") | strmatch(省,"*区*")
	gen id = _n
	keep 省代码 省 市代码 市 县代码 县 id
save "${root}raw/环境/county2014.dta",replace

import delimited "/Users/x152/Downloads/county2019.csv", varnames(1) clear 
	keep if strmatch(省,"*市*") | strmatch(省,"*省*") | strmatch(省,"*区*")
	gen id = _n
	keep 省代码 省 市代码 市 pac name id
	ren pac 县代码
	ren name 县 
save "${root}raw/环境/county2019.dta",replace

**********CL
foreach k in ECHAP_cl_D1K_2013{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_Cl_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2013.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	
	
foreach k in  ECHAP_cl_D1K_2014 ECHAP_cl_D1K_2015 ECHAP_cl_D1K_2016 ECHAP_cl_D1K_2017 ECHAP_cl_D1K_2018{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_Cl_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2014.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}		

foreach k in  ECHAP_cl_D1K_2019 ECHAP_cl_D1K_2020{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_Cl_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2019.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}		
	
**********SO4
foreach k in ECHAP_SO4_D1K_2013 {
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_SO4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2013.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	

foreach k in ECHAP_SO4_D1K_2014 ECHAP_SO4_D1K_2015 ECHAP_SO4_D1K_2016 ECHAP_SO4_D1K_2017 ECHAP_SO4_D1K_2018 {
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_SO4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2014.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	
		
		
foreach k in ECHAP_SO4_D1K_2019 ECHAP_SO4_D1K_2020{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_SO4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2019.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	
			
	
**********NH4
foreach k in ECHAP_NH4_D1K_2013 {
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NH4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2013.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	


foreach k in  ECHAP_NH4_D1K_2014 ECHAP_NH4_D1K_2015 ECHAP_NH4_D1K_2016 ECHAP_NH4_D1K_2017 ECHAP_NH4_D1K_2018 {
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NH4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2014.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	

foreach k in  ECHAP_NH4_D1K_2019 ECHAP_NH4_D1K_2020{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NH4_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2019.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}				
			
			
**********NO3
foreach k in ECHAP_NO3_D1K_2013 {
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NO3_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2013.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}		

foreach k in ECHAP_NO3_D1K_2014 ECHAP_NO3_D1K_2015 ECHAP_NO3_D1K_2016 ECHAP_NO3_D1K_2017 ECHAP_NO3_D1K_2018 {
import delimited "${root}raw/环境/countyf_`k'.csv", cl d ear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NO3_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2014.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	

foreach k in ECHAP_NO3_D1K_2019 ECHAP_NO3_D1K_2020{
import delimited "${root}raw/环境/countyf_`k'.csv", clear 
	replace year = subinstr(year,"/Users/x152/Desktop/PM数据处理/环境栅格数据/`k'/rds/ECHAP_NO3_D1K_","",.)
	replace year = subinstr(year,"_V1.rds","",.)
	merge m:1 id using "${root}raw/环境/county2019.dta"
	keep if _m == 3
	drop _m
	
	destring year,replace
	
	gen double date = year
	
	format date %tdYMD
	drop year
save 	"${root}intermediate/环境/`k'.dta",replace
}	
	
**************** 合并数据
foreach k in cl SO4 NH4 NO3{
	use "${root}intermediate/环境/ECHAP_`k'_D1K_2013.dta",clear
		append using "${root}intermediate/环境/ECHAP_`k'_D1K_2014.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2015.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2016.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2017.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2018.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2019.dta" "${root}intermediate/环境/ECHAP_`k'_D1K_2020.dta"
	duplicates tag 县代码 date,gen(a)
	drop if a==1
save 		"${root}intermediate/环境/ECHAP_`k'_D1K.dta",replace
}		

use "${root}intermediate/环境/ECHAP_cl_D1K.dta",clear
	ren (省代码 省 市代码 市 县) (provcode prov citycode city county)
	ren value cl
	merge 1:1 date 县代码  using "${root}intermediate/环境/ECHAP_SO4_D1K.dta"
	
	replace provcode = 省代码 if  _m == 2 
	replace prov = 省  if  _m == 2 
	replace citycode = 市代码 if  _m == 2 
	replace city = 市 if  _m == 2 
	replace county = 县 if  _m == 2 

	drop  _m 省代码 省 市代码 市  县 a id
	ren value SO4
	
	merge 1:1 date 县代码  using "${root}intermediate/环境/ECHAP_NH4_D1K.dta"	
	drop  _m 省代码 省 市代码 市  县 
	ren value NH4
		
	merge 1:1 date 县代码  using "${root}intermediate/环境/ECHAP_NO3_D1K.dta"	
	drop  _m 省代码 省 市代码 市  县 
	ren value NO3
	
	keep 县代码 prov date county city NH4 NO3 SO4 cl
	ren cl CL
	
	foreach k in SO4 NO3 NH4 CL{
		replace `k' = "" if `k' == "NA"
		destring `k',replace
	}
	
	foreach k in SO4 NO3 NH4 CL{
		drop if `k' ==.
	}	
	
	foreach k in SO4 NO3 NH4 CL{
		drop if `k' ==0
	}		
	
save 			"${root}intermediate/环境/PM25conposure_1dk.dta",replace		
				
**************** 计算天数
use "${root}intermediate/环境/PM25conposure_1dk.dta",clear
*计算平均值
	foreach k in SO4 NO3 NH4 CL{
		gen `k'_36m = 0
		gen `k'_24m = 0
		gen `k'_12m = 0
		gen `k'_6m = 0
		gen `k'_90d = 0
		gen `k'_30d = 0
		gen `k'_7d = 0
		gen `k'_1d = 0
		forvalues i =0/1094{
			bysort 县代码 (date) :replace `k'_36m = `k'_36m+`k'[_n-`i']	
		}	
		forvalues i =0/729{
			bysort 县代码 (date) :replace `k'_24m = `k'_24m+`k'[_n-`i']	
		}
		forvalues i =0/364{
			bysort 县代码 (date) :replace `k'_12m = `k'_12m+`k'[_n-`i']	
		}
		forvalues i =0/179{
			bysort 县代码 (date) :replace `k'_6m = `k'_6m+`k'[_n-`i']	
		}	
		forvalues i =0/89{
			bysort 县代码 (date) :replace `k'_90d = `k'_90d+`k'[_n-`i']	
		}		
		forvalues i =0/29{
			bysort 县代码 (date) :replace `k'_30d = `k'_30d+`k'[_n-`i']	
		}		
		forvalues i =0/6{
			bysort 县代码 (date) :replace `k'_7d = `k'_7d+`k'[_n-`i']	
		}		
		replace `k'_36m = `k'_36m/1095	
		replace `k'_24m = `k'_24m/730
		replace `k'_12m = `k'_12m/365
		replace `k'_6m = `k'_6/180
		replace `k'_90d = `k'_90d/90
		replace `k'_30d = `k'_30d/30
		replace `k'_7d = `k'_7d/7
		replace `k'_1d = `k'
	}
	
	ren 县代码  gbcode
save "${root}intermediate/环境/PM25conposure_average.dta",replace		
	