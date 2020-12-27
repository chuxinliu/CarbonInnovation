*time trend by year: national level, treat&control
*outputs are in "trend" folder 

set more off
clear
capture log close

global root = "C:\Users\chuxi\OneDrive\Documents\GitHub\CarbonInnovation"

*******************************************************************************
*******************************************************************************
use "$root\data\trend_prov_year.dta", clear

preserve
*time trend: collapse to year (national)
collapse (sum) p_*, by(year)
foreach i of varlist p_* {
    gen log_`i' = log(`i'+1)
	twoway (line `i' year, sort)
	graph export "$root\figures\trend\trend_`i'.png", as(png) replace
	twoway (line log_`i' year, sort)
	graph export "$root\figures\trend\trend_log_`i'.png", as(png) replace
}

twoway (line p_煤 year, sort) (line p_天然气 year, sort) (line p_能源 year, sort) (line p_发电 year, sort)(line p_地热 year, sort) (line p_生物燃料 year, sort) (line p_再生能 year, sort) (line p_核 year, sort) (line p_油 year, sort) (line p_垃圾 year, sort) (line p_水 year, sort) (line p_浪 year, sort) (line p_风 year, sort) (line p_太阳 year, sort), legend(cols(1) position(3))
graph export "$root\figures\trend\trend_n.png", as(png) replace

twoway (line log_p_煤 year, sort) (line log_p_天然气 year, sort) (line log_p_能源 year, sort) (line log_p_发电 year, sort)(line log_p_地热 year, sort) (line log_p_生物燃料 year, sort) (line log_p_再生能 year, sort) (line log_p_核 year, sort) (line log_p_油 year, sort) (line log_p_垃圾 year, sort) (line log_p_水 year, sort) (line log_p_浪 year, sort) (line log_p_风 year, sort) (line log_p_太阳 year, sort), legend(cols(1) position(3))
graph export "$root\figures\trend\trend_log.png", as(png) replace
restore

*time trend: collapse to year， treat&control
gen treat = 0
replace treat = 1 if prov=="上海" | prov=="北京" | prov=="广东" | prov=="湖北" | prov=="重庆" | prov=="天津"
collapse (sum) p_*, by(year treat)
foreach i of varlist p_* {
    gen log_`i' = log(`i'+1)
	twoway (line `i' year if treat == 1, sort) (line `i' year if treat == 0, sort), xline(2013) legend(order(1 "treated" 2 "control"))
	graph export "$root\figures\trend\trend_tc_`i'.png", as(png) replace
	twoway (line log_`i' year if treat == 1, sort) (line log_`i' year if treat == 0, sort), xline(2013) legend(order(1 "treated" 2 "control"))
	graph export "$root\figures\trend\trend_tc_log_`i'.png", as(png) replace
}
