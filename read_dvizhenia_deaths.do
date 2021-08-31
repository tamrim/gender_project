global dir "/Users/tamrim/google_drive_s/gender_ratio_project/"

*** remember to add earlier years.
forvalues year =  1901/1910 {
#delimit 
import excel 
Province = A 
District = B 
age_younger1_monthMale = C 
age_younger1_monthFemale = D
age1_3_monthMale = E 
age1_3_monthFemale = F
age3_6_monthMale = G
age3_6_monthFemale = H
age6_12_monthMale = I
age6_12_monthFemale = J
age1_2_yearsMale = K
age1_2_yearsFemale = L 
age2_3_yearsMale = M 
age2_3_yearsFemale = N
age3_4_yearsMale = O 
age3_4_yearsFemale = P
age4_5_yearsMale = Q 
age4_5_yearsFemale = R
age5_10_yearsMale = S 
age5_10_yearsFemale = T 
using "${dir}data/child_deaths_0_10_entered.xlsx", sheet("`year'") clear;
#delimit cr

* remove empty rows
drop if Province == ""
** make a local for future iterations
local vars age_younger1_month age1_3_month age3_6_month age6_12_month age1_2_years age2_3_years age3_4_years age4_5_years age5_10_years
** drop extra top lines
drop if _n<=2

** reshape long 
gen id=_n
reshape long `vars' , i(id) j(sex) string

gen year = `year'


if `year'==1901 {
	tempfile temp
	save `temp', replace
}
else {
	append using `temp'
	save `temp', replace
}
}

*** destring

** two cells for age 3_4 years have linguistic comments on missing data, drop these
destring age3_4_years, gen(test) force
drop if test ==. & age3_4_years!=""
drop test

foreach var of varlist age* {
destring `var', replace 
}

**** create less than one year old variable, since we won't have such detailed births, and want cohorts.

gen age0_1_years = age_younger1_month+age3_6_month+age6_12_month

drop age_you* *month


** link cohorts, for this need to reshape again.
gen id_1 = _n
reshape long age, i(id_1) j(age1) string
rename age num_deaths
rename age1 age
* note that we can't assign the 5-10 year cohort.
gen cohort = year if age == "0_1_years"
replace cohort = year-1 if age == "1_2_years"
replace cohort = year-2 if age == "2_3_years"
replace cohort = year-3 if age == "3_4_years"
replace cohort = year-4 if age == "4_5_years"


save "$dir/data/dvizhenia_deaths.dta", replace

** hypothetically for scatters

bys sex year: egen avg_num_deaths = mean(num_deaths)

twoway (scatter avg_num_deaths year if sex == "Female" & cohort == 1902) (scatter avg_num_deaths year if sex == "Male" & cohort == 1902) 







