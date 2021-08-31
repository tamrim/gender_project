global dir "/Users/tamrim/google_drive_s/gender_ratio_project/"


use "$dir/data/dvizhenia_deaths.dta", clear

merge m:1 Province District sex cohort using "$dir/data/dvizhenia_births.dta"

keep if _merge == 3

** delete this later
keep if cohort == 1907



drop if num_deaths == .

gen num_alive = num_births - num_deaths

gen percent_alive = num_alive/num_births*100

gen num_alive_0_1_temp = num_births-num_deaths if age == "0_1_years"
bys Province District sex: egen num_alive_0_1 = mean(num_alive_0_1_temp)
gen perc_alive_0_1 = num_alive_0_1/num_births

gen num_alive_1_2_temp = num_alive_0_1-num_deaths if age == "1_2_years"
bys Province District sex: egen num_alive_1_2 = mean(num_alive_1_2_temp)
gen perc_alive_1_2 = num_alive_1_2/num_births

gen num_alive_2_3_temp = num_alive_1_2-num_deaths if age == "2_3_years"
bys Province District sex: egen num_alive_2_3 = mean(num_alive_2_3_temp)
gen perc_alive_2_3 = num_alive_2_3/num_births

gen num_alive_3_4_temp = num_alive_2_3-num_deaths if age == "3_4_years"
bys Province District sex: egen num_alive_3_4 = mean(num_alive_3_4_temp)
gen perc_alive_3_4 = num_alive_3_4/num_births

gen num_alive_4_5_temp = num_alive_3_4-num_deaths if age == "4_5_years"
bys Province District sex: egen num_alive_4_5 = mean(num_alive_4_5_temp)
gen perc_alive_4_5 = num_alive_4_5/num_births



ttest perc_alive_0_1, by(sex)
ttest perc_alive_1_2, by(sex)


*** CHANGE this later

ttest perc_alive_4_5, by(sex)

**** FIX 1905 DUPLICATION
