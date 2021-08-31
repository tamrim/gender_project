global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

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
* definition 1 
* children = 1-9

gen children1 = age_1_9
gen children2 = age_less_1+age_1_9
gen children3 = age_1_9+age_10_19
gen children4 = age_less_1+age_1_9+age_10_19


gen infants = age_less_1

** test run for merge
bys ProvinceName AdministrativeDivision CityorUezd: egen total_num1 = sum(children1)
bys ProvinceName AdministrativeDivision CityorUezd: egen total_num2 = sum(children2)
bys ProvinceName AdministrativeDivision CityorUezd: egen total_num3 = sum(children3)

bys ProvinceName AdministrativeDivision CityorUezd: egen total_num4 = sum(children4)

bys ProvinceName AdministrativeDivision CityorUezd: egen total_infants = sum(infants)

gen fem_male_ratio1 = children1/(total_num1-children1) if Gender=="Female"
gen fem_male_ratio2 = children2/(total_num2-children2) if Gender=="Female"
gen fem_male_ratio3 = children3/(total_num3-children3) if Gender=="Female"
gen fem_male_ratio4 = children4/(total_num4-children4) if Gender=="Female"


label var fem_male_ratio1 "Female to Male Children ratio"
drop if fem_male_ratio1==.

gen fertile_women = age_20_29+age_30+39 if Gender=="Female"



gen infants_to_women = total_infants/fertile_women

qui xi: reg fem_male_ratio1 infants_to_women i.District, r
est table, keep(infants_to_women ) b se


qui xi: reg fem_male_ratio2 infants_to_women i.District, r
est table, keep(infants_to_women) b se
qui xi: reg fem_male_ratio3 infants_to_women i.District, r
est table, keep(infants_to_women) b se
qui xi: reg fem_male_ratio4 infants_to_women i.District, r
est table, keep(infants_to_women) b se
