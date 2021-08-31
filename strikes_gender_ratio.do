

global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"


*** 1897 child gender ratio and strikes


import excel "${working}Data/Strikes 1861-1894.xlsx", sheet ("Лист1") firstrow clear

gen strike = 1

collapse (sum) strike, by(province district year_start)
rename province ProvinceName
rename district Uezd
*** prep for merge
gen ProvinceName_strikesog = ProvinceName
gen Uezd_strikesog = Uezd
replace ProvinceName = subinstr(ProvinceName, "'", "",.) 
replace Uezd = subinstr(Uezd, "'", "",.) 
*** A lot of conflict comes from replacing "y" with "i", so normalize
replace ProvinceName = subinstr(ProvinceName, "y" ,"i", .)
replace Uezd = subinstr(Uezd, "y", "i", .)
replace ProvinceName = subinstr(ProvinceName, "Y" ,"I", .)
replace Uezd = subinstr(Uezd, "Y", "I", .)

replace ProvinceName = substr(ProvinceName,1,6)
replace Uezd = substr(Uezd,1,7)
drop if Uezd == ""

* Correct entry errors
replace Uezd = "Dmitrovskii" if Uezd == "Gulnevskii" & ProvinceName == "Moscovskaia "
replace Uezd = "Egorievskii" if Uezd == "Grigorievskii" & ProvinceName == "Riazanskaia "
replace Uezd = "Peterburgskii" if Uezd == "Okhtinskii" & ProvinceName == "Peterburgskaia "
replace Uezd = "Slobodskii" if Uezd == "Redkinskii" & ProvinceName == "Viatskaia "
replace Uezd = "Drissenskii" if Uezd == "Disnenskii" & ProvinceName == "Vitebskaia "
replace Uezd = "Viaznikovskii" if Uezd == "Brianikovskii" & ProvinceName == "Vladimirskaia "

gen ProvinceName_firmsog = ProvinceName
gen Uezd_firmsog = Uezd

replace ProvinceName = substr(ProvinceName,1,6)
replace Uezd = substr(Uezd,1,7)
* make some handchanges for better matching

*** A lot of conflict comes from replacing "y" with "i", so normalize
replace ProvinceName = subinstr(ProvinceName, "y" , "i", .)
replace Uezd = subinstr(Uezd, "y" ,"i", .)
replace ProvinceName = subinstr(ProvinceName, "Y" ,"I", .)
replace Uezd = subinstr(Uezd, "Y", "I", .)

drop if Uezd==""

***** match names before merging
replace ProvinceName = "Ekater" if ProvinceName == "Iekate"
replace ProvinceName = "Kievsk" if ProvinceName == "Kiievs"
replace ProvinceName = "Peterb" if ProvinceName == "Sankt-"
replace ProvinceName = "Moscov" if ProvinceName == "Moskov"
replace ProvinceName = "Donska" if ProvinceName == "Oblast"
replace ProvinceName = "Estlan" if ProvinceName == "Estlia"
replace ProvinceName = "Kurlan" if ProvinceName == "Kurlia"


