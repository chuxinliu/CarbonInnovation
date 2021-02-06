*this do file separate the IPC codes from the IPC green inventory
*last updated: 2/6/2021
*author: Chuxin Liu

/** structure of IPC codes **
1. class: A11
2. subclass: A11A
3. group1: A11A 01
4. group2: A11A 01/00 
****************************/

clear
set more off

global root = "F:\GitHub\CarbonInnovation"

*----------------------------------------------
import excel "$root\IPC Green Ivtr.xlsx", sheet("Sheet1") firstrow clear

drop PATENTSCOPE
rename Class1 green1
rename Class2_3_4 green2_3_4
label variable green1 "names of technologies 1"
label variable green2_3_4 "names of technologies 2/3/4"
gen class = substr(IPC, 1, 3)
gen subclass = substr(IPC, 1, 4)
label variable class    "IPC code of class, 1 letter & 2 digits"
label variable subclass "IPC code of subclass, 1 letter & 2 digits & 1 letter"
order green* IPC class subclass

* change subclass to "" when only class information is mentioned
replace subclass="" if subclass == "B61"
replace subclass="" if subclass == "G21"

***********************************************************************
* Challenge: clean the info of group, which is after 4-digit subclass *
***********************************************************************
split IPC, gen(wide)
reshape long wide, i(green* IPC *class) j(split)
drop if wide==""
replace wide = "" if class == wide
replace wide = "" if subclass == wide

split wide, p(,) gen(wide)
drop wide
rename wide1 wide

*hyphen: separate minimum and maximum group number, terribly tricky
split wide, p(-) gen(hyphen)
*for those without hyphen, generate group1 and group2
split hyphen1, p(/) gen(group)
replace group1 = "" if hyphen2!=""
replace group2 = "" if hyphen2!=""
order green* IPC class subclass group*

*for those with hyphen (44 obs): (1) same group1; (2) different group1; 
sort hyphen2
split hyphen1, p(/) gen(min_group)
split hyphen2, p(/) gen(max_group)

* (1) same group1 (37 obs)
replace group1 = min_group1 if hyphen2!="" & min_group1==max_group1
gen group2_min = min_group2 if hyphen2!="" & min_group1==max_group1
gen group2_max = max_group2 if hyphen2!="" & min_group1==max_group1

* (2) different group1 (6+1 obs)
gen group1_min = min_group1 if hyphen2!="" & min_group1!=max_group1 & min_group2=="00" & max_group2=="00"
gen group1_max = max_group1 if hyphen2!="" & min_group1!=max_group1 & min_group2=="00" & max_group2=="00"
*last weird one: Transportation, with power fuel cells, e.g. hydrogen vehical
expand 2 in 581, gen(copy)
replace group1 = "50" in 591
replace group2_min = "50" in 591
replace group2_max = "90" in 591
replace group1_min = "53" in 581
replace group1_max = "58" in 581
drop hyphen1 hyphen2 min_group1 min_group2 max_group1 max_group2 copy
drop split wide
replace group2="" if group2=="00"
order green1 green2_3_4 IPC class subclass group1* group2*

foreach i of varlist group1* group2* {
destring `i', replace
}

su

save "$root\data\workingdata\IPC_green_ivtr_cleaned.dta", replace
