* Last Update: 11/26/2020
* difference in difference design: by year and city


set more off
set maxiter 3000
clear
capture log close

global root = "C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation"

*******************************************************************************
*******************************************************************************
use "$root\data\patent_city.dta", clear

order code prov city apply_time pyear firm research important

/* collapse之前，需要将几个关键词处理一下 ***************************************
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
drop _merge p_煤气 p_石油 p_炼油 p_水力发电 p_水能 p_波浪能 p_海洋能 p_潮汐 p_风能 p_风电 p_垃圾焚烧 p_焚烧垃圾 p_垃圾发酵 p_核能 p_核电 p_太阳能 p_光伏
***

/***************************************************************************
**** collapse by year, city and key word **********************************
对于每个关键词{i}，每个地区{c}，每个申请时间{t}（三个维度）加总： p_* (city, year)
	1. apply_time处理为year，只保留2006-2016
	2. 需要保留prov的信息: 如果city和prov有mismatch的话，直接collapse成mean的话，会导致某些城市的省份值变成非整数，所以采用多个quantile的值，collapse之后再进行调整； 
	3. 无法保留的信息：pyear, firm, research, important*/

* -------------------------------------
*1. apply_time处理为year，只保留2006-2016
gen year = .
foreach i of numlist 2006/2016{
    replace year = `i' if apply_time/100 > `i' & apply_time/100<`i'+1
}
tab year,m 
drop if year==.

* -------------------------------------
*2. 需要保留prov的信息
egen plist1 = group(prov)
egen plist5 = group(prov)
egen plist10 = group(prov)
egen plist50 = group(prov)
egen plist90 = group(prov)
egen plist95 = group(prov)
egen plist99 = group(prov)

collapse (sum) p_* (p1) plist1 (p5) plist5 (p10) plist10 (p50) plist50 (p90) plist90 (p95) plist95 (p99) plist99, by(year city)

* collapse之后： 将某些year，city专利加总为零的补充上去, 这些新的observation只有城市信息没有省份信息

egen clist = group(city)
*for missing regions in any time, add an observation and assign 0 to number of patents
levelsof clist, local(levels1)
levelsof year, local(levels2)
gen noncomplete = 1

foreach l1 of local levels1 {
	di `l1'
    foreach l2 of local levels2 {
		di `l2'
		qui su year if clist==`l1' & year == `l2'
		if r(N) == 0 {
		    insobs 1
			local N=_N
			replace year=`l2' in `N'
			replace clist=`l1' in `N'
		}
	} 
}
su noncomplete
local e1 = r(N) + 1
local en = _N
foreach v of varlist p_* {
    replace `v' = 0 in `e1'/`en'
}
drop noncomplete
order year city clist plist*

*现在来处理prov(plist)的问题
gen diff_plist = 0
replace diff_plist = 1 if plist1 - plist5 != 0
replace diff_plist = 1 if plist10 - plist5 != 0
replace diff_plist = 1 if plist10 - plist50 != 0
replace diff_plist = 1 if plist90 - plist50 != 0
replace diff_plist = 1 if plist90 - plist95 != 0
replace diff_plist = 1 if plist99 - plist95 != 0
tab diff_plist,m
*7% （265个城市有不同的prov值）
*row mode可以处理，但是现在先使用p50的mode
by clist, sort : egen float plist = mode(plist50)
drop plist1-plist99
order year city plist clist



******************************************************************************
******************************************************************************
******************************************************************************

gen post = (year>2013)
gen treat = 0
replace treat = 1 if plist == 1 | plist == 4 | plist == 7 | plist == 12 | plist == 21 | plist == 28   
gen trtXpost = treat * post

foreach i of varlist p_* {
    gen log_`i' = log(`i'+1)
}

est clear
foreach i of varlist p_* {
	eststo: reg `i' treat post trtXpost i.year i.plist, robust
}
esttab using "$root\tables\table4.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace
est clear
foreach i of varlist p_* {
	eststo: reg log_`i' treat post trtXpost i.year i.plist, robust
}
esttab using "$root\tables\table5.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace
est clear

/* poisson： convergence not achieved
foreach i of varlist p_* {
	eststo: poisson `i' treat post trtXpost i.year i.plist, robust
}
esttab using "$root\tables\table6.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace
est clear


