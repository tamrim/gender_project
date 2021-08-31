
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


gen children = age_1_9


 gen total_pop_t = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+age_unknown
 
 gen total_pop_no_child = age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+age_unknown
 

 
 
 
* create urbanization rate
bys ProvinceName District: egen pop_in_cities = sum(total_pop_t) if AdministrativeDivision=="City" | AdministrativeDivision=="Station"

bys ProvinceName District: egen pop_district = sum(total_pop_t)

gen urban_rate = pop_in_cities/pop_district
label var urban_rate "perc. urban pop."
** test run for merge

**** make gender ratios
* children
bys ProvinceName AdministrativeDivision CityorUezd: egen total_num = sum(children)
bys ProvinceName AdministrativeDivision CityorUezd Gender: egen total_num_sex = sum(children)
* total_num
bys ProvinceName AdministrativeDivision CityorUezd: egen total_num_all = sum(total_pop_no_child)
bys ProvinceName AdministrativeDivision CityorUezd Gender: egen total_num_sex_all = sum(total_pop_no_child)

gen fem_male_ratio = total_num_sex/(total_num-total_num_sex) if Gender== "Female"
gen fem_male_ratio_all = total_num_sex_all/(total_num_all-total_num_sex_all) if Gender== "Female"


drop if fem_male_ratio==.
label var fem_male_ratio "Female to Male Children ratio"


** show that lower fem/male ratio in cities.
gen more_girls = 1 if fem_male_ratio > 1
replace more_girls = 0 if fem_male_ratio <= 1
gen Urban = 1 if AdministrativeDivision=="City" | AdministrativeDivision=="Station"
replace Urban = 0 if Urban!=1


/*
	estpost ttest urban_rate, by(more_girls)
	*esttab ., cells("mu_1 mu_2 b p") noobs
	eststo X
	*cap macro drop storelist2
*global storelist2="${storelist2} X"


estpost prtest Urban, by(more_girls)
	esttab ., cells("P_1 P_2 b p") noobs
	eststo Y
	cap macro drop storelist3
global storelist3="${storelist3} Y"

ttest fem_male_ratio_all, by(more_girls)


esttab ${storelist2} using "$tables/test.tex" , style(tex) label cells("mu_1 mu_2 b p") legend  collabels(none) mtitles("more boys.   more girls.   t-value    p-value") replace

esttab ${storelist3} using "$tables/test2.tex" , style(tex) label cells("P_1 P_2 b p") legend  collabels(none) mtitles("more boys.   more girls.   t-value    p-value") replace

*/


bys AdministrativeDivision CityorUezd ProvinceName: egen total_pop= sum(total_pop_t)


drop if fem_male_ratio==.
drop age* Gender CityName Gubernia children total_num

duplicates drop


tempfile temp1

save `temp1'

use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta", clear
*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge
** correct some more city-level errors in factory data.
replace CityorUezd = "Benderskii" if CityorUezd == "Bessarabskii" & Uezd=="Benderskii"



merge m:1 ProvinceName AdministrativeDivision CityorUezd using `temp1'

/*

xi: reg propWomen fem_male_ratio Total Age logTotalMachinePower City i.Industry i.District if Child >0 | Women >0, robust
est store prelim_reg_women

esttab prelim_reg_women using "$tables/prelim_women_distrcict_reg.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IInd* _IDis*) collabels(none) stats(N r2, label("N" "R2") fmt(0 %9.3f)) replace

xi: reg PropChildren fem_male_ratio Total Age logTotalMachinePower City i.Industry i.District if Child > 0 | Women >0, robust
est store prelim_reg_children

esttab prelim_reg_children using "$tables/prelim_child_distrcict_reg.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IInd* _IDis*) collabels(none) stats(N r2, label("N" "R2") fmt(0 %9.3f)) replace

*/
replace Total = 0 if _merge==2
drop if _merge==1

gen id_count =_n
bys ProvinceName AdministrativeDivision CityorUezd: egen total_workers_per_unit = sum(Total)
bys ProvinceName AdministrativeDivision CityorUezd: egen propWomenFac = mean(propWomen)



gen worker_to_pop = total_workers_per_unit/total_pop
preserve
keep fem_male_ratio worker_to_pop ProvinceName AdministrativeDivision CityorUezd District City total_pop Region City propWomenFac


duplicates drop
reg fem_male_ratio worker_to_pop total_pop if City==1, robust

label var total_pop "Total population"
label var worker_to_pop "Factory workers/Total Pop."


reg fem_male_ratio worker_to_pop if City==0, robust
est store column_1 
estadd local fixed "no" , replace

reg fem_male_ratio worker_to_pop total_pop if City==0, robust
est store column_2 
estadd local fixed "no" , replace

qui xi: reg fem_male_ratio worker_to_pop total_pop i.District if City==0, robust
est store column_3
estadd local fixed "yes" , replace


esttab column_1 column_2 column_3 using "$tables/num_fac_workers.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IDis*) collabels(none) stats(fixed N r2, label("District Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace

label var propWomenFac "Prop. Fem. Fact. Empl. 1894"

reg propWomenFac fem_male_ratio, robust
est store womenfac_1 
estadd local fixed "no" , replace
estadd local drop_1876 "no", replace


reg propWomenFac fem_male_ratio total_pop, robust
est store womenfac_2
estadd local fixed "no" , replace
estadd local drop_1876 "no", replace

qui xi: reg propWomenFac fem_male_ratio total_pop i.District, robust
est store womenfac_3
estadd local fixed "yes" , replace
estadd local drop_1876 "no", replace

esttab womenfac_1 womenfac_2 womenfac_3 using "$tables/women_factories_1897.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IDis*) collabels(none) stats(fixed drop_1876 N r2, label("District Fixed Effects" "Pre-1876 factories excluded" "N" "R2") fmt(str3 str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace

restore
drop if Age > 18 

keep fem_male_ratio worker_to_pop ProvinceName AdministrativeDivision CityorUezd District City total_pop Region City propWomenFac
duplicates drop


label var propWomenFac "Prop. Fem. Fact. Empl. 1894"

qui xi: reg propWomenFac fem_male_ratio total_pop i.District, robust
est store womenfac_4
estadd local fixed "yes" , replace
estadd local drop_1876 "yes", replace

esttab womenfac_1 womenfac_2 womenfac_3 womenfac_4 using "$tables/women_factories_1897.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IDis*) collabels(none) stats(fixed drop_1876 N r2, label("District Fixed Effects" "Pre-1876 factories excluded" "N" "R2") fmt(str3 str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace



gen more_girls=(fem_male_ratio>1)

/*
estpost ttest worker_to_pop, by(more_girls)
	*esttab ., cells("mu_1 mu_2 b p") noobs
	eststo Z
global storelist2="${storelist2} Z"
esttab X Z using "$tables/test.tex" , style(tex) label cells("mu_1 mu_2 b p") legend  collabels(none) mtitles("more boys.   more girls.   t-value    p-value") replace
*/





