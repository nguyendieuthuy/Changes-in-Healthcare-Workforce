
/* Start log */
capture log close
log using "${logdir}/QCEW_CompilingData$S_DATE.log", replace

cd "${basedir}"
	

// GDP inflator 
clear 
import excel "${datadir}/GDPDEF-2010-2021.xls",sheet("FRED Graph") cellrange(A11:E57) firstrow 
keep observation_date ratio3

	ren ratio3 GDPDEF 
	gen yq =qofd(observation_date)	
	format yq %tq
	tab yq

	sort yq 
	keep yq GDPDEF 
  	save "${intdir}/GDPDEF_2021.dta", replace

	
	

// extracting data from QCEW_CompilingData

use "${QCEWcleandatadir}/QCEW_2011_2021-2021-12-01.dta", clear

codebook industry_code
keep if industry_code=="10" |industry_code=="62" | industry_code=="622" | industry_code=="622210" | industry_code=="621420" | industry_code=="623220"| industry_code=="621330"| industry_code=="621112" ///
	|industry_code=="6222" | industry_code=="6214" |industry_code=="6232" ///
	|industry_code=="621" ///
	|industry_code=="6211" ///
	|industry_code=="6212" ///
	|industry_code=="6213" ///
	|industry_code=="6214" ///
	|industry_code=="6215" ///
	|industry_code=="6216" ///	
	|industry_code=="6219" ///	
	|industry_code=="622" ///
	|industry_code=="6221" ///
	|industry_code=="6222" ///
	|industry_code=="6223" ///
	|industry_code=="623" ///
	|industry_code=="6231" ///
	|industry_code=="6232" ///
	|industry_code=="6233" ///
	|industry_code=="6239" 
		
tab own_code
sort industry_code year qtr area_fips qtrly_estabs month3_emplvl 
duplicates tag industry_code year qtr area_fips qtrly_estabs avg_wkly_wage month3_emplvl,gen(dup)
tab dup
keep industry_code year qtr area_fips qtrly_estabs avg_wkly_wage month3_emplvl own_code total_qtrly_wages

codebook industry_code year qtr area_fips qtrly_estabs avg_wkly_wage month3_emplvl own_code

sum total_qtrly_wages, detail
sum qtrly_estabs,detail 
sum avg_wkly_wage, detail
sum month3_emplvl,detail

rename qtrly_estabs est_
rename avg_wkly_wage wage_
rename month3_emplvl emp_

	gen yq = yq(year,qtr)
	format yq %tq	
    
    sum est_ emp_ wage_, detail 
	compress 
  	save "${datadir}/qcew_2011_2021yq_all.dta", replace

*** subsector "other" : 62 but not hospitals, physicians, dentists, and SNFs ***
use "${QCEWcleandatadir}/QCEW_2011_2021-2021-12-01.dta", clear
keep if industry_code=="6213" | industry_code=="6214" | industry_code=="6215" /* | industry_code=="6216" */ | industry_code=="6219"| industry_code=="6232"| industry_code=="6233" ///
	|industry_code=="6239" 
		/*
		ren `y'6213 `y'otheoffice
		ren `y'6214 `y'outpatient
		ren `y'6215 `y'medlab
		ren `y'6216 `y'homehealth
		ren `y'6219 `y'otheambHC
		ren `y'6232 `y'residcare
		ren `y'6233 `y'retirecom
		ren `y'6239 `y'otherresid	
		*/
	sort industry_code year qtr area_fips qtrly_estabs month3_emplvl 
	duplicates tag industry_code year qtr area_fips qtrly_estabs avg_wkly_wage month3_emplvl,gen(dup)
	keep industry_code year qtr area_fips qtrly_estabs avg_wkly_wage month3_emplvl own_code total_qtrly_wages

	rename qtrly_estabs est_
	rename avg_wkly_wage wage_
	rename month3_emplvl emp_

	gen yq = yq(year,qtr)
	format yq %tq	
    
	sum est_ emp_ wage_, detail 
	replace industry_code="other"	
	compress 
  	save "${datadir}/qcew_2011_2021yq_other.dta", replace
