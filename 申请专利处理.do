/*第一步主要是减少文件大小的，但也可以直接加入第二步那一堆，提前做好关键词分类*/
forvalues i=2007/2015{
		use ip_`i',clear/*这里我命名格式是ip_xxxx形式*/
		drop PAGE_COUNT SUMMARY_WORD_NUM SPEC_FIGURE_NUM PUBLIC_NUM 
		/*其他的后面没用到的变量也可以加入，我这里是提前清洗过，删掉了一些，用2017年以后的数据会有别的变量，大小写可能也不一样*/
		gen patent_want=0	
		replace patent_want=1 if subinstr(PATENT_NAME,"煤","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"天然气","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"石油","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"炼油","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"能源","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"发电","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"地热","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"水力发电","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"水能","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"波浪能","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"海洋能","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"潮汐","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"太阳能","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"光伏","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"风能","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"风电","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"核能核电","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"生物燃料","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"垃圾焚烧","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"焚烧垃圾","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"垃圾发酵","",.)~= PATENT_NAME
		replace patent_want=1 if subinstr(PATENT_NAME,"再生能","",.)~= PATENT_NAME
		keep if patent_want==1
		drop  patent_want
		gen firm=0
		replace firm=1 if subinstr(PATENT_OWN,"公司","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"厂","",.)~=PATENT_OWN
		gen research=0
		replace research=1 if subinstr(PATENT_OWN,"中心","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"大学","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"学院","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"中学","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"医院","",.)~=PATENT_OWN|subinstr(PATENT_OWN,"研究","",.)~=PATENT_OWN
		save patent`i',replace
		}
use patent2007,clear
forvalues i=2008/2015{
	append using patent`i'
	}
gen year=year(dofc(APPLY_DATE))
gen month=month(dofc(APPLY_DATE))
gen apply_ym=year*100+month
drop year month

gen p_煤=0
gen p_煤气=0
gen p_天然气=0
gen p_石油=0
gen p_炼油=0
gen p_能源=0
gen p_发电=0
gen p_地热=0
gen p_水力发电=0
gen p_水能=0
gen p_波浪能=0
gen p_海洋能=0
gen p_潮汐=0
gen p_太阳能=0
gen p_光伏=0
gen p_风能=0
gen p_风电=0
gen p_核能核电=0
gen p_生物燃料=0
gen p_垃圾焚烧=0
gen p_焚烧垃圾=0
gen p_垃圾发酵=0
gen p_再生能=0
replace p_煤=1 if subinstr(PATENT_NAME,"煤","",.)~=PATENT_NAME
replace p_煤气=1 if subinstr(PATENT_NAME,"煤气","",.)~=PATENT_NAME
replace p_天然气=1 if subinstr(PATENT_NAME,"天然气","",.)~=PATENT_NAME
replace p_石油=1 if subinstr(PATENT_NAME,"石油","",.)~=PATENT_NAME
replace p_炼油=1 if subinstr(PATENT_NAME,"炼油","",.)~=PATENT_NAME
replace p_能源=1 if subinstr(PATENT_NAME,"能源","",.)~=PATENT_NAME
replace p_发电=1 if subinstr(PATENT_NAME,"发电","",.)~=PATENT_NAME
replace p_地热=1 if subinstr(PATENT_NAME,"地热","",.)~=PATENT_NAME
replace p_水力发电=1 if subinstr(PATENT_NAME,"水力发电","",.)~=PATENT_NAME
replace p_水能=1 if subinstr(PATENT_NAME,"水能","",.)~=PATENT_NAME
replace p_波浪能=1 if subinstr(PATENT_NAME,"波浪能","",.)~=PATENT_NAME
replace p_海洋能=1 if subinstr(PATENT_NAME,"海洋能","",.)~=PATENT_NAME
replace p_潮汐=1 if subinstr(PATENT_NAME,"潮汐","",.)~=PATENT_NAME
replace p_太阳能=1 if subinstr(PATENT_NAME,"太阳能","",.)~=PATENT_NAME
replace p_光伏=1 if subinstr(PATENT_NAME,"光伏","",.)~=PATENT_NAME
replace p_风能=1 if subinstr(PATENT_NAME,"风能","",.)~=PATENT_NAME
replace p_风电=1 if subinstr(PATENT_NAME,"风电","",.)~=PATENT_NAME
replace p_核能核电=1 if subinstr(PATENT_NAME,"核能核电","",.)~=PATENT_NAME
replace p_生物燃料=1 if subinstr(PATENT_NAME,"生物燃料","",.)~=PATENT_NAME
replace p_垃圾焚烧=1 if subinstr(PATENT_NAME,"垃圾焚烧","",.)~=PATENT_NAME
replace p_焚烧垃圾=1 if subinstr(PATENT_NAME,"焚烧垃圾","",.)~=PATENT_NAME
replace p_垃圾发酵=1 if subinstr(PATENT_NAME,"垃圾发酵","",.)~=PATENT_NAME
replace p_再生能=1 if subinstr(PATENT_NAME,"再生能","",.)~=PATENT_NAME

foreach var of varlist p_煤气  p_天然气  p_石油  p_炼油  p_能源  p_发电  p_地热  p_水力发电  p_水能  p_波浪能  p_海洋能  p_潮汐  p_太阳能  p_光伏  p_风能  p_风电  p_核能核电  p_生物燃料  p_垃圾焚烧  p_焚烧垃圾  p_垃圾发酵  p_再生能{
	bys apply_ym NATION_CODE_NATION firm:egen num_`var'=total(`var')
	}
drop CODE PATENT_NUM APPLY_PATENT_NUM APPLY_DATE APPLY_ADDR PATENT_NAME PATENT_OWN
drop research prov p_煤 p_煤气 p_天然气 p_石油 p_炼油 p_能源 p_发电 p_地热 p_水力发电 p_水能 p_波浪能 p_海洋能 p_潮汐 p_太阳能 p_光伏 p_风能 p_风电
duplicates drop NATION_CODE_NATION firm apply_ym,force
rename NATION_CODE_NATION province
save 申请专利,replace
