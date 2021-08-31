
global data "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/data"
global tables "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/tables"
global figures "/Users/tamrim/Dropbox (Personal)/gender_ratio_project/out/figures"
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

import excel "$data/gender_district_census_1897_diana.xls", sheet("Sheet1") firstrow clear

gen CityorUezd = CityName if CityName!=""
replace CityorUezd= District if CityName==""
gen ProvinceName = subinstr(Gubernia,"aya","aia",.)
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
bys ProvinceName District: egen total_num = sum(children)
bys ProvinceName District Gender: egen total_num_sex = sum(children)
* total_num
bys ProvinceName District: egen total_num_all = sum(total_pop_no_child)
bys ProvinceName District Gender: egen total_num_sex_all = sum(total_pop_no_child)

gen fem_male_ratio = total_num_sex/(total_num-total_num_sex) if Gender== "Female"
gen fem_male_ratio_all = total_num_sex_all/(total_num_all-total_num_sex_all) if Gender== "Female"


drop if fem_male_ratio==.
label var fem_male_ratio "Female to Male Children ratio"


bys ProvinceName District : egen total_pop= sum(total_pop_t)

keep ProvinceName District total_pop fem_male_ratio 
drop if District == ""
duplicates drop
rename District Uezd


replace Uezd = "Nercho-Zadovskii" if Uezd == "Nerchinsko - Zavodskii"
replace ProvinceName = subinstr(ProvinceName, "y" ,"i", .)
replace Uezd = subinstr(Uezd, "y", "i", .)
replace ProvinceName = subinstr(ProvinceName, "Y" ,"I", .)
replace Uezd = subinstr(Uezd, "Y", "I", .)


replace ProvinceName = substr(ProvinceName,1,6)
replace Uezd = substr(Uezd,1,7)


*** *now change Uezd/Prov names for merging to match destination
replace ProvinceName = "Dagest" if ProvinceName=="Dagast"
replace ProvinceName = "Karssk" if ProvinceName=="Karska"
replace ProvinceName = "Sir Da" if ProvinceName=="Sir-Da"