////////////////////////////////////////////////////////////////////////////////	
	use  "${datadir}/qcew_2011_2021yq_other.dta", clear 
	sort yq area_fips industry_code
	collapse (sum) est_ emp_ , by( yq area_fips industry_code)
  	save "${intdir}/qcew_2011_2021yq_est_other.dta", replace
	
	use  "${datadir}/qcew_2011_2021yq_other.dta", clear 
	sort yq area_fips industry_code
	codebook wage_ emp_ if wage!=0 | emp_!=0     // 318.181/1,058,884 obs: have nonmissing values in both wage and employment
	// adjust for inflation 
	merge m:1 yq using "${intdir}/GDPDEF_2021.dta"
	replace wage_ = wage_ * GDPDEF 
		
	collapse (mean) wage_ [fweight=emp_] , by( yq area_fips industry_code)
  	save "${intdir}/qcew_2011_2021yq_wage_other.dta", replace
	sort yq area_fips industry_code
	merge 1:1 yq area_fips industry_code using "${intdir}/qcew_2011_2021yq_est_other.dta"
	
	tostring yq, replace 
	gen area_fips_yq = area_fips+"_" + yq
	keep est_ emp_ wage_ area_fips_yq industry_code 
	sort area_fips_yq industry_code

	reshape wide est_ emp_ wage_, i(area_fips_yq) j(industry_code) string 

	split area_fips_yq ,parse("_")
	drop area_fips_yq
	ren area_fips_yq1 area_fips
	ren area_fips_yq2 yq
	
	destring yq, replace 
	format yq %tq 
	sort area_fips yq 
	
	save "${intdir}/qcew_2011_2021yq_temp_other.dta", replace
		
	
******************************************************************
******************************************************************

	
	use  "${datadir}/qcew_2011_2021yq_all.dta", clear 
	sort yq area_fips industry_code
	collapse (sum) est_ emp_ , by( yq area_fips industry_code)
  	save "${intdir}/qcew_2011_2021yq_est.dta", replace
	
	use  "${datadir}/qcew_2011_2021yq_all.dta", clear 
	sort yq area_fips industry_code
	codebook wage_ emp_ if wage!=0 | emp_!=0     // 318.181/1,058,884 obs: have nonmissing values in both wage and employment
	// adjust for inflation 
	merge m:1 yq using "${intdir}/GDPDEF_2021.dta"
	replace wage_ = wage_ * GDPDEF 
		
	collapse (mean) wage_ [fweight=emp_] , by( yq area_fips industry_code)
  	save "${intdir}/qcew_2011_2021yq_wage.dta", replace
	sort yq area_fips industry_code
	merge 1:1 yq area_fips industry_code using "${intdir}/qcew_2011_2021yq_est.dta"
	
    
	sum est_ emp_ wage_, detail 

	tostring yq, replace 
	gen area_fips_yq = area_fips+"_" + yq
	keep est_ emp_ wage_ area_fips_yq industry_code 
	sort area_fips_yq industry_code

	
	reshape wide est_ emp_ wage_, i(area_fips_yq) j(industry_code) string 

		foreach y in est_ wage_ emp_ {		
		ren `y'62 `y'Healthcare
		ren `y'10 `y'All
		
		ren `y'621 `y'ambHCservice
		ren `y'6211 `y'Physician
		ren `y'6212 `y'dentoffice
		ren `y'6213 `y'otheoffice
		ren `y'6214 `y'outpatient
		ren `y'6215 `y'medlab
		ren `y'6216 `y'homehealth
		ren `y'6219 `y'otheambHC

		ren `y'622 `y'Hospital		
		ren `y'6221 `y'genhospital
		ren `y'6222 `y'SUDhospital
		ren `y'6223 `y'spechospital

		ren `y'623 `y'nurseResid		
		ren `y'6231 `y'SNF
		ren `y'6232 `y'residcare
		ren `y'6233 `y'retirecom
		ren `y'6239 `y'otherresid	
		}
	split area_fips_yq ,parse("_")
	drop area_fips_yq
	ren area_fips_yq1 area_fips
	ren area_fips_yq2 yq
	
	destring yq, replace 
	format yq %tq 
	sort area_fips yq 
	

	save "${intdir}/qcew_2011_2021yq_temp.dta", replace

        // US 
    use "${intdir}/qcew_2011_2021yq_temp.dta", clear
    merge m:1 area_fips yq using "${intdir}/qcew_2011_2021yq_temp_other.dta",keep (1 3) keepusing(est_other wage_other emp_other) nogen 
    
    keep if strpos( area_fips ,"US000")>0

    local IND Healthcare ambHCservice Physician dentoffice otheoffice outpatient medlab homehealth otheambHC Hospital genhospital SUDhospital spechospital ///
	nurseResid SNF residcare retirecom otherresid other All
    
	foreach var in `IND' {
	foreach y in est_ wage_ emp_ {				
		ren `y'`var' US`y'`var'
		}
		}
	sort yq
	drop area_fips
	save "${intdir}/qcew_2011_2021yq_nation_covid.dta", replace



