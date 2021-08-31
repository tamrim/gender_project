
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


**** make gender ratios for descriptive statistics
* children
gen children = age_1_9
bys ProvinceName AdministrativeDivision District CityName: egen total_num = sum(children)
bys ProvinceName AdministrativeDivision District CityName Gender: egen total_num_sex = sum(children)




bys ProvinceName Gender: egen total_young_gub_fem_t = sum(total_pop_young) if Gender=="Female"
bys ProvinceName Gender: egen total_young_gub_mal_t = sum(total_pop_young) if Gender=="Male"


bys ProvinceName Gender: egen total_unmarried_young = sum(unmarried_young) 

gen unmarried_women_young_ratio_t = total_unmarried_young/(total_young_gub_fem_t) if Gender=="Female"
gen unmarried_men_young_ratio_t = total_unmarried_young/(total_young_gub_mal_t) if Gender=="Male"

gen fem_male_ratio_t = total_num_sex/(total_num-total_num_sex) if Gender== "Female"
* fill in missing 
bys ProvinceName AdministrativeDivision CityName: egen fem_male_ratio = mean(fem_male_ratio_t)


gen more_girls = 1 if fem_male_ratio > 1
replace more_girls = 0 if fem_male_ratio <= 1
ttest unmarried_women_young_ratio, by(more_girls)
ttest unmarried_men_young_ratio, by(more_girls)

bys ProvinceName AdministrativeDivision CityName: egen unmarried_women_young_ratio = mean(unmarried_women_young_ratio_t)
bys ProvinceName AdministrativeDivision CityName: egen unmarried_men_young_ratio = mean(unmarried_men_young_ratio_t)
bys ProvinceName AdministrativeDivision CityName: egen total_young_gub_fem = mean(total_young_gub_fem_t)
bys ProvinceName AdministrativeDivision CityName: egen total_young_gub_mal = mean(total_young_gub_mal_t)



duplicates drop
keep ProvinceName unmarried_men_young_ratio unmarried_women_young_ratio total_young_gub_fem total_young_gub_mal
drop if unmarried_men_young_ratio ==. | unmarried_women_young_ratio==.
duplicates drop
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo "
replace ProvinceName="Iaroslavskaia " if ProvinceName== "Yaroslavskaia "

tempfile temp4
save `temp4'

*** now look at 1877


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
*twoway (scatter death_rate_Female death_rate_Male) (line death_rate_Female death_rate_Female)

gen ProvinceName = subinstr(Province,"aya","aia ",.)


keep ProvinceName death_female_to_male
tempfile temp2


merge 1:1 ProvinceName using `temp4'
drop _merge


replace ProvinceName="Estlandskaia " if ProvinceName== "Estliandskaia "
replace ProvinceName="Kurlandskaia " if ProvinceName== "Kurliandskaia "
replace ProvinceName= "Yaroslavskaia " if ProvinceName=="Iaroslavskaia "
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
replace ProvinceName="Yakutskaia " if ProvinceName== "Iakutskaia "
replace ProvinceName="Peterburgskaia " if ProvinceName== "S. Peterburgskaia "


tempfile temp5

save `temp5'

use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta", clear
*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge
** correct some more city-level errors in factory data.
replace CityorUezd = "Benderskii" if CityorUezd == "Bessarabskii" & Uezd=="Benderskii"
keep ProvinceName Region
duplicates drop




merge 1:1 ProvinceName using `temp5'
label var unmarried_men_young_ratio "sh. unmarr. men"
label var unmarried_women_young_ratio "sh. unmarr. women"
label var total_young_gub_fem "total pop. fem."
label var total_young_gub_mal "total pop. male"


reg unmarried_women_young_ratio  death_female_to_male, r 
est store marriage_1
estadd local fixed "no" , replace

reg unmarried_women_young_ratio  death_female_to_male total_young_gub_fem, r 
est store marriage_2
estadd local fixed "no" , replace

xi: reg unmarried_women_young_ratio  death_female_to_male total_young_gub_fem i.Region, r
est store marriage_3
estadd local fixed "yes" , replace


reg unmarried_men_young_ratio  death_female_to_male, r 
est store marriage_4
estadd local fixed "no" , replace

reg unmarried_men_young_ratio  death_female_to_male total_young_gub_mal, r 
est store marriage_5
estadd local fixed "no" , replace

xi: reg unmarried_men_young_ratio  death_female_to_male total_young_gub_mal i.Region, r
est store marriage_6
estadd local fixed "yes" , replace





esttab marriage_1 marriage_2 marriage_3 marriage_4 marriage_5 marriage_6 using "$tables/unmarried_men_women_infmort.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IReg*) collabels(none) stats(fixed N r2, label("Region Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace


**** add women



