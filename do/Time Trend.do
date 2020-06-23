/*
To do: 
1. 不区分省份画time trend (collapse)
	(1). 将省份collapse掉
	(2). 能源，发电，石油，煤，clean
2. 区分treatment和control画time trend (collapse)
	(1). 将省份分成两个组
	(2). 还是需要将省份collapse掉
3. 拿treatment的节点画trend (不需要collapse)
	(1). 选择要画的y变量是什么
*/

set more off
use "C:\Users\chuxi\Downloads\patent_kw.dta", clear

by kword prov, sort : egen float ymrank = rank(ym)

collapse (sum) num (mean) ymrank , by(kword ym)

tab ym, m
tab kword, m

twoway (connected num ymrank if kword=="能源") (connected num ymrank if kword=="石油") , legend(order(1 "能源" 2 "石油"))

twoway (connected num ymrank if kword=="发电") (connected num ymrank if kword=="煤"), legend(order(1 "发电" 2 "煤"))

twoway (connected num ymrank if kword=="煤气") (connected num ymrank if kword=="天然气"), legend(order(1 "煤气" 2 "天然气"))

gen clean = .
*replace clean = 1 if kword=="光伏" 
replace clean = 1 if kword=="再生能" 
replace clean = 1 if kword=="地热" 
replace clean = 1 if kword=="垃圾发酵" 
replace clean = 1 if kword=="垃圾焚烧" 
*replace clean = 1 if kword=="太阳能" 
replace clean = 1 if kword=="核电" 
replace clean = 1 if kword=="核能" 
replace clean = 1 if kword=="水力发电" 
replace clean = 1 if kword=="水能" 
replace clean = 1 if kword=="波浪能" 
replace clean = 1 if kword=="海洋能" 
replace clean = 1 if kword=="潮汐" 
replace clean = 1 if kword=="焚烧垃圾" 
replace clean = 1 if kword=="生物燃料"
replace clean = 1 if kword=="风电" 
replace clean = 1 if kword=="风能"
replace clean = 1 if kword=="天然气" 

by ym, sort : egen float num_clean = total(num) if clean==1
twoway (connected num_clean ymrank) (connected num ymrank if kword=="光伏")  (connected num ymrank if kword=="太阳能"), legend(order(1 "other clean" 2 "光伏" 3 "太阳能"))

*********************************************************************************
/* 区分control and treatment */
use "C:\Users\chuxi\Downloads\patent_kw.dta", clear
by kword prov, sort : egen float ymrank = rank(ym)

graph hbar (sum) num, over(kword)
graph hbar (sum) num, over(ym)
graph hbar (sum) num, over(prov)

split prov, p(_)
drop prov1 prov
rename prov2 prov

gen treat_group = 0
replace treat_group = 1 if prov=="广东"
replace treat_group = 1 if prov=="北京"
replace treat_group = 1 if prov=="上海"
replace treat_group = 1 if prov=="湖北"
replace treat_group = 1 if prov=="重庆"

collapse (sum) num (mean) ymrank , by(kword ym treat_group)

twoway (connected num ymrank if kword=="能源" & treat_group==1) (connected num ymrank if kword=="石油"  & treat_group==1) (connected num ymrank if kword=="能源" & treat_group==0) (connected num ymrank if kword=="石油"  & treat_group==0), legend(order(1 "能源 T" 2 "石油 T" 3 "能源" 4 "石油"))

twoway (connected num ymrank if kword=="发电" & treat_group==1) (connected num ymrank if kword=="煤"  & treat_group==1) (connected num ymrank if kword=="发电" & treat_group==0) (connected num ymrank if kword=="煤"  & treat_group==0), legend(order(1 "发电 T" 2 "煤 T" 3 "发电" 4 "煤"))

twoway (connected num ymrank if kword=="天然气" & treat_group==1) (connected num ymrank if kword=="煤气"  & treat_group==1) (connected num ymrank if kword=="天然气" & treat_group==0) (connected num ymrank if kword=="煤气"  & treat_group==0), legend(order(1 "天然气 T" 2 "煤气 T" 3 "天然气" 4 "煤气"))

gen clean = .
*replace clean = 1 if kword=="光伏" 
replace clean = 1 if kword=="再生能" 
replace clean = 1 if kword=="地热" 
replace clean = 1 if kword=="垃圾发酵" 
replace clean = 1 if kword=="垃圾焚烧" 
*replace clean = 1 if kword=="太阳能" 
replace clean = 1 if kword=="核电" 
replace clean = 1 if kword=="核能" 
replace clean = 1 if kword=="水力发电" 
replace clean = 1 if kword=="水能" 
replace clean = 1 if kword=="波浪能" 
replace clean = 1 if kword=="海洋能" 
replace clean = 1 if kword=="潮汐" 
replace clean = 1 if kword=="焚烧垃圾" 
replace clean = 1 if kword=="生物燃料"
replace clean = 1 if kword=="风电" 
replace clean = 1 if kword=="风能"
replace clean = 1 if kword=="天然气" 

by ym treat_group, sort : egen float num_clean = total(num) if clean==1

twoway (connected num_clean ymrank if treat_group==1) (connected num ymrank if kword=="光伏" & treat_group==1)  (connected num ymrank if kword=="太阳能" & treat_group==1) (connected num_clean ymrank if treat_group==0) (connected num ymrank if kword=="光伏" & treat_group==0)  (connected num ymrank if kword=="太阳能" & treat_group==0), legend(order(1 "other clean T" 2 "光伏 T" 3 "太阳能 T" 4 "other clean" 5 "光伏" 6 "太阳能"))






