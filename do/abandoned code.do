*abandoned codes


/*	c. 跨类别不能比较的问题： 
		想法一： ni_{pt}除以i专利前后六个月的全国总申请量（13个月），那么i与i之间就可以比较了: 生成comparable的新变量p_*_c{pt}
		想法二： 比增速，前一阶段是0的话就尝试用t-2来计算，看看missing有多少 */

*******************************************************************************
*创建各专利各时间段的全国加总
*各类别当期全国加总
foreach v of varlist p_* {
    by t, sort : egen float national_`v' = total(`v')
}
*生成全国加总的lag和lead
xtset plist t
foreach v of varlist national* {
	foreach i of numlist 1/12{
		gen `v'_lag`i' = `v'[_n-`i']
	}
	foreach j of numlist 1/12{
		gen `v'_lead`j' = `v'[_n+`j']
	}
}
*通过横向加总，可以得出加上了上下1-12期之后的各专利全国加总
*这样我们可以看加到多少期之后就没有0的问题
foreach v of varlist p_* {
	gen national_`v'_sum1 = national_`v'_lag1 + national_`v' + national_`v'_lead1
	foreach i of numlist 2/12 {
		gen national_`v'_sum`i' = national_`v'
		foreach j of numlist 1/`i' {
			replace national_`v'_sum`i'= national_`v'_sum`i' + national_`v'_lag`j' + national_`v'_lead`j'
}
}
}
su national_*_sum1
su national_*_sum2
su national_*_sum3
su national_*_sum4
su national_*_sum5
su national_*_sum6
su national_*_sum7
su national_*_sum8
su national_*_sum9
su national_*_sum10
su national_*_sum11
su national_*_sum12

*加了上下6期之后，0的问题基本没有了，所以选择除以sum6结尾的全国加总
*生成comparable的新变量p_*_c{province, time}
foreach v of varlist p_* {
	gen `v'_c = 13 * `v'/national_`v'_sum6
}
su p_*



/*synthetic control的想法，用的是月份level*/
******************************************************************************
******************************************************************************
tsset plist t
ssc install synth
tab plist if prov=="上海"
tab plist if prov=="北京"
tab plist if prov=="广东"
tab plist if prov=="天津"
tab plist if prov=="湖北"
tab plist if prov=="重庆"
tab t if atime==201311
tab t if atime==201312
tab t if atime==201404
tab t if atime==201406
drop if t<=6 | t>=143
tsset plist t

foreach v of varlist p_*{
*上海
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(7(1)100), trunit(1) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\上海_`v'.png", as(png) replace
restore
*北京
preserve
drop if plist == 1 | plist == 7 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(7(1)100), trunit(4) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\北京_`v'.png", as(png) replace
restore
*广东
preserve
drop if plist == 4 | plist == 7 | plist == 1 | plist == 21 | plist == 28
synth `v' `v'(7(1)100), trunit(12) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\广东_`v'.png", as(png) replace
restore
*天津
preserve
drop if plist == 4 | plist == 1 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(7(1)100), trunit(7) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\天津_`v'.png", as(png) replace
restore
*湖北
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 1 | plist == 28
synth `v' `v'(7(1)100), trunit(21) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\湖北_`v'.png", as(png) replace
restore
*重庆
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 21 | plist == 1
synth `v' `v'(7(1)100), trunit(28) trperiod(101) mspeperiod(7(1)100) fig
graph export "$root\figures\synth_province\重庆_`v'.png", as(png) replace
restore
}

*******************************************************************************
*******************************************************************************
*time trend: national_*_sum6， 不太看出来啥
twoway (line national_p_太阳_sum3 t, sort) (line national_p_煤_sum3 t, sort) (line national_p_油_sum3 t, sort) (line national_p_天然气_sum3 t, sort)
twoway (line national_p_太阳_sum6 t, sort) (line national_p_煤_sum6 t, sort) (line national_p_油_sum6 t, sort) (line national_p_天然气_sum6 t, sort)

gen national_clean_sum6 = national_p_地热_sum6 + national_p_太阳_sum6 + national_p_生物燃料_sum6 + national_p_再生能_sum6 + national_p_核_sum6 + national_p_垃圾_sum6 + national_p_水_sum6 + national_p_浪_sum6 + national_p_风_sum6
gen national_dirty_sum6 = national_p_天然气_sum6 + national_p_煤_sum6 + national_p_油_sum6

twoway (line national_clean_sum6 t, sort) (line national_dirty_sum6 t, sort)
*这图确实能看出来dirty增速没有clean快，仅此而已


