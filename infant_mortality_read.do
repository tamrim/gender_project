
global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"




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




*twoway (scatter death_rate_Female death_rate_Male) (line death_rate_Female death_rate_Female)



gen death_female_to_male = total_children_Female_1_5_dr/total_children_Male_1_5_dr
label var death_female_to_male "childhood female/male death rate, ages 1-5, 1872-6"
tempfile temp3
save `temp3'
replace Province="Yaroslavskaya" if Province== "Iaroslavskaya"
replace Province="Kurlandskaya" if Province== "Kurliandskaya"
replace Province="Peterburgskaya" if Province== "S. Peterburgskaya"
replace Province="Estlandskaya" if Province== "Estliandskaya"

gen ProvinceName = subinstr(Province,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"

keep ProvinceName death_female_to_male
tempfile temp2
save `temp2', replace

use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta", clear
*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge
** correct region error, check with Gregg.
replace Region = "CentralBlacksoil" if ProvinceName=="Orlovskaia "



preserve
collapse (mean) propWomen, by(Region ProvinceName)

merge m:1 ProvinceName using `temp2'

label var propWomen "Prop. Fem. Fact. Empl. 1894"
xi: reg propWomen death_female_to_male, robust
est store propwomen1
estadd local fixed_reg "no" , replace

estadd local drop_1876 "no", replace

xi: reg propWomen death_female_to_male  i.Region, robust
est store  propwomen2
estadd local fixed_reg "yes" , replace

estadd local drop_1876 "no", replace



**** look at factories established after 1876. 
restore
keep if Age < 18 
collapse (mean) propWomen, by(Region ProvinceName)
merge m:1 ProvinceName using `temp2'
label var propWomen "Prop. Fem. Fact. Empl. 1894"
xi: reg propWomen death_female_to_male, robust
est store propwomen3
estadd local fixed_reg "no" , replace

estadd local drop_1876 "yes", replace

xi: reg propWomen death_female_to_male  i.Region, robust
est store  propwomen4
estadd local fixed_reg "yes" , replace

estadd local drop_1876 "yes", replace


esttab propwomen* using "$tables/infant_mortality_women_factories.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IReg* ) collabels(none) stats(fixed_reg drop_1876 N r2, label("Region Fixed Effects" "Pre-1876 factories excluded" "N" "R2") fmt(str3 str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01)  addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01")  replace 


/*

import excel using "${data}/infant_mortality_1867_1881.xlsx", sheet("death_rate_1872_1876") cellra(A3:Q52) clear
rename A Province
rename B deaths_months_0_1_Male
rename C deaths_months_0_1_Female
rename D deaths_months_1_3_Male
rename E deaths_months_1_3_Female
rename F deaths_months_3_6_Male
rename G deaths_months_3_6_Female
rename H deaths_months_6_12_Male
rename I deaths_months_6_12_Female
rename J deaths_age_1_2_Male
rename K deaths_age_1_2_Female
rename L deaths_age_2_3_Male
rename M deaths_age_2_3_Female
rename N deaths_age_3_4_Male
rename O deaths_age_3_4_Female
rename P deaths_age_4_5_Male
rename Q deaths_age_4_5_Female


twoway (scatter deaths_months_0_1_Male deaths_months_0_1_Female) (line deaths_months_0_1_Female deaths_months_0_1_Female)
twoway (scatter deaths_months_1_3_Male deaths_months_1_3_Female) (line deaths_months_1_3_Female deaths_months_1_3_Female)
twoway (scatter deaths_months_3_6_Male deaths_months_3_6_Female) (line deaths_months_3_6_Female deaths_months_3_6_Female)
twoway (scatter deaths_months_6_12_Male deaths_months_6_12_Female) (line deaths_months_6_12_Female deaths_months_6_12_Female)
twoway (scatter deaths_age_1_2_Male deaths_age_1_2_Female) (line deaths_age_1_2_Female deaths_age_1_2_Female)
twoway (scatter deaths_age_2_3_Male deaths_age_2_3_Female) (line deaths_age_2_3_Female deaths_age_2_3_Female)
twoway (scatter deaths_age_3_4_Male deaths_age_3_4_Female) (line deaths_age_3_4_Female deaths_age_3_4_Female)
twoway (scatter deaths_age_4_5_Male deaths_age_4_5_Female) (line deaths_age_4_5_Female deaths_age_4_5_Female)







