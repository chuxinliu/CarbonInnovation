use "$root\data\data_Dec2020\patent_adate.dta", clear
rename v2 adate

merge 1:1 v1 using "$root\data\data_Dec2020\patent_by.dta"
drop _merge
rename v2 by

merge 1:1 v1 using "$root\data\data_Dec2020\patent_prov.dta"
drop _merge
rename v2 prov
codebook prov /* prov is missing for 2016 2017 */
merge 1:1 v1 using "$root\data\data_Dec2020\patent_prov1.dta"
drop _merge
replace prov = prov1 if prov == ""
drop prov1

merge 1:1 v1 using "$root\data\data_Dec2020\patent_ipc.dta"
drop _merge
rename first_type_num ipc1
rename second_type_num ipc2

save "$root\data\workingdata\merged.dta", replace