******************************************************************************
******************************************************************************
******************************************************************************
*构建treat{province, time}
gen treat = 0
replace treat = 1 if prov=="上海" & atime>201311
replace treat = 1 if prov=="北京" & atime>201311
replace treat = 1 if prov=="广东" & atime>201312
replace treat = 1 if prov=="天津" & atime>201312
replace treat = 1 if prov=="湖北" & atime>201404
replace treat = 1 if prov=="重庆" & atime>201406

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


*****************************************************************************
*****************************************************************************
*****************************************************************************

/*


*对比clean和dirty
gen cd_ratio = clean_c/dirty_c

reg cd_ratio d_treat* i.t i.plist, r
coefplot, xline(0) keep(d_treat_p*)
coefplot, xline(0) keep(d_treat_m*)

*不显著

*******************************************************************************
*******************************************************************************
*按照季节去处理，1-3，4-6，7-9，10-12
*******************************************************************************
*******************************************************************************

use "$root\data\patent_province.dta", clear

order code prov apply_time pyear firm research
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
**** collapse by season, province and key word **********************************
对于每个关键词{i}，每个地区{p}，每个申请时间{t}（三个维度）加总： p_* (province, season)
*/
tab apply_time, m
gen atime = apply_time
*change the front and end periods to missing: not enough areas
replace atime=. if apply_time>201709
replace atime=. if apply_time<200507
gen amonth = mod(atime,100)
gen ayear = (atime - amonth)/100
gen aseason = .
replace aseason = 1 if amonth >=1 & amonth<=3
replace aseason = 2 if amonth >=4 & amonth<=6
replace aseason = 3 if amonth >=7 & amonth<=9
replace aseason = 4 if amonth >=10 & amonth<=12

egen float t_season = group(ayear aseason)

collapse (sum) p_*, by(t_season prov)
drop if t_season==.
**********************************************************
* collapse之后： 将某些season，省中专利加总为零的补充上去
egen plist = group(prov)
*for missing regions in any time, add an observation and assign 0 to number of patents
levelsof plist, local(levels1)
levelsof t_season, local(levels2)
foreach l1 of local levels1 {
    foreach l2 of local levels2 {
		su plist if plist==`l1' & t_season == `l2'
		if r(N) == 0 {
		    insobs 1
			local N=_N
			replace plist=`l1' in `N'
			replace t_season=`l2' in `N'
		}
	} 
}
su p_*
local e1 = r(N) + 1
local en = _N
foreach v of varlist p_* {
    replace `v' = 0 in `e1'/`en'
}
sort t_season

*******************************************************************************
*创建各专利各时间段的全国加总
*各类别当期全国加总
foreach v of varlist p_* {
    by t_season, sort : egen float national_`v' = total(`v')
}
*生成全国加总的lag和lead
xtset plist t_season
foreach v of varlist national* {
	foreach i of numlist 1/4{
		gen `v'_lag`i' = `v'[_n-`i']
	}
	foreach j of numlist 1/4{
		gen `v'_lead`j' = `v'[_n+`j']
	}
}
*通过横向加总，可以得出加上了上下1-4期之后的各专利全国加总
*这样我们可以看加到多少期之后就没有0的问题
foreach v of varlist p_* {
	gen national_`v'_sum1 = national_`v'_lag1 + national_`v' + national_`v'_lead1
	foreach i of numlist 2/4 {
		gen national_`v'_sum`i' = national_`v'
		foreach j of numlist 1/`i' {
			replace national_`v'_sum`i'= national_`v'_sum`i' + national_`v'_lag`j' + national_`v'_lead`j'
}
}
}
su national_*_sum1
su national_*_sum2
su national_*_sum3
su national_*_sum4

*加了上下2期之后，0的问题基本没有了，所以选择除以sum6结尾的全国加总
*生成comparable的新变量p_*_c{province, t_season}
foreach v of varlist p_* {
	gen `v'_c = 3 * `v'/national_`v'_sum2
}
su p_*

tsset plist t_season
ssc install synth
tab plist if prov=="上海"
tab plist if prov=="北京"
tab plist if prov=="广东"
tab plist if prov=="天津"
tab plist if prov=="湖北"
tab plist if prov=="重庆"
drop if t_season<=2 | t_season>=48
tsset plist t_season

