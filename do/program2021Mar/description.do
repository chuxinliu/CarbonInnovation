use "$root\data\workingdata\merged_with_cleaned_IPC.dta", clear

/* trend figures */
*collapse by treat/control, year
*collapse by treat/control, year, person/firm/research
*collapse by treat/control, year, energy types