replace Uezd = "Pinejsk" if Uezd == "Pinezhs" & ProvinceName=="Arkhan"
replace Uezd = "Shengur" if Uezd == "Shenkur" & ProvinceName=="Arkhan"
replace Uezd = "Shemaxi" if Uezd == "Shemakh" & ProvinceName=="Bakins"
replace Uezd = "Elisave" if Uezd == "Elizave" & ProvinceName=="Elizav"
replace Uezd = "Andizha" if Uezd == "Andijan" & ProvinceName=="Fergan"
replace Uezd = "Romano-" if Uezd == "Romanov" & ProvinceName=="Iarosl"
replace Uezd = "Seradzs" if Uezd == "Sradzsk" & ProvinceName=="Kalish"
replace Uezd = "Tureksk" if Uezd == "Tereksk" & ProvinceName=="Kalish"
replace Uezd = "Zhidrin" if Uezd == "Jizdrin" & ProvinceName=="Kaluzh"
replace Uezd = "Meshons" if Uezd == "Meschov" & ProvinceName=="Kaluzh"
replace Uezd = "Karsski" if Uezd == "Karskii" & ProvinceName=="Karssk"
replace Uezd = "Sviiazh" if Uezd == "Sviajsk" & ProvinceName=="Kazans"
replace Uezd = "Tsarevo" if Uezd == "Tserevo" & ProvinceName=="Kazans"
replace Uezd = "Mekhovs" if Uezd == "Mkhovsk" & ProvinceName=="Kelets"
replace Uezd = "Stopnit" if Uezd == "Stopins" & ProvinceName=="Kelets"
replace Uezd = "Buevski" if Uezd == "Buiskii" & ProvinceName=="Kostro"
replace Uezd = "Chuhlom" if Uezd == "Chukhlo" & ProvinceName=="Kostro"
replace Uezd = "Iurieve" if Uezd == "Iurevet" & ProvinceName=="Kostro"
replace Uezd = "Makarev" if Uezd == "Makarie" & ProvinceName=="Kostro"
replace Uezd = "Vetluzh" if Uezd == "Vatlujs" & ProvinceName=="Kostro"
replace Uezd = "Ponevez" if Uezd == "Ponevjs" & ProvinceName=="Kovens"
replace Uezd = "Telshev" if Uezd == "Talshev" & ProvinceName=="Kovens"
replace Uezd = "Temruks" if Uezd == "Temriuk" & ProvinceName=="Kubans"
replace Uezd = "Tukkums" if Uezd == "Tukumsk" & ProvinceName=="Kurlan"
replace Uezd = "Belgoro" if Uezd == "Blgorod" & ProvinceName=="Kurska"
replace Uezd = "Kutaiss" if Uezd == "Kutaisk" & ProvinceName=="Kutaii"
replace Uezd = "Sharopa" if Uezd == "Shorapa" & ProvinceName=="Kutaii"
replace Uezd = "Belgora" if Uezd == "Blgorai" & ProvinceName=="Liubli"
replace Uezd = "Lomzhin" if Uezd == "Lomjins" & ProvinceName=="Lomzhi"
replace Uezd = "Makovsk" if Uezd == "Makovet" & ProvinceName=="Lomzhi"
replace Uezd = "Ostrov" if Uezd == "Ostrovs" & ProvinceName=="Lomzhi"
replace Uezd = "Schuchi" if Uezd == "Shuchin" & ProvinceName=="Lomzhi"
replace Uezd = "Rechits" if Uezd == "Rchitsk" & ProvinceName=="Minska"
replace Uezd = "Cheriko" if Uezd == "Chariko" & ProvinceName=="Mogile"
replace Uezd = "Chaussk" if Uezd == "Chauski" & ProvinceName=="Mogile"
replace Uezd = "Klimovi" if Uezd == "Kimovic" & ProvinceName=="Mogile"
replace Uezd = "Mozhais" if Uezd == "Mojaisk" & ProvinceName=="Moscov"
replace Uezd = "Serpukh" if Uezd == "Seprukh" & ProvinceName=="Moscov"
replace Uezd = "Belozer" if Uezd == "Blozers" & ProvinceName=="Novgor"
replace Uezd = "Demiano" if Uezd == "Demians" & ProvinceName=="Novgor"
replace Uezd = "Ustiuzh" if Uezd == "Ustiuji" & ProvinceName=="Novgor"
replace Uezd = "Maloark" if Uezd == "Malo - "  & ProvinceName=="Orlovs"
replace Uezd = "Sevskii" if Uezd == "Svskii" & ProvinceName=="Orlovs"
replace Uezd = "Nizhnel" if Uezd == "Nijne -" & ProvinceName=="Penzen"
replace Uezd = "Ustiuzh" if Uezd == "Ustiuji" & ProvinceName=="Primor"
replace Uezd = "Khabaro" if Uezd == "Kharabo" & ProvinceName=="Primor"
replace Uezd = "Belskii" if Uezd == "Blskii" & ProvinceName=="Sedlet"
replace Uezd = "Karkara" if Uezd == "Karkali" & ProvinceName=="Semipa"
replace Uezd = "Pavlogr" if Uezd == "Pavloda" & ProvinceName=="Semipa"
replace Uezd = "Korsuns" if Uezd == "Karsuns" & ProvinceName=="Simbir"
replace Uezd = "Belskii" if Uezd == "Blskii" & ProvinceName=="Smolen"
replace Uezd = "Gzhatsk" if Uezd == "Gjatski" & ProvinceName=="Smolen"
replace Uezd = "Porechs" if Uezd == "Porchsk" & ProvinceName=="Smolen"
replace Uezd = "Medvezh" if Uezd == "Medviji" & ProvinceName=="Stavro"
replace Uezd = "Suvalks" if Uezd == "Suvalsk" & ProvinceName=="Suvals"
replace Uezd = "Dneprov" if Uezd == "Dnprovs" & ProvinceName=="Tavric"
replace Uezd = "Dneprov" if Uezd == "Dnprovs" & ProvinceName=="Tavric"
replace Uezd = "Signakh" if Uezd == "Signagh" & ProvinceName=="Tiflis"
replace Uezd = "Belevsk" if Uezd == "Blevski" & ProvinceName=="Tulska"
replace Uezd = "Chernsk" if Uezd == "Charnsk" & ProvinceName=="Tulska"
replace Uezd = "Bezhets" if Uezd == "Bjetski" & ProvinceName=="Tversk"
replace Uezd = "Kashirs" if Uezd == "Kashins" & ProvinceName=="Tversk"
replace Uezd = "Rzhevsk" if Uezd == "Rjevski" & ProvinceName=="Tversk"
replace Uezd = "Tverski" if Uezd == "Tversko" & ProvinceName=="Tversk"
replace Uezd = "Pultusk" if Uezd == "Varsha" & ProvinceName=="Varsha"
replace Uezd = "Skernev" if Uezd == "Skverne" & ProvinceName=="Varsha"
replace Uezd = "Pultusk" if Uezd == "Pultuss" & ProvinceName=="Varsha"
replace Uezd = "Gorokho" if Uezd == "Gorokoh" & ProvinceName=="Vladim"
replace Uezd = "Kremene" if Uezd == "Kremets" & ProvinceName=="Volins"
replace Uezd = "Vlad.-V" if Uezd == "Vladimi" & ProvinceName=="Volins"
replace Uezd = "Solvich" if Uezd == "Solvitc" & ProvinceName=="Vologo"
replace Uezd = "Solvich" if Uezd == "Solvitc" & ProvinceName=="Vologo"
replace Uezd = "Nerch. " if Uezd == "Nercho-" & ProvinceName=="Zabaik"
replace Uezd = "Tedzhen" if Uezd == "Tedjens" & ProvinceName=="Zakasp"