foreach v of varlist p_*{
*上海
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(3(1)33), trunit(1) trperiod(34) mspeperiod(3(1)33) fig
graph export "$root\figures\synth_province\s上海_`v'.png", as(png) replace
restore
*北京
preserve
drop if plist == 1 | plist == 7 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(3(1)33), trunit(4) trperiod(34) mspeperiod(3(1)33) fig
graph export "$root\figures\synth_province\s北京_`v'.png", as(png) replace
restore
*广东
preserve
drop if plist == 4 | plist == 7 | plist == 1 | plist == 21 | plist == 28
synth `v' `v'(3(1)33), trunit(12) trperiod(34) mspeperiod(3(1)33) fig
graph export "$root\figures\synth_province\s广东_`v'.png", as(png) replace
restore
*天津
preserve
drop if plist == 4 | plist == 1 | plist == 12 | plist == 21 | plist == 28
synth `v' `v'(3(1)33), trunit(7) trperiod(34) mspeperiod(3(1)33) fig
graph export "$root\figures\synth_province\s天津_`v'.png", as(png) replace
restore
*湖北
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 1 | plist == 28
synth `v' `v'(3(1)35), trunit(21) trperiod(36) mspeperiod(3(1)35) fig
graph export "$root\figures\synth_province\s湖北_`v'.png", as(png) replace
restore
*重庆
preserve
drop if plist == 4 | plist == 7 | plist == 12 | plist == 21 | plist == 1
synth `v' `v'(3(1)35), trunit(28) trperiod(36) mspeperiod(3(1)35) fig
graph export "$root\figures\synth_province\s重庆_`v'.png", as(png) replace
restore
}


*画图： 6个carbon market的
gen carbon_market = 0
replace carbon_market = 1 if prov=="上海" 
replace carbon_market = 1 if prov=="北京" 
replace carbon_market = 1 if prov=="广东" 
replace carbon_market = 1 if prov=="天津" 
replace carbon_market = 1 if prov=="湖北" 
replace carbon_market = 1 if prov=="重庆" 

/*
foreach v of varlist p_* {
by carbon_market t_season, sort : egen float carbon_market_`v'_c = total(`v'_c)
twoway (lpoly carbon_market_`v'_c t if carbon_market==1) (lpoly carbon_market_`v'_c t if carbon_market==0), legend(order(1 "Carbon Market == 1" 2 "No" )) title("`v'")
graph export "$root\figures\carbon_market_`v'_season_trend.png", as(png) replace
}
*/

gen clean_c = p_地热_c + p_太阳_c + p_生物燃料_c + p_再生能_c + p_核_c + p_垃圾_c + p_水_c + p_浪_c + p_风_c + p_天然气_c
gen dirty_c = p_煤_c + p_油_c

*time trend: national_*_sum6， 不太看出来啥
gen t= t_season
twoway (line national_p_太阳_sum2 t, sort) (line national_p_煤_sum2 t, sort) (line national_p_油_sum2 t, sort) (line national_p_天然气_sum2 t, sort)
twoway (line national_p_太阳_sum3 t, sort) (line national_p_煤_sum3 t, sort) (line national_p_油_sum3 t, sort) (line national_p_天然气_sum3 t, sort)

*******************************************************************************
*构建treat{province, time}
gen treat = 0
replace treat = 1 if prov=="上海" & t_season>34
replace treat = 1 if prov=="北京" & t_season>34
replace treat = 1 if prov=="广东" & t_season>34
replace treat = 1 if prov=="天津" & t_season>34
replace treat = 1 if prov=="湖北" & t_season>36
replace treat = 1 if prov=="重庆" & t_season>36

*构建event study的dummies
foreach i of numlist 1/15 {
gen d_treat_p`i' = 0
replace d_treat_p`i'= 1 if prov=="上海" & t-34 == `i'
replace d_treat_p`i'= 1 if prov=="北京" & t-34 == `i'
replace d_treat_p`i'= 1 if prov=="广东" & t-34 == `i'
replace d_treat_p`i'= 1 if prov=="天津" & t-34 == `i'
replace d_treat_p`i'= 1 if prov=="湖北" & t-36 == `i'
replace d_treat_p`i'= 1 if prov=="重庆" & t-36 == `i'
}

foreach i of numlist 1/36 {
gen d_treat_m`i' = 0
replace d_treat_m`i'= 1 if prov=="上海" & t-34 == -`i'
replace d_treat_m`i'= 1 if prov=="北京" & t-34 == -`i'
replace d_treat_m`i'= 1 if prov=="广东" & t-34 == -`i'
replace d_treat_m`i'= 1 if prov=="天津" & t-34 == -`i'
replace d_treat_m`i'= 1 if prov=="湖北" & t-36 == -`i'
replace d_treat_m`i'= 1 if prov=="重庆" & t-36 == -`i'
}
su d_treat*

*对比clean和dirty
gen cd_ratio = clean_c/dirty_c

reg cd_ratio d_treat* i.t_season i.plist, r
coefplot, xline(0) keep(d_treat_p*)
coefplot, xline(0) keep(d_treat_m*)
