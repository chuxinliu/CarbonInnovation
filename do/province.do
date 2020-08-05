/*
1. 建立起处理patent data的一套统一方案: 
	!. collapse之前，需要将几个关键词处理一下： 
		- 核能核电去掉
		- “核能”与“核电”合并
		- “石油”与“炼油”合并
		- 几个垃圾相关的合到一起
		- “水力发电”和“水能”
		- “波浪能”，“海洋能”与“潮汐”
		- “风能”与“风电”
	a. 通过collapse: 对于每个关键词{i}，每个地区{p}，每个申请时间{t}（三个维度）加总： ni_{pt}
	b. 跨类别不能比较的问题： 
		想法一： ni_{pt}除以i专利前后六个月的全国总申请量（13个月），那么i与i之间就可以比较了: 生成comparable的新变量p_*_c{pt}
		想法二： 比增速，前一阶段是0的话就尝试用t-2来计算，看看missing有多少
2. 画各类能源，清洁/脏能源的time trend
3. 构建treat_{it}核心变量和post两个
4. run event study design
*/

set more off
clear
capture log close

global root = "C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation"

use "$root\data\patent_province.dta", clear

order code prov apply_time pyear firm research

/*	!. collapse之前，需要将几个关键词处理一下： 
		- 核能核电去掉
		- “核能”与“核电”合并
		- “石油”与“炼油”合并
		- 几个垃圾相关的合到一起
		- “水力发电”和“水能”
		- “波浪能”，“海洋能”与“潮汐”
		- “风能”与“风电” */

drop p_核能核电

su p_核* if p_核能==1 & p_核电==1
gen p_核 = p_核能 + p_核电

su p_*油 if p_石油==1 & p_炼油==1
gen p_油 = p_石油 + p_炼油
replace p_油 = 1 if p_石油==1 & p_炼油==1

gen p_垃圾 =  p_垃圾焚烧 + p_焚烧垃圾 + p_垃圾发酵
su *垃圾*
replace p_垃圾 = 1 if p_垃圾>1

gen p_水 = p_水力发电 + p_水能
replace p_水 = 1 if p_水>1

gen p_浪 = p_波浪能 + p_海洋能 + p_潮汐
replace p_浪 = 1 if p_浪>1

gen p_风 = p_风能 + p_风电
replace p_风 = 1 if p_风>1

gen p_太阳 = p_太阳能 + p_光伏
replace p_太阳 = 1 if p_太阳>1

***
drop p_煤气 p_石油 p_炼油 p_水力发电 p_水能 p_波浪能 p_海洋能 p_潮汐 p_风能 p_风电 p_垃圾焚烧 p_焚烧垃圾 p_垃圾发酵 p_核能 p_核电 p_太阳能 p_光伏
***

collapse (sum) p_*, by(apply_time prov)
gen atime=apply_time
replace atime=. if apply_time>201710
replace atime=. if apply_time<200507
egen plist = group(prov)
levelsof plist, local(levels1)
levelsof atime, local(levels2)
foreach l1 of local levels1 {
    foreach l2 of local levels2 {
		su apply_time if plist==`l1' & atime == `l2'
		if r(N) == 0 {
		    insobs 1
			local N=_N
			replace atime=`l2' in `N'
			replace plist=`l1' in `N'
		}
	} 
}
su apply_time
local e1 = r(N) + 1
local en = _N
foreach v of varlist p_* {
    replace `v' = 0 in `e1'/`en'
}
sort atime
egen t = group(atime)
order t plist atime apply_time prov p_*
keep if t!=.

*各类别当期全国加总
foreach v of varlist p_* {
    by t, sort : egen float national_`v' = total(`v')
}

xtset plist t
foreach v of varlist national* {
	foreach i of numlist 1/12{
		gen `v'_lag`i' = `v'[_n-`i']
	}
	foreach j of numlist 1/12{
		gen `v'_lead`j' = `v'[_n+`j']
	}
}

foreach v of varlist p_* {
	gen national_`v'_sum1 = national_`v'_lag1 + national_`v' + national_`v'_lead1
	foreach i of numlist 2/12 {
		gen national_`v'_sum`i' = national_`v'
		foreach j of numlist 1/`i' {
			replace national_`v'_sum`i'= national_`v'_sum`i' + national_`v'_lag`j' + national_`v'_lead`j'
}
}
}

*生成comparable的新变量p_*_c{province, time}
foreach v of varlist p_* {
	gen `v'_c = `v'/national_`v'_sum6
}
su p_*c

gen clean_c = p_地热_c + p_太阳_c + p_生物燃料_c + p_再生能_c + p_核_c + p_垃圾_c + p_水_c + p_浪_c + p_风_c + p_天然气_c
gen dirty_c = p_煤_c + p_油_c

su *c

*time trend: national_*_sum6， 不太看出来啥
twoway (line national_p_太阳_sum3 t, sort) (line national_p_煤_sum3 t, sort) (line national_p_油_sum3 t, sort) (line national_p_天然气_sum3 t, sort)
twoway (line national_p_太阳_sum6 t, sort) (line national_p_煤_sum6 t, sort) (line national_p_油_sum6 t, sort) (line national_p_天然气_sum6 t, sort)

gen national_clean_sum6 = national_p_地热_sum6 + national_p_太阳_sum6 + national_p_生物燃料_sum6 + national_p_再生能_sum6 + national_p_核_sum6 + national_p_垃圾_sum6 + national_p_水_sum6 + national_p_浪_sum6 + national_p_风_sum6
gen national_dirty_sum6 = national_p_天然气_sum6 + national_p_煤_sum6 + national_p_油_sum6

twoway (line national_clean_sum6 t, sort) (line national_dirty_sum6 t, sort)
*这图确实能看出来dirty增速没有clean快，仅此而已

*****************************************************************************************************
*构建treat{province, time}
gen treat = 0
replace treat = 1 if prov=="上海" & atime>201311
replace treat = 1 if prov=="北京" & atime>201311
replace treat = 1 if prov=="广东" & atime>201312
replace treat = 1 if prov=="天津" & atime>201312
replace treat = 1 if prov=="湖北" & atime>201404
replace treat = 1 if prov=="重庆" & atime>201406

gen cd_ratio = clean_c/dirty_c

*构建event study的dummies
foreach i of numlist 1/47 {
gen d_treat_p`i' = 0
replace d_treat_p`i'= 1 if prov=="上海" & t-101 == `i'
replace d_treat_p`i'= 1 if prov=="北京" & t-101 == `i'
replace d_treat_p`i'= 1 if prov=="广东" & t-102 == `i'
replace d_treat_p`i'= 1 if prov=="天津" & t-102 == `i'
replace d_treat_p`i'= 1 if prov=="湖北" & t-106 == `i'
replace d_treat_p`i'= 1 if prov=="重庆" & t-108 == `i'
}

foreach i of numlist 1/107 {
gen d_treat_m`i' = 0
replace d_treat_m`i'= 1 if prov=="上海" & t-101 == -`i'
replace d_treat_m`i'= 1 if prov=="北京" & t-101 == -`i'
replace d_treat_m`i'= 1 if prov=="广东" & t-102 == -`i'
replace d_treat_m`i'= 1 if prov=="天津" & t-102 == -`i'
replace d_treat_m`i'= 1 if prov=="湖北" & t-106 == -`i'
replace d_treat_m`i'= 1 if prov=="重庆" & t-108 == -`i'
}
su d_treat*

reg cd_ratio d_treat* i.t i.plist, r
coefplot, xline(0) keep(d_treat_p*)
*不显著


