/*
# import and merge 5 files: patent_kw.dta, patent_adate, patent_pdate, patent_by, patent_prov

# clean merged.dta
1. clean adate and pdate: generate adate, pdate, ayear, amonth, aday, pyear, pmonth, pday
2. count total number of patents by province, year, person/firm/research
3. keep only kw!=""
4. count selected number of patents by province, year, person/firm/research, keywords
5. collapse for analysis
    5.1 collapse by province, year, keywords
    5.2 collapse by province, year, keywords, person/firm/research
    5.3 collapse by year, keywords: make national trends
    5.4 collapse by treat/control, year, keywords: make trends for treated/control
*/
clear
set more off
global root = "C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation"

/* -----------------------------------------------------------------------------
* import and merge 5 dta files: patent_kw, patent_adate, patent_pdate, patent_by, patent_prov
cd C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation\data\data_Dec2020
import delimited patent_adate.csv, varnames(1) encoding(Big5) 
save patent_adate.dta, replace
clear
import delimited patent_by.csv, varnames(1) encoding(Big5)
save patent_by.dta, replace
clear
import delimited patent_kw.csv, varnames(1) encoding(UTF-8)
save patent_kw.dta, replace
clear
import delimited patent_pdate.csv, varnames(1) encoding(Big5)
save patent_pdate.dta, replace
clear
import delimited patent_prov.csv, varnames(1) encoding(UTF-8)
save patent_prov.dta, replace

use "$root\data\data_Dec2020\patent_kw.dta", clear
rename v2 kw
merge 1:1 v1 using "$root\data\data_Dec2020\patent_adate.dta"
drop _merge
rename v2 adate
merge 1:1 v1 using "$root\data\data_Dec2020\patent_pdate.dta"
drop _merge
rename v2 pdate
merge 1:1 v1 using "$root\data\data_Dec2020\patent_by.dta"
drop _merge
rename v2 by
merge 1:1 v1 using "$root\data\data_Dec2020\patent_prov.dta"
drop _merge
rename v2 prov
save "$root\data\data_Dec2020\merged.dta", replace
*----------------------------------------------------------------------------*/

use "$root\data\data_Dec2020\merged.dta", clear

*1. clean adate and pdate: generate adate, pdate, ayear, amonth, aday, pyear, pmonth, pday

split adate, p(" ") gen(adate)
rename adate adate_raw
* for those adate2 == "00:00:00"
gen adate = date(adate1, "YMD") if adate2 == "00:00:00"
split adate1 if adate2 == "00:00:00", p("-") gen(a)
rename a1 ayear
rename a2 amonth
rename a3 aday
* for those adate2 != "00:00:00"
split adate_raw if adate2 != "00:00:00", p("-") gen(adate_2format)
replace adate = date(adate_raw, "DMY", 2050) if adate2 != "00:00:00"
replace aday = adate_2format1 if adate2 != "00:00:00"
replace amonth = adate_2format2 if adate2 != "00:00:00"
replace ayear = "20" + adate_2format3 if adate2 != "00:00:00"
replace ayear = "1999"  if adate_2format3=="99"

drop adate_raw adate1 adate2 adate_2format1 adate_2format2 adate_2format3

split pdate, p(" ") gen(pdate)
rename pdate pdate_raw
* for those pdate2 == "00:00:00"
gen pdate = date(pdate1, "YMD") if pdate2 == "00:00:00"
split pdate1 if pdate2 == "00:00:00", p("-") gen(p)
rename p1 pyear
rename p2 pmonth
rename p3 pday
* for those pdate2 != "00:00:00"
split pdate_raw if pdate2 != "00:00:00", p("-") gen(pdate_2format)
replace pdate = date(pdate_raw, "DMY", 2050) if pdate2 != "00:00:00"
replace pday = pdate_2format1 if pdate2 != "00:00:00"
replace pmonth = pdate_2format2 if pdate2 != "00:00:00"
replace pyear = "20" + pdate_2format3 if pdate2 != "00:00:00"

drop pdate1 pdate2 pdate_2format1 pdate_2format2 pdate_2format3 pdate_raw

*2. count total number of patents by province, year, person/firm/research
preserve
collapse (count) v1, by(prov ayear by)
rename v1 total_count
label variable total_count "# of all patents (with or without keywords)"
save "$root\data\workingdata\total_count.dta", replace
restore

*3. keep only kw!=""
tab kw, m sort
tab kw if kw=="", m
keep if kw!=""

*4. count selected number of patents by province, year, person/firm/research, keywords
*--------------- clean up similar keywords
levelsof kw, local(kwlevels)
foreach l of local kwlevels {
	generate p_`l' = 0
	replace p_`l' = 1 if kw == "`l'"
}
su p_核* if p_核能==1 & p_核电==1
gen p_核 = p_核能 + p_核电

su p_*油 if p_石油==1 & p_炼油==1
gen p_油 = p_石油 + p_炼油