merge 1:m ProvinceName Uezd using "${data}/Wages.dta"
label var Woman_Summer_Ind "Summer wages, women, liv. indep."
label var  Woman_Winter_Ind "Winter wages, women, liv. indep."
label var  Woman_Summer_notInd "Summer wages, women, liv. not indep."
label var  Woman_Winter_notInd "Winter wages, women, liv. not indep."

label var  Man_Summer_Ind "Summer wages, men, liv. indep."
label var  Man_Winter_Ind "Winter wages, men, liv. indep."
label var  Man_Summer_notInd "Summer wages, men, liv. not indep."
label var  Man_Winter_notInd "Winter wages, men, liv. not indep."

xi: reg Woman_Summer_Ind fem_male_ratio i.Prov, r
est store w_sum_ind
estadd local fix "yes", replace
xi: reg Woman_Winter_Ind fem_male_ratio i.Prov, r
est store w_wint_ind
estadd local fix "yes", replace
xi: reg  Woman_Summer_notInd fem_male_ratio i.Prov, r
est store w_sum_nind
estadd local fix "yes", replace
xi: reg  Woman_Winter_notInd fem_male_ratio i.Prov, r
est store w_wint_nind
estadd local fix "yes", replace

esttab w_sum_ind w_wint_ind w_sum_nind w_wint_nind using "$tables/wages_1910_wom.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IProv*) collabels(none) stats(fix N r2, label("Province Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace

xi: reg Man_Summer_Ind fem_male_ratio i.Prov, r
est store m_sum_ind
estadd local fix "yes", replace
xi: reg Man_Winter_Ind fem_male_ratio i.Prov, r
est store m_wint_ind
estadd local fix "yes", replace
xi: reg  Man_Summer_notInd fem_male_ratio i.Prov, r
est store m_sum_nind
estadd local fix "yes", replace
xi: reg  Man_Winter_notInd fem_male_ratio i.Prov, r
est store m_wint_nind
estadd local fix "yes", replace

esttab m_sum_ind m_wint_ind m_sum_nind m_wint_nind using "$tables/wages_1910_men.tex", style(tex) label cells(b(fmt(3) star) se(fmt(2) par)) drop(_IProv*) collabels(none) stats(fix N r2, label("Province Fixed Effects" "N" "R2") fmt(str3 0 %9.3f)) star(* 0.1 ** 0.05 *** 0.01) addnote("* p$<$0.1, ** p$<$0.05, *** p$<$0.01") replace