******************************************************************
******************************************************************
	

// extracting data from QCEW_CompilingData
        // US 
    use "${intdir}/qcew_2011_2021yq_temp.dta", clear
    merge m:1 area_fips yq using "${intdir}/qcew_2011_2021yq_temp_other.dta",keep (1 3) keepusing(est_other wage_other emp_other) nogen 
     
     drop if strpos( area_fips ,"C")>0
    drop if strpos( area_fips ,"U")>0
	save "${intdir}/qcew_2011_2021yq_county.dta", replace


******************************************************************
******************************************************************	
// prepare a panel of counties 
	use "${Rootdatadir}/DataSets-other/StateLaws/CleanData/CoreState_law_countydata_2011_2019_lagged", clear
	gen area_fips = substr( county_5fips , 2, .)
	keep area_fips
	duplicates drop area_fips,force
	gen yq=-9
	save  "${intdir}/qcew_fips.dta",replace
	
	use "${intdir}/qcew_2018_2021yq_covid.dta",clear 
	keep yq
	drop if yq==0
	sort yq
	gen dur= yq[_N] - yq[1] + 1
	keep if _n==1
	expand dur 
	replace yq = yq+ _n - 1
	
	gen area_fips="FAKE"
	append using  "${intdir}/qcew_fips.dta"
	
	
	sort area_fips yq
	
	fillin area_fips yq
	drop _fillin 
	drop if yq == -9

	keep area_fips yq
	sort area_fips yq
	duplicates drop area_fips yq ,force
	compress
	save  "${intdir}/qcew_fips_panel.dta",replace
	
	// match the panel to the full data 
	
	use "${intdir}/qcew_2011_2021yq_county.dta",clear 
	sort area_fips yq
	merge m:1 area_fips yq using "${intdir}/qcew_fips_panel.dta", nogen 
	
	sort area_fips yq
	fillin area_fips yq
	drop _fillin 
	codebook area_fips yq
	drop if area_fips==""
	drop if area_fips == "FAKE"
	drop if yq == -9
	
	destring area_fips,gen(fips_digit)
	sort fips_digit yq
	tsset fips_digit yq	
	
	gen year = year(dofq(yq))
	compress 
	save "${intdir}/qcew_2018_2021_panel_covid.dta",replace
	

	
	* case and death rates 	
	use "${Rootdatadir}/COVID19policy/deaths_and_cases/cleandata/us-counties_2021-08-21.dta",clear 
	destring fips, gen(FIPS)
	drop if FIPS==. 
	*collapse (mean) cases deaths, by(FIPS yq)
	save "${intdir}/covid_cases_deaths.dta",replace	
	keep if date==td(30jun2020)
	ren (cases deaths) (casesq2 deathsq2)
	save "${intdir}/covid_cases_deaths_2020q2.dta", replace 
	
	use "${intdir}/covid_cases_deaths.dta",clear
	keep if date==td(31dec2020)
	ren (cases deaths) (casesq4 deathsq4)
	save "${intdir}/covid_cases_deaths_2020q4.dta", replace 

	use "${intdir}/covid_cases_deaths.dta",clear
	keep if date==td(30jun2021)
	ren (cases deaths) (cases2021q2 deaths2021q2)
	save "${intdir}/covid_cases_deaths_2021q2.dta", replace 

	
	
