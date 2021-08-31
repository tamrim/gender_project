
global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear

gen CityorUezd = CityName if CityName!=""
replace CityorUezd= District if CityName==""
gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)
replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"
replace ProvinceName= "Yaroslavskaia " if ProvinceName=="Iaroslavskaia "
replace ProvinceName= "Yakutskaia " if ProvinceName=="Iakutskaia "
replace ProvinceName= "Sir Darinskaia " if ProvinceName=="Sir-Darinskaia "

destring(age_60_69), replace force

rename unknown_age age_unknown

foreach var of varlist age*{
replace `var'=0 if `var'==.

}


gen children = age_1_9


 gen total_pop_t = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+age_unknown
 
 gen total_pop_no_child = age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+age_unknown
 
** test run for merge

**** make gender ratios
* children
bys ProvinceName: egen total_num = sum(children)
bys ProvinceName Gender: egen total_num_sex = sum(children)
* total_num
bys ProvinceName: egen total_num_all = sum(total_pop_no_child)
bys ProvinceName Gender: egen total_num_sex_all = sum(total_pop_no_child)

gen fem_male_ratio = total_num_sex/(total_num-total_num_sex) if Gender== "Female"
gen fem_male_ratio_all = total_num_sex_all/(total_num_all-total_num_sex_all) if Gender== "Female"


drop if fem_male_ratio==.
label var fem_male_ratio "Female to Male Children ratio"


bys ProvinceName : egen total_pop= sum(total_pop_t)

keep ProvinceName total_pop fem_male_ratio 
duplicates drop

   

merge 1:m ProvinceName using "$data/WagesEstablishments1900ProvInd.dta"

bys Province: egen mean_WagestoWorkersintheFactory1 = mean(WagestoWorkersintheFactory1)
bys Province: egen sum_TotalWorkers1900 = sum(TotalWorkers1900)
bys Province: egen sum_TotalMachinePower = sum(TotalMachinePower)

keep Province fem_male_ratio mean_WagestoWorkersintheFactory1 sum_TotalWorkers1900 sum_TotalMachinePower

duplicates drop 

label var mean_WagestoWorkersintheFactory1 "Mean Wages per Worker, factory"
label var sum_TotalWorkers1900 "Total number of factory workers"
label var sum_TotalMachinePower "Total machine power in factories"

reg mean_WagestoWorkersintheFactory1 fem_male_ratio ,r
est store wages1

reg mean_WagestoWorkersintheFactory1 fem_male_ratio sum_TotalWorkers1900 ,r
est store wages2

reg mean_WagestoWorkersintheFactory1 fem_male_ratio  sum_TotalWorkers1900 sum_TotalMachinePower,r
est store wages3

esttab wages1 wages2 wages3 using "$tables/wages_est_1900.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) collabels(none) stats(N r2, label("N" "R2") fmt(0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace
