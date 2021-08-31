global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

import excel "$data/gender_data_1858.xlsx", sheet("Sheet1") firstrow clear


bys Gubernia : egen total_pop = sum(D)
gen female_prop_1858 = D/total_pop if Gender=="Female"
drop if female_prop_1858==.
tempfile temp
save `temp'

import excel "$data/gender_data_1897_census.xlsx", sheet("Sheet1") firstrow clear
foreach var of varlist age*{
replace `var'=0 if `var'==.

}
gen total_pop_g = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more
bys Gubernia: egen total_pop = sum(total_pop_g)
gen female_prop_1897 = total_pop_g/total_pop if Gender=="Female"
drop if female_prop_1897==.
gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
tempfile temp1
save `temp1'
merge 1:1 Gubernia Gender using `temp'
corr female_prop_1858 female_prop_1897

scatter female_prop_1858 female_prop_1897 if _merge==3, xscale(range(0.45 0.55))

clear
use `temp'

gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"

tempfile temp
save `temp'
use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta", clear
*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge

merge m:1 ProvinceName using `temp'
drop if _merge!=3
drop _merge
xi: reg propWomen female_prop_1858 Total Age logTotalMachinePower i.Industry i.Region, robust

xi: reg propWomen female_prop_1858 Total Age logTotalMachinePower City i.Industry i.Region, robust


merge m:1 ProvinceName using `temp1'
