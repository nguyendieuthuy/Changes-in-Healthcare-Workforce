
/* Start log */
capture log close
log using "${logdir}/QCEW_GenerateVariables$S_DATE.log", replace


	use "${intdir}/QCEW_county_Combined2018_2021_covid.dta",clear
	
	drop stateabbreviation
// Medicaid expansion 
	gen MedicaidDate = mdy(1,1,2014)
	codebook state*
	codebook state_code 
	
	local control AL AK FL GA ID IN KS LA MI MS ME MO MT NE NH NC OK PA SC SD TN TX UT VA WY 
	foreach x in `control' { 
	replace MedicaidDate=. if state_code==`"`x'"'
	      }
	
	replace MedicaidDate=mdy(4,1,2014) if state_code=="MI"  //MI expanded in April 2014
	replace MedicaidDate=mdy(8,1,2014) if state_code=="NH"  //NH expanded in August 2014
	replace MedicaidDate=mdy(1,1,2015) if state_code=="PA"  //PA expanded in Jan 2015 
	replace MedicaidDate=mdy(2,1,2015) if state_code=="IN" //IN expanded in Feb 2015
	replace MedicaidDate=mdy(9,1,2015) if state_code=="AK"  //AK expanded in Sept 2015
	replace MedicaidDate=mdy(1,1,2016) if state_code=="MT" //MT expanded in Jan 2016 
	replace MedicaidDate=mdy(7,1,2016) if state_code=="LA" //LA expanded in July 2016
	replace MedicaidDate=mdy(7,2,2018) if state_code=="ME" //ME 1/10/2019 with coverage retroactive to 7/2/2018
	replace MedicaidDate=mdy(1,1,2019) if state_code=="VA" //VA expanded in 1/1/2019			
	format MedicaidDate %td
	*Maine's Medicaid expansion is approved but not yet implemented, so we will consider ME a non-expansion state.
	// IMD waiver policy 
	foreach var in Medicaid IMD_Approval IMD_Authority {
		gen yq`var' = qofd(`var'Date)
		gen `var' = 0
		replace `var'=1 if `var'Date!=0 & `var'Date!=. 
		gen `var'trend=yq-yq`var' if `var'==1	
		gen `var'Post =0
		replace `var'Post= 1 if `var'trend >=0 & `var'trend!=. 
		}

		
    local IND Healthcare ambHCservice Physician dentoffice otheoffice outpatient medlab homehealth otheambHC Hospital genhospital SUDhospital spechospital ///
	nurseResid SNF residcare retirecom otherresid other 
  		
		
	foreach var in `IND' {
	replace est_`var' = 0 if est_`var'==. 
	}
		
	foreach var in `IND' { 
	gen `var'censored=0 
	replace `var'censored=1 if (est_`var' !=. & est_`var'>0 ) &  (emp_`var' ==. | emp_`var'==0)
	
	tab `var'censored
	}
	tab Hospitalcensored if yq==yq(2019,2)
	sum est_Hospital emp_Hospital emp_HospitalB Hospitalcensored  if yq==yq(2019,2)
	

	// for non-censored data --> set zeros for establishment and employment 
	foreach var in `IND' {
	replace emp_`var' = 0 if emp_`var'==. & `var'censored!=1
	sum emp_`var' 
	}
	
* Socio-econ characteristics 
	replace age18_ratio= age18_ratio*100
	replace age65_ratio= age65_ratio*100
	gen pop_18_64_ratio=100-age18_ratio-age65_ratio
	gen male_ratio=100*(100-female_ratio)
	replace white_ratio=white_ratio*100
	replace black_ratio=black_ratio*100
	
	replace hispanic_ratio=hispanic_ratio*100
	replace otherrace_ratio=otherrace_ratio*100

	gen opioid_mort_yes=.
	replace opioid_mort_yes=1 if opioid_mort>0 & opioid_mort!=.
	replace opioid_mort_yes=0 if opioid_mort==0
	
	foreach var in poisoing_dealth {
	gen opioid_mort_pop=`var'
	gen l2_opioid_mort_pop=`var'
	gen l3_opioid_mort_pop=`var'
	}
	
		
	gen lopioid_mort_pop=log(opioid_mort_pop+sqrt(opioid_mort_pop^2+1))
	gen l2_lopioid_mort_pop=log(l2_opioid_mort_pop+sqrt(l2_opioid_mort_pop^2+1))
	gen l3_lopioid_mort_pop=log(l3_opioid_mort_pop+sqrt(l3_opioid_mort_pop^2+1))
	
	label var opioid_mort_pop "Drug-related deaths/100k residents"
	label var opioid_mort_yes "Presence of opioid-related deaths"
	label var lopioid_mort_pop "Drug-related deaths/100k residents, logged"
	label var l2_lopioid_mort_pop "Drug-related deaths/100k residents, logged & 2 lagged years"
	label var l3_lopioid_mort_pop "Drug-related deaths/100k residents, logged & 3 lagged years"
	
		
	gen lnum_uninsured_18_64=log(num_uninsured_18_64)
	gen lnum_uninsured_0_64=log(num_uninsured_0_64)
	gen lnum_insured_18_64=log(num_insured_18_64)
	gen lnum_insured_0_64=log(num_insured_0_64)
	label var lnum_insured_18_64 "Insured adults 18-64, logged"
	label var lnum_insured_18_64 "Insured population 0-64, logged"
	label var pct_insured_18_64 "Insured adults 18-64, %"
	label var pct_insured_0_64  "Insured population 0-64, %"
	// control 
	sum population if yq ==235
	dis r(sum) 

	*gen density = population/landsqmi
	gen POPULATION=population/100000
	label var POPULATION "County populations"
	replace rural_ratio=rural_ratio*100

	foreach var in cases deaths {
	gen `var'_pop_q4 = `var'q4/POPULATION
	gen `var'_pop_q2 = `var'q2/POPULATION
	gen `var'_pop_2021q2 = `var'2021q2/POPULATION
	label var `var'_pop_q4 "COVID `var' per 100k residents"
	label var `var'_pop_q2 "COVID `var' per 100k residents"
	label var `var'_pop_2021q2 "COVID `var' per 100k residents"
	}
	
	
	label var density "Residents per square mile of land area"
	
	gen ldensity=log(density)
	gen lpopulation=log(population)
	gen lhousehold_income=log(household_income)
	label var ldensity "Residents per squared mile, logged"
	label var lhousehold_income "Household income, logged"	
	label var lpopulation "Population, logged"
	label var pop_18_64_ratio "Aged 18-64 population (%)"
	label var age18_ratio "Aged <18 population (%)"
	label var age65_ratio "Aged >64 population (%)"
	label var male_ratio "Male population (%)"
	label var unemployment_rate "Unemployment rate (%)"
	label var white_ratio "Non-Hispanic White population (%)"
	label var black_ratio "Non-Hispanic African American population (%)"
	label var otherrace_ratio "Asian, Pacific Islander, American Indian population (%)"
	label var hispanic_ratio "Hispanic American population (%)"

	gen Mincome=household_income/1000
	label var Mincome "Household income (\$1,000)"
	gen Mprescribingrate=prescribingrate/1000
	label var Mprescribingrate "No. Opioid Rx per 100 residents (1,000)"
	gen prescribingrate_pop=prescribingrate/10
	label var prescribingrate_pop "No. Opioid Rx per 1K residents"
	gen phys_primary_pop=phys_primary/population*100000	
	label var phys_primary_pop "Primary physicians per 100K residents"
	gen lphys_primary_pop=log(phys_primary_pop+sqrt(phys_primary_pop^2+1))
	label var lphys_primary_pop "Primary physicians per 100K residents in logs"

	gen totalMD_pop = totalMD/population*100000
	label var totalMD_pop "MDs per 100K residents"
	gen activeMDs_pop = activeMDs/population*100000
	label var activeMDs_pop "MDs per 100K residents"	
	
	*codebook
		
	// rurality 
	label define NCHSURCodesl 1 "Large central metro" 2 "Large fringe metro" ///
	3 "Medium metro" 4 "Small metro" 5 "Micropolitan" 6 "Rural" 
	label values NCHSURCodes NCHSURCodesl
	
	gen NCHSURCodes3=1
	replace NCHSURCodes3=2 if NCHSURCodes5==1
	replace NCHSURCodes3=3 if NCHSURCodes6==1

	label define NCHSURCodes3l 1 "Metropolitan" 2 "Micropolitan" 3 "Rural" 
	label values NCHSURCodes3 NCHSURCodes3l
	
	tab NCHSURCodes3,gen(URBAN)
	
	gen lopioid_mort_popURBAN1 = lopioid_mort_pop*URBAN1
	gen lopioid_mort_popURBAN2 = lopioid_mort_pop*URBAN2
	gen lopioid_mort_popURBAN3 = lopioid_mort_pop*URBAN3

	
	label var lpopulation "Population, logged"
	label var pop_18_64_ratio "Aged 18-64 population (%)"
	label var age18_ratio "Aged <18 population (%)"
	label var age65_ratio "Aged >64 population (%)"
	label var male_ratio "Male population (%)"
	label var unemployment_rate "Unemployment rate (%)"
	label var white_ratio "Non-Hispanic White population (%)"
	label var black_ratio "Non-Hispanic African American population (%)"
	label var hispanic_ratio "Hispanic American population (%)"
	label var rural_ratio "Rural population (%)"
 	label var lnum_insured_18_64 "Insured adults 18-64, logged"
	label var lnum_insured_0_64 "Insured population 0-64, logged"
	label var pct_insured_18_64 "Insured adults 18-64, %"
	label var pct_insured_0_64  "Insured population 0-64, %"
	label var lopioid_mort_popURBAN3 "Drug-related dealths/100k residents, logged x Rural (vs. Metropolitan)"
	label var lopioid_mort_popURBAN2 "Drug-related dealths/100k residents, logged x Micropolitan (vs. Metropolitan)"
	label var lopioid_mort_popURBAN1 "Drug-related dealths/100k residents, logged x Metropolitan"
	
	
