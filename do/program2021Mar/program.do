clear
set more off
global root = "F:\GitHub\CarbonInnovation"

do merge.do /* Output: "$root\data\workingdata\merged.dta" */
do clean.do /* Output: "$root\data\workingdata\merged_with_cleaned_IPC.dta" */
do description.do
do analysis.do
