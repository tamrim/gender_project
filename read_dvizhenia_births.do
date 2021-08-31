global dir "/Users/tamrim/google_drive_s/gender_ratio_project/"


foreach year in  1898 1905 1906 1907 {
#delimit 
import excel 
Province = A 
District = B 
Born_Male = C
Born_Female = D
using "${dir}data in progress/births_dvizhenia.xlsx", sheet("`year'") clear;
#delimit cr

drop if _n<3

destring Born_Male, replace
destring Born_Female, replace

gen id = _n
reshape long Born_ , i(id) j(sex) string
rename Born_ num_births

gen cohort = `year'

if `year'==1898 {
	tempfile temp
	save `temp', replace
}
else {
	append using `temp'
	save `temp', replace
}

}
save "$dir/data/dvizhenia_births.dta", replace
