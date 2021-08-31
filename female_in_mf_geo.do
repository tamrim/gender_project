*
*
* Code that performs province-level and uezd-level analysis for Part-Year Operation Paper
*
*

clear all
set more off

*Set each author's directory

*Gregg directiory
*global working "/Users/agregg/Dropbox/Tamri and Amanda/2018 Part-Year Paper/"
* Matiashvili directory 
global working "/Users/tamrim/Dropbox (Personal)/Tamri and Amanda/2018 Part-Year Paper/"

*
*
* Province-Level Analysis
*
*

*Load the Factory Data
use "${working}/Data/1894MicroData_PartYearOperation_July2018.dta"

*Add Province Names
merge m:1 Province using "${working}/Data/ProvinceNames.dta"
drop _merge

*Collapse Factory Data by variables of interest
collapse (sum) Men Women Children Girls Boys Total TotalMachinePower, by(ProvinceName)

gen share_women = Women/Total

gen Georgia = 1 if ProvinceName=="Kutaiiskaia " | ProvinceName=="Tiflisskaia " | ProvinceName== "Batumskaia "
replace Georgia = 0 if Georgia!=1

label define Georgia_l 0 "Rest of the Russian Empire" 1 "~Georgia"
label values Georgia Georgia_l
  graph bar (mean) share_women, over(Georgia) ytitle("Share Women in Manufacturing Firms") yla(, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100)
  
  gen Caucasus = 1 if ProvinceName=="Kutaiiskaia " | ProvinceName=="Tiflisskaia " | ProvinceName== "Batumskaia " | ProvinceName== "Karskaia " | ProvinceName== "Elizavetpolskaia " | ProvinceName== "Bakinskaia " | ProvinceName== "Erivanskaia " | ProvinceName== "Stavropolskaia " | ProvinceName == "Dagastanskaia " | ProvinceName == "Chernomorskaia " | ProvinceName == "Kubanskaia " | ProvinceName == "Terskaia "
  replace Caucasus = 0 if Caucasus!=1

  label define Caucasus_l 0 "Rest of the Russian Empire" 1 "Caucasus"
label values Caucasus Caucasus_l
  graph bar (mean) share_women, over(Caucasus) ytitle("Share Women in Manufacturing Firms") yla(, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100)
  

 gen share_children = Children/Total


  graph bar (mean) share_children, over(Georgia) ytitle("Share Children in Manufacturing Firms") yla(0 (0.02) 0.06, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100) yscale(range(0 0.06))
  

  graph bar (mean) share_children, over(SouthernCaucasus) ytitle("Share Children in Manufacturing Firms") yla(0 (0.02) 0.06, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100) yscale(range(0 0.06))

  
   gen share_girls = Girls/Total
   gen share_boys = Boys/Total

  graph bar (mean) share_girls, over(Georgia) ytitle("Share Girls in Manufacturing Firms") yla(0 (0.02) 0.06, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100) yscale(range(0 0.06))
  

  graph bar (mean) share_girls, over(SouthernCaucasus) ytitle("Share Girls in Manufacturing Firms") yla(0 (0.02) 0.06, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100) yscale(range(0 0.06))
  
    graph bar (mean) share_boys, over(SouthernCaucasus) ytitle("Share Boys in Manufacturing Firms") yla(0 (0.02) 0.06, angle(45)) graphregion(color(white)) bgcolor(white)  bar(1, color(blue%50)) bargap(100) yscale(range(0 0.06))
