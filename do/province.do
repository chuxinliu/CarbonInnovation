/*
1. 建立起处理patent data的一套统一方案: 
	a. collapse之前，需要将几个关键词处理一下： 
		- 核能核电去掉
		- “核能”与“核电”合并
		- “石油”与“炼油”合并
		- 几个垃圾相关的合到一起
		- “水力发电”和“水能”
		- “波浪能”，“海洋能”与“潮汐”
		- “风能”与“风电”
	b. 通过collapse: 对于每个关键词{i}，每个地区{p}，每个申请时间{t}（三个维度）加总： ni_{pt}, 再collapse到year
2. time trend的图用另外一个do file去做
3. run DID design
*/

set more off
clear
capture log close

global root = "C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation"

*******************************************************************************
*******************************************************************************
use "$root\data\patent_province.dta", clear

order code prov apply_time pyear firm research

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
drop p_煤气 p_石油 p_炼油 p_水力发电 p_水能 p_波浪能 p_海洋能 p_潮汐 p_风能 p_风电 p_垃圾焚烧 p_焚烧垃圾 p_垃圾发酵 p_核能 p_核电 p_太阳能 p_光伏
***

/*
**** collapse by month, province and key word **********************************
对于每个关键词{i}，每个地区{p}，每个申请时间{t}（三个维度）加总： p_* (province, month)

collapse (sum) p_*, by(apply_time prov)
tab apply_time, m
gen atime = apply_time

*change the front and end periods to missing: not enough areas
replace atime=. if apply_time>201710
replace atime=. if apply_time<200507
*/

gen rftype=0
replace rftype=1 if firm==1
replace rftype=2 if research == 1
*** collapse by month, province, keyword, and rftype (none, firm, research)
collapse (sum) p_*, by(apply_time prov rftype)
tab apply_time, m
gen atime = apply_time


* collapse之后： 将某些月，省中专利加总为零的补充上去
egen plist = group(prov)
*for missing regions in any time, add an observation and assign 0 to number of patents
levelsof plist, local(levels1)
levelsof atime, local(levels2)
levelsof rftype, local(levels3)
foreach l1 of local levels1 {
foreach l2 of local levels2 {
foreach l3 of local levels3 {
		su apply_time if plist==`l1' & atime == `l2' & rftype == `l3'
		if r(N) == 0 {
		    insobs 1
			local N=_N
			replace atime=`l2' in `N'
			replace plist=`l1' in `N'
			replace rftype=`l3' in `N'
		}
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
order t plist atime apply_time prov rftype p_*
keep if t!=.
drop apply_time

gen year = .
foreach i of numlist 2006/2016{
    replace year = `i' if atime/100 > `i' & atime/100<`i'+1
}
tab year,m
drop t
order year atime 

/*
*collapse到year， province
collapse (firstnm) plist (sum) p_*, by(year prov)
save "$root\data\trend_prov_year.dta", replace
*/

******************************************************************************
******************************************************************************
******************************************************************************

*collapse到year， province, rftype
collapse (firstnm) plist (sum) p_*, by(year prov rftype)

gen post = (year>2013)
gen treat = 0
replace treat = 1 if prov=="上海" | prov=="北京" | prov=="广东" | prov=="湖北" | prov=="重庆" | prov=="天津"
gen trtXpost = treat * post

drop if plist == 25 

foreach i of varlist p_* {
    gen log_`i' = log(`i'+1)
}

est clear
foreach i of varlist p_* {
	eststo: reg `i' treat post trtXpost i.year i.plist, robust
foreach j of numlist 0 1 2 {
	eststo: reg `i' treat post trtXpost i.year i.plist if rftype == `j', robust
}
}
esttab using "$root\tables\table1_rft.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace


est clear
foreach i of varlist p_* {
	eststo: reg log_`i' treat post trtXpost i.year i.plist, robust
foreach j of numlist 0 1 2 {
	eststo: reg log_`i' treat post trtXpost i.year i.plist if rftype == `j', robust
}
}
esttab using "$root\tables\table2_rft.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace
est clear

* separate tables for research patent and firm patent
est clear
foreach j of numlist 0 1 2 {
foreach i of varlist p_*   {
	eststo: reg log_`i' treat post trtXpost i.year i.plist if rftype == `j', robust
}
esttab using "$root\tables\table_rft`j'.html", b(4) se(4) r2(4) label html keep(trtXpost treat post) replace
est clear
}





