//keep this: one year lag of county data	
	* keep certain variables as the latest available year		
	 * combine state/county data files 	
		
	use "${Rootdatadir}/DataSets-other/StateLaws/CleanData/CoreState_law_countydata_2011_2020_lagged", clear
	sum black_ratio rural_ratio unemploy16 pct_insured_18_64 if year ==2020 
	sum black_ratio rural_ratio unemploy16 pct_insured_18_64 if year ==2019 
	
	codebook IMD_ApprovalDate IMD_AuthorityDate
	codebook pct_uninsured_18_64
	
	gen area_fips = substr( county_5fips , 2, .)
	
	keep area_fips IMD_ApprovalDate IMD_AuthorityDate state_code 
	sort area_fips IMD_ApprovalDate IMD_AuthorityDate state_code 
	duplicates drop area_fips IMD_ApprovalDate IMD_AuthorityDate state_code, force 
	
	sort area_fips 
	codebook area_fips state_code
	save "${intdir}/Statedata_2011_2020.dta",replace		

	use "${Rootdatadir}/DataSets-other/StateLaws/CleanData/CoreState_law_countydata_2011_2020_lagged", clear
	
	sum black_ratio rural_ratio unemploy16 if year ==2020 
	sum black_ratio rural_ratio unemploy16 if year ==2019 
	
	codebook IMD_ApprovalDate IMD_AuthorityDate
	codebook pct_uninsured_18_64
	
	gen area_fips = substr( county_5fips , 2, .)
	sort area_fips year
	codebook area_fips 
	save "${intdir}/Corecountydata_2011_2020.dta",replace	
	
	
	use "${Rootdatadir}/DataSets-other/StateLaws/CleanData/CoreState_law_countydata_2011_2020_lagged", clear
	keep if year==2020 
	replace year=2021
	sum poisoing_dealth phys_primary pct_insured_18_64 unemployment_rate household_income ///
	black_ratio hispanic_ratio otherrace_ratio household_income pct_uninsured_18_64 if year ==2021 
	
	codebook IMD_ApprovalDate IMD_AuthorityDate
	codebook pct_uninsured_18_64
	
	gen area_fips = substr( county_5fips , 2, .)
	sort area_fips year
	codebook area_fips 
	
	
	append using "${intdir}/Corecountydata_2011_2020.dta"
	sort area_fips year
	
	save "${intdir}/Corecountydata_2011_2021.dta",replace	

	
	** average of 2019
	 
	use "${intdir}/qcew_2018_2021_panel_covid.dta", clear 
	keep if yq>=yq(2019,1) & yq<=yq(2019,4)	
	collapse emp_* wage_* est_*,by(area_fips)
	ren (emp_*) (emp_*B)
	save "${intdir}/QCEW_county_covid2019.dta", replace
		


******************************************************************
******************************************************************
	
	use "${intdir}/qcew_2018_2021_panel_covid.dta"	, clear
	
	sort area_fips year
	merge m:1 area_fips year using  "${intdir}/Corecountydata_2011_2021.dta", keep(3) nogen 
	merge m:1 area_fips using  "${intdir}/QCEW_county_covid2019.dta", keep(3) nogen 
	gen FIPS = fips_digit 
	sort FIPS
	merge m:1 FIPS using  "${intdir}/covid_cases_deaths_2020q2.dta", keep(1 3) nogen keepusing(casesq2 deathsq2)
	sort FIPS
	merge m:1 FIPS using  "${intdir}/covid_cases_deaths_2020q4.dta", keep(1 3) nogen keepusing(casesq4 deathsq4)
	sort FIPS
	merge m:1 FIPS using  "${intdir}/covid_cases_deaths_2021q2.dta", keep(1 3) nogen keepusing(cases2021q2 deaths2021q2)

	
	sort FIPS 
	merge m:1 FIPS using "${intdir}/HPSA_2020.dta",nogen keep(1 3)
	
	sort area_fips year
	
	merge m:1 area_fips using  "${intdir}/Statedata_2011_2020", keep(1 3) nogen keepusing(IMD_ApprovalDate IMD_AuthorityDate state_code)
	
	list area_fips statecode if state_code==""
	replace state_code="AK" if statecode==2
	replace state_code="SD" if statecode==46
	
	drop fips_digit
	destring area_fips,gen(fips_digit)	
	
	sort fips_digit yq	
	tsset fips_digit yq	
	
	save "${intdir}/QCEW_county_Combined2018_2021_covid.dta",replace

	
	
	

	
	log close
	exit 