gen p_垃圾 =  p_垃圾焚烧 + p_焚烧垃圾 + p_垃圾发酵
su *垃圾*

gen p_水 = p_水力发电 + p_水能 + p_水电
replace p_水 = 1 if p_水>1

gen p_浪 = p_波浪能 + p_海洋能 + p_潮汐
replace p_浪 = 1 if p_浪>1

gen p_风 = p_风能 + p_风电 + p_风力发电
replace p_风 = 1 if p_风>1

replace p_煤 = 1 if p_煤气 == 1 
replace p_煤 = 1 if p_火电 == 1 
replace p_煤 = 1 if p_火力发电 == 1 
replace p_煤 = 1 if p_煤电 == 1 

gen p_太阳 = p_太阳能 + p_光伏
replace p_太阳 = 1 if p_太阳>1

gen p_生物 = p_生物质 + p_生物燃料

su p*
keep v1 prov by kw a* pdate pyear pmonth p_生物 p_太阳 p_风 p_浪 p_水 p_垃圾 p_油 p_核 p_能源 p_煤 p_天然气 p_地热 p_发电 p_再生能
gen p_clean = p_生物 + p_太阳 + p_风 + p_浪 + p_水 + p_垃圾 + p_核 + p_天然气 + p_地热 + p_再生能
gen p_dirty = p_煤 + p_油 
*-----------------------------------------

preserve
collapse (sum) p_*, by(prov ayear by)
save "$root\data\workingdata\patent_kw_count.dta", replace
restore

*5. collapse for analysis
*    5.1 collapse by year, keywords: make national trends 
*    5.2 collapse by treat/control, year, keywords: make trends for treated/control 
*    5.3 collapse by province, year, keywords
*    5.4 collapse by province, year, keywords, person/firm/research

* ------------------------------------------------------------------------------
*5.1 collapse by year, keywords: make full sample trends
preserve 
collapse (sum) p_*, by(ayear)
save "$root\data\workingdata\patent_kw_fullsample.dta", replace
restore

*5.2 collapse by treat/control, year, keywords: make trends for treated/control 
gen treat = 0
replace treat = 1 if prov == "上海"
replace treat = 1 if prov == "北京"
replace treat = 1 if prov == "广东"
replace treat = 1 if prov == "重庆"
replace treat = 1 if prov == "天津"
replace treat = 1 if prov == "湖北"
preserve
collapse (sum) p_*, by(ayear treat)
save "$root\data\workingdata\patent_kw_fullsample_treat.dta", replace
restore

*5.3 collapse by province, year, keywords
*preserve
collapse (sum) p_* (mean) treat, by(ayear prov)
keep if prov == "山东" | prov == "广东" | prov == "上海" | prov == "云南" | prov == "内蒙古"  ///
			| prov == "北京" | prov == "吉林" | prov == "四川" | prov == "天津" | prov == "宁夏" ///
			| prov == "安徽" | prov == "广西" | prov == "新疆" | prov == "江苏" | prov == "河北" ///
			| prov == "河南" | prov == "浙江" | prov == "湖北" | prov == "湖南" | prov == "甘肃" ///
			| prov == "福建" | prov == "贵州" | prov == "辽宁" | prov == "重庆" | prov == "陕西" ///
			| prov == "黑龙江" | prov == "山西" | prov == "海南" | prov == "青海" | prov == "西藏" | prov == "江西" 
tab ayear, m
drop if ayear == "2004" 
tab prov, m
*collapse之后： 将某些年，省中专利加总为零的补充上去 (for missing regions in any time, add an observation and assign 0 to number of patents)
levelsof prov, local(levels1)
levelsof ayear, local(levels2)
foreach l1 of local levels1 {
foreach l2 of local levels2 {
		su treat if prov=="`l1'" & ayear == "`l2'"
		if r(N) == 0 {
		    insobs 1
			local N=_N
			replace prov="`l1'" in `N'
			replace ayear="`l2'" in `N'
		}
} 
}
local e1 = r(N) + 1
local en = _N
foreach v of varlist p_* {
    replace `v' = 0 in `e1'/`en'
}
tab ayear, m sort
tab prov, m sort

destring ayear, replace
replace treat = 0
replace treat = 1 if prov == "上海"
replace treat = 1 if prov == "北京"
replace treat = 1 if prov == "广东"
replace treat = 1 if prov == "重庆"
replace treat = 1 if prov == "天津"
replace treat = 1 if prov == "湖北"
gen post=(ayear>2013)
gen treatXpost = treat * post
egen plist = group(prov)

foreach i of varlist p_* {
	gen log_`i' = log(`i'+1)
}

est clear
foreach i of varlist p_* {
	quietly reg log_`i' treatXpost treat post i.ayear i.plist, robust
	est store `i'
}
esttab * using table.html, keep(treatXpost) replace
*restore

