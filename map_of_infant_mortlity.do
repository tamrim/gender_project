clear

global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"
cd "${data}/Maps Data/"
import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear

gen CityorUezd = CityName if CityName!=""
replace CityorUezd= District if CityName==""
gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
destring(age_60_69), replace force

rename unknown_age age_unknown

foreach var of varlist age*{
replace `var'=0 if `var'==.

}


gen children = age_1_9

** test run for merge

**** FIX ONLY KEEPING WOMEn!!
bys ProvinceName: egen total_num = sum(children)
bys ProvinceName Gender: egen total_num_sex = sum(children)
drop if Gender=="Male"
gen fem_male_ratio = total_num_sex/(total_num-total_num_sex)
label var fem_male_ratio "Female to Male Children ratio"
keep ProvinceName fem_male_ratio

duplicates drop
merge 1:1 ProvinceName using "${working}Data/ProvinceNames.dta"
keep if _merge==3
drop _merge
tempfile temp

save `temp'
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta
shp2dta using Russia_1897, database(rusdb) coordinates(ruscoord) genid(id) replace


use rusdb.dta
drop if X_COORD > 61 
drop if Province == .
replace Province = 62 if NAME == "Volynia"
drop if X_COORD == 0

rename NAME ProvinceName

merge 1:1 Province using `temp'

drop if X_COORD > 61 
drop if X_COORD == 0
drop if fem_male_ratio==.
save rusdb1.dta, replace

spmap fem_male_ratio using ruscoord, id(id) clmethod(quantile) fcolor(Blues) ///
label(data(rusdb1.dta) xcoord(X_COORD) ycoord(Y_COORD) label(ProvinceName) length(30) size(vsmall))

graph export "${figures}/Map_child_ratio.png", replace


*** make infant map.
clear all
import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear

gen CityorUezd = CityName if CityName!=""
replace CityorUezd= District if CityName==""
gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
destring(age_60_69), replace force

rename unknown_age age_unknown

foreach var of varlist age*{
replace `var'=0 if `var'==.

}


gen children = age_less_1

** test run for merge

**** FIX ONLY KEEPING WOMEn!!
bys ProvinceName: egen total_num = sum(children)
bys ProvinceName Gender: egen total_num_sex = sum(children)
drop if Gender=="Male"
gen fem_male_ratio = total_num_sex/(total_num-total_num_sex)
label var fem_male_ratio "Female to Male Children ratio"
keep ProvinceName fem_male_ratio

duplicates drop
merge 1:1 ProvinceName using "${working}Data/ProvinceNames.dta"
keep if _merge==3
drop _merge
tempfile temp

save `temp'
*ssc install spmap
*ssc install shp2dta
*ssc install mif2dta
shp2dta using Russia_1897, database(rusdb) coordinates(ruscoord) genid(id) replace


use rusdb.dta
drop if X_COORD > 61 
drop if Province == .
replace Province = 62 if NAME == "Volynia"
drop if X_COORD == 0

rename NAME ProvinceName

merge 1:1 Province using `temp'

drop if X_COORD > 61 
drop if X_COORD == 0
drop if fem_male_ratio==.
save rusdb1.dta, replace

spmap fem_male_ratio using ruscoord, id(id) clmethod(quantile) fcolor(Blues) ///
label(data(rusdb1.dta) xcoord(X_COORD) ycoord(Y_COORD) label(ProvinceName) length(30) size(vsmall))

graph export "${figures}/Map_infant_ratio.png", replace


**** Make another map on infant mortality in 1872-1876
clear

global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"
cd "${data}/Maps Data/"
import excel using "${data}/infant_mortality_1867_1881.xlsx", sheet("death_rate_1872_1876") cellra(A3:Q52) clear
rename A Province
rename B total_months_0_1_Male
rename C total_months_0_1_Female
rename D total_months_1_3_Male
rename E total_months_1_3_Female
rename F total_months_3_6_Male
rename G total_months_3_6_Female
rename H total_months_6_12_Male
rename I total_months_6_12_Female
rename J total_age_1_2_Male
rename K total_age_1_2_Female
rename L total_age_2_3_Male
rename M total_age_2_3_Female
rename N total_age_3_4_Male
rename O total_age_3_4_Female
rename P total_age_4_5_Male
rename Q total_age_4_5_Female


gen total_children_Male_1_5_dr = total_age_1_2_Male+total_age_2_3_Male+total_age_3_4_Male+total_age_4_5_Male
gen total_children_Female_1_5_dr = total_age_1_2_Female+total_age_2_3_Female+total_age_3_4_Female+total_age_4_5_Female

gen Death_rate_diff_chi = total_children_Female_1_5_dr/total_children_Male_1_5_dr
rename Province ProvinceName_t
gen ProvinceName = subinstr(ProvinceName_t,"aya","aia ",.)
replace ProvinceName= "Yaroslavskaia " if ProvinceName=="Iaroslavskaia "
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
replace ProvinceName="Peterburgskaia " if ProvinceName== "S. Peterburgskaia "
replace ProvinceName="Estlandskaia " if ProvinceName== "Estliandskaia "
replace ProvinceName="Kurlandskaia " if ProvinceName== "Kurliandskaia "
replace ProvinceName= "Yakutskaia " if ProvinceName=="Iakutskaia "
replace ProvinceName= "Sir Darinskaia " if ProvinceName=="Sir-Darinskaia "


drop ProvinceName_t
merge 1:1 ProvinceName using "${working}Data/ProvinceNames.dta"

keep if _merge==3
drop _merge
tempfile temp

save `temp'
use rusdb.dta
drop if X_COORD > 61 
drop if Province == .
replace Province = 62 if NAME == "Volynia"
drop if X_COORD == 0

rename NAME ProvinceName

merge 1:1 Province using `temp'

drop if X_COORD > 61 
drop if X_COORD == 0
*drop if Death_rate_diff_chi==.
save rusdb1.dta, replace

spmap Death_rate_diff_chi using ruscoord, id(id) clmethod(quantile) fcolor(Blues) ///
label(data(rusdb1.dta) xcoord(X_COORD) ycoord(Y_COORD) label(ProvinceName) length(30) size(vsmall))

graph export "${figures}/Map_female_to_male_death_rate_1-5.png", replace






