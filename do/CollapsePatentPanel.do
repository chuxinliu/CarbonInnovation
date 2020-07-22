** Input: Patent_panel.dta

* Time variable: apply_time
* Location variables: province, city

/* Patent Categories */
* dirty: p_煤 p_石油 p_炼油
* clean: p_天然气 p_地热 p_水力发电 p_水能 p_波浪能 p_海洋能 p_潮汐 p_太阳能 p_光伏 p_风能 p_风电 p_核能核电 p_生物燃料 p_垃圾焚烧 p_焚烧垃圾 p_垃圾发酵 p_再生能

* firm application (暂不考虑)
* research institution application (暂不考虑)


***************************** Province Level ****************************
use "C:\Users\chuxi\Downloads\patent_panel.dta", clear
collapse (sum) p_*, by(apply_time province)
* data problem: huge amount of late patents do not contain location information

foreach i of varlist p_* {

}
