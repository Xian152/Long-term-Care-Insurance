***** combine prob results	
	foreach k in grp2_lifstyle_avg_prob grp3_lifstyle_avg_prob grp4_lifstyle_avg_prob grp5_lifstyle_avg_prob  grp6_lifstyle_avg_prob grp7_lifstyle_avg_prob{
		import delimited "${OUT}20231105/out_results/`k'.csv",clear
		save "${OUT}20231105/out_results/`k'.dta",replace
	}
	
	
	foreach k in grp2_lifstyle_avg_prob  grp3_lifstyle_avg_prob grp4_lifstyle_avg_prob grp5_lifstyle_avg_prob grp6_lifstyle_avg_prob  grp7_lifstyle_avg_prob{
		use "${OUT}20231105/out_results/`k'.dta",clear
			gen drop = 1 if prb_mean <0.7

		save "${OUT}20231105/out_results/`k'.dta",replace
	}	
	
	foreach k in grp2_lifstyle_avg_prob  grp3_lifstyle_avg_prob grp4_lifstyle_avg_prob grp5_lifstyle_avg_prob grp6_lifstyle_avg_prob  grp7_lifstyle_avg_prob{
		use "${OUT}20231105/out_results/`k'.dta",clear
			bysort label : egen dropt = max(drop)
			drop if  dropt ==1 
			gen type = "`k'"
			tempfile `k'
			save ``k'',replace
	}	
	
*
use `grp2_lifstyle_avg_prob',clear
	append using  `grp3_lifstyle_avg_prob' `grp4_lifstyle_avg_prob' `grp5_lifstyle_avg_prob' `grp6_lifstyle_avg_prob'  `grp7_lifstyle_avg_prob'
save 	"${OUT}/traj_prob_sum.dta",replace 

use "${OUT}20231105/out_results/grp2_lifstyle_avg_prob.dta",clear
	foreach k in grp3_lifstyle_avg_prob grp4_lifstyle_avg_prob grp5_lifstyle_avg_prob grp6_lifstyle_avg_prob  grp7_lifstyle_avg_prob{
		append using "${OUT}20231105/out_results/`k'.dta"
	}	
save 	"${OUT}/traj_prob_sum_ori.dta",replace 

	
	
***** combine aic results
	foreach k in grp2_lifstyle_aic grp3_lifstyle_aic grp4_lifstyle_aic grp5_lifstyle_aic grp6_lifstyle_aic  grp7_lifstyle_aic {
		import delimited "${OUT}20231105/out_results/`k'.csv",clear
		save "${OUT}20231105/out_results/`k'.dta",replace
	}
	
	foreach k in grp2_lifstyle_aic grp3_lifstyle_aic  grp4_lifstyle_aic  grp5_lifstyle_aic  grp6_lifstyle_aic  grp7_lifstyle_aic {
		use "${OUT}20231105/out_results/`k'.dta",clear
			keep if _type_ == "PARMS"
		save "${OUT}20231105/out_results/`k'.dta",replace
	}		

	foreach k in grp2_lifstyle_aic grp3_lifstyle_aic  grp4_lifstyle_aic  grp5_lifstyle_aic  grp6_lifstyle_aic  grp7_lifstyle_aic {
		use "${OUT}20231105/out_results/`k'.dta",clear
			gen type = "`k'"
			tempfile `k'
			save ``k'',replace			
	}		
use `grp2_lifstyle_aic',clear
	append using  `grp3_lifstyle_aic'  `grp4_lifstyle_aic'  `grp5_lifstyle_aic'  `grp6_lifstyle_aic'  `grp7_lifstyle_aic'
	
	order type interc11 linear11 quadra11 interc12 linear12 quadra12 interc13 linear13 quadra13 interc14 linear14 quadra14 interc15 linear15 quadra15 interc16 linear16 quadra16 interc17 linear17 quadra17
	
	gen 分组 = substr(type,4,1)
	destring 分组,replace
	order 分组
	
	forvalues k = 1/7{
		gen 参数`k' =1
		replace 参数`k' = 2 if quadra1`k' !=.
		replace 参数`k' = . if  分组<`k'
	}
save 	"${OUT}/traj_aicbic_sum.dta",replace	


***** combine 编号
import excel 	"${OUT}/轨迹模型参数数据库.xlsx", firstrow clear
	keep 编号 每个分组模型编号 参数7 参数6 参数5 参数4 参数3 参数2 参数1 分组
	merge 1:1 参数7 参数6 参数5 参数4 参数3 参数2 参数1 分组 using "${OUT}/traj_aicbic_sum.dta"
	drop _merge 
	sort 编号
save 	"${OUT}/traj_aicbic_sum.dta",replace	
	
**** combine everything
use "${OUT}/traj_prob_sum_with pvaluedrop.dta",clear //包含手动整理，不要改
	gen 编号 = substr(label,9,.)
	destring 编号,replace
	ren 编号 每个分组模型编号
	gen 分组 = substr(type,4,1)
	destring 分组,replace
	order 分组	 每个分组模型编号
save,replace	
	
use "${OUT}/traj_prob_sum_with pvaluedrop.dta",clear //包含手动整理，不要改
	ren type typeprob
	merge m:1 分组 每个分组模型编号 using "${OUT}/traj_aicbic_sum.dta"		
	keep if _merge == 3
	order 编号
	
	drop _merge label *type* _model_ _model2_ _name_
save "${OUT}/select stage1 model_details.dta",replace	

	gen drop = .	
	order drop
	
	bysort 编号: egen maxdrop = max(drop)

	drop if maxdrop == 1
	drop if 分组 == 6 
	drop if 分组 == 5
	drop if 分组 == 4
	drop maxdrop drop

**** select by bic aic
	duplicates drop 编号,force
	bysort 分组: egen minbic = min(_bic1_)
	gen best =  minbic == _bic1_
	
	sort _bic1_
	gen gap_bic = 2*(_bic1_ - _bic1_[_n-1])
	
	
/*
按照_bic1_排序后计算前后者的差值

    gap_bic |      Freq.     Percent        Cum.
------------+-----------------------------------
      .0625 |          1        7.69        7.69
    6.03125 |          1        7.69       15.38
    9.46875 |          1        7.69       23.08
   10.46875 |          1        7.69       30.77
   11.96875 |          1        7.69       38.46
   13.39063 |          1        7.69       46.15
      18.25 |          1        7.69       53.85
   362.7031 |          1        7.69       61.54
   381.4688 |          1        7.69       69.23
   546.4375 |          1        7.69       76.92
   1577.359 |          1        7.69       84.62
   2142.234 |          1        7.69       92.31
   4741.266 |          1        7.69      100.00
------------+-----------------------------------
      Total |         13      100.00
	  
	除了模型8和10以外(都是分三组），基本上可以接受复杂模型，最高是分出5组。
	  
*/	

ren best bestwithingroup

save "${OUT}/select stage2 model_details.dta",replace	

use  "${OUT}/select stage2 model_details.dta",clear

keep 编号 分组 参数1 参数2 参数3 参数4 参数5 prb_mean interc11 linear11 quadra11 interc12 linear12 quadra12 interc13 linear13 quadra13 interc14 linear14 quadra14 interc15 linear15 quadra15 bestwithingroup gap_bic _bic1_ _aic_ prb_n

	keep if bestwithingroup == 1 
	
	drop gap_bic 
	sort _bic1_
	gen gap_bic = 2*(_bic1_ - _bic1_[_n-1])

save "${OUT}/select model fin.dta",replace	

	
	foreach k in grp2_lifstyle_aic grp3_lifstyle_aic  grp4_lifstyle_aic  grp5_lifstyle_aic  grp6_lifstyle_aic  grp7_lifstyle_aic {
		use "${OUT}20231105/out_results/`k'.dta",clear
			gen aicdistance = 1 - _aic_
			gen keep = 0
			foreach t in _bic1_   {
				egen min`t' = min(`t')
				replace keep = 1 if min`t' ==`t'
			}
			foreach t in aicdistance   {
				egen min`t' = min(`t')
				replace keep = keep+1 if min`t' ==`t'
			}			
		save "${OUT}20231105/out_results/`k'.dta",replace
	}	
	
	
	





xx
use "${OUT}/traj_aicbic_sum.dta",clear
	drop keep min*
			gen keep = 0
			foreach t in _bic1_   {
				egen min`t' = min(`t')
				replace keep = 1 if min`t' ==`t'
			}
			foreach t in aicdistance   {
				egen min`t' = min(`t')
				replace keep = keep+1 if min`t' ==`t'
			}			
	
save "${OUT}/traj_aicbic_sum.dta",replace	


replace keep = 1 if prb_n==1273 & type=="grp6_lifstyle_avg_prob" & group == 1 

bysort type label: egen max = max(keep)
replace keep = max

keep if keep ==1

drop keep max

drop drop dropt
