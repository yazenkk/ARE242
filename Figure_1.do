/*
Import TMO wheat purchase quantities
Source: TMO website accessed using Turkish VPN (see storage_lit folder TMO).

From the Excel File's README
Source: storagelit/TMO/salesAndProd_quantities.pdf
From the TMO wesbite. Table titled: TÜRKİYE BUĞDAY EKİLİŞ-ÜRETİM-VERİM VE TMO ALIMLARI
*/


qui import excel "${projectfile}/TMO/tmo_wheat_sales_prod_quantities.xlsx", ///
	sheet("raw") clear firstrow

** make numeric
foreach var of varlist CultivatedAreaHa YieldKgDa TMOPurchasesTons PurchasesasofProduction {
	replace `var' = "." if `var' == "-"
	destring `var', replace
}

** rename
rename Year year
rename CultivatedAreaHa area_h
rename ProductionTons prod
rename YieldKgDa yield
rename TMOPurchasesTons tmo_q 
rename PurchasesasofProduction tmo_perc


** fill in gaps using online reports
replace tmo_q = 0*10^6 if year == 2014 // not announce wheat intervention prices for MY2014
replace tmo_q = 1*10^6 if year == 2019 // (Mar 30, 2015) USDA, Grain and Feed Annual
replace tmo_q = 0*10^6 if year == 2020 // (Apr 12, 2021) USDA, Grain and Feed Annual
replace tmo_q = 0*10^6 if year == 2021 // (Apr 18, 2022) USDA, Grain and Feed Annual
replace tmo_q = 4*10^6 if year == 2022 // (Apr 06, 2023) USDA, Grain and Feed Annual
replace tmo_q = 9*10^6 if year == 2023 // (Apr 04, 2024) USDA, Grain and Feed Annual
replace tmo_perc = tmo_q/prod if tmo_perc == .
gen double free_q = prod - tmo_q

** plot
label var tmo_perc "TMO purchases as share of production (annual)"
// line tmo_perc year if year >= 1990 

** rescale
** rescale from MT to MMT
foreach var of varlist prod tmo_q {
	replace `var' = `var'/1000000
}
label var prod "Production, TMO est. (MMT)"
label var tmo_q "TMO Purchases, TMO est. (MMT)"

** plot Figure 1
line  tmo_perc  year
