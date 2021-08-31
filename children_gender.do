
global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"
/*
import excel "$data/gender_data_1897_census.xlsx", sheet("Sheet1") firstrow clear
gen today_country = "Georgia" if Gubernia=="Tiffliskaya" | Gubernia=="Kutaisskaya"
gen children = age_less_1+age_1_9
preserve
bys today_country Gender: egen sum_children = sum(children)

 graph bar (asis) sum_children if today_country=="Georgia", over(Gender) ytitle("Number of Children") exclude0 yscale(range(125000 160000)) yla(125000(5000)160000, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100)
 
  graph bar (asis) children, over(Gender) by(Gubernia) ytitle("Number of Children") yla(, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100)
  
  
  
 gen id =_n
 drop children
 drop today_country
 
rename age_less_1 age_1
rename age_1_9 age_9
rename age_10_19 age_19
rename age_20_29 age_29
rename age_30_39 age_39
rename age_40_49 age_49
 rename age_50_59 age_59
rename age_60_69 age_69
rename age_70_79 age_79
rename age_80_89 age_89
rename age_90_99 age_99
rename age_100_109 age_109
rename age_110_more age_110

 
reshape long age_, i(id) j(age)
rename age_ number

bys Gubernia age: egen total_num = sum(number)
gen fem_male_ratio = number/(total_num-number) if Gender=="Female"
drop if age > 70
label var fem_male_ratio "Female to Male ratio"

twoway (line fem_male_ratio age if Gubernia == "Tiflisskaya") ///
(line fem_male_ratio age if Gubernia == "Stavropolskaya", lpattern(dash)) ///
(line fem_male_ratio age if Gubernia == "Kutaisskaya", lpattern(longdash)) ///
(line fem_male_ratio age if Gubernia == "Moskovskaya", lpattern(dash_dot)) ///
(line fem_male_ratio age if Gubernia == "Bakinskaya", lpattern(shortdash)) ///
(line fem_male_ratio age if Gubernia == "Erivanskaya", lpattern(dot)), ///  
xlab(0 (10) 70) legend(order(1 "Tiflisskaya" 2 "Stavropolskaya" 3 "Kutaisskaya" 4 "Moskovskaya" 5 "Bakinskaya" 6 "Erivanskaya")) ///
 graphregion(color(white)) bgcolor(white) 

restore
preserve

 gen id =_n
 drop children
 drop today_country
 

rename age_less_1 age_1
rename age_1_9 age_9
rename age_10_19 age_19
rename age_20_29 age_29
rename age_30_39 age_39
rename age_40_49 age_49
 rename age_50_59 age_59
rename age_60_69 age_69
rename age_70_79 age_79
rename age_80_89 age_89
rename age_90_99 age_99
rename age_100_109 age_109
rename age_110_more age_110

reshape long age_, i(id) j(age)
rename age_ number
label define age_l 0 "<1" 9 "1-9" 19 "10-19" 29 "20-29" 39 "30-39" 49 "40-49" 59 "50-59" 69 "60-69" 79 "70-79" 89 "80-89" 99 "90-99" 109 "100-109" 110 "110+"
label values age age_l
bys Region Gender age: egen total_num_by_gen=sum(number)
drop Gubernia number 
duplicates drop Region Gender age total_num_by_gen, force

bys Region age: egen total_num = sum(total_num_by_gen)
gen fem_male_ratio = total_num_by_gen/(total_num-total_num_by_gen) if Gender=="Female"
drop if age > 70
label var fem_male_ratio "Female to Male ratio"


twoway (line fem_male_ratio age if Region == "European Russia") ///
(line fem_male_ratio age if Region == "Caucasus", lpattern(dash)) ///
(line fem_male_ratio age if Region == "Central Asia", lpattern(longdash)) ///
(line fem_male_ratio age if Region == "Siberia", lpattern(dash_dot)) ///
(line fem_male_ratio age if Region == "Poland", lpattern(shortdash)), ///
xlab(0 (10) 70) legend(order(1 "European Russia" 2 "Caucasus" 3 "Central Asia" 4 "Siberia" 5 "Poland")) ///
 graphregion(color(white)) bgcolor(white) xlabel(0 "<1" 9 "1-9" 19 "10-19" 29 "20-29" 39 "30-39" 49 "40-49" 59 "50-59" 69 "60-69" )
graph export "$figures/gender_ratio_all_ages.png", replace

restore
preserve
bys Region Gender: egen total_children_region = sum(children)
keep Region Gender total_children_region
duplicates drop  
graph bar (asis) total_children_region, over(Gender) by(Region) ytitle("Number of Children") yla(, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100)

bys Region: gen female_male_ratio = total_children_region/total_children_region[_n+1]

restore 
bys Region: egen boys_region = sum(children) if Gender=="Male"
bys Region: egen girls_region = sum(children) if Gender=="Female"
bys Region: egen young_women = sum(age_20_29) if Gender=="Female"

keep Region boys_region girls_region young_women
collapse (mean) boys_region young_women girls_region, by(Region)

gen boy_to_fert_women = boys_region/young_women
gen girl_to_fert_women = girls_region/young_women


preserve
keep Region boy_to_fert_women girl_to_fert_women

tempname notefile5
file open `notefile5' using "$tables/table_children_women.tex", write replace
file write `notefile5' "\footnotesize"
file write `notefile5' "\begin{tabular}{l c c}\hline\hline" _n
file write `notefile5' " Region & N. girls per 20-29 woman & N. boys per 20-29 woman  \\" _n "\hline" _n

local X=_N
forval x=1/`X' {
  local Region=Region[`x']
  local girl: display  %6.2f girl_to_fert_women[`x']
  local boy: display  %6.2f boy_to_fert_women[`x']

  file write `notefile5' "`Region' & `girl' & `boy'  \\" _n
  }
file write `notefile5' "\hline\hline" _n "\end{tabular}"

file close `notefile5'
restore


*** now show that fewer 20-29 man/total men in Caucasus
bys Region: egen young_men = sum(age_20_29) if Gender=="Male"
egen total_pop = rowtotal(age*)


global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
clear all
*/

*** merge wiht manufacturing
import excel "$data/gender_data_1897_census.xlsx", sheet("Sheet1") firstrow clear
gen children = age_less_1+age_1_9

 gen id =_n 
drop age* Q Region


bys Gubernia: egen total_num = sum(children)
gen fem_male_ratio = children/(total_num-children) if Gender=="Female"
label var fem_male_ratio "Female to Male Children ratio"

gen ProvinceName = subinstr(Gubernia,"aya","aia ",.)

keep ProvinceName fem_male_ratio
drop if fem_male_ratio==.
duplicates drop

replace ProvinceName="Donskaia Oblast " if ProvinceName== "Voiska Donskogo"

tempfile temp
save `temp'

use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta", clear
*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge

merge m:1 ProvinceName using `temp'
drop if _merge!=3

xi: reg propWomen fem_male_ratio Total Age logTotalMachinePower City i.Industry i.Region, robust
est store prelim_reg_women

xi: reg PropChildren fem_male_ratio Total Age logTotalMachinePower City i.Industry i.Region, robust
est store prelim_reg_children

esttab prelim_reg_women using "$tables/prelim_reg_women.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) collabels(none) drop(_I*) stats(r2  N) legend replace

esttab prelim_reg_children using "$tables/prelim_reg_children.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) collabels(none) drop(_I*) stats(r2  N) legend replace










