
global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear
drop if Gubernia == "Erivanskaya"
tempfile temp
save `temp'
import excel "$data/gender_marriage_1897_census.xlsx", sheet("Sheet1") firstrow clear
merge 1:1 Gubernia District AdministrativeDivision CityName Gender using `temp' 
keep if _merge==3

gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
drop Gubernia 

destring(age_60_69), replace force

gen total_pop_g = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+unknown_age
gen unmarried_young = Unmarried - age_less_1 - age_1_9
gen total_pop_young = total_pop_g - age_less_1 - age_1_9
 
bys ProvinceName AdministrativeDivision CityName Gender: egen total_young_gub = sum(total_pop_young)
bys ProvinceName AdministrativeDivision CityName Gender: egen total_unmarried_young = sum(unmarried_young)

gen unmarried_men_young_ratio = total_unmarried_young/(total_young_gub) if Gender=="Male"



gen children = age_1_9

bys ProvinceName AdministrativeDivision CityName: egen total_num = sum(children)
gen fem_male_ratio_t = children/(total_num-children) if Gender=="Female"
bys ProvinceName AdministrativeDivision CityName: egen fem_male_ratio = mean(fem_male_ratio)
label var fem_male_ratio "Female to Male Children ratio"
drop if unmarried_men_young_ratio==.
label var unmarried_men_young_ratio "Ratio of unmarried males > 9"

reg unmarried_men_young_ratio fem_male_ratio, r
est store married_1
estadd local fixed "no" , replace

reg unmarried_men_young_ratio fem_male_ratio total_young_gub, r
est store married_2
estadd local fixed "no" , replace

xi: reg unmarried_men_young_ratio fem_male_ratio total_young_gub i.District, r
est store married_3
estadd local fixed "yes" , replace

esttab married_1 married_2 married_3 using "$tables/unmarried_men_infmort_1897.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IDis*) collabels(none) stats(fixed N r2, label("District Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace


clear


global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear
drop if Gubernia == "Erivanskaya"
tempfile temp
save `temp'
import excel "$data/gender_marriage_1897_census.xlsx", sheet("Sheet1") firstrow clear
merge 1:1 Gubernia District AdministrativeDivision CityName Gender using `temp' 
keep if _merge==3

gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
drop Gubernia 

destring(age_60_69), replace force

gen total_pop_g = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+unknown_age
gen unmarried_young = Unmarried - age_less_1 - age_1_9
gen total_pop_young = total_pop_g - age_less_1 - age_1_9
 
bys ProvinceName AdministrativeDivision CityName Gender: egen total_young_gub = sum(total_pop_young)
bys ProvinceName AdministrativeDivision CityName Gender: egen total_unmarried_young = sum(unmarried_young)

gen unmarried_women_young_ratio = total_unmarried_young/(total_young_gub) if Gender=="Female"
label var unmarried_women_young_ratio sh. unmarr. women"


gen children = age_1_9

bys ProvinceName AdministrativeDivision CityName: egen total_num = sum(children)
gen fem_male_ratio_t = children/(total_num-children) if Gender=="Female"
bys ProvinceName AdministrativeDivision CityName: egen fem_male_ratio = mean(fem_male_ratio)
label var fem_male_ratio "Female to Male Children ratio"
drop if unmarried_women_young_ratio==.
label var total_young_gub "total population of same sex"


reg unmarried_women_young_ratio fem_male_ratio, r
est store married_4
estadd local fixed "no" , replace

reg unmarried_women_young_ratio fem_male_ratio total_young_gub, r
est store married_5
estadd local fixed "no" , replace


xi: reg unmarried_women_young_ratio fem_male_ratio total_young_gub i.District, r
est store married_6
estadd local fixed "yes" , replace

gen unmarried_men_young_ratio=.
lavel var unmarried_men_young_ratio "sh. unmarr. men"

esttab married_1 married_2 married_3  married_4 married_5 married_6 using "$tables/unmarried_infmort_1897.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IDis*) collabels(none) stats(fixed N r2, label("District Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace
