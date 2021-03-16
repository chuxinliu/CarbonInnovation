use "$root\data\workingdata\merged.dta", clear

*1. clean adate: generate adate, ayear, amonth, aday
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

*2. keep only ipc!="", clean IPC codes: class, subclass, group
tab ayear if ipc1!=""
tab ayear if ipc2!=""
keep if ipc1!="" | ipc2!=""

split ipc1, p(/) gen(ipc1_)
gen len_1 = length(ipc1_1)
tab len_1, m
**********
gen subclass = substr(ipc1_1,1,4)
gen class    = substr(subclass,1,3)
**********
gen group1 = ""
gen group2 = ""
replace group1 = substr(ipc1_1,5,1) if len_1==5
replace group1 = substr(ipc1_1,5,2) if len_1==6
replace group1 = substr(ipc1_1,5,3) if len_1==7
split ipc1_1, gen(len9_)
replace group1 = len9_2 if len_1==9
drop len9*
replace group1 = substr(ipc1_1,5,2) if len_1==8
replace group1 = "487" if len_1==10
replace group1 = "9" if len_1==17
**********
split ipc1_2, p("(2006") gen(ipc1_2006_)
gen len_2006 = length(ipc1_2006_1)
tab len_2006, m
replace group2 = "00" in 2931362
replace group2 = "08" in 3130190
replace group2 = ipc1_2006_1 if len_2006==2
replace group2 = "08" in 3208262
replace group2 = ipc1_2006_1 if len_2006==3
replace group2 = ipc1_2006_1 if len_2006==4
replace group2 = ipc1_2006_1 if len_2006==5
replace group2 = ipc1_2006_1 if len_2006==6
foreach i of numlist 2007/2017 {
split ipc1_2, p("(`i'") gen(ipc1_`i'_)
codebook *`i'*
replace group2 = ipc1_`i'_1 if ipc1_`i'_2!=""
}
replace group2 = substr(ipc1_1,7,2) if len_1==8
replace group2 = "04" if len_1==10
replace group2 = "04" if len_1==17
destring group1, replace
destring group2, replace force
replace group2=0 in 2959578
replace group2=0205 in 3253463

codebook class subclass group1 group2
drop ipc1_* len*

* --------
* 3. provinces, treat and control
destring ayear, replace
keep if prov == "山东" | prov == "广东" | prov == "上海" | prov == "云南" | prov == "内蒙古"  ///
			| prov == "北京" | prov == "吉林" | prov == "四川" | prov == "天津" | prov == "宁夏" ///
			| prov == "安徽" | prov == "广西" | prov == "新疆" | prov == "江苏" | prov == "河北" ///
			| prov == "河南" | prov == "浙江" | prov == "湖北" | prov == "湖南" | prov == "甘肃" ///
			| prov == "福建" | prov == "贵州" | prov == "辽宁" | prov == "重庆" | prov == "陕西" ///
			| prov == "黑龙江" | prov == "山西" | prov == "海南" | prov == "青海" | prov == "西藏" | prov == "江西"
gen treat = 0
replace treat = 1 if prov == "上海"
replace treat = 1 if prov == "北京"
replace treat = 1 if prov == "广东"
replace treat = 1 if prov == "重庆"
replace treat = 1 if prov == "天津"
replace treat = 1 if prov == "湖北"

save "$root\data\workingdata\merged_with_cleaned_IPC.dta", replace