* outcome measures	
	destring area_fips, gen(areafips)
	xtset areafips yq
	
	foreach var in `IND' {
    	foreach X in est_ emp_ {
	bysort areafips : gen D1`X'`var'=`X'`var'-`X'`var'[_n-1]
	gen D1`X'`var'_pop = D1`X'`var'/population*1000000			
	}
	}			
			
	// first difference and growth rate
	
	foreach var in `IND' {
	gen Any`var' = est_`var'>0&est_`var'!=.
	tab Any`var'
	label var Any`var' "Have `var' facilities"
		}
			
	foreach var in `IND' {
    	foreach X in est_ emp_ {
	gen `X'`var'_pop = `X'`var'/population*100000	
	gen i`X'`var'_pop=log(`X'`var'_pop+sqrt(`X'`var'_pop^2+1))
	gen l`X'`var'_pop=log(`X'`var'_pop)
	bysort areafips : gen G`X'`var'_pop=(`X'`var'_pop-`X'`var'_pop[_n-4]	)/`X'`var'_pop[_n-4] *100
	bysort areafips : gen D`X'`var'_pop=(`X'`var'_pop-`X'`var'_pop[_n-4]	)			
	}
	}
	
	
	foreach var in `IND' {
    	foreach X in emp_  {
	gen `X'`var'B_pop = `X'`var'B/population*100000	
	gen B`X'`var'_pop = `X'`var'_pop/`X'`var'B_pop*100
	gen BD`X'`var'_pop = `X'`var'_pop - `X'`var'B_pop	
	}
	}		
	
	
	foreach var in `IND' {
    	foreach X in est_ emp_ wage_ {
	gen l`X'`var'=log(`X'`var')	
	bysort areafips : gen G`X'`var'=(`X'`var'-`X'`var'[_n-4]	)/`X'`var'[_n-4] *100
	bysort areafips : gen D`X'`var'=(`X'`var'-`X'`var'[_n-4]	)
	}
	}		
	// final sample 
	keep if year>=2011 & year<=2021
	
	reghdfe est_Healthcare opioid_mort_pop black_ratio hispanic_ratio otherrace_ratio unemployment_rate /// 
 pct_insured_18_64  lhousehold_income  , absorb( fips_digit yq) vce(cluster statecode) 
 	gen include=e(sample)==1 
	
	sum Bemp_other_pop BDemp_other_pop emp_otherB_pop if yq==yq(2020,2) & othercensor!=1, detail

	
	keep yq area_fips B* emp* wage* est_* D* HPSACodePrimaryCare ///
	black_ratio rural_ratio unemploy16 pct_insured_18_64 cases_pop_q2 cases_pop_2021q2 activeMDs_pop ///
	black_ratio  age65_ratio   hispanic_ratio otherrace_ratio unemploy16 pct_insured_18_64 ///
	lhousehold_income lpopulation rural_ratio statecode   
	
	compress 
	save "${intdir}/QCEW_county_regression2018_2021_covid.dta",replace	


log close
exit

	
	