replace Uezd = "Egoriev" if Uezd == "Iegorie" & ProvinceName == "Riazan"
replace Uezd = "Lasskii" if Uezd == "Laskii" & ProvinceName == "Petrok"
replace Uezd = "Eletski" if Uezd == "Ieletsk" & ProvinceName == "Orlovs"
replace Uezd = "Tverski" if Uezd == "Tversko" & ProvinceName == "Tversk"
replace Uezd = "Ekateri" if Uezd == "Iekater" & ProvinceName == "Ekater"
replace Uezd = "Kievski" if Uezd == "Kiievsk" & ProvinceName == "Kievsk"
replace Uezd = "Peterbu" if Uezd == "Sankt-P" & ProvinceName == "Peterb"
replace Uezd = "Romano-" if Uezd == "Romanov" & ProvinceName == "Iarosl"
replace Uezd = "Jizdrin" if Uezd == "Zhizdri" & ProvinceName == "Kaluzh"
replace Uezd = "Borzens" if Uezd == "Borznia" & ProvinceName == "Cherni"
replace Uezd = "Slavyan" if Uezd == "Slavian" & ProvinceName == "Ekater"
replace Uezd = "Romanov" if Uezd == "Romano-" & ProvinceName == "Iarosl"
replace Uezd = "Sviajsk" if Uezd == "Sviiazh" & ProvinceName == "Kazans"
replace Uezd = "Shuchin" if Uezd == "Shchuch" & ProvinceName == "Lomzhi"
replace Uezd = "Seprukh" if Uezd == "Serpukh" & ProvinceName == "Moscov"
replace Uezd = "Ekateri" if Uezd == "Iekater" & ProvinceName == "Permsk"
replace Uezd = "Elnins" if Uezd == "Ielnins" & ProvinceName == "Smolen"
replace Uezd = "Tversko" if Uezd == "Tverski" & ProvinceName == "Tversk"
replace Uezd = "Elabuzh" if Uezd == "Ielabuz" & ProvinceName == "Viatsk"
replace Uezd = "Veliko-" if Uezd == "Ustiuzh" & ProvinceName == "Vologo"
replace Uezd = "Yarosla" if Uezd == "Iarosla" & ProvinceName == "Iarosl"
replace Uezd = "Yurievs" if Uezd == "Iurievs" & ProvinceName == "Liflia"
replace Uezd = "Pereyas" if Uezd == "Pereias" & ProvinceName == "Poltav"
replace Uezd = "Elninsk" if Uezd == "Elnins" & ProvinceName == "Smolen"


rename Uezd District
rename  ProvinceName Province
tempfile temp 
save `temp'


import excel "${data}/gender_district_census_1897_diana.xls", firstrow clear
rename unknown_age age_unknown
destring(age_60_69), replace force

foreach var of varlist age*{
replace `var'=0 if `var'==.

}


gen children = age_1_9
bys Gubernia District Gender: egen total_num_sex = sum(children)
bys Gubernia District : egen total_num = sum(children)

 gen total_pop_t = age_less_1+age_1_9+age_10_19+age_20_29+age_30_39+age_40_49+age_50_59+age_60_69+age_70_79+age_80_89+age_90_99+age_100_109+age_110_more+age_unknown
 
 
* create urbanization rate
bys Gubernia District: egen pop_in_cities = sum(total_pop_t) if AdministrativeDivision=="City" | AdministrativeDivision=="Station"

bys Gubernia District: egen pop_district = sum(total_pop_t)

gen urban_rate_temp = pop_in_cities/pop_district
replace urban_rate_temp = 0 if urban_rate_temp==.
bys Gubernia District: egen urban_rate = mean(urban_rate_temp)

gen fem_male_ratio = total_num_sex/(total_num-total_num_sex) if Gender== "Female"
drop if fem_male_ratio==.



* fill in missing values

drop urban_rate_temp
keep Gubernia District fem_male_ratio urban_rate
rename Gubernia Province
replace District = substr(District,1,7)
replace Province = substr(Province,1,6)
** make some changes known to cause merge issues
replace Province = "Donska" if Province=="Voiska"
replace Province = "Iarosl" if Province=="Yarosl"


duplicates drop District Province, force
merge 1:m Province District using `temp'
keep if _merge==3 | _merge==1
replace strike = 0 if strike == .
gen logstrike=log(strike)
drop if year_start < 1877
bys Province District: egen sum_strike = sum(strike)
label var strike "Number of strikes 1877-1895"
label var fem_male_ratio "female/male ratio, children aged 1-9"
label var urban_rate "Rate of urbanization"

xi: reg fem_male_ratio strike  i.Province , robust
est store strikes_2
estadd local fixed "yes" , replace

xi: reg fem_male_ratio strike urban_rate i.Province , robust
est store strikes_4
estadd local fixed "yes" , replace

esttab strikes_2 strikes_4 using "$tables/strikes_reg.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IProv*) collabels(none) stats(fixed N r2, label("Province Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01")  replace

gen more_girls=(fem_male_ratio>1)

ttest strike, by(more_girls)


